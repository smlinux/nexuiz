
// increments sprite frame, loops when end is hit.. simple

float TE_SMOKE =77;
void (vector vec) WriteVec =
{
		WriteCoord (MSG_BROADCAST, vec_x);
		WriteCoord (MSG_BROADCAST, vec_y);
		WriteCoord (MSG_BROADCAST, vec_z);
}
void (vector org, vector dir, float counts) W_Smoke =
{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SMOKE);
		WriteVec (org);
		WriteVec (dir);
		WriteByte (MSG_BROADCAST, counts);
}

// increments sprite frame, loops when end is hit.. simple
void animate_sprite (float startframe, float frame_count)
{
	if ((self.frame - startframe) >= (frame_count - 1 ))
		self.frame = startframe;
	else
		self.frame = self.frame + 1;
}

void W_UpdateAmmo (void)
{
	/*
	self.items = self.items - (self.items & (IT_NAILS | IT_SHELLS | IT_ROCKETS | IT_CELLS));

	if (self.weapon == IT_LASER)
		self.currentammo = 1;
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_UZI)
	{
		self.currentammo = self.ammo_nails;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER || self.weapon == IT_HAGAR || self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_ELECTRO || self.weapon == IT_NEX || self.weapon == IT_CRYLINK)
	{
		self.currentammo = self.ammo_cells;
		self.items = self.items | IT_CELLS;
	}
	*/
}

void W_UpdateWeapon (void)
{
	/*
	if (self.weapon == IT_LASER)
		self.weaponmodel = "models/weapons/w_laser.zym";
	else if (self.weapon == IT_SHOTGUN)
		self.weaponmodel = "models/weapons/w_shotgun.zym";
	else if (self.weapon == IT_UZI)
		self.weaponmodel = "models/weapons/w_uzi.zym";
	else if (self.weapon == IT_GRENADE_LAUNCHER)
		self.weaponmodel = "models/weapons/w_gl.zym";
	else if (self.weapon == IT_ELECTRO)
		self.weaponmodel = "models/weapons/w_electro.zym";
	else if (self.weapon == IT_CRYLINK)
		self.weaponmodel = "models/weapons/w_crylink.zym";
	else if (self.weapon == IT_NEX)
		self.weaponmodel = "models/weapons/w_nex.zym";
	else if (self.weapon == IT_HAGAR)
		self.weaponmodel = "models/weapons/w_hagar.zym";
	else if (self.weapon == IT_ROCKET_LAUNCHER)
		self.weaponmodel = "models/weapons/w_rl.zym";
	else
		objerror ("Illegal weapon - please register your guns please!");
	*/
}

float W_GetBestWeapon (entity e)
{
	/*
	if ((e.items & IT_ROCKET_LAUNCHER) && e.ammo_rockets)
		return IT_ROCKET_LAUNCHER;
	else if ((e.items & IT_NEX) && e.ammo_cells)
		return IT_NEX;
	else if ((e.items & IT_HAGAR) && e.ammo_rockets)
		return IT_HAGAR;
	else if ((e.items & IT_GRENADE_LAUNCHER) && e.ammo_rockets)
		return IT_GRENADE_LAUNCHER;
	else if ((e.items & IT_ELECTRO) && e.ammo_cells)
		return IT_ELECTRO;
	else if ((e.items & IT_CRYLINK) && e.ammo_cells)
		return IT_CRYLINK;
	else if ((e.items & IT_UZI) && e.ammo_nails)
		return IT_UZI;
	else if ((e.items & IT_SHOTGUN) && e.ammo_shells)
		return IT_SHOTGUN;
	else
		
		*/
	return IT_LASER;
}

