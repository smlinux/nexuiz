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
	self.items = self.items - (self.items & (IT_NAILS | IT_SHELLS | IT_ROCKETS | IT_CELLS));

	if (self.weapon == IT_LASER)
		self.currentammo = 1;
	else if (self.weapon == IT_UZI)
	{
		self.currentammo = self.ammo_nails;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.items = self.items | IT_SHELLS;
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
}

void W_UpdateWeapon (void)
{
	if (self.weapon == IT_LASER)
		self.weaponmodel = "models/weapons/w_laser.zym";
	else if (self.weapon == IT_UZI)
		self.weaponmodel = "models/weapons/w_uzi.zym";
	else if (self.weapon == IT_SHOTGUN)
		self.weaponmodel = "models/weapons/w_shotgun.zym";
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
}

float W_GetBestWeapon (void)
{
	if ((self.items & IT_ROCKET_LAUNCHER) && self.ammo_rockets)
		return IT_ROCKET_LAUNCHER;
	else if ((self.items & IT_HAGAR) && self.ammo_rockets)
		return IT_HAGAR;
	else if ((self.items & IT_NEX) && self.ammo_cells)
		return IT_NEX;
	else if ((self.items & IT_CRYLINK) && self.ammo_cells)
		return IT_CRYLINK;
	else if ((self.items & IT_ELECTRO) && self.ammo_cells)
		return IT_ELECTRO;
	else if ((self.items & IT_GRENADE_LAUNCHER) && self.ammo_rockets)
		return IT_GRENADE_LAUNCHER;
	else if ((self.items & IT_SHOTGUN) && self.ammo_shells)
		return IT_SHOTGUN;
	else if ((self.items & IT_UZI) && self.ammo_nails)
		return IT_UZI;
	else
		return IT_LASER;
}

void W_GiveWeapon (entity e, float wep)	// FIXME - make it 'smarter'
{
	entity oldself;

	if (!wep)
		return;

	if (!(e.items & wep))
	{
		e.items = e.items | wep;
		e.weapon = wep;
	}

	oldself = self;
	self = e;

	W_UpdateWeapon ();
	W_UpdateAmmo ();

	self = oldself;
}

