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
		self.weaponmodel = "models/weapons/w_lazer.zym";
	else if (self.weapon == IT_UZI)
		self.weaponmodel = "models/weapons/w_uzi.md3";
	else if (self.weapon == IT_SHOTGUN)
		self.weaponmodel = "models/weapons/w_shotgun.md3";
	else if (self.weapon == IT_GRENADE_LAUNCHER)
		self.weaponmodel = "models/weapons/w_gl.md3";
	else if (self.weapon == IT_ELECTRO)
		self.weaponmodel = "models/weapons/w_electro.md3";
	else if (self.weapon == IT_CRYLINK)
		self.weaponmodel = "models/weapons/w_crylink.md3";
	else if (self.weapon == IT_NEX)
		self.weaponmodel = "models/weapons/w_nex.md3";
	else if (self.weapon == IT_HAGAR)
		self.weaponmodel = "models/weapons/w_hagar.md3";
	else if (self.weapon == IT_ROCKET_LAUNCHER)
		self.weaponmodel = "models/weapons/w_rl.md3";
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

	float	loops;

// AK Let it test only every possible weapon then kick it out of the loop
	while (loops <= 9)
	{
		noammo = FALSE;
		
// AK Sombody messed up the sequence (please undo if it was extra made so)
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
		
		loops++;
	}
}

void W_PreviousWeapon (void)
{
	float	noammo;

	float 	loops;
	
// AK the same as above
	while (loops <= 9)
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
		
		loops++;
	}
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

void(vector src, float bdamage, vector dir) FireRailgunBullet =
{
	local   vector  v, lastpos;		
	local   entity  saveself, last;

	if (bdamage < 1)
		return;

	last = self;
	lastpos = src;
	
	while (bdamage > 0)
	{		
		traceline (lastpos + dir * 2, lastpos + dir*8192, FALSE, last);
		last = trace_ent;
		lastpos = trace_endpos;
		if (trace_fraction != 1.0)		
			{
				if (pointcontents(trace_endpos - dir*4) == CONTENT_SKY)
					return;	

				if (trace_ent.takedamage)
				{
					Damage (self, trace_endpos, trace_ent, 0, bdamage);
				}		
			}
		if (last.solid == SOLID_BSP)			
			bdamage = 0;	
	}
};

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
			te_spike (trace_endpos);
		else if (trace_ent.classname == "player" || trace_ent.classname == "corpse" || trace_ent.classname == "gib")
		{
			Damage (self, trace_endpos, trace_ent, 0, damage);
			if (random () < 0.5)
				sound (trace_ent, CHAN_IMPACT, "misc/BodyImpact1.wav", 1, ATTN_NORM);
			else
				sound (trace_ent, CHAN_IMPACT, "misc/BodyImpact2.wav", 1, ATTN_NORM);
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
	
	sound (self, CHAN_BODY, "weapons/NexImpact.wav", 1, ATTN_NORM);
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 79);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, dir_x);
	WriteCoord (MSG_BROADCAST, dir_y);
	WriteCoord (MSG_BROADCAST, dir_z);
	WriteByte (MSG_BROADCAST, 155);

	remove (self);
}

void W_Laser_Attack (void)
{
	entity	missile;
	
	sound (self, CHAN_WEAPON, "weapons/Electro_fire.wav", 1, ATTN_NORM);
	
	missile = spawn ();
	missile.owner = self;
	missile.classname = "laser";
	
	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	
	setmodel (missile, "models/bullet.mdl");
	setsize (missile, '-4 -4 -4', '4 4 4');
	setorigin (missile, self.origin + self.view_ofs);

	makevectors (self.v_angle);
	missile.velocity = v_forward * 2000;
	missile.angles = vectoangles (missile.velocity);
	missile.glow_color = 250; // 244, 250
	missile.glow_size = 1020;
	missile.glow_trail = 1;	// ??? 256
	missile.touch = W_Laser_Touch;
	missile.think = SUB_Remove;
	missile.nextthink = time + 2;
	
	self.punchangle_x = random () - 0.5;
	self.punchangle_y = random () - 0.5;
	self.punchangle_z = random () - 0.5;
	
	self.attack_finished = time + 0.3;
}

void W_Laser_Attack2 (void)
{
	
}

