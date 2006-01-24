/*
===========================================================================

  CLIENT WEAPONSYSTEM CODE
  Bring back W_Weaponframe

===========================================================================
*/

void LaserTarget_Think()
{
	entity e;
	vector offset;
	float uselaser;
	uselaser = 0;

	// list of weapons that will use the laser, and the options that enable it
	if(self.owner.laser_on && self.owner.weapon == WEP_ROCKET_LAUNCHER && cvar("g_homing_missile"))
		uselaser = 1;
	// example
	//if(self.owner.weapon == WEP_ELECTRO && cvar("g_homing_electro"))
	//	uselaser = 1;



	// if a laser-enabled weapon isn't selected, delete any existing laser and quit
	if(!uselaser)
	{
		// rocket launcher isn't selected, so no laser target.
		if(self.lasertarget != world)
		{
			remove(self.lasertarget);
			self.lasertarget = world;
		}
		return;
	}

	if(!self.lasertarget)
	{
		// we don't have a lasertarget entity, so spawn one
		//bprint("create laser target\n");
		e = self.lasertarget = spawn();
		e.owner = self.owner;			// Its owner is my owner
		e.classname = "laser_target";
		e.movetype = MOVETYPE_NOCLIP;	// don't touch things
		setmodel(e, "models/laser_dot.mdl");	// what it looks like
		e.scale = 1.25;				// make it larger
		e.alpha = 0.25;				// transparency
		e.colormod = '255 0 0' * (1/255) * 8;	// change colors
		e.effects = EF_FULLBRIGHT;
		// make it dynamically glow
		// you should avoid over-using this, as it can slow down the player's computer.
		e.glow_color = 251; // red color
		e.glow_size = 12;
	}
	else
		e = self.lasertarget;

	// move the laser dot to where the player is looking

	makevectors(self.owner.v_angle); // set v_forward etc to the direction the player is looking
	offset = '0 0 26' + v_right*3;
	traceline(self.owner.origin + offset, self.owner.origin + offset + v_forward * 2048, FALSE, self); // trace forward until you hit something, like a player or wall
	setorigin(e, trace_endpos + v_forward*8); // move me to where the traceline ended
	if(trace_plane_normal != '0 0 0')
		e.angles = vectoangles(trace_plane_normal);
	else
		e.angles = vectoangles(v_forward);
}

void() CL_Weaponentity_Think =
{
	self.nextthink = time;
	if (self.owner.weaponentity != self)
	{
		remove(self);
		return;
	}
	self.effects = self.owner.effects;
	self.alpha = self.owner.alpha;

	// create or update the lasertarget entity
	LaserTarget_Think();
};

void() CL_ExteriorWeaponentity_Think =
{
	self.nextthink = time;
	if (self.owner.exteriorweaponentity != self)
	{
		remove(self);
		return;
	}
	if (self.cnt != self.owner.weaponentity.modelindex || self.dmg != self.owner.modelindex || self.deadflag != self.owner.deadflag)
	{
		self.cnt = self.owner.weaponentity.modelindex;
		self.dmg = self.owner.modelindex;
		self.deadflag = self.owner.deadflag;
		if (self.owner.deadflag) return;
		else if (self.owner.weapon == WEP_LASER) setmodel(self, "models/weapons/v_laser.md3");
		else if (self.owner.weapon == WEP_SHOTGUN) setmodel(self, "models/weapons/v_shotgun.md3");
		else if (self.owner.weapon == WEP_UZI) setmodel(self, "models/weapons/v_uzi.md3");
		else if (self.owner.weapon == WEP_GRENADE_LAUNCHER) setmodel(self, "models/weapons/v_gl.md3");
		else if (self.owner.weapon == WEP_ELECTRO) setmodel(self, "models/weapons/v_electro.md3");
		else if (self.owner.weapon == WEP_CRYLINK) setmodel(self, "models/weapons/v_crylink.md3");
		else if (self.owner.weapon == WEP_NEX) setmodel(self, "models/weapons/v_nex.md3");
		else if (self.owner.weapon == WEP_HAGAR) setmodel(self, "models/weapons/v_hagar.md3");
		else if (self.owner.weapon == WEP_ROCKET_LAUNCHER) setmodel(self, "models/weapons/v_rl.md3");
		setattachment(self, self.owner, "bip01 r hand");
		// if that didn't find a tag, hide the exterior weapon model
		if (!self.tag_index)
			self.model = "";
	}
	self.effects = self.owner.weaponentity.effects;
};