void W_SwitchWeapon (float wep)
{
	float		nextwep;
	var float	noammo = FALSE;

	if (wep == 1)
		nextwep = IT_LASER;
	else if (wep == 2)
	{
		nextwep = IT_UZI;
		if (!self.ammo_nails)
			noammo = TRUE;
	}
	else if (wep == 3)
	{
		nextwep = IT_SHOTGUN;
		if (!self.ammo_shells)
			noammo = TRUE;
	}
	else if (wep == 4)
	{
		nextwep = IT_GRENADE_LAUNCHER;
		if (!self.ammo_rockets)
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
		nextwep = IT_CRYLINK;
		if (!self.ammo_cells)
			noammo = TRUE;
	}
	else if (wep == 7)
	{
		nextwep = IT_NEX;
		if (!self.ammo_cells)
			noammo = TRUE;
	}
	else if (wep == 8)
	{
		nextwep = IT_HAGAR;
		if (!self.ammo_rockets)
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

	sound (self, CHAN_WEAPON, "weapons/gunswitch.wav", 1, ATTN_NORM);

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
			self.weapon = IT_UZI;
			if (!self.ammo_nails)
				noammo = TRUE;
		}
		else if (self.weapon == IT_UZI)
		{
			self.weapon = IT_SHOTGUN;
			if (!self.ammo_shells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (!self.ammo_rockets)
				noammo = TRUE;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_ELECTRO;
			if (!self.ammo_cells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_ELECTRO)
		{
			self.weapon = IT_CRYLINK;
			if (!self.ammo_cells)
			noammo = TRUE;
		}
		else if (self.weapon == IT_CRYLINK)
		{
			self.weapon = IT_NEX;
			if (!self.ammo_cells)
			noammo = TRUE;
		}
		else if (self.weapon == IT_NEX)
		{
			self.weapon = IT_HAGAR;
			if (!self.ammo_rockets)
			noammo = TRUE;
		}
		else if (self.weapon == IT_HAGAR)
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
	sound (self, CHAN_WEAPON, "weapons/gunswitch.wav", 1, ATTN_NORM);
}

void W_PreviousWeapon (void)
{
	float	noammo;

	while (TRUE)
	{
		noammo = FALSE;

		if (self.weapon == IT_UZI)
			self.weapon = IT_LASER;
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_UZI;
			if (!self.ammo_nails)
				noammo = TRUE;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_SHOTGUN;
			if (!self.ammo_shells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_ELECTRO)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (!self.ammo_rockets)
				noammo = TRUE;
		}
		else if (self.weapon == IT_CRYLINK)
		{
			self.weapon = IT_ELECTRO;
			if (!self.ammo_cells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_NEX)
		{
			self.weapon = IT_CRYLINK;
			if (!self.ammo_cells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_HAGAR)
		{
			self.weapon = IT_NEX;
			if (!self.ammo_cells)
				noammo = TRUE;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_HAGAR;
			if (!self.ammo_rockets)
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
	sound (self, CHAN_WEAPON, "weapons/gunswitch.wav", 1, ATTN_NORM);
}

float W_CheckAmmo (void)
{
	W_UpdateAmmo ();
	if (self.weapon == IT_LASER)
		return TRUE;
	else if (self.currentammo)
		return TRUE;

	self.weapon = W_GetBestWeapon ();
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

void FireRailgunBullet (vector src, float damage, vector dir, float dtype)
{
	vector	org;

	makevectors (self.v_angle);

	// use traceline_hitcorpse to make sure it can hit gibs and corpses too
	org = self.origin + self.view_ofs;
	traceline_hitcorpse (self, org, org + v_forward * 4096 + v_right + v_up, FALSE, self);
	
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

	makevectors (self.v_angle);

	// use traceline_hitcorpse to make sure it can hit gibs and corpses too
	org = self.origin + self.view_ofs;
	traceline_hitcorpse (self, org, org + v_forward * 4096 + v_right * crandom () * spread + v_up * crandom () * spread, FALSE, self);

	// FIXME - causes excessive 'tinking'. Hopefully remove "tink1.wav" from the ricochets with csqc
	if ((trace_fraction != 1.0) && (trace_ent != self) && (pointcontents (trace_endpos) != CONTENT_SKY))
	{
		if (trace_ent == world)
			te_gunshot (trace_endpos);
		else if (trace_ent.classname == "case")
		{
//			te_gunshot (trace_endpos);
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

void W_Laser_Touch (void)
{
	vector	dir;

	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	dir = normalize (self.owner.origin - self.origin);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_FLAMEJET);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, 0);		// SeienAbunae: groan... Useless clutter
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	WriteByte (MSG_BROADCAST, 155);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, 15, 7, 50, world, 200, IT_LASER);
	sound (self, CHAN_IMPACT, "weapons/laserimpact.wav", 1, ATTN_NORM);

	remove (self);
}

void W_Laser_Attack (void)
{
	entity	missile;

	sound (self, CHAN_WEAPON, "weapons/lasergun_fire.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "spike";

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;

	setmodel (missile, "models/beam.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	makevectors (self.v_angle);
	missile.velocity = v_forward * 1000;
	missile.velocity = missile.velocity + v_right * ( crandom() * 45 );
	missile.velocity = missile.velocity + v_up * ( crandom() * 25 );
	missile.angles = vectoangles (missile.velocity);
	missile.glow_color = 250; // 244, 250
	missile.glow_size = 30;
	missile.touch = W_Laser_Touch;
	missile.think = SUB_Remove;
	missile.nextthink = time + 9;

	self.punchangle_x = random () - 0.5;
	self.punchangle_y = random () - 0.5;
	self.punchangle_z = random () - 0.5;

	self.attack_finished = time + 0.2;
}

void W_Laser_Attack2 (void)
{
	entity	missile;

	sound (self, CHAN_WEAPON, "weapons/lasergun_fire.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "spike";

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;

	setmodel (missile, "models/beam.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	makevectors (self.v_angle);
	missile.velocity = v_forward * 4000;
	missile.angles = vectoangles (missile.velocity);
	missile.glow_color = 250; // 244, 250
	missile.glow_size = 30;
	missile.touch = W_Laser_Touch;
	missile.think = SUB_Remove;
	missile.nextthink = time + 2;

	self.punchangle_x = random () - 0.5;
	self.punchangle_y = random () - 0.5;
	self.punchangle_z = random () - 0.5;

	self.attack_finished = time + 0.4;
}

void W_Uzi_Attack (void)
{
	sound (self, CHAN_WEAPON, "weapons/uzi_fire.wav", 1, ATTN_NORM);

	fireBullet (v_forward, 100, 6, IT_UZI);

	//self.punchangle = (randomvec() + '-1 0 0') * 2;
	//self.punchangle_z = 0; // don't want roll

	self.attack_finished = time + 0.075;
	self.ammo_nails = self.ammo_nails - 1;

	vector	org; // casing code
	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 1) + (v_forward * 20);
	SpawnCasing (org, v_forward, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 1);
	//W_Smoke(org, v_forward, 12);
}

void W_Uzi_Attack2 (void)
{
	float	sc;
	float	bullets;

	sound (self, CHAN_WEAPON, "weapons/shotgun_fire.wav", 1, ATTN_NORM);

	bullets = 5;
	if (bullets > self.ammo_nails)
		bullets = self.ammo_nails;

	for (sc = bullets; sc > 0; sc = sc - 1)
		fireBullet (v_forward, 400, 8, IT_SHOTGUN);

	//self.punchangle_x = -2;

	self.ammo_nails = self.ammo_nails - bullets;
	self.attack_finished = time + 0.4;

	vector	org; // casing code
	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 4) + (v_forward * 15);
	SpawnCasing (org, v_forward, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2);
}

void W_Shotgun_Attack (void)
{
	float	sc;
	float	bullets;

	sound (self, CHAN_WEAPON, "weapons/shotgun_fire.wav", 1, ATTN_NORM);

	bullets = 10;

	for (sc = bullets; sc > 0; sc = sc - 1)
		fireBullet (v_forward, 150, 8, IT_SHOTGUN);

	self.ammo_shells = self.ammo_shells - 1;
	self.attack_finished = time + 0.7;

	vector	org; // casing code
	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 4) + (v_forward * 15);
	SpawnCasing (org, v_forward, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2);
}

void W_Shotgun_Attack2 (void)
{

}

void W_Grenade_Explode (entity ignore)
{
	ImpactEffect (self, IT_GRENADE_LAUNCHER);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, 65, 35, 140, world, 400, IT_GRENADE_LAUNCHER);

	remove (self);
}

void W_Grenade_FuseExplode (void)
{
	W_Grenade_Explode (world);
}

void W_Grenade_Touch (void)
{
	// I decided to take this out to add more skill to using the grenade launcher, so the user always has to trigger it.
	// I increased the power of the grenade launcher because of this.
	//if (other.classname == "player" || other.classname == "corpse")
	//	W_Grenade_Explode (other);
	//else
	sound (self, CHAN_BODY, "weapons/grenade_bounce.wav", 1, ATTN_NORM);
}

void W_Grenade_Damage (vector hitloc, float damage, entity inflictor, entity attacker, float deathtype)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Grenade_FuseExplode();
}

void W_Grenade_Attack (void)
{
	entity	gren;

	sound (self, CHAN_WEAPON, "weapons/grenade_fire.wav", 1, ATTN_NORM);

	self.punchangle_x = -4;

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";

	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;

	gren.takedamage = DAMAGE_YES;
	gren.damageforcescale = 4;
	gren.health = 10;
	gren.event_damage = W_Grenade_Damage;

	setmodel (gren, "models/grenademodel.md3");
	setsize (gren, '-6 -6 -3', '6 6 3');

	makevectors (self.v_angle);
	setorigin (gren, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	gren.velocity = v_forward * 900 + v_up * 200;
	gren.angles = vectoangles (gren.velocity);
	gren.avelocity = '150 1500 150';

	gren.touch = W_Grenade_Touch;
	gren.think = W_Grenade_FuseExplode;
	gren.nextthink = time + 5;

	self.attack_finished = time + 0.8;
	self.ammo_rockets = self.ammo_rockets - 1;
}

void W_Grenade_Attack2 (void)
{
	entity	proj;
	proj = findradius (self.origin, 50000);
	while (proj)
	{
		if (proj.classname == "grenade" && proj.owner == self)
		{
			proj.nextthink = time;
		}
		proj = proj.chain;
	}

	self.attack_finished = time;
}

void W_Electro_Touch (void)
{
	vector dir;
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 79);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, 0);		// SeienAbunae: groan... Useless clutter
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	WriteByte (MSG_BROADCAST, 155);
	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, 50, 10, 70, world, 50, IT_ELECTRO);
	sound (self, CHAN_IMPACT, "weapons/plasmahit.wav", 1, ATTN_NORM);
	remove (self);
}

void W_Electro_Attack (float postion)
{
	entity	proj;

	sound (self, CHAN_WEAPON, "weapons/electro_fire.wav", 1, ATTN_NORM);

	proj = spawn ();
	proj.owner = self;
	proj.classname = "spike";

	proj.movetype = MOVETYPE_FLY; 
	proj.solid = SOLID_BBOX;
	proj.effects = 1;
	
	makevectors (self.v_angle);

	vector org;
	org = self.origin + self.view_ofs + v_forward * 18 + v_right * 7 + v_up * -9;
	te_smallflash(org);

	setmodel (proj, "models/bullet.mdl");
	setsize (proj, '0 0 0', '0 0 0');
	if (postion == 0)
	setorigin (proj, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -14);
	if (postion == 1)
	setorigin (proj, self.origin + self.view_ofs + v_forward * 18 + v_right * 10 + v_up * -12);
	if (postion == 2)
	setorigin (proj, self.origin + self.view_ofs + v_forward * 18 + v_right * 15 + v_up * -14);

	proj.velocity = v_forward * 2500;
	proj.touch = W_Electro_Touch;
	proj.think = SUB_Remove;
	proj.nextthink = time + 9;

	proj.effects = proj.effects | EF_ADDITIVE;

	self.attack_finished = time + 0.4;
	self.ammo_cells = self.ammo_cells - 1;
}

void W_Plasma_Explode (entity ignore)
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 79);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, 0);		// SeienAbunae: groan... Useless clutter
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	WriteByte (MSG_BROADCAST, 155);

	te_customflash (self.origin, 5000, 10, '0 0 1');

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, 100, 50, 100, world, 50, IT_ELECTRO);
	sound (self, CHAN_IMPACT, "weapons/plasmahit.wav", 1, ATTN_NORM);

	remove (self);
}