void W_Uzi_Attack (void)
{
	sound (self, CHAN_WEAPON, "weapons/Uzi_Fire.wav", 1, ATTN_NORM);

	fireBullet (v_forward, 300, 8, IT_SHOTGUN);	

	self.punchangle_x = random () * -2;
	self.punchangle_y = crandom () * 0.5;
	self.punchangle_z = crandom () * 0.5;
	
	self.attack_finished = time + 0.075;
	self.ammo_nails = self.ammo_nails - 1;

	vector	org; // casing code
	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 1) + (v_forward * 20);
	SpawnCasing (org, v_forward, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2);

	self.effects = self.effects | EF_MUZZLEFLASH;
}

void W_Uzi_Attack2 (void)
{
	sound (self, CHAN_WEAPON, "weapons/Uzi_Fire.wav", 1, ATTN_NORM);
	
	fireBullet (v_forward, 3, 10, IT_SHOTGUN);
	
	self.punchangle = '-0.5 0 0';
	
	self.attack_finished = time + 0.3;
	self.ammo_nails = self.ammo_nails - 1;

	vector	org;
	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 1) + (v_forward * 20);
	SpawnCasing (org, v_forward, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2);
}

void W_Shotgun_Attack (void)
{
	sound (self, CHAN_WEAPON, "weapons/Shotgun_fire.wav", 1, ATTN_NORM);

	float	sc;
	sc = 7;
	while (sc > 0)
	{
		fireBullet (v_forward, 300, 8, IT_SHOTGUN);
		sc = sc - 1;
	}

	self.punchangle_x = -2;

	self.ammo_shells = self.ammo_shells - 1;
	self.attack_finished = time + 0.8;

	vector	org; // casing code
	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 4) + (v_forward * 15);
	SpawnCasing (org, v_forward, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 1);
}

void W_Shotgun_Attack2 (void)
{

}

void W_Grenade_Explode (entity ignore)
{
	ImpactEffect (self, IT_GRENADE_LAUNCHER);

	RadiusDamage (self.owner, self, 0, 100, world);

	remove (self);
}

void W_Grenade_FuseExplode (void)
{
	W_Grenade_Explode (world);
}

void W_Grenade_Touch (void)
{
	if (other.classname == "player" || other.classname == "corpse")
	{
		Damage (self.owner, self.origin, other, 0, 100);
		W_Grenade_Explode (other);
	}
	else
		sound (self, CHAN_BODY, "weapons/Grenade_Bounce.wav", 1, ATTN_NORM);
}

void W_Grenade_Attack (void)
{
	entity	gren;
	
	sound (self, CHAN_WEAPON, "weapons/Grenade_fire.wav", 1, ATTN_NORM);
	
	self.punchangle_x = -4;
	
	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	
	gren.takedamage = DAMAGE_YES;
	gren.health = 1;
	gren.event_hurt = W_Grenade_Explode;

	setmodel (gren, "models/grenademodel.md3");
	setsize (gren, '0 0 0', '0 0 0');
	
	makevectors (self.v_angle);
	setorigin (gren, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	gren.velocity = v_forward * 900 + v_up * 200;
	gren.angles = vectoangles (gren.velocity);
	gren.avelocity = '150 1500 150';
	
	gren.touch = W_Grenade_Touch;
	gren.think = W_Grenade_FuseExplode;
	gren.nextthink = time + 2;
	
	self.attack_finished = time + 1;
	self.ammo_rockets = self.ammo_rockets - 1;
}

void W_Grenade_Attack2 (void)
{
	entity	gren;
	
	sound (self, CHAN_WEAPON, "weapons/Grenade_fire.wav", 1, ATTN_NORM);
	
	self.punchangle_x = -4;
	
	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	
	gren.movetype = MOVETYPE_TOSS;
	gren.solid = SOLID_BBOX;
	
	gren.takedamage = DAMAGE_YES;
	gren.health = 1;
	gren.event_hurt = W_Grenade_Explode;
	
	setmodel (gren, "models/grenademodel.md3");
	setsize (gren, '0 0 0', '0 0 0');
	
	makevectors (self.v_angle);
	setorigin (gren, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);
	
	gren.velocity = v_forward * 1400 + v_up * 100;
	gren.angles = vectoangles (gren.velocity);
	gren.avelocity = '150 1500 150';
		
	gren.touch = W_Grenade_Explode;
	gren.think = W_Grenade_FuseExplode;
	gren.nextthink = time + 5;
	
	self.attack_finished = time + 1;
	self.ammo_rockets = self.ammo_rockets - 1;
}

void W_Electro_Touch (void)
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
	
	if (other.classname == "player" || other.classname == "corpse" || other.classname == "gib")
	{
		Damage (self.owner, self.origin, other, 0, 40);
		// SeienAbunae: the impact sound doesn't seem to play when the victim dies instead of being hurt
		// Maybe it's not that big of a deal
		if (random () < 0.5)
			sound (other, CHAN_IMPACT, "misc/BodyImpact1.wav", 1, ATTN_NORM);
		else
			sound (other, CHAN_IMPACT, "misc/BodyImpact2.wav", 1, ATTN_NORM);
	}
	
	remove (self);
}

