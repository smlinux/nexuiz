float lastclientthink, sv_maxspeed, sv_friction, sv_accelerate, sv_stopspeed;
float sv_edgefriction, cl_rollspeed, cl_divspeed, cl_rollangle;
.float ladder_time;
.entity ladder_entity;

void SV_PlayerPhysics()
{
	local vector wishvel, wishdir, v;
	local float wishspeed, f;

	if (self.movetype == MOVETYPE_NONE)
		return;

	if (self.punchangle != '0 0 0')
	{
		f = vlen(self.punchangle) - 10 * frametime;
		if (f > 0)
			self.punchangle = normalize(self.punchangle) * f;
		else
			self.punchangle = '0 0 0';
	}

	// if dead, behave differently
	if (self.health <= 0)
		return;

	if (time != lastclientthink)
	{
		lastclientthink = time;
		sv_maxspeed = cvar("sv_maxspeed");
		sv_friction = cvar("sv_friction");
		sv_accelerate = cvar("sv_accelerate");
		sv_stopspeed = cvar("sv_stopspeed");
		sv_edgefriction = cvar("edgefriction");
		// LordHavoc: this * 4 is an optimization
		cl_rollangle = cvar("cl_rollangle") * 4;
		// LordHavoc: this 1 / is an optimization
		cl_divspeed = 1 / cvar("cl_rollspeed");
	}

	// show 1/3 the pitch angle and all the roll angle
	self.angles_x = 0;
	self.angles_y = self.v_angle_y; // FIXME: rotate the models, not the entity!
	self.angles_z = bound(-1, self.velocity * v_right * cl_divspeed, 1) * cl_rollangle;
	self.angles = self.angles + self.angleoffset;
/*	if (!self.fixangle)
	{
		self.angles_x = (self.v_angle_x + self.punchangle_x) * -0.333;
		self.angles_y = self.v_angle_y + self.punchangle_y;
	}*/
	
	if (self.flags & FL_WATERJUMP )
	{
		self.velocity_x = self.movedir_x;
		self.velocity_y = self.movedir_y;
		if (time > self.teleport_time || self.waterlevel == 0)
		{
			self.flags = self.flags - (self.flags & FL_WATERJUMP);
			self.teleport_time = 0;
		}
		return;
	}

	makevectors(self.v_angle);

	if (self.movetype == MOVETYPE_NOCLIP)
	{
		// noclip
		self.velocity = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		return;
	}

	if (self.waterlevel >= 2)
	{
		// swimming
		// friction
		self.velocity = self.velocity * (1 - frametime * sv_friction);
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > sv_maxspeed)
			wishspeed = sv_maxspeed;
		if (self.items & IT_SPEED)
			wishspeed = wishspeed * POWERUP_SPEED_MOVEMENT;
		if (self.crouch)
			wishspeed = wishspeed * 0.5;
		wishspeed = wishspeed * 0.6;
		// acceleration
		f = wishspeed - (self.velocity * wishdir);
		if (f > 0)
			self.velocity = self.velocity + wishdir * min(f, sv_accelerate * frametime * wishspeed);
		return;
	}

	if (time < self.ladder_time)
	{
		// on a func_ladder or swimming in func_water
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > sv_maxspeed)
			wishspeed = sv_maxspeed;
		if (self.items & IT_SPEED)
			wishspeed = wishspeed * POWERUP_SPEED_MOVEMENT;
		if (self.crouch)
			wishspeed = wishspeed * 0.5;
		if (self.ladder_entity.classname == "func_water")
		{
			if (wishspeed > self.ladder_entity.speed)
				wishspeed = self.ladder_entity.speed;
			self.watertype = self.ladder_entity.skin;
			f = self.ladder_entity.origin_z + self.ladder_entity.maxs_z;
			if ((self.origin_z + self.view_ofs_z) < f)
				self.waterlevel = 3;
			else if ((self.origin_z + (self.mins_z + self.maxs_z) * 0.5) < f)
				self.waterlevel = 2;
			else if ((self.origin_z + self.mins_z + 1) < f)
				self.waterlevel = 1;
			else
			{
				self.waterlevel = 0;
				self.watertype = CONTENT_EMPTY;
			}
		}
		// friction
		self.velocity = self.velocity * (1 - frametime * sv_friction);
		// acceleration
		f = wishspeed - (self.velocity * wishdir);
		if (f > 0)
			self.velocity = self.velocity + wishdir * min(f, sv_accelerate * frametime * wishspeed);
		return;
	}

	// calculate wishvel/wishdir/wishspeed for normal walking
	makevectors(self.v_angle_y * '0 1 0');
	// hack to not let you back into teleporter
	if (time < self.teleport_time && self.movement_x < 0)
		wishvel = v_right * self.movement_y;
	else
		wishvel = v_forward * self.movement_x + v_right * self.movement_y;
	wishdir = normalize(wishvel);
	wishspeed = vlen(wishvel);
	if (wishspeed > sv_maxspeed)
		wishspeed = sv_maxspeed;
	if (self.items & IT_SPEED)
		wishspeed = wishspeed * POWERUP_SPEED_MOVEMENT;
	if (self.crouch)
		wishspeed = wishspeed * 0.5;

	if (self.flags & FL_ONGROUND) // walking
	{
		// friction
		if (self.velocity_x || self.velocity_y)
		{
			v = self.velocity;
			v_z = 0;
			f = vlen(v);

			// if the leading edge is over a dropoff, increase friction
			v = self.origin + normalize(v) * 16 + '0 0 1' * self.mins_z;

			traceline(v, v + '0 0 -34', TRUE, self);

			// apply friction
			if (trace_fraction == 1.0)
			{
				if (f < sv_stopspeed)
					f = 1 - frametime * (sv_stopspeed / f) * sv_friction * sv_edgefriction;
				else
					f = 1 - frametime * sv_friction * sv_edgefriction;
			}
			else
			{
				if (f < sv_stopspeed)
					f = 1 - frametime * (sv_stopspeed / f) * sv_friction;
				else
					f = 1 - frametime * sv_friction;
			}

			if (f < 0)
				self.velocity = '0 0 0';
			else
				self.velocity = self.velocity * f;
		}
	}
	else if (!(game & GAME_NO_AIR_CONTROL))
		wishspeed = wishspeed * 0.25;
		//if (wishspeed > 50)
		//	wishspeed = 50;

	self.velocity = self.velocity + wishdir * sv_accelerate * frametime * wishspeed;
}