void W_Plasma_FuseExplode (void)
{
	W_Plasma_Explode (world);
}

void W_Plasma_Touch (void)
{
	if (other.classname == "player" || other.classname == "corpse")
		W_Plasma_Explode (other);
	else
		sound (self, CHAN_BODY, "weapons/grenade_bounce.wav", 1, ATTN_NORM);
}

void W_Plasma_Damage (vector hitloc, float damage, entity inflictor, entity attacker, float deathtype)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Plasma_FuseExplode ();
}

void W_Electro_Attack2 (float postion)
{
	entity	Plasma;

	sound (self, CHAN_WEAPON, "weapons/electro_fire.wav", 1, ATTN_NORM);

	self.punchangle_x = -4;

	Plasma = spawn ();
	Plasma.owner = self;
	Plasma.classname = "grenade";
	Plasma.effects = 1;

	Plasma.movetype = MOVETYPE_BOUNCE;
	Plasma.solid = SOLID_BBOX;
	
	vector org;
	org = self.origin + self.view_ofs + v_forward * 18 + v_right * 7 + v_up * -9;
	te_smallflash(org);

	Plasma.takedamage = DAMAGE_YES;
	Plasma.damageforcescale = 4;
	Plasma.health = 5;
	Plasma.event_damage = W_Plasma_Damage;

	setmodel (Plasma, "models/bullet.mdl");
	setsize (Plasma, '-6 -6 -3', '6 6 3');

	makevectors (self.v_angle);

	if (postion == 0)
	setorigin (Plasma, self.origin + self.view_ofs + v_forward * 18 + v_right * 0 + v_up * -14);
	if (postion == 1)
	setorigin (Plasma, self.origin + self.view_ofs + v_forward * 18 + v_right * 10 + v_up * -12);
	if (postion == 2)
	setorigin (Plasma, self.origin + self.view_ofs + v_forward * 18 + v_right * 20 + v_up * -14);

	Plasma.velocity = v_forward * 900 + v_up * 200;
	Plasma.angles = vectoangles (Plasma.velocity);
	Plasma.avelocity = '150 1500 150';

	Plasma.touch = W_Plasma_Touch;
	Plasma.think = W_Plasma_FuseExplode;
	Plasma.nextthink = time + 2;

	Plasma.effects = Plasma.effects | EF_ADDITIVE;

	self.attack_finished = time + 1;
	self.ammo_cells = self.ammo_cells - 2;

}