void W_Electro_Attack (void)
{
	entity	proj;
	
	sound (self, CHAN_WEAPON, "weapons/Electro_fire.wav", 1, ATTN_NORM);
	
	proj = spawn ();
	proj.owner = self;
	proj.classname = "elec";
	
	proj.movetype = MOVETYPE_FLY;
	proj.solid = SOLID_BBOX;
	proj.effects = 1;
	
	makevectors (self.v_angle);
	
	setmodel (proj, "models/bullet.mdl");
	setsize (proj, '0 0 0', '0 0 0');
	setorigin (proj, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);
	
	proj.velocity = v_forward * 3000;
	proj.touch = W_Electro_Touch;
	proj.think = SUB_Remove;
	proj.nextthink = time + 3;
	
	self.attack_finished = time + 0.6;
	self.ammo_cells = self.ammo_cells - 1;
}

void W_Plasma_Touch (void)
{
	if (other.classname == "player" || other.classname == "corpse" || other.classname == "gib")
		Damage (self.owner, self.origin, other, 0, 15);

	ImpactEffect (self, IT_ELECTRO);

	remove (self);
}

void W_Electro_Attack2 (void)
{
	entity	proj;
	
	sound (self, CHAN_WEAPON, "weapons/LazerGun_Fire.wav", 1, ATTN_NORM);
	
	proj = spawn ();
	proj.owner = self;
	proj.classname = "plasma";
	
	proj.movetype = MOVETYPE_FLY;
	proj.solid = SOLID_BBOX;
	proj.effects = EF_DIMLIGHT;
	
	makevectors (self.v_angle);
	
	setmodel (proj, "models/sprites/plasmashot.spr32");
	setsize (proj, '0 0 0', '0 0 0');
	setorigin (proj, self.origin + self.view_ofs + v_forward * 5 + v_right * 5 + v_up * -12);
	
	proj.velocity = v_forward * 5000;
	proj.touch = W_Plasma_Touch;
	proj.think = SUB_Remove;
	proj.nextthink = time + 1.5;

	self.attack_finished = time + 0.175;
	self.ammo_cells = self.ammo_cells - 1;
}

void W_Crylink_Attack (void)
{
	vector	org;
	
	sound (self, CHAN_WEAPON, "weapons/crylink.wav", 1, ATTN_NORM);
	org = self.origin + self.view_ofs + v_forward * 18 + v_right * 7 + v_up * -9;
	makevectors (self.v_angle);

	// FIXME: make it accurate!

	FireRailgunBullet (org, 25, v_forward);	

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

	te_spike (trace_endpos);

	self.ammo_cells = self.ammo_cells - 0.25;
	self.attack_finished = time + 0.165;
}

void W_Crylink_Attack2 (void)
{
	vector	org;
	vector	dir;
	
	makevectors (self.v_angle);

	org = self.origin + self.view_ofs + v_forward * 19 + v_right * 5 + v_up * -7;
	
	traceline (org, self.origin + self.view_ofs + v_forward * 4096 + v_right * (random () * 100 - 50) + v_up * (random () * 100 - 50), FALSE, self);

	Damage (self, trace_endpos, trace_ent, 0, 20);	
	
	te_lightning1 (self, org, trace_endpos);
	
	self.ammo_cells = self.ammo_cells - 0.25;
	self.attack_finished = time + 0.075;
}

