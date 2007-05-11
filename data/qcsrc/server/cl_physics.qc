float sv_accelerate;
float sv_friction;
float sv_maxspeed;
float sv_airaccelerate;
float sv_maxairspeed;
float sv_stopspeed;
float sv_gravity;
float sv_airaccel_sideways_friction;
float sv_airaccel_qw;
.float ladder_time;
.entity ladder_entity;
.float gravity;
.float swamp_slowdown;
.float lastflags;
.float lastground;

/*
=============
PlayerJump

When you press the jump key
=============
*/
void PlayerJump (void)
{
	float mjumpheight;

	mjumpheight = cvar("sv_jumpvelocity");
	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 200;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

		return;
	}


	if (!(self.flags & FL_ONGROUND))
		return;

	if (!(self.flags & FL_JUMPRELEASED))
		return;

	if(cvar("g_runematch"))
	{
		if(self.runes & RUNE_SPEED)
		{
			if(self.runes & CURSE_SLOW)
				mjumpheight = mjumpheight * cvar("g_balance_rune_speed_combo_jumpheight");
			else
				mjumpheight = mjumpheight * cvar("g_balance_rune_speed_jumpheight");
		}
		else if(self.runes & CURSE_SLOW)
		{
			mjumpheight = mjumpheight * cvar("g_balance_curse_slow_jumpheight");
		}
	}

	if(cvar("g_minstagib") && (self.items & IT_INVINCIBLE))
	{
		mjumpheight = mjumpheight * cvar("g_balance_rune_speed_jumpheight");
	}

	self.velocity_z = self.velocity_z + mjumpheight;
	self.oldvelocity_z = self.velocity_z;

	self.flags = self.flags - FL_ONGROUND;
	self.flags = self.flags - FL_JUMPRELEASED;
}

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8;
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};