void W_Crylink_Touch (void)
{
	vector dir;
	self.event_damage = SUB_Null;
	te_smallflash(self.origin);
	RadiusDamage (self, self.owner, 20, 0, 3, world, 50, IT_CRYLINK);
	remove (self);
}

void W_Crylink_Attack (void)
{
	vector	org;

	sound (self, CHAN_WEAPON, "weapons/crylink.wav", 1, ATTN_NORM);
	org = self.origin + self.view_ofs + v_forward * 18 + v_right * 7 + v_up * -9;
	makevectors (self.v_angle);

	FireRailgunBullet (org, 25, v_forward, IT_CRYLINK);

	traceline (org, self.origin + self.view_ofs + (v_forward * 4096), FALSE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 76);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	WriteCoord (MSG_BROADCAST, self.v_angle_x);
	WriteCoord (MSG_BROADCAST, self.v_angle_y);
	WriteCoord (MSG_BROADCAST, self.v_angle_z);

	te_gunshot (trace_endpos);

	self.ammo_cells = self.ammo_cells - 0.25;
	self.attack_finished = time + 0.165;
}

void W_Crylink_Attack2 (void)
{

	entity	proj;

	//sound (self, CHAN_WEAPON, "weapons/electro_fire.wav", 1, ATTN_NORM);

	proj = spawn ();
	proj.owner = self;
	proj.classname = "spike";

	proj.movetype = MOVETYPE_FLY; 
	proj.solid = SOLID_BBOX;
	
	makevectors (self.v_angle);

	setmodel (proj, "models/sprites/bubbles.spr");
	setsize (proj, '0 0 0', '0 0 0');
	setorigin (proj, self.origin + self.view_ofs + v_forward * 10 + v_right * 5 + v_up * -14);

	proj.velocity = v_forward * 1000;
	proj.velocity = proj.velocity + v_right * ( crandom() * 50 );
	proj.velocity = proj.velocity + v_up * ( crandom() * 50 );
	proj.touch = W_Crylink_Touch;
	proj.think = SUB_Remove;
	proj.nextthink = time + 9;

	proj.glow_color = 10;
	proj.glow_size = 30;

	self.attack_finished = time + 0.20;
	self.ammo_cells = self.ammo_cells - 0.2;
}

