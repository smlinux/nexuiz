/*
===========================================================================

  CLIENT WEAPONSYSTEM CODE
  Bring back W_Weaponframe

===========================================================================
*/

void() CL_Weaponentity_Think =
{
	self.nextthink = time;
	if (self.owner.weaponentity != self)
	{
		remove(self);
		return;
	}
	self.effects = self.owner.effects;
	if(!(self.class == CLASS_SPY && self.special_active))
		self.alpha = self.owner.alpha;
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
		if (self.owner.deadflag) self.model = "";
		else if (self.owner.wpn == WEP_LASER) setmodel(self, "models/weapons/v_laser.md3");
		else if (self.owner.wpn == WEP_SHOTGUN) setmodel(self, "models/weapons/v_shotgun.md3");
		else if (self.owner.wpn == WEP_UZI) setmodel(self, "models/weapons/v_uzi.md3");
		else if (self.owner.wpn == WEP_GRENADE_LAUNCHER) setmodel(self, "models/weapons/v_gl.md3");
		else if (self.owner.wpn == WEP_ELECTRO) setmodel(self, "models/weapons/v_electro.md3");
		else if (self.owner.wpn == WEP_CRYLINK) setmodel(self, "models/weapons/v_crylink.md3");
		else if (self.owner.wpn == WEP_NEX) setmodel(self, "models/weapons/v_nex.md3");
		else if (self.owner.wpn == WEP_HAGAR) setmodel(self, "models/weapons/v_hagar.md3");
		else if (self.owner.wpn == WEP_ROCKET_LAUNCHER) setmodel(self, "models/weapons/v_rl.md3");
		else if (self.owner.wpn == WEP_BOMBLETTS) setmodel(self, "models/weapons/v_bombletts.md3");
		else if (self.owner.wpn == WEP_ROCKET_INCENDIARY) setmodel(self, "models/weapons/v_rli.md3");
		else if (self.owner.wpn == WEP_HOTBOMBS) setmodel(self, "models/weapons/v_hotbombs.md3");
		else if (self.owner.wpn == WEP_GRAPPLE) setmodel(self, "models/weapons/v_grapple.md3");
		else if (self.owner.wpn == WEP_NAMEK) setmodel(self, "models/weapons/v_namek.md3");
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
	if (index == WEP1)
		return IT_WEP1;
	else if (index == WEP2)
		return IT_WEP2;
	else if (index == WEP3)
		return IT_WEP3;
	else if (index == WEP4)
		return IT_WEP4;
	else if (index == WEP5)
		return IT_WEP5;
	return IT_WEP1;
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
	if(e.class == CLASS_SCOUT)
	{
		if (client_hasweapon(e, WEP5, TRUE))
			return WEP5;
		else if (client_hasweapon(e, WEP3, TRUE))
			return WEP3;
		else if (client_hasweapon(e, WEP2, TRUE))
			return WEP2;
		weapon_hasammo = TRUE;
		return WEP1;
	}
	if(e.class == CLASS_SPY)
	{
		if (client_hasweapon(e, WEP5, TRUE))
			return WEP5;
		else if (client_hasweapon(e, WEP2, TRUE))
			return WEP2;
		weapon_hasammo = TRUE;
		return WEP1;
	}
	if(e.class == CLASS_SOLDIER)
	{
		if (client_hasweapon(e, WEP5, TRUE))
			return WEP5;
		else if (client_hasweapon(e, WEP4, TRUE))
			return WEP4;
		else if (client_hasweapon(e, WEP3, TRUE))
			return WEP3;
		else if (client_hasweapon(e, WEP2, TRUE))
			return WEP2;
		weapon_hasammo = TRUE;
		return WEP1;
	}
	if(e.class == CLASS_PYRO)
	{
		if (client_hasweapon(e, WEP5, TRUE))
			return WEP5;
		else if (client_hasweapon(e, WEP3, TRUE))
			return WEP3;
		else if (client_hasweapon(e, WEP2, TRUE))
			return WEP2;
		else if (client_hasweapon(e, WEP4, TRUE))
			return WEP4;
		weapon_hasammo = TRUE;
		return WEP1;
	}
	if(e.class == CLASS_MEDIC)
	{
		if (client_hasweapon(e, WEP5, TRUE))
			return WEP5;
		else if (client_hasweapon(e, WEP4, TRUE))
			return WEP4;
		else if (client_hasweapon(e, WEP3, TRUE))
			return WEP3;
		else if (client_hasweapon(e, WEP2, TRUE))
			return WEP2;
		weapon_hasammo = TRUE;
		return WEP1;
	}
	if(e.class == CLASS_ENGINEER)
	{
		if (client_hasweapon(e, WEP5, TRUE))
			return WEP5;
		else if (client_hasweapon(e, WEP4, TRUE))
			return WEP4;
		else if (client_hasweapon(e, WEP3, TRUE))
			return WEP3;
		else if (client_hasweapon(e, WEP2, TRUE))
			return WEP2;
		weapon_hasammo = TRUE;
		return WEP1;
	}
	weapon_hasammo = TRUE;
	return WEP1;
};

// Setup weapon for client (after this raise frame will be launched)
void(float new_wep, string wmodel, float hudammo) weapon_setup =
{
	local string weaponmdl;

	self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
	self.items = self.items | hudammo;

	self.weapon = self.switchweapon;
	//self.weapon = weapon_translateindextoflag(new_wep);
	self.wpn = new_wep;

	if (wmodel != "")
	{
		weaponmdl = strzone(strcat("models/weapons/", wmodel));
		setmodel(self.weaponentity, weaponmdl);
	}
	// VorteX: update visible weapon
	// CL_ViswepUpdate();
};

/*void(float new_wep, string wmodel, float hudammo, void spfunciton()) weapon_setup_special =
{
	weapon_setup(new_wep, wmodel, hudammo);
	spfunction();
}*/

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
	// fixme: does spy need to decloak here?
	//if(self.class == CLASS_SPY)
	//{
	//	SpyDecloak();
	//}
	// Change to best weapon if failed
	if ((cvar("g_instagib") == 0) && (cvar("g_rocketarena") == 0))
	{
		if (!checkfunc1())
		{
			if (!checkfunc2())
				self.switchweapon = w_getbestweapon(self);
			return;
		}
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

void SpyDecloak();
// perform weapon attack
void(float() checkfunc1, float() checkfunc2, void() firefunc) weapon_doattack
{
	if(self.class == CLASS_SPY)
	{
		SpyDecloak();
	}


	// Change to best weapon if failed
	if ((cvar("g_instagib") == 0) && (cvar("g_rocketarena") == 0))
	{
		if (!checkfunc1())
		{
			if (!checkfunc2())
				self.switchweapon = w_getbestweapon(self);
			return;
		}
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
		if (self.weaponentity != world)
			self.weaponentity.frame = fr;
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
