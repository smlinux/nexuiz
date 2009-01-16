.entity move_groundentity;
.float move_suspendedinair;
.float move_didgravity;

void _Movetype_CheckVelocity() // SV_CheckVelocity
{
}

float _Movetype_CheckWater() // SV_CheckWater
{
	return FALSE;
}

void _Movetype_CheckWaterTransition() // SV_CheckWaterTransition
{
}

void _Movetype_Impact(entity oth) // SV_Impact
{
	if(self.move_moveflags & MOVEFLAG_STOPONIMPACT)
	{
		// don't CLIP the velocity, but stop ENTIRELY
		self.velocity = '0 0 0';
		self.avelocity = '0 0 0';
	}
}

void _Movetype_LinkEdict(float touch_triggers) // SV_LinkEdict
{
}

float _Movetype_TestEntityPosition(vector ofs) // SV_TestEntityPosition
{
	vector org;
	float cont;
	org = self.move_origin + ofs;
	
	cont = self.dphitcontentsmask;
	self.dphitcontentsmask = DPCONTENTS_SOLID;
	tracebox(self.move_origin, self.mins, self.maxs, self.move_origin, MOVE_NOMONSTERS, self);
	self.dphitcontentsmask = cont;

	if(trace_startsolid)
		return TRUE;

	if(vlen(trace_endpos - self.move_origin) > 0.0001)
		self.move_origin = trace_endpos;
	return FALSE;
}

float _Movetype_UnstickEntity() // SV_UnstickEntity
{
	if(!_Movetype_TestEntityPosition('0 0 0'))
		return TRUE;
	if(!_Movetype_TestEntityPosition('-1 0 0')) goto success;
	if(!_Movetype_TestEntityPosition('1 0 0')) goto success;
	if(!_Movetype_TestEntityPosition('0 -1 0')) goto success;
	if(!_Movetype_TestEntityPosition('0 1 0')) goto success;
	if(!_Movetype_TestEntityPosition('-1 -1 0')) goto success;
	if(!_Movetype_TestEntityPosition('1 -1 0')) goto success;
	if(!_Movetype_TestEntityPosition('-1 1 0')) goto success;
	if(!_Movetype_TestEntityPosition('1 1 0')) goto success;
	float i;
	for(i = 1; i <= 17; ++i)
	{
		if(!_Movetype_TestEntityPosition('0 0 -1' * i)) goto success;
		if(!_Movetype_TestEntityPosition('0 0 1' * i)) goto success;
	}
	dprint("Some entity is stuck\n");
	return FALSE;
:success
	dprint("Unstuck some entity\n");
	_Movetype_LinkEdict(TRUE);
	return TRUE;
}

vector _Movetype_ClipVelocity(vector vel, vector norm, float f) // SV_ClipVelocity
{
	vel = vel - ((vel * norm) * norm) * f;

	if(vel_x > -0.1 && vel_x < 0.1) vel_x = 0;
	if(vel_y > -0.1 && vel_y < 0.1) vel_y = 0;
	if(vel_z > -0.1 && vel_z < 0.1) vel_z = 0;

	return vel;
}

void _Movetype_PushEntityTrace(vector push)
{
	vector end;
	float type;

	end = self.move_origin + push;

	if(self.move_movetype == MOVETYPE_FLYMISSILE)
		type = MOVE_MISSILE;
	else if(self.solid == SOLID_TRIGGER || self.solid == SOLID_NOT)
		type = MOVE_NOMONSTERS;
	else
		type = MOVE_NORMAL;

	tracebox(self.move_origin, self.mins, self.maxs, end, type, self);
}

float _Movetype_PushEntity(vector push, float failonstartsolid) // SV_PushEntity
{
	_Movetype_PushEntityTrace(push);

	if(trace_startsolid && failonstartsolid)
		return trace_fraction;

	self.move_origin = trace_endpos;

	if(self.solid >= SOLID_TRIGGER && trace_ent && (!(self.move_flags & FL_ONGROUND) || (self.move_groundentity != trace_ent)))
		_Movetype_Impact(trace_ent);

	return trace_fraction;
}