void W_Nex_Attack (void)
{
	vector	org;
	vector	dir;

	sound (self, CHAN_WEAPON, "weapons/nexfire.wav", 1, ATTN_NORM);
	//self.effects = EF_MUZZLEFLASH;
	self.punchangle_x = -4;

	makevectors (self.v_angle);

	org = self.origin + self.view_ofs + v_forward * 18 + v_right * 8 + v_up * -5;

	// FIXME: make it accurate!

	traceline (org, self.origin + self.view_ofs + (v_forward * 4096), FALSE, self);

	te_smallflash(org);

	FireRailgunBullet (org, 99, v_forward, IT_NEX);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 76);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	WriteCoord (MSG_BROADCAST, self.v_angle_x);
	WriteCoord (MSG_BROADCAST, self.v_angle_y);
	WriteCoord (MSG_BROADCAST, self.v_angle_z);

	te_plasmaburn (trace_endpos);

	dir = trace_plane_normal * 100;
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_FLAMEJET);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	WriteCoord (MSG_BROADCAST, dir_x);
	WriteCoord (MSG_BROADCAST, dir_y);
	WriteCoord (MSG_BROADCAST, dir_z);
	WriteByte (MSG_BROADCAST, 255);

	PointSound (trace_endpos, "weapons/neximpact.wav", 1, ATTN_NORM);

	self.attack_finished = time + 1;
	self.ammo_cells = self.ammo_cells - 1;
}

