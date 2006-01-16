
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

void ResetExtraWeapon()
{
	if(self.wpn5 == world)
	{
		self.wpn5 = spawn();
	}

	self.wpn5.weapon = 0;
	self.wpn5.mass = 0;
	self.items = self.items - (self.items & IT_WEP5);
}

void W_GiveWeapon (entity e, float wep, string name, float wmass)
{
	entity oldself;

	if (!wep)
		return;

	//e.items = e.items | wep;

	oldself = self;
	self = e;

	self.wpn5.weapon = wep;
	self.wpn5.mass = wmass;

	self.items = self.items | IT_WEP5;

	weapon_action(self.weapon, WR_UPDATECOUNTS);
	if(self.weapon == WEP5)					// if using carrying # 5 already
	{
		//bprint("reset wep5\n");
		self.wpn = self.wpn5.weapon;
		self.switchweapon = WEP5;
		weapon_action(self.weapon, WR_DROP);
		self.weapon = 0;
		//weapon_action(self.wpn, WR_SETUP);	// update the weapon we're holding
		//weapon_action(self.wpn, WR_RAISE);	// update the weapon we're holding
	}

	if (other.classname == "player")
	{
		sprint (other, "You got the ^2");
		sprint (other, name);
		sprint (other, "\n");
	}


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
	if ((cvar("g_instagib") == 1) | (cvar("g_rocketarena") == 1))
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

void FireRailgunBullet (vector start, vector end, float bdamage, float deathtype)
{
	local vector hitloc, force;
	local entity ent;
	//local entity explosion;

	force = normalize(end - start) * 800; //(bdamage * 10);

	// find how far the beam can go until it hits a wall
	traceline (start, end, MOVE_HITMODEL, self);		// doing this enables checking against model
														// geometry -- leaving it disabled for now since
														// it's a cpu hog.
	//traceline (start, end, TRUE, self);
	// go a little bit into the wall because we need to hit this wall later
	end = trace_endpos + normalize(end - start);

	local float dam_mult;
	local float zdif;
	local float x;
	local vector f;
	local vector g;
	local vector h;

	traceline_hitcorpse (self, start, end, FALSE, self);
	if (trace_ent/* && deathtype == WEP_RAILGUN*/)			// Area damage!
	{
		if ((trace_ent.classname == "player"))
		{
			f = (trace_endpos - start);
			g_x = trace_endpos_x;
			g_y = trace_endpos_y;
			g_z = 0;
			h_x = trace_ent.origin_x;
			h_y = trace_ent.origin_y;
			h_z = 0;
			x = vlen ((g - h));
			f = ((normalize (f) * x) + trace_endpos);
			zdif = (f_z - trace_ent.origin_z);
			bprint(ftos(zdif));
			bprint("\n");
			deathmsg = 18;
			trace_ent.head_shot_vector = '0 0 0';
			if (trace_ent.crouch == 1)		// Damage enemy that's crouching
			{
				if (zdif < -5)
				{
					dam_mult = 0.5;
					if ((trace_ent.team_no != self.team_no))
					{
						trace_ent.leg_damage = (trace_ent.leg_damage + 1);
						TeamFortress_SetSpeed (trace_ent);
						deathmsg = RAILGUN_LEGSHOT;
						bdamage = bdamage * .8;
					}
					if ((trace_ent.health > 0))
					{
						if ((trace_ent.team_no == self.team_no))
						{
							sprint (self, "Stop shooting team mates!!!\n");
						}
						else
						{
							sprint (trace_ent, "Leg injury!\n");
							sprint (self, "Leg shot - that'll slow him down!\n");
						}
					}
				}
				else
				{
					if (zdif > 5)
					{
						dam_mult = 3;
						stuffcmd (trace_ent, "bf\n");
						//deathmsg = 29;
						if ((trace_ent.health > 0))
						{
							if ((trace_ent.team_no == self.team_no))
							{
								sprint (self, "Stop shooting team mates!!!\n");
							}
							else
							{
								trace_ent.head_shot_vector = (trace_ent.origin - self.origin);
								deathmsg = 29;
								if (zdif > 9.1)
								{
									bdamage = floor(bdamage * 4.0);
									deathmsg = RAILGUN_HEADSHOT;
								}
								else
								{
									bdamage = floor(bdamage * 2.5);
									deathmsg = RAILGUN_CHESTSHOT;
								}
								sound (self, 0, "speech/excelent.wav", 1, 0);
							}
						}
						else
						{
							deathmsg = RAILGUN_BODYSHOT;
						}
					}
				}
			}
			else {					// Damage standing enemy
				if (zdif < 0)
				{
					dam_mult = 0.5;
					if ((trace_ent.team_no != self.team_no))
					{
						trace_ent.leg_damage = (trace_ent.leg_damage + 1);
						TeamFortress_SetSpeed (trace_ent);
						deathmsg = RAILGUN_LEGSHOT;
						bdamage = bdamage * .8;
						//T_Damage (trace_ent, self, self, (self.heat * dam_mult));
					}
					if ((trace_ent.health > 0))
					{
						if ((trace_ent.team_no == self.team_no))
						{
							sprint (self, "Stop shooting team mates!!!\n");
						}
						else
						{
							sprint (trace_ent, "Leg injury!\n");
							sprint (self, "Leg shot - that'll slow him down!\n");
						}
					}
					//return;
				}
				else
				{
					if (zdif > 20)
					{
						dam_mult = 3;
						stuffcmd (trace_ent, "bf\n");
						//deathmsg = 29;
						if ((trace_ent.health > 0))
						{
							if ((trace_ent.team_no == self.team_no))
							{
								sprint (self, "Stop shooting team mates!!!\n");
							}
							else
							{
								trace_ent.head_shot_vector = (trace_ent.origin - self.origin);
								deathmsg = 29;
//								bdamage = floor(bdamage * 3.5);
								if (zdif > 31)
								{
									bdamage = floor(bdamage * 15.5);
									deathmsg = RAILGUN_HEADSHOT;
								}
								else
								{
									bdamage = floor(bdamage * 2.5);
									deathmsg = RAILGUN_CHESTSHOT;
								}
//								T_Damage (trace_ent, self, self, (self.heat * dam_mult));
								sound (self, 0, "speech/excelent.wav", 1, 0);
//								if ((trace_ent.health > 0))
//								{
//									sprint (trace_ent, 0, "Head injury!\n");
//									sprint (self, 1, "Head shot - that's gotta hurt!\n");
//								}
							}
							//return;
						}
						else
						{
							deathmsg = RAILGUN_BODYSHOT;
						}
					}
				}
			}
		}
	}

	// trace multiple times until we hit a wall, each obstacle will be made
	// non-solid so we can hit the next, while doing this we spawn effects and
	// note down which entities were hit so we can damage them later
	while (1)
	{
		traceline_hitcorpse (self, start, end, FALSE, self);

		// if it is world we can't hurt it so stop now
		if (trace_ent == world || trace_fraction == 1)
			break;

		// make the entity non-solid so we can hit the next one
		trace_ent.railgunhit = TRUE;
		trace_ent.railgunhitloc = trace_endpos;
		trace_ent.railgunhitsolidbackup = trace_ent.solid;

		// stop if this is a wall
		if (trace_ent.solid == SOLID_BSP)
			break;

		// make the entity non-solid
		trace_ent.solid = SOLID_NOT;
	}

	// find all the entities the railgun hit and restore their solid state
	ent = findfloat(world, railgunhit, TRUE);
	while (ent)
	{
		// restore their solid type
		ent.solid = ent.railgunhitsolidbackup;
		ent = findfloat(ent, railgunhit, TRUE);
	}

	// spawn a temporary explosion entity for RadiusDamage calls
	//explosion = spawn();

	// find all the entities the railgun hit and hurt them
	ent = findfloat(world, railgunhit, TRUE);
	while (ent)
	{
		// get the details we need to call the damage function
		hitloc = ent.railgunhitloc;
		ent.railgunhitloc = '0 0 0';
		ent.railgunhitsolidbackup = SOLID_NOT;
		ent.railgunhit = FALSE;

		// apply the damage
		if (ent.takedamage || ent.classname == "case")
//			Damage (ent, self, self, bdamage, deathtype, hitloc, force);
			Damage (ent, self, self, bdamage, deathmsg, hitloc, force);

		// create a small explosion to throw gibs around (if applicable)
		//setorigin (explosion, hitloc);
		//RadiusDamage (explosion, self, 10, 0, 50, world, 300, deathtype);

		// advance to the next entity
		ent = findfloat(ent, railgunhit, TRUE);
	}

	// we're done with the explosion entity, remove it
	//remove(explosion);
}

// Area damage function --
//	added this so I dont have to paste this into every function I want area damage in.
//	Returns a value of LEGSHOT, BODYSHOT, CHESTSHOT, or HEADSHOT.
float (entity a, vector start, vector end, float flt, entity b) FindBodyDamage =
{
	local float dam_mult;
	local float zdif;
	local float x;
	local vector f;
	local vector g;
	local vector h;

	traceline_hitcorpse (a, start, end, flt, b);
	if (trace_ent)
	{
		if ((trace_ent.classname == "player"))
		{
			f = (trace_endpos - start);
			g_x = trace_endpos_x;
			g_y = trace_endpos_y;
			g_z = 0;
			h_x = trace_ent.origin_x;
			h_y = trace_ent.origin_y;
			h_z = 0;
			x = vlen ((g - h));
			f = ((normalize (f) * x) + trace_endpos);
			zdif = (f_z - trace_ent.origin_z);
			bprint(ftos(zdif));
			bprint("\n");
			deathmsg = 18;
			trace_ent.head_shot_vector = '0 0 0';
			if (trace_ent.crouch == 1)		// Damage enemy that's crouching
			{
				if (zdif < -5)
				{
					dam_mult = 0.5;
					if ((trace_ent.team_no != self.team_no))
					{
						trace_ent.leg_damage = (trace_ent.leg_damage + 1);
//						TeamFortress_SetSpeed (trace_ent);
						return LEGSHOT;
					}
					if ((trace_ent.health > 0))
					{
						if ((trace_ent.team_no == self.team_no))
						{
							sprint (self, "Stop shooting team mates!!!\n");
						}
						else
						{
							sprint (trace_ent, "Leg injury!\n");
							sprint (self, "Leg shot - that'll slow him down!\n");
						}
					}
				}
				else
				{
					if (zdif > 5)
					{
						dam_mult = 3;
						stuffcmd (trace_ent, "bf\n");
						if ((trace_ent.health > 0))
						{
							if ((trace_ent.team_no == self.team_no))
							{
								sprint (self, "Stop shooting team mates!!!\n");
							}
							else
							{
								trace_ent.head_shot_vector = (trace_ent.origin - self.origin);
								deathmsg = 29;
								if (zdif > 9.1)
								{
									return HEADSHOT;
								}
								else
								{
									return CHESTSHOT;
								}
							}
						}
						else
						{
							return BODYSHOT;
						}
					}
				}
			}
			else {					// Damage standing enemy
				if (zdif < 0)
				{
					dam_mult = 0.5;
					if ((trace_ent.team_no != self.team_no))
					{
						trace_ent.leg_damage = (trace_ent.leg_damage + 1);
//						TeamFortress_SetSpeed (trace_ent);
						return LEGSHOT;
					}
/*					if ((trace_ent.health > 0))
					{
						if ((trace_ent.team_no == self.team_no))
						{
							sprint (self, "Stop shooting team mates!!!\n");
						}
						else
						{
							sprint (trace_ent, "Leg injury!\n");
							sprint (self, "Leg shot - that'll slow him down!\n");
						}
					}*/
				}
				else
				{
					if (zdif > 20)
					{
						dam_mult = 3;
						stuffcmd (trace_ent, "bf\n");
						if ((trace_ent.health > 0))
						{
							if ((trace_ent.team_no == self.team_no))
							{
								sprint (self, "Stop shooting team mates!!!\n");
							}
							else
							{
								trace_ent.head_shot_vector = (trace_ent.origin - self.origin);
								if (zdif > 31)
								{
									return HEADSHOT;
								}
								else
								{
									return CHESTSHOT;
								}
							}
						}
						else
						{
							return BODYSHOT;
						}
					}
				}
			}
		}
	}
};

void fireBullet2 (vector start, vector dir, float spread, float damage, float dtype, float tracer, float force)
{
	vector  end;
	float r;
	local entity e;
	local float bdamage;

	// use traceline_hitcorpse to make sure it can hit gibs and corpses too
	dir = dir + randomvec() * spread;
	end = start + dir * 4096;
	traceline_hitcorpse (self, start, end, FALSE, self);

	if (dtype = WEP_PISTOL)			// if pistol weapon, apply area damage
	{
		bdamage = FindBodyDamage (self, start, end, FALSE, self);
		if (bdamage == HEADSHOT)
		{
			damage = damage * 3;
			dtype = PISTOL_HEADSHOT;
		}
		else if (bdamage == LEGSHOT)
		{
			damage = damage * .75;
			dtype = PISTOL_LEGSHOT;
		}
		else
		{
			dtype = PISTOL_BODYSHOT;
		}
	}

	if (tracer)
	{
		e = spawn();
		e.owner = self;
		e.movetype = MOVETYPE_FLY;
		e.solid = SOLID_NOT;
		e.think = SUB_Remove;
		e.nextthink = time + vlen(trace_endpos - start) / 6000;
		if (dtype == WEP_PISTOL)			// if pistol, show slower bullet
			e.velocity = dir * 1750;
		else
			e.velocity = dir * 6000;
		e.angles = vectoangles(e.velocity);
		setmodel (e, "models/tracer.mdl");
		setsize (e, '0 0 0', '0 0 0');
		setorigin (e, start);
		e.effects = e.effects | EF_ADDITIVE;
	}

	// FIXME - causes excessive 'tinking'. Hopefully remove "tink1.wav" from the ricochets with csqc
	if ((trace_fraction != 1.0) && (pointcontents (trace_endpos) != CONTENT_SKY))
	{
		if (trace_ent.solid == SOLID_BSP)
		{
			pointcontents (self.origin);
			te_gunshot (trace_endpos);
			r = random ();
			if (r < 0.10)
				PointSound (trace_endpos, "weapons/ric1.wav", 1, ATTN_NORM);
			else if (r < 0.20)
				PointSound (trace_endpos, "weapons/ric2.wav", 1, ATTN_NORM);
			else if (r < 0.30)
				PointSound (trace_endpos, "weapons/ric3.wav", 1, ATTN_NORM);
		}
		else if (trace_ent.classname == "player" || trace_ent.classname == "corpse" || trace_ent.classname == "gib")
			sound (self, CHAN_BODY, "misc/hit.wav", 1, ATTN_NORM);
		Damage (trace_ent, self, self, damage, dtype, trace_endpos, dir * force);
	}
}

void fireBullet (vector start, vector dir, float spread, float damage, float dtype, float tracer)
{
	fireBullet2(start, dir, spread, damage, dtype, tracer, damage * 5); // default force value
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

float RateFlameDamage(float flametime, float flamedmg, float flamerate)
{
	// return (how much longer flame will last) * (how much to damage per think / how often to think)
	return (flametime - time) * (flamedmg / flamerate);
}

/*void FlamePuffThink()
{
	self.nextthink = time + self.cnt;
	self.frame = self.frame + 1;
	if(self.frame >= self.count)
		self.think = SUB_Remove;
}
*/
void FlameBurnTarget();


entity CreateFlame(entity targ, entity attacker)
{
	entity f;
	f = targ.onfire = spawn();
	f.classname = "burning";
	f.owner = attacker;
	f.enemy = targ;
	f.dmg = 0;
	f.ltime = 0;
	f.wait = 0;
	f.think = FlameBurnTarget;
	f.onfire = spawn();

	f.effects = f.onfire.effects = EF_ADDITIVE;
	f.scale = f.onfire.scale = 2;

	setmodel(f, "models/sprites/fire_top.spr32");
	setattachment(f, f.enemy, "");
	setmodel(f.onfire, "models/sprites/fire_base.spr32");

	setorigin(f.onfire, '0 0 -5' * f.scale);
	setorigin(f, '0 0 2' * f.scale + '0 0 20');
	setattachment(f.onfire, f, "");

	return f;
}

entity IgniteTarget (entity targ, entity attacker, float flametime, float flamedmg, float flamerate, float rateflame)
{
	entity f;

	//bprint("ignite targets?\n");

	if(targ.class == CLASS_PYRO)
	{
		//flametime = flametime / 5; // pyros don't stay on fire for long
		return world; // don't set pyros on fire
	}

	if(targ.class == CLASS_MEDIC)
	{
		//flametime = flametime / 3; // medics don't stay on fire for long
		return world; // don't set medics on fire
	}

	f = targ.onfire;
	if(f == world)
	{
		f = CreateFlame(targ, attacker);
	}
	else
	{
		if(f.nextthink <= 0)
			f.nextthink = time + flamerate;
	}


//	bprint(ftos(f.wait), ", ", ftos(f.dmg), ", ", ftos(f.ltime), "\n");
	//bprint(ftos(flametime), ", ", ftos(flamedmg), ", ", ftos(flamerate), "\n");
//	bprint(ftos(RateFlameDamage(f.wait, f.dmg, f.ltime)), ", ", ftos(RateFlameDamage(flametime, flamedmg, flamerate)), "\n");

	if(rateflame && RateFlameDamage(f.wait, f.dmg, f.ltime) > RateFlameDamage(time + flametime, flamedmg, flamerate))
	{
		f.owner = attacker; // give the new attacker ownership of the burn damage
		return f; // current damage rating is larger, don't replace it
	}

	//bprint("burning success: ", ftos(flametime), "\n");

	f.dmg = flamedmg;
	f.ltime = flamerate;
	f.wait = time + flametime;

	if(!f.nextthink || f.nextthink > time + f.ltime)
		f.nextthink = time + f.ltime;

	return f;
}

void ExtinguishFlame(entity targ)
{
	entity f, b;
	if(!targ.onfire)//targ.onfire.classname != "burning")
		return;
	//bprint(strcat("ExtinguishFlame(", targ.classname, ") ", targ.onfire.classname, "\n"));

	f = targ.onfire;
	b = targ.onfire.onfire;

	// fixme: hiss sound

	if(b)
	{
		b.think = SUB_Null;
		b.nextthink = -1;
		setmodel(b, "models/sprites/null.spr");
		setattachment(b, world, "");
		remove(b); // remove base model
		//targ.onfire.onfire.think = SUB_Remove;
		//targ.onfire.onfire.nextthink = time + 0.1;
		f.onfire = world;
	}
	f.think = SUB_Null;
	f.nextthink = -1;
	setmodel(f, "models/sprites/null.spr");
	setattachment(f, world, "");
	//targ.onfire.think = SUB_Remove;
	//targ.onfire.nextthink = time + 0.1;
	remove(f);
	targ.onfire = world;
}

void FlameBurnTarget()
{
	entity head;
	float flametime, flametimemax, radius, flameratio, distratio, edgeratio, damage;
	//bprint("flame burn target\n");

	if(self.enemy == world || self.enemy.classname == "gib")
	{
		if(self.enemy != world)
		{
			//bprint("on a gib, remove flame\n");
			//self.enemy.onfire = world;
			ExtinguishFlame(self.enemy);
			return;
		}
		//bprint("enemy is world, remove flame\n");
		self.think = SUB_Null;
		self.nextthink = -1;
		setmodel(self, "models/sprites/null.spr");
		setattachment(self, world, "");
		if(self.onfire)
		{
			self.onfire.think = SUB_Null;
			self.onfire.nextthink = -1;
			setmodel(self.onfire, "models/sprites/null.spr");
			setattachment(self.onfire, world, "");
			remove(self.onfire);
			self.onfire = world;
		}
		remove(self);
		return;
	}

	if(self.wait < time || self.enemy.waterlevel > 2 || (!self.enemy.takedamage && self.enemy.classname != "grenade"))
	{
		/*if(self.enemy != world)
		{
			self.enemy.effects = self.enemy.effects - (self.enemy.effects & EF_FLAME);
			self.enemy.onfire = world;
		}
		remove(self);*/
		ExtinguishFlame(self.enemy);
		return;
	}
	self.nextthink = time + self.ltime;

	Damage (self.enemy, self, self.owner, self.dmg, DEATH_BURNING, self.enemy.origin - '0 0 5', '0 0 0');//'0 0 -1' * self.dmg);

	// flames spread to other targets

	radius = cvar("g_balance_heat_radius");
	head = findradius(self.enemy.origin, radius);
	while(head)
	{
		if((head.takedamage || head.classname == "grenade") && head != self.enemy)
		{
			//bprint(strcat("maybe burn ", head.classname, "\n"));
			// don't harm or spread to allies or pyros
			//if(!(head.classname == "player" && (head.team == self.owner.team || head.class == CLASS_PYRO)) )
			if(head.classname == "player")
			{
				if(head.class == CLASS_PYRO || head.class == CLASS_MEDIC) // pyros & medics are mostly immune to fire
				{	head = head.chain;	continue;}
				if(head.team == self.owner.team && teamplay) // don't hurt teammates
				{	head = head.chain;	continue;}
			}

			traceline(self.enemy.origin, head.origin, TRUE, self);
			if(trace_fraction >= 1)
			{
				//bprint(strcat("burn ", head.classname, "\n"));
				edgeratio = cvar("g_balance_heat_edgeratio");
				distratio = ( 1 - (vlen(self.enemy.origin - head.origin) / radius) );
				flameratio = edgeratio + distratio*(1 - edgeratio);

				// increase the player's heat; if it goes over the max it'll get capped automatically by the cooldown code
				//head.flame_heat = cvar("g_balance_maxheat");
				head.flame_heat = head.flame_heat + flameratio * cvar("g_balance_heatup_rate") * self.ltime;
				//head.flame_heat_time = time;

				// deal direct damage from the heat radiated by the fire
				damage = flameratio * self.dmg*cvar("g_balance_heat_damage");
				Damage (head, self, self.owner, damage, DEATH_BURNING, self.enemy.origin, '0 0 0');

				if(head.flame_heat >= 1.0 && head.takedamage == DAMAGE_AIM && head.health > 0)
				{
					flametimemax = cvar("g_balance_heat_timemax");
					flametime = (self.wait - time) * cvar("g_balance_heat_transfer");
					if(flametime > flametimemax)
						flametime = flametimemax;


					//bprint(ftos(time), " - flame transfer - ", ftos(flametime), "\n");

					
					IgniteTarget(head, self.owner, flametime, self.dmg, self.ltime, TRUE);
				}
			}
		}
		head = head.chain;
	}
}


void PoisonTarget(entity targ, float poisonDamage, float poisonTime, float ratepoison)
{
	if(targ.class == CLASS_MEDIC)
	{
		return; // don't poison medics
	}

	if(ratepoison && targ.poison_damage > poisonDamage)
		return; // current damage rating is larger, don't replace it

	targ.poison_damage = poisonDamage;
	targ.poison_rate = poisonDamage / poisonTime;
}











float W_LimitNumEnts(string clname, float num_allowed, void() DeathFunc)
{
	float num, oldest;
	local entity e, selected;
	e = world;
	oldest = time + 1;
	num = 0;
	do
	{
		e = find(e, classname, clname);
		if(e != world && e.owner == self)
		{
			num = num + 1;
			if(e.create_time < oldest)
			{
				selected = e;
				oldest = e.create_time;
			}
		}
	}while(e);

	if(num > num_allowed)
	{
		if(selected != world)
		{
			e = self;
			self = selected;
			DeathFunc();
			self = e;
			return TRUE;
		}
		else
			bprint("error (W_LimitNumEnts): cannot find oldest entity\n");
	}
	return FALSE;
}