void W_GiveWeapon (entity e, float wep)
{
	entity oldself;

	if (!wep)
		return;

	e.items = e.items | wep;

	oldself = self;
	self = e;

	weapon_action(self.weapon, WR_UPDATECOUNTS);
/*
	W_UpdateWeapon ();
	W_UpdateAmmo ();
*/
	self = oldself;
}
/*
void W_SwitchWeapon (float wep)
{
	float		nextwep;
	var float	noammo = FALSE;

	if (wep == 1)
		nextwep = IT_LASER;
	else if (wep == 2)
	{
		nextwep = IT_SHOTGUN;
		if (!self.ammo_shells)
			noammo = TRUE;
	}
	else if (wep == 3)
	{
		nextwep = IT_UZI;
		if (!self.ammo_nails)
			noammo = TRUE;
	}
	else if (wep == 4)
	{
		nextwep = IT_CRYLINK;
		if (!self.ammo_cells)
			noammo = TRUE;
	}
	else if (wep == 5)
	{
		nextwep = IT_ELECTRO;
		if (!self.ammo_cells)
			noammo = TRUE;
	}
	else if (wep == 6)
	{
		nextwep = IT_GRENADE_LAUNCHER;
		if (!self.ammo_rockets)
			noammo = TRUE;
	}
	else if (wep == 7)
	{
		nextwep = IT_HAGAR;
		if (!self.ammo_rockets)
			noammo = TRUE;
	}
	else if (wep == 8)
	{
		nextwep = IT_NEX;
		if (!self.ammo_cells)
			noammo = TRUE;
	}
	else if (wep == 9)
	{
		nextwep = IT_ROCKET_LAUNCHER;
		if (!self.ammo_rockets)
			noammo = TRUE;
	}


	if (!(self.items & nextwep))
	{
		sprint (self, "You don't own that weapon\n");
		return;
	}
	else if (noammo)
	{
		sprint (self, "You don't have any ammo for that weapon\n");
		return;
	}

	self.weapon = nextwep;
	W_UpdateWeapon ();
	W_UpdateAmmo ();
	self.attack_finished = time + 0.2;
	if (self.viewzoom != 1)
		self.viewzoom = 1;
}

void W_NextWeapon (void)
{
	float	noammo;

	while (TRUE)
	{
		noammo = FALSE;

		if (self.weapon == IT_ROCKET_LAUNCHER)
			self.weapon = IT_LASER;
		else if (self.weapon == IT_LASER)
		{
			self.weapon = IT_SHOTGUN;
			if (!self.ammo_shells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_UZI;
			if (!self.ammo_nails)
				noammo = TRUE;
		}
		else if (self.weapon == IT_UZI)
		{
			self.weapon = IT_CRYLINK;
			if (!self.ammo_cells)
			noammo = TRUE;
		}
		else if (self.weapon == IT_CRYLINK)
		{
			self.weapon = IT_ELECTRO;
			if (!self.ammo_cells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_ELECTRO)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (!self.ammo_cells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_HAGAR;
			if (!self.ammo_rockets)
				noammo = TRUE;
		}
		else if (self.weapon == IT_HAGAR)
		{
			self.weapon = IT_NEX;
			if (!self.ammo_rockets)
			noammo = TRUE;
		}
		else if (self.weapon == IT_NEX)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (!self.ammo_cells)
			noammo = TRUE;
		}

		if ((self.items & self.weapon) && !noammo)
		{
			W_UpdateWeapon ();
			W_UpdateAmmo ();
			return;
		}
	}
}

void W_PreviousWeapon (void)
{
	float	noammo;

	while (TRUE)
	{
		noammo = FALSE;

		if (self.weapon == IT_SHOTGUN)
			self.weapon = IT_LASER;
		else if (self.weapon == IT_UZI)
		{
			self.weapon = IT_SHOTGUN;
			if (!self.ammo_shells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_CRYLINK)
		{
			self.weapon = IT_UZI;
			if (!self.ammo_nails)
				noammo = TRUE;
		}
		else if (self.weapon == IT_ELECTRO)
		{
			self.weapon = IT_CRYLINK;
			if (!self.ammo_cells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_ELECTRO;
			if (!self.ammo_cells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_HAGAR)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (!self.ammo_rockets)
				noammo = TRUE;
		}
		else if (self.weapon == IT_NEX)
		{
			self.weapon = IT_HAGAR;
			if (!self.ammo_rockets)
				noammo = TRUE;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_NEX;
			if (!self.ammo_cells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_LASER)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (!self.ammo_rockets)
				noammo = TRUE;
		}

		if ((self.items & self.weapon) && !noammo)
		{
			W_UpdateWeapon ();
			W_UpdateAmmo ();
			return;
		}
	}
}
*/
float W_CheckAmmo (void)
{
	if (game & (GAME_INSTAGIB | GAME_ROCKET_ARENA))
		return TRUE;

	W_UpdateAmmo ();
	if (self.weapon == IT_LASER)
		return TRUE;
	else if (self.currentammo)
		return TRUE;

	self.weapon = W_GetBestWeapon (self);
	W_UpdateWeapon ();

	return FALSE;
}

