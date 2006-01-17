float sv_accelerate;
float sv_maxairspeed;
float sv_friction;
float sv_maxspeed;
float sv_stopspeed;
float sv_gravity;
.float ladder_time;
.entity ladder_entity;
.float gravity;

vector HorizVelocity(vector vel)
{
	vel_z = 0;
	return vel;
}

void CapPlayerVelocity(entity pl, float classmaxspeed)
{
	if(self.jump_pad || self.hook.state)
		return;
	vector wishvel;
	// prevent bunnyhopping
	wishvel = pl.velocity;
	wishvel_z = 0;
	if(vlen(wishvel) > classmaxspeed)
	{
		wishvel = normalize(wishvel) * classmaxspeed;
		pl.velocity_x = wishvel_x;
		pl.velocity_y = wishvel_y;
	}
}

void MauveBot_AI();

void SV_PlayerPhysics()
{
	if (self.is_building == 1 || self.is_feigning == 1)
	{
		self.velocity = '0 0 0';
		return;
	}

	local vector wishvel, wishdir, v;
	local float wishspeed, prevspeed, f;

	local float classmaxspeed, classmaxairspeed, classstopspeed;

	MauveBot_AI();

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

	if (self.punchvector != '0 0 0')
	{
		f = vlen(self.punchvector) - 30 * frametime;
		if (f > 0)
			self.punchvector = normalize(self.punchvector) * f;
		else
			self.punchvector = '0 0 0';
	}

	// if dead, behave differently
	if (self.deadflag)
		return;

	// determine the max speed this class can move at
	SetPlayerSpeed(self);
	classmaxspeed = self.speed;

	if (self.leg_damage)			// Railgun does leg damage :D
	{
		if ((self.leg_damage > 6))
		{
			self.leg_damage = 6;
		}
		classmaxspeed = (classmaxspeed * ((10 - self.leg_damage) / 10));
	}

	if(classmaxspeed < 0)
		classmaxspeed = sv_maxspeed;

	// help the slower players climb slopes a little more easily
	classstopspeed = sv_stopspeed * (self.speed / sv_maxspeed);

	if (!self.fixangle)
	{
		self.angles_x = 0;
		self.angles_y = self.v_angle_y;
		self.angles_z = 0;
	}

	if (self.flags & FL_WATERJUMP )
	{
		self.velocity_x = self.movedir_x;
		self.velocity_y = self.movedir_y;
		if (time > self.teleport_time || self.waterlevel == 0)
		{
			self.flags = self.flags - (self.flags & FL_WATERJUMP);
			self.teleport_time = 0;
		}
	}
	else if (self.movetype == MOVETYPE_NOCLIP || (self.movetype == MOVETYPE_FLY && !self.hook.state))
	{
		// noclipping or flying
		self.velocity = self.velocity * (1 - frametime * sv_friction);
		makevectors(self.v_angle);
		//wishvel = v_forward * self.movement_x + v_right * self.movement_y + v_up * self.movement_z;
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		// acceleration
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > classmaxspeed)//sv_maxspeed)
			wishspeed = classmaxspeed;//sv_maxspeed;
		if (time >= self.teleport_time)
		{
			f = wishspeed - (self.velocity * wishdir);
			if (f > 0)
				self.velocity = self.velocity + wishdir * min(f, sv_accelerate * frametime * wishspeed);
		}
	}
	else if (self.waterlevel >= 2)
	{
		// swimming
		makevectors(self.v_angle);
		//wishvel = v_forward * self.movement_x + v_right * self.movement_y + v_up * self.movement_z;
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		if (wishvel == '0 0 0')
			wishvel = '0 0 -60'; // drift towards bottom

		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > classmaxspeed)//sv_maxspeed)
			wishspeed = classmaxspeed;//sv_maxspeed;
		wishspeed = wishspeed * 0.7;

		//if(self.jump_pad || self.hook.state)
		//{
		//	//wishspeed = wishspeed * cvar("sv_jumppad_control"); // give player limited control on a jump pad
		//	wishspeed = cvar("sv_jumppad_control"); // give player limited control on a jump pad
		//}

		// water friction
		self.velocity = self.velocity * (1 - frametime * sv_friction);

		// water acceleration
		f = wishspeed - (self.velocity * wishdir);
		if (f > 0)
			self.velocity = self.velocity + wishdir * min(f, sv_accelerate * frametime * wishspeed);
		CapPlayerVelocity(self, classmaxspeed);
	}
	else if (time < self.ladder_time)
	{
		if (self.ladder_entity.classname == "scout_rope")
		{
			// friction
			self.velocity = self.velocity * (1 - frametime * sv_friction);

			makevectors(self.v_angle);

			// forward makes you move up, backward makes you move down.
			wishvel = '0 0 1' * self.movement_x + v_right * self.movement_y;
			// also push forward when reaching the top
			if(//self.movement_x > 0 && 
				(self.origin_z + self.mins_z*0.9 > self.ladder_entity.origin_z + self.ladder_entity.maxs_z))
				wishvel = wishvel + v_forward * self.movement_x;

			// negate gravity
			if (self.gravity)
				self.velocity_z = self.velocity_z + self.gravity * sv_gravity * frametime;
			else
				self.velocity_z = self.velocity_z + sv_gravity * frametime;

			// acceleration
			wishdir = normalize(wishvel);
			wishspeed = vlen(wishvel);


			if (wishspeed > classmaxspeed)//sv_maxspeed)
				wishspeed = classmaxspeed;//sv_maxspeed;
			if (time >= self.teleport_time)
			{
				f = wishspeed - (self.velocity * wishdir);
				if (f > 0)
					self.velocity = self.velocity + wishdir * min(f, sv_accelerate * frametime * wishspeed);
			}
			CapPlayerVelocity(self, classmaxspeed);
		}
		else
		{
			// on a func_ladder or swimming in func_water
			self.velocity = self.velocity * (1 - frametime * sv_friction);
			makevectors(self.v_angle);
			//wishvel = v_forward * self.movement_x + v_right * self.movement_y + v_up * self.movement_z;
			wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
			if (self.gravity)
				self.velocity_z = self.velocity_z + self.gravity * sv_gravity * frametime;
			else
				self.velocity_z = self.velocity_z + sv_gravity * frametime;
			if (self.ladder_entity.classname == "func_water")
			{
				f = vlen(wishvel);
				if (f > self.ladder_entity.speed)
					wishvel = wishvel * (self.ladder_entity.speed / f);

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
			// acceleration
			wishdir = normalize(wishvel);
			wishspeed = vlen(wishvel);


			if (wishspeed > classmaxspeed)//sv_maxspeed)
				wishspeed = classmaxspeed;//sv_maxspeed;
			if (time >= self.teleport_time)
			{
				f = wishspeed - (self.velocity * wishdir);
				if (f > 0)
					self.velocity = self.velocity + wishdir * min(f, sv_accelerate * frametime * wishspeed);
			}
			CapPlayerVelocity(self, classmaxspeed);
		}
	}
	else if (self.flags & FL_ONGROUND)
	{
		// walking
		makevectors(self.v_angle_y * '0 1 0');
		wishvel = v_forward * self.movement_x + v_right * self.movement_y;
		// friction
		if (self.velocity_x || self.velocity_y)
		{
			v = self.velocity;
			v_z = 0;
			f = vlen(v);
			if (f < classstopspeed)//sv_stopspeed)
				f = 1 - frametime * (classstopspeed / f) * sv_friction;//sv_stopspeed / f) * sv_friction;
			else
				f = 1 - frametime * sv_friction;
			if (f > 0)
				self.velocity = self.velocity * f;
			else
				self.velocity = '0 0 0';
		}
		// acceleration
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if(self.jump_pad || self.hook.state)
		{
			//wishspeed = wishspeed * cvar("sv_jumppad_control"); // give player limited control on a jump pad
			wishspeed = cvar("sv_jumppad_control"); // give player limited control on a jump pad
		}

		if (wishspeed > classmaxspeed)//sv_maxspeed)
			wishspeed = classmaxspeed;//sv_maxspeed;
		if (time >= self.teleport_time)
		{
			f = wishspeed - (self.velocity * wishdir);
			if (f > 0)
				self.velocity = self.velocity + wishdir * min(f, sv_accelerate * frametime * wishspeed);
		}

		CapPlayerVelocity(self, classmaxspeed);
	}
	else
	{
		classmaxairspeed = classmaxspeed;//*0.8;
		if(self.jump_pad || self.hook.state) // allow limited air control and upper velocity when coming off a jump pad
			prevspeed = vlen(HorizVelocity(self.velocity));
		else
			prevspeed = classmaxairspeed;
		// airborn
		makevectors(self.v_angle_y * '0 1 0');
		wishvel = v_forward * self.movement_x + v_right * self.movement_y;
		// acceleration
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);

		if(self.jump_pad || self.hook.state)
		{
			//wishspeed = wishspeed * cvar("sv_jumppad_control"); // give player limited control on a jump pad
			wishspeed = cvar("sv_jumppad_control"); // give player limited control on a jump pad
		}

		if (wishspeed > classmaxairspeed)//sv_maxairspeed)
			wishspeed = classmaxairspeed;//sv_maxairspeed;
		if (time >= self.teleport_time)
		{
			f = wishspeed;// - (self.velocity * wishdir);
			if (f > 0)
				self.velocity = self.velocity + wishdir * min(f, sv_accelerate * frametime * wishspeed);
		}
		CapPlayerVelocity(self, max(prevspeed, classmaxairspeed));
	}
};
