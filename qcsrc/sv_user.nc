float sv_maxspeed, sv_friction, sv_accelerate, sv_stopspeed;
float cl_rollspeed, cl_divspeed, cl_rollangle;

.float ladder_time;
.entity ladder_entity;

void SV_PlayerPhysics (void)
{
	vector	wishvel, wishdir, v;
	float	wishspeed, f;

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
	self.punchvector = '0 0 0';	// unused

	self.angles_x = 0;
	self.angles_z = bound (-1, self.velocity * v_right * cl_divspeed, 1) * cl_rollangle;
	if (!self.fixangle)
		self.angles_y = self.v_angle_y + self.punchangle_y;

	if (self.flags & FL_WATERJUMP)
	{
		self.velocity_x = self.movedir_x;
		self.velocity_y = self.movedir_y;
		if (time > self.teleport_time || !self.waterlevel)
		{
			self.flags = self.flags - (self.flags & FL_WATERJUMP);
			self.teleport_time = 0;
		}

		return;
	}

	if (self.waterlevel >= 2)
	if (self.movetype != MOVETYPE_NOCLIP)
	{
		// swimming
		self.flags = self.flags - (self.flags & FL_ONGROUND);

		makevectors (self.v_angle);

		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		if (wishvel == '0 0 0')
			wishvel = '0 0 -30';	// drift towards bottom

		wishdir = normalize (wishvel);
		wishspeed = vlen (wishvel);
		if (wishspeed > sv_maxspeed)
			wishspeed = sv_maxspeed;
		wishspeed = wishspeed * 0.7;

		self.velocity = self.velocity * (1 - frametime * sv_friction);

		f = wishspeed - (self.velocity * wishdir);
		if (f > 0)
			self.velocity = self.velocity + wishdir * min (f, sv_accelerate * frametime * wishspeed);

		return;
	}

	if (self.movetype == MOVETYPE_NOCLIP || self.movetype == MOVETYPE_FLY)
	{
		// noclipping or flying
		self.velocity = self.velocity * (1 - frametime * sv_friction);
		makevectors (self.v_angle);
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		self.flags = self.flags - (self.flags & FL_ONGROUND);
	}
	else if (time < self.ladder_time)
	{
		// on a func_ladder or swimming in func_water
		self.velocity = self.velocity * (1 - frametime * sv_friction);
		makevectors (self.v_angle);
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;

		if (self.gravity)
			self.velocity_z = self.velocity_z + self.gravity * sv_gravity * frametime;
		else
			self.velocity_z = self.velocity_z + sv_gravity * frametime;

		if (self.ladder_entity.classname == "func_water")
		{
			f = vlen (wishvel);
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
	}
	else if (self.flags & FL_ONGROUND)
	{
		// walking
		makevectors (self.v_angle_y * '0 1 0');
		wishvel = v_forward * self.movement_x + v_right * self.movement_y;

		// friction
		if (self.velocity_x || self.velocity_y)
		{
			v = self.velocity;
			v_z = 0;
			f = vlen (v);

			if (f < sv_stopspeed)
				f = 1 - frametime * (sv_stopspeed / f) * sv_friction;
			else
				f = 1 - frametime * sv_friction;

			if (f > 0)
				self.velocity = self.velocity * f;
			else
				self.velocity = '0 0 0';
		}
	}
	else
	{
		makevectors (self.v_angle_y * '0 1 0');
		wishvel = self.velocity + v_forward * self.movement_x + v_right * self.movement_y;
		wishvel_z = 0;

		if (game & GAME_AIR_CONTROL)
		{
			v = self.velocity;
			v_z = 0;
			f = vlen (v);

			if (f < sv_stopspeed)
				f = 1 - frametime * (sv_stopspeed / f) * sv_friction;
			else
				f = 1 - frametime * sv_friction;

			if (f > 0)
				v = self.velocity * f;
			else
				v = self.velocity_z * '0 0 1';

			v_z = self.velocity_z;
			self.velocity = v;
		}
		else if (vlen (wishvel) > 10)
			wishvel = normalize (wishvel) * 10;
	}

	// acceleration
	if (time >= self.teleport_time)
	{
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > sv_maxspeed)
			wishspeed = sv_maxspeed;
		f = wishspeed - (self.velocity * wishdir);
		if (f > 0)
			self.velocity = self.velocity + wishdir * min (f, sv_accelerate * frametime * wishspeed);
	}
}