void W_Nex_Attack (void)
{
	vector	org;
	vector	dir;
	
	sound (self, CHAN_WEAPON, "weapons/NexFire.wav", 1, ATTN_NORM);
	//self.effects = EF_MUZZLEFLASH;
	self.punchangle_x = -4;
	
	makevectors (self.v_angle);

	org = self.origin + self.view_ofs + v_forward * 18 + v_right * 8 + v_up * -5;
	
	// FIXME: iterate to hit multiple guys
	// FIXME: make it accurate!

	traceline (org, self.origin + self.view_ofs + (v_forward * 4096), FALSE, self);

	FireRailgunBullet (org, 90, v_forward);	

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
	
	PointSound (trace_endpos, "weapons/NexImpact.wav", 1, ATTN_NORM);
	
	self.attack_finished = time + 1;
	self.ammo_cells = self.ammo_cells - 1;
}

void W_Nex_Attack2 (void)
{

}

void W_Hagar_Explode (void)
{
	ImpactEffect (self, IT_HAGAR);

	RadiusDamage (self.owner, self, 0, 100, world);

	remove (self);
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

void W_Hagar_Attack (void)
{
	entity	missile;
	vector	org;
	
	sound (self, CHAN_WEAPON, "weapons/Hagar_Fire.wav", 1, ATTN_NORM);
	
	missile = spawn ();
	missile.owner = self;
	missile.classname = "rocket";
	
	missile.takedamage = DAMAGE_YES;
	missile.health = 1;
	missile.event_hurt = W_Hagar_Explode;
	
	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/hagarmissile.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	
	makevectors (self.v_angle);
	
	org = self.origin + self.view_ofs + v_forward * 20 + v_right * 4 + v_up * -15;
	
	setorigin (missile, org);
	missile.velocity = v_forward * 2000;
	missile.angles = vectoangles (missile.velocity);
	
	missile.touch = W_Hagar_Touch;
	missile.think = SUB_Remove;
	missile.nextthink = time + 1;
	
	self.attack_finished = time + 0.2;
	self.ammo_rockets = self.ammo_rockets - 0.25;
}

void W_Hagar_Attack2 (void)
{
	entity	missile;
	vector	org;
	
	sound (self, CHAN_WEAPON, "weapons/Hagar_Fire.wav", 1, ATTN_NORM);
	
	missile = spawn ();
	missile.owner = self;
	missile.classname = "rocket";
	
	missile.takedamage = DAMAGE_YES;
	missile.health = 1;
	missile.event_hurt = W_Hagar_Explode;
	
	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/hagarmissile.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	
	makevectors (self.v_angle);
	
	org = self.origin + self.view_ofs + v_forward * 20 + v_right * 4 + v_up * -15;
	
	setorigin (missile, org);
	missile.velocity = v_forward * 15000;
	missile.angles = vectoangles (missile.velocity);
	
	missile.touch = W_Hagar_Touch;
	missile.think = SUB_Remove;
	missile.nextthink = time + 1;
	
	self.attack_finished = time + 0.7;
	self.ammo_rockets = self.ammo_rockets - 0.25;
}

void W_Rocket_Explode (entity ignore)
{
	ImpactEffect (self, IT_ROCKET_LAUNCHER);

	RadiusDamage (self.owner, self, 0, 100, ignore);

	remove (self);
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
	else if (other.classname == "player" || other.classname == "corpse")
	{
		Damage (self.owner, self.origin, other, 0, 100);
		W_Rocket_Explode (other);
	}
	else
		W_Rocket_Explode (world);
}

void W_Rocket_Attack (void)
{
	entity	missile;
	vector	org;
	
	sound (self, CHAN_WEAPON, "weapons/Rocket_Fire.wav", 1, ATTN_NORM);
	
	missile = spawn ();
	missile.owner = self;
	missile.classname = "rocket";
	
	missile.takedamage = DAMAGE_YES;
	missile.health = 1;
	missile.event_hurt = W_Rocket_Explode;
	
	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/rocketmissile.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	
	makevectors (self.v_angle);
	
	org = self.origin + self.view_ofs + v_forward * 20 + v_right * 4 + v_up * -15;
	
	setorigin (missile, org);
	missile.velocity = v_forward * 2500;
	missile.angles = vectoangles (missile.velocity);
	
	missile.touch = W_Rocket_Touch;
	missile.think = SUB_Remove;
	missile.nextthink = time + 1;
	
	self.attack_finished = time + 0.5;
	self.ammo_rockets = self.ammo_rockets - 1;
	
}

void W_Rocket_Attack2 (void)
{

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
		W_Electro_Attack ();
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
	else if (self.weapon == IT_ELECTRO)
		W_Electro_Attack2 ();
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