void W_Nex_Attack2 (void)
{

}

void() W_Drunkmissile = 
{
        self.velocity = ((self.velocity + ((v_right * 61.000) * crandom ())) + ((v_up * 61.000) * crandom ()));
        self.nextthink = time + 0.1;
        self.think = W_Drunkmissile;
};


void W_Hagar_Explode (void)
{
	ImpactEffect (self, IT_HAGAR);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, 20, 10, 50, world, 90, IT_HAGAR);

	remove (self);
}

void W_Hagar_Fireball (void)
{
	self.effects = self.effects | EF_FLAME;
}

void W_Hagar_Touch (void)
{
	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	W_Hagar_Explode ();
}

void W_Hagar_Damage (vector hitloc, float damage, entity inflictor, entity attacker, float deathtype)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Hagar_Explode();
}

void W_Hagar_Attack (void)
{
	entity	missile;
	vector	org;

	sound (self, CHAN_WEAPON, "weapons/hagar_fire.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 10;
	missile.event_damage = W_Hagar_Damage;

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/hagarmissile.mdl");
	setsize (missile, '0 0 0', '0 0 0');

	makevectors (self.v_angle);

	setorigin (missile, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	missile.velocity = v_forward * 2000;
	missile.velocity = missile.velocity + v_right * ( crandom() * 70 );
	missile.velocity = missile.velocity + v_up * ( crandom() * 30 );
	missile.angles = vectoangles (missile.velocity);
	setorigin (missile, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	missile.touch = W_Hagar_Touch;
	missile.think = W_Hagar_Explode;
	missile.nextthink = time + 10;

	self.attack_finished = time + 0.2;
	self.ammo_rockets = self.ammo_rockets - 0.25;
}

void W_Hagar_Attack2 (void)
{
	entity	missile;

	sound (self, CHAN_WEAPON, "weapons/hagar_fire.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.movetype = MOVETYPE_TOSS;
	missile.solid = SOLID_BBOX;

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 5;
	missile.event_damage = W_Hagar_Damage;

	setmodel (missile, "models/bullet.mdl");
	setsize (missile, '-6 -6 -3', '6 6 3');

	makevectors (self.v_angle);
	setorigin (missile, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	missile.velocity = v_forward * 1400 + v_up * 100;
	missile.angles = vectoangles (missile.velocity);
	missile.avelocity = '150 1500 150';

	missile.touch = W_Hagar_Touch;
	missile.think = W_Hagar_Fireball;
	missile.nextthink = time + 0.05;

	self.attack_finished = time + 0.2;
	self.ammo_rockets = self.ammo_rockets - 0.25;
}

void W_Hagar_Attack3 (void)
{
	entity	missile;
	vector	org;

	sound (self, CHAN_WEAPON, "weapons/hagar_fire.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 10;
	missile.event_damage = W_Hagar_Damage;

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/hagarmissile.mdl");
	setsize (missile, '0 0 0', '0 0 0');

	makevectors (self.v_angle);

	setorigin (missile, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	missile.velocity = v_forward * 1000;
	missile.angles = vectoangles (missile.velocity);
	setorigin (missile, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	missile.touch = W_Hagar_Touch;
	missile.think = W_Drunkmissile;
	missile.nextthink = time + 0.01;

	self.attack_finished = time + 0.2;
	self.ammo_rockets = self.ammo_rockets - 0.25;
}

void W_Rocket_Explode (entity ignore)
{
	ImpactEffect (self, IT_ROCKET_LAUNCHER);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, 130, 50, 170, ignore, 600, IT_ROCKET_LAUNCHER);

	remove (self);
}

void W_Rocket_Think (void)
{
	W_Rocket_Explode (world);
}

void W_Rocket_Touch (void)
{
	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}
	else
		W_Rocket_Explode (world);
}

void W_Rocket_Damage (vector hitloc, float damage, entity inflictor, entity attacker, float deathtype)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Rocket_Explode(world);
}

void W_Rocket_Attack (void)
{
	entity	missile;
	vector	org;

	sound (self, CHAN_WEAPON, "weapons/rocket_fire.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 10;
	missile.event_damage = W_Rocket_Damage;

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/rocketmissile.mdl");
	setsize (missile, '0 0 0', '0 0 0');

	makevectors (self.v_angle);

	org = self.origin + self.view_ofs + v_forward * 20 + v_right * 4 + v_up * -15;

	setorigin (missile, org);
	missile.velocity = v_forward * 1200;
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_Rocket_Touch ;
	missile.think = W_Rocket_Think;
	missile.nextthink = time + 9;

	self.attack_finished = time + 1.5;
	self.ammo_rockets = self.ammo_rockets - 1;

}

void W_Rocket_Attack2 (void)
{
	entity	proj;
	proj = findradius (self.origin, 50000);
	while (proj)
	{
		if (proj.classname == "missile" && proj.owner == self)
		{
			proj.nextthink = time;
		}
		proj = proj.chain;
	}

	self.attack_finished = time;
}


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

	if (self.weapon == IT_LASER)
		W_Laser_Attack ();
	else if (self.weapon == IT_UZI)
		W_Uzi_Attack ();
	else if (self.weapon == IT_SHOTGUN)
		W_Shotgun_Attack ();
	else if (self.weapon == IT_GRENADE_LAUNCHER)
		W_Grenade_Attack ();
	else if (self.weapon == IT_ELECTRO)
		{
		W_Electro_Attack (self.electrocount);
		self.electrocount = self.electrocount + 1;
		if (self.electrocount == 3)
			self.electrocount = 0;
		}
	else if (self.weapon == IT_CRYLINK)
		W_Crylink_Attack ();
	else if (self.weapon == IT_NEX)
		W_Nex_Attack ();
	else if (self.weapon == IT_HAGAR)
		W_Hagar_Attack ();
	else if (self.weapon == IT_ROCKET_LAUNCHER)
		W_Rocket_Attack ();

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

	if (self.weapon == IT_LASER)
		W_Laser_Attack2 ();
	else if (self.weapon == IT_UZI)
		W_Uzi_Attack2 ();
	else if (self.weapon == IT_SHOTGUN)
		W_Shotgun_Attack2 ();
	else if (self.weapon == IT_GRENADE_LAUNCHER)
		W_Grenade_Attack2 ();
	else if (self.weapon == IT_ELECTRO) {
		W_Electro_Attack2 (self.electrocount);
		self.electrocount = self.electrocount + 1;
		if (self.electrocount == 3)
			self.electrocount = 0;
		}
	else if (self.weapon == IT_CRYLINK)
		W_Crylink_Attack2 ();
	else if (self.weapon == IT_NEX)
		W_Nex_Attack2 ();
	else if (self.weapon == IT_HAGAR)
		W_Hagar_Attack2 ();
	else if (self.weapon == IT_ROCKET_LAUNCHER)
		W_Rocket_Attack2 ();

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

	if (self.weapon == IT_HAGAR)
		W_Hagar_Attack3 ();

	W_UpdateAmmo ();
}