void _Movetype_Physics_Toss(float dt) // SV_Physics_Toss
{
	if(self.move_flags & FL_ONGROUND)
	{
		if(self.velocity_z >= 1/32)
			self.move_flags &~= FL_ONGROUND;
		else if(!self.move_groundentity)
			return;
		else if(self.move_suspendedinair && wasfreed(self.move_groundentity))
		{
			self.move_groundentity = world;
			return;
		}
	}

	self.move_suspendedinair = FALSE;

	_Movetype_CheckVelocity();

	if(self.move_movetype == MOVETYPE_BOUNCE || self.move_movetype == MOVETYPE_TOSS)
	{
		self.move_didgravity = TRUE;
		self.move_velocity_z -= dt * self.gravity * getstatf(STAT_MOVEVARS_GRAVITY);
	}

	self.move_angles = self.move_angles + self.move_avelocity * dt;

	vector move;
	move = self.move_velocity * dt;

	_Movetype_PushEntity(move, TRUE);
	if(wasfreed(self))
		return;
	
	if(trace_startsolid)
	{
		_Movetype_UnstickEntity();
		_Movetype_PushEntity(move, FALSE);
		if(wasfreed(self))
			return;
	}

	if(trace_fraction < 1)
	{
		if(self.move_movetype == MOVETYPE_BOUNCEMISSILE)
		{
			self.move_velocity = _Movetype_ClipVelocity(self.move_velocity, trace_plane_normal, 2.0);
			self.move_flags &~= FL_ONGROUND;
		}
		else if(self.move_movetype == MOVETYPE_BOUNCE)
		{
			self.move_velocity = _Movetype_ClipVelocity(self.move_velocity, trace_plane_normal, 1.5);

			float d;
			d = trace_plane_normal * self.move_velocity;
			if(trace_plane_normal_z > 0.7 && d < 60 && d > -60)
			{
				self.move_flags |= FL_ONGROUND;
				self.move_groundentity = trace_ent;
				self.move_velocity = '0 0 0';
				self.move_avelocity = '0 0 0';
			}
			else
				self.move_flags &~= FL_ONGROUND;
		}
		else
		{
			self.move_velocity = _Movetype_ClipVelocity(self.move_velocity, trace_plane_normal, 1.0);
			if(trace_plane_normal_z > 0.7)
			{
				self.move_flags |= FL_ONGROUND;
				self.move_groundentity = trace_ent;
				if(trace_ent.solid == SOLID_BSP)
					self.move_suspendedinair = TRUE;
				self.move_velocity = '0 0 0';
				self.move_avelocity = '0 0 0';
			}
			else
				self.move_flags &~= FL_ONGROUND;
		}
	}

	_Movetype_CheckWaterTransition();
}

void Movetype_Physics(float matchserver) // SV_Physics_Entity
{
	float n, i, dt, movedt;

	dt = time - self.move_time;

	if(matchserver)
	{
		movedt = ticrate;
		n = max(0, floor(dt / ticrate));
		dt -= n * ticrate;
		self.move_time += n * ticrate;
	}
	else
	{
		movedt = dt;
		dt = 0;
		n = 1;
		self.move_time = time;
	}

	//self.move_didgravity = ((self.move_movetype == MOVETYPE_BOUNCE || self.move_movetype == MOVETYPE_TOSS) && !(self.move_flags & FL_ONGROUND));
	// we use the field as set by the last run of this

	for(i = 0; i < n; ++i)
	{
		self.move_didgravity = FALSE;
		switch(self.move_movetype)
		{
			case MOVETYPE_PUSH:
			case MOVETYPE_FAKEPUSH:
				error("SV_Physics_Pusher not implemented");
				break;
			case MOVETYPE_NONE:
				break;
			case MOVETYPE_FOLLOW:
				error("SV_Physics_Follow not implemented");
				break;
			case MOVETYPE_NOCLIP:
				_Movetype_CheckWater();
				self.move_origin = self.move_origin + ticrate * self.move_velocity;
				self.move_angles = self.move_angles + ticrate * self.move_avelocity;
				_Movetype_LinkEdict(FALSE);
				break;
			case MOVETYPE_STEP:
				error("SV_Physics_Step not implemented");
				break;
			case MOVETYPE_WALK:
				error("SV_Physics_Walk not implemented");
				break;
			case MOVETYPE_TOSS:
			case MOVETYPE_BOUNCE:
			case MOVETYPE_BOUNCEMISSILE:
			case MOVETYPE_FLYMISSILE:
			case MOVETYPE_FLY:
				_Movetype_Physics_Toss(movedt);
				break;
		}
	}

	self.avelocity = self.move_avelocity;

	if(dt > 0 && self.move_movetype != MOVETYPE_NONE)
	{
		// now continue the move from move_time to time
		self.velocity = self.move_velocity;
		if(self.move_didgravity)
			self.velocity_z -= dt * self.gravity * getstatf(STAT_MOVEVARS_GRAVITY);

		self.angles = self.move_angles + dt * self.avelocity;

		if(self.movetype != MOVETYPE_NOCLIP)
		{
			_Movetype_PushEntityTrace(dt * self.velocity);
			if(!trace_startsolid)
				self.origin = trace_endpos;
		}
		else
			self.origin = self.move_origin + dt * self.velocity;
	}
	else
	{
		self.velocity = self.move_velocity;
		self.angles = self.move_angles;
		self.origin = self.move_origin;
	}
}