/*
void FireRailgunBullet (vector src, float bdamage, vector dir, float spread, float deathtype)
{
	vector	v, lastpos;
	entity	saveself, last;
	vector	org;
	org = self.origin + self.view_ofs;
	if (bdamage < 1)
		return;

	last = self;
	lastpos = src;

	while (bdamage > 0)
	{
		traceline_hitcorpse (self, org, org + v_forward * 4096 + v_right * crandom () * spread + v_up * crandom () * spread, FALSE, self);
		last = trace_ent;
		lastpos = trace_endpos;
		if (trace_fraction != 1.0)
		{
			if (pointcontents(trace_endpos - dir*4) == CONTENT_SKY)
				return;

			if (trace_ent.takedamage || trace_ent.classname == "case")
			{
				if (trace_ent.classname == "player" || trace_ent.classname == "corpse" || trace_ent.classname == "gib")
					te_blood (trace_endpos, dir * bdamage * 16, bdamage);
				Damage (trace_ent, self, self, bdamage, deathtype, trace_endpos, dir * bdamage);
			}
		}
		if (last.solid == SOLID_BSP)
			bdamage = 0;
	}
}
*/
void FireRailgunBullet (vector start, vector end, float damage, float dtype)
{
	vector	v, lastpos;
	entity	saveself, last;
	vector	org;
	org = self.origin + self.view_ofs;
	if (bdamage < 1)
		return;

	last = self;
	lastpos = src;

	while (bdamage > 0)
	{
		traceline_hitcorpse (self, org, org + v_forward * 4096 + v_right * crandom () * spread + v_up * crandom () * spread, FALSE, self);
		last = trace_ent;
		lastpos = trace_endpos;
		if (trace_fraction != 1.0)
		{
			if (pointcontents(trace_endpos - dir*4) == CONTENT_SKY)
				return;

			if (trace_ent.takedamage || trace_ent.classname == "case")
			{
				if (trace_ent.classname == "player" || trace_ent.classname == "corpse" || trace_ent.classname == "gib")
					te_blood (trace_endpos, dir * bdamage * 16, bdamage);
				Damage (trace_ent, self, self, bdamage, deathtype, trace_endpos, dir * bdamage);
			}
		}
		if (last.solid == SOLID_BSP)
			bdamage = 0;
	}
}

void FireLaser (vector start, vector end, float damage, float dtype)
{
	vector	dir;

	dir = normalize (end - start);
	traceline_hitcorpse (self, start, end, FALSE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 76);
	WriteCoord (MSG_BROADCAST, start_x);
	WriteCoord (MSG_BROADCAST, start_y);
	WriteCoord (MSG_BROADCAST, start_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);

	if ((trace_fraction != 1.0) && (trace_ent != self) && (pointcontents (trace_endpos) != CONTENT_SKY))
	{
		if (trace_ent.classname == "case")
		{
			Damage (trace_ent, self, self, damage, dtype, trace_endpos, dir * damage);
		}
		else if (trace_ent.classname == "player" || trace_ent.classname == "corpse" || trace_ent.classname == "gib")
		{
			te_blood (trace_endpos, dir * damage * 16, damage);
			Damage (trace_ent, self, self, damage, dtype, trace_endpos, dir * damage);
		}
	}
}


void fireBullet (vector dir, float spread, float damage, float dtype)
{
	vector	org;
	float r;

	// use traceline_hitcorpse to make sure it can hit gibs and corpses too
	org = self.origin + self.view_ofs;
	traceline_hitcorpse (self, org, org + v_forward * 4096 + v_right * crandom () * spread + v_up * crandom () * spread, FALSE, self);

	// FIXME - causes excessive 'tinking'. Hopefully remove "tink1.wav" from the ricochets with csqc
	if ((trace_fraction != 1.0) && (trace_ent != self) && (pointcontents (trace_endpos) != CONTENT_SKY))
	{
		if (trace_ent == world)
		{
			pointcontents (self.origin);
			te_gunshot (trace_endpos);
			r = random ();
			if (r < 0.10)
				sound (self, CHAN_IMPACT, "weapons/ric1.wav", 1, ATTN_NORM);
			else if (r < 0.20)
				sound (self, CHAN_IMPACT, "weapons/ric2.wav", 1, ATTN_NORM);
			else if (r < 0.30)
				sound (self, CHAN_IMPACT, "weapons/ric3.wav", 1, ATTN_NORM);
		}
		else if (trace_ent.classname == "case")
		{
			Damage (trace_ent, self, self, damage, dtype, trace_endpos, dir * damage);
		}
		else if (trace_ent.classname == "player" || trace_ent.classname == "corpse" || trace_ent.classname == "gib")
		{
			te_blood (trace_endpos, dir * damage * 16, damage);
			Damage (trace_ent, self, self, damage, dtype, trace_endpos, dir * damage);
			sound (trace_ent, CHAN_IMPACT, "misc/enemyimpact.wav", 1, ATTN_NORM);
		}
	}
}