void Nixnex_GiveCurrentWeapon();
void SV_PlayerPhysics()
{
	local vector wishvel, wishdir, v;
	local float wishspeed, f, maxspd_mod, spd, maxairspd, airaccel, swampspd_mod;
	string temps;

	if (clienttype(self) == CLIENTTYPE_BOT)
		bot_think();

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

	maxspd_mod = 1;

	if(cvar("g_runematch"))
	{
		if(self.runes & RUNE_SPEED)
		{
			if(self.runes & CURSE_SLOW)
				maxspd_mod = maxspd_mod * cvar("g_balance_rune_speed_combo_moverate");
			else
				maxspd_mod = maxspd_mod * cvar("g_balance_rune_speed_moverate");
		}
		else if(self.runes & CURSE_SLOW)
		{
			maxspd_mod = maxspd_mod * cvar("g_balance_curse_slow_moverate");
		}
	}

	if(cvar("g_minstagib") && (self.items & IT_INVINCIBLE))
	{
		maxspd_mod = cvar("g_balance_rune_speed_moverate");
	}

	swampspd_mod = 1;
	if(self.in_swamp) {
		swampspd_mod = self.swamp_slowdown; //cvar("g_balance_swamp_moverate");
	}

	if(self.flags & FL_NOTARGET)
		maxspd_mod = cvar("sv_spectator_speed_multiplier");

	spd = sv_maxspeed * maxspd_mod * swampspd_mod;

	if(self.speed != spd)
	{
		self.speed = spd;
		temps = ftos(spd);
		stuffcmd(self, strcat("cl_forwardspeed ", temps, "\n"));
		stuffcmd(self, strcat("cl_backspeed ", temps, "\n"));
		stuffcmd(self, strcat("cl_sidespeed ", temps, "\n"));
		stuffcmd(self, strcat("cl_upspeed ", temps, "\n"));

		temps = ftos(sv_accelerate * maxspd_mod);
		stuffcmd(self, strcat("cl_movement_accelerate ", temps, "\n"));
	}

	// if dead, behave differently
	if (self.deadflag)
		return;

	if (!self.fixangle)
	{
		self.angles_x = 0;
		self.angles_y = self.v_angle_y;
		self.angles_z = 0;
	}

	if(self.classname == "player")
	{
		if (self.button2)
			PlayerJump ();
		else
			self.flags = self.flags | FL_JUMPRELEASED;

		if (self.waterlevel == 2)
			CheckWaterJump ();
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
	else if (self.movetype == MOVETYPE_NOCLIP || self.movetype == MOVETYPE_FLY)
	{
		// noclipping or flying
		self.flags = self.flags - (self.flags & FL_ONGROUND);

		self.velocity = self.velocity * (1 - frametime * sv_friction);
		makevectors(self.v_angle);
		//wishvel = v_forward * self.movement_x + v_right * self.movement_y + v_up * self.movement_z;
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		// acceleration
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > sv_maxspeed*maxspd_mod)
			wishspeed = sv_maxspeed*maxspd_mod;
		if (time >= self.teleport_time)
		{
			f = wishspeed - (self.velocity * wishdir);
			if (f > 0)
				self.velocity = self.velocity + wishdir * min(f, sv_accelerate*maxspd_mod * frametime * wishspeed);
		}
	}
	else if (self.waterlevel >= 2)
	{
		// swimming
		self.flags = self.flags - (self.flags & FL_ONGROUND);

		makevectors(self.v_angle);
		//wishvel = v_forward * self.movement_x + v_right * self.movement_y + v_up * self.movement_z;
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		if (wishvel == '0 0 0')
			wishvel = '0 0 -60'; // drift towards bottom

		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > sv_maxspeed*maxspd_mod)
			wishspeed = sv_maxspeed*maxspd_mod;
		wishspeed = wishspeed * 0.7;

		// water friction
		self.velocity = self.velocity * (1 - frametime * sv_friction);

		// water acceleration
		f = wishspeed - (self.velocity * wishdir);
		if (f > 0)
			self.velocity = self.velocity + wishdir * min(f, sv_accelerate*maxspd_mod * frametime * wishspeed);
	}
	else if (time < self.ladder_time)
	{
		// on a func_ladder or swimming in func_water
		self.flags = self.flags - (self.flags & FL_ONGROUND);

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
		if (wishspeed > sv_maxspeed)
			wishspeed = sv_maxspeed;
		if (time >= self.teleport_time)
		{
			f = wishspeed - (self.velocity * wishdir);
			if (f > 0)
				self.velocity = self.velocity + wishdir * min(f, sv_accelerate*maxspd_mod * frametime * wishspeed);
		}
	}
	else if (self.flags & FL_ONGROUND)
	{
		// walking
		makevectors(self.v_angle_y * '0 1 0');
		wishvel = v_forward * self.movement_x + v_right * self.movement_y;

		if(!(self.lastflags & FL_ONGROUND))
		{
			if(cvar("speedmeter"))
				dprint(strcat("landing velocity: ", vtos(self.velocity), " (abs: ", ftos(vlen(self.velocity)), ")\n"));
			if(self.lastground < time - 0.3)
				self.velocity = self.velocity * (1 - cvar("sv_friction_on_land"));
			if(self.jumppadcount > 1)
				dprint(strcat(ftos(self.jumppadcount), "x jumppad combo\n"));
			self.jumppadcount = 0;
		}

		if (self.velocity_x || self.velocity_y)
		if (!(self.flags & FL_JUMPRELEASED) || !self.button2)
		{
			v = self.velocity;
			v_z = 0;
			f = vlen(v);
			if (f < sv_stopspeed)
				f = 1 - frametime * (sv_stopspeed / f) * sv_friction;
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
		if (wishspeed > sv_maxspeed*maxspd_mod)
			wishspeed = sv_maxspeed*maxspd_mod;
		if (self.crouch)
			wishspeed = wishspeed * 0.5;
		if (time >= self.teleport_time)
		{
			f = wishspeed - (self.velocity * wishdir);
			if (f > 0)
				self.velocity = self.velocity + wishdir * min(f, sv_accelerate*maxspd_mod * frametime * wishspeed);
		}
	}
	else
	{
		if(maxspd_mod < 1)
		{
			maxairspd = sv_maxairspeed*maxspd_mod;
			airaccel = sv_airaccelerate*maxspd_mod;
		}
		else
		{
			maxairspd = sv_maxairspeed;
			airaccel = sv_airaccelerate;
		}
		// airborn
		makevectors(self.v_angle_y * '0 1 0');
		wishvel = v_forward * self.movement_x + v_right * self.movement_y;
		// acceleration
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > maxairspd)
			wishspeed = maxairspd;
		if (self.crouch)
			wishspeed = wishspeed * 0.5;
		if (time >= self.teleport_time)
		{
			// NOTE: this does the same as the commented out old code if:
			//   sv_airaccel_qw 0
			//   sv_airaccel_sideways_friction 0
			
			float vel_straight;
			float vel_z;
			vector vel_perpend;
			vel_straight = self.velocity * wishdir;
			vel_z = self.velocity_z;
			vel_perpend = self.velocity - vel_straight * wishdir - vel_z * '0 0 1';

			f = wishspeed - vel_straight;
			if(f > 0)
				vel_straight = vel_straight + min(f, airaccel * frametime * wishspeed) * sv_airaccel_qw;
			if(wishspeed > 0)
				vel_straight = vel_straight + min(wishspeed, airaccel * frametime * wishspeed) * (1 - sv_airaccel_qw);

			// anti-sideways friction to fix QW-style bunnyhopping
			vel_perpend = vel_perpend * (1 - frametime * (wishspeed / maxairspd) * sv_airaccel_sideways_friction);

			self.velocity = vel_straight * wishdir + vel_z * '0 0 1' + vel_perpend;

			/*
			f = wishspeed;// - (self.velocity * wishdir);
			if (f > 0)
				self.velocity = self.velocity + wishdir * min(f, airaccel * frametime * wishspeed);
			*/
		}
	}

	if(self.flags & FL_ONGROUND)
		self.lastground = time;

	self.lastflags = self.flags;
};