// spawning weaponentity for client
void() CL_SpawnWeaponentity =
{
	if (self.weaponentity)
	{
		w_clear();
		return;
	}
	self.weaponentity = spawn();
	self.weaponentity.solid = SOLID_NOT;
	self.weaponentity.owner = self;
	self.weaponentity.weaponentity = self.weaponentity;
	setmodel(self.weaponentity, "");
	self.weaponentity.origin = '0 0 0';
	self.weaponentity.angles = '0 0 0';
	self.weaponentity.viewmodelforclient = self;
	self.weaponentity.flags = 0;
	self.weaponentity.think = CL_Weaponentity_Think;
	self.weaponentity.nextthink = time;

	self.exteriorweaponentity = spawn();
	self.exteriorweaponentity.solid = SOLID_NOT;
	self.exteriorweaponentity.exteriorweaponentity = self.exteriorweaponentity;
	self.exteriorweaponentity.owner = self;
	self.exteriorweaponentity.origin = '0 0 0';
	self.exteriorweaponentity.angles = '0 0 0';
	self.exteriorweaponentity.think = CL_ExteriorWeaponentity_Think;
	self.exteriorweaponentity.nextthink = time;
};

// convertion from index (= impulse) to flag in .items
float(float index) weapon_translateindextoflag =
{
	if (index == WEP_LASER)
		return IT_LASER;
	else if (index == WEP_SHOTGUN)
		return IT_SHOTGUN;
	else if (index == WEP_UZI)
		return IT_UZI;
	else if (index == WEP_GRENADE_LAUNCHER)
		return IT_GRENADE_LAUNCHER;
	else if (index == WEP_ELECTRO)
		return IT_ELECTRO;
	else if (index == WEP_CRYLINK)
		return IT_CRYLINK;
	else if (index == WEP_NEX)
		return IT_NEX;
	else if (index == WEP_HAGAR)
		return IT_HAGAR;
	else if (index == WEP_ROCKET_LAUNCHER)
		return IT_ROCKET_LAUNCHER;
	else if (index == WEP_LASER)
		return IT_LASER;
	else
		return 0;
};

float(entity cl, float wpn, float andammo) client_hasweapon =
{
	local float itemcode;
	local entity oldself;

	weapon_hasammo = TRUE;
	if (wpn < WEP_FIRST || wpn > WEP_LAST)
		return FALSE;
	itemcode = weapon_translateindextoflag(wpn);
	if (cl.items & itemcode)
	{
		if (andammo)
		{
			oldself = self;
			self = cl;
			weapon_action(wpn, WR_CHECKAMMO);
			self = oldself;
			if (weapon_hasammo)
				return TRUE;
			return FALSE;
		}
		return TRUE;
	}
	return FALSE;
};

// Weapon subs
void() w_clear =
{
	weapon_action(self.weapon, WR_CLEAR);
	if (self.weapon != -1)
		self.weapon = 0;
	if (self.weaponentity)
	{
		self.weaponentity.state = WS_CLEAR;
		setmodel(self.weaponentity, "");
		self.weaponentity.effects = 0;
	}
};

void() w_ready =
{
	self.weaponentity.state = WS_READY;
	weapon_action(self.weapon, WR_IDLE);
};

// FIXME: add qw-style client-custom weaponrating (cl_weaponrating)?
float(entity e) w_getbestweapon
{// add new weapons here
	if (client_hasweapon(e, WEP_ROCKET_LAUNCHER, TRUE))
		return WEP_ROCKET_LAUNCHER;
	else if (client_hasweapon(e, WEP_NEX, TRUE))
		return WEP_NEX;
	else if (client_hasweapon(e, WEP_HAGAR, TRUE))
		return WEP_HAGAR;
	else if (client_hasweapon(e, WEP_GRENADE_LAUNCHER, TRUE))
		return WEP_GRENADE_LAUNCHER;
	else if (client_hasweapon(e, WEP_ELECTRO, TRUE))
		return WEP_ELECTRO;
	else if (client_hasweapon(e, WEP_CRYLINK, TRUE))
		return WEP_CRYLINK;
	else if (client_hasweapon(e, WEP_UZI, TRUE))
		return WEP_UZI;
	else if (client_hasweapon(e, WEP_SHOTGUN, TRUE))
		return WEP_SHOTGUN;
	else if (client_hasweapon(e, WEP_LASER, FALSE))
		return WEP_LASER;
	else
		return 0;
};

// Setup weapon for client (after this raise frame will be launched)
void(float windex, string wmodel, float hudammo) weapon_setup =
{
	local string weaponmdl;

	self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
	self.items = self.items | hudammo;

	self.weapon = windex;

	if (wmodel != "")
	{
		weaponmdl = strzone(strcat("models/weapons/", wmodel));
		setmodel(self.weaponentity, weaponmdl);
	}
	// VorteX: update visible weapon
	// CL_ViswepUpdate();
};

// shot direction
float WEAPON_MAXRELX = 14; // if more, shot can be spawned after wall surface (in empty worldspace) or inside other entity if client stands close to it
void(float x, float y, float z) weapon_shotdir =
{
	makevectors(self.v_angle);
	self.shotorg  = self.origin + self.view_ofs + v_forward*bound(0, x, WEAPON_MAXRELX) + v_right*(y + self.weaponentity.view_ofs_y) + v_up*z;
	self.shotdir = aim(self, 1000);
};

// perform weapon to attack (weaponstate and attack_finished check is here)
void(float() checkfunc1, float() checkfunc2, void() firefunc, float atktime) weapon_prepareattack =
{
	if (!checkfunc1())
	{
		if (!checkfunc2())
			self.switchweapon = w_getbestweapon(self);
		return;
	}
	// Don't do shot if previos attack  not finished
		if (time < self.attack_finished)
			return;
	// Can't do shot if changing weapon
		if (self.weaponentity.state != WS_READY)
			return;

	self.attack_finished = time + atktime;
	firefunc();
};

// perform weapon attack
void(float() checkfunc1, float() checkfunc2, void() firefunc) weapon_doattack
{
	if (!checkfunc1())
	{
		if (!checkfunc2())
			self.switchweapon = w_getbestweapon(self);
		return;
	}
	self.weaponentity.state = WS_INUSE;
	firefunc();
	weapon_action(self.weapon, WR_UPDATECOUNTS); // update ammo now
};

void(entity ent, float recoil) weapon_recoil =
{
	ent.punchangle = (randomvec() + '-1 0 0')*recoil;
	ent.punchangle_z = 0; // don't want roll
	if (recoil > 3) // push back if large recoil
		ent.velocity = ent.velocity - normalize(ent.shotdir)*recoil*25;
};

void(float fr, float t, void() func) weapon_thinkf =
{
	if (fr >= 0)
	{
		if (self.weaponentity != world)
			self.weaponentity.frame = fr;
	}

	if(cvar("g_runematch"))
	{
		if(self.runes & RUNE_SPEED)
		{
			if(self.runes & CURSE_SLOW)
				t = t * cvar("g_balance_rune_speed_combo_atkrate");
			else
				t = t * cvar("g_balance_rune_speed_atkrate");
		}
		else if(self.runes & CURSE_SLOW)
		{
			t = t * cvar("g_balance_curse_slow_atkrate");
		}
	}

	// VorteX: haste can be added here
	self.weapon_nextthink = time + t;
	self.weapon_think = func;
};

void(float spd, vector org) weapon_boblayer1 =
{
	// VorteX: haste can be added here
	self.weaponentity.pos1 =org;
	self.weaponentity.lip = spd;
};