/*
void W_Attack (void)
{
	if (self.deadflag != DEAD_NO)
	{
		if (self.death_time < time)
			PutClientInServer();

		return;
	}

	if (!W_CheckAmmo ())
		return;

	makevectors (self.v_angle);
	//if (self.weapon == IT_LASER)
	//	W_Laser_Attack ();
	//if (self.weapon == IT_SHOTGUN)
		//W_Shotgun_Attack ();
	//else if (self.weapon == IT_UZI)
		//W_Uzi_Attack ();
	if (self.weapon == IT_CRYLINK)
		W_Crylink_Attack ();
	else if (self.weapon == IT_ELECTRO)
		{
		W_Electro_Attack (self.electrocount);
		self.electrocount = self.electrocount + 1;
		if (self.electrocount == 3)
			self.electrocount = 0;
		}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
		W_Grenade_Attack ();
	else if (self.weapon == IT_HAGAR)
		W_Hagar_Attack ();
	else if (self.weapon == IT_NEX)
		W_Nex_Attack ();
	//else if (self.weapon == IT_ROCKET_LAUNCHER)
	//	W_Rocket_Attack ();

	W_UpdateAmmo ();
}

void W_SecondaryAttack (void)
{
	if (self.deadflag != DEAD_NO)
	{
		if (self.death_time < time)
			PutClientInServer();

		return;
	}

	if (!W_CheckAmmo ())
		return;

	makevectors (self.v_angle);
	//if (self.weapon == IT_LASER)
		//W_Laser_Attack2 ();
	//if (self.weapon == IT_SHOTGUN)
		//W_Shotgun_Attack2 ();
	//else if (self.weapon == IT_UZI)
		//W_Uzi_Attack2 ();
	else if (self.weapon == IT_CRYLINK)
		W_Crylink_Attack2 ();
	else if (self.weapon == IT_ELECTRO) {
		W_Electro_Attack2 (self.electrocount);
		self.electrocount = self.electrocount + 1;
		if (self.electrocount == 3)
			self.electrocount = 0;
		}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
		W_Grenade_Attack2 ();
	else if (self.weapon == IT_HAGAR)
		W_Hagar_Attack2 ();
	else if (self.weapon == IT_NEX)
		W_Nex_Attack2 ();
	//else if (self.weapon == IT_ROCKET_LAUNCHER)
		//W_Rocket_Attack2 ();

	W_UpdateAmmo ();
}

void W_ThirdAttack (void)
{
	if (self.deadflag != DEAD_NO)
	{
		if (self.death_time < time)
			PutClientInServer();

		return;
	}

	if (!W_CheckAmmo ())
		return;
	
	makevectors (self.v_angle);
	//if (self.weapon == IT_LASER)
		//W_Laser_Attack2 ();
	//if (self.weapon == IT_SHOTGUN)
		//W_Shotgun_Attack2 ();
	//else if (self.weapon == IT_UZI)
		//W_Uzi_Attack3 ();
	else if (self.weapon == IT_CRYLINK)
		W_Crylink_Attack2 ();
	else if (self.weapon == IT_ELECTRO) {
		W_Electro_Attack3 (self.electrocount);
		self.electrocount = self.electrocount + 1;
		if (self.electrocount == 3)
			self.electrocount = 0;
		}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
		W_Grenade_Attack3 ();
	else if (self.weapon == IT_HAGAR)
		W_Hagar_Attack3 ();
	else if (self.weapon == IT_NEX)
		W_Nex_Attack2 ();
	//else if (self.weapon == IT_ROCKET_LAUNCHER)
		//W_Rocket_Attack3 ();

	W_UpdateAmmo ();
}
*/