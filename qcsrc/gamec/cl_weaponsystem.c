/*
===========================================================================

  CLIENT WEAPONSYSTEM CODE
  Bring back W_Weaponframe

===========================================================================
*/ 
// definitions (move this part to defs after finishing of weapon system)
.entity weaponentity;
.float switchweapon;
void(float wpn, float wrequest) weapon_action;
void() w_clear;
// VorteX: standalone think for weapons, so normal think on weaponentity can be reserved by weaponflashes which needs update even player dies)
.float weapon_nextthink;
.void() weapon_think;
.vector shotdir, shotorg;
float	weapon_hasammo; // sets by WR_CHECKAMMO request

// weapon states (self.weaponentity.state)
float WS_CLEAR			= 0; // no weapon selected
float WS_RAISE			= 1; // raise frame
float WS_DROP			= 2; // deselecting frame
float WS_INUSE			= 3; // fire state
float WS_READY			= 4; // idle frame

// weapon requests
float WR_SETUP		  = 1;	// setup weapon data
float WR_UPDATECOUNTS = 2;  // update ammo display
float WR_IDLE		  = 3;  // idle frame
float WR_DROP		  = 4;	// deselect frame
float WR_RAISE		  = 5;	// select frame
float WR_FIRE1		  = 6;  // primary fire frame
float WR_FIRE2		  = 7;  // secondary fire
float WR_FIRE3		  = 8;  // third fire
float WR_CHECKAMMO	  = 9;  // checks ammo for weapon 
float WR_CLEAR		  = 10;  // runs afted deselecting frames, remove weapon parts (if presented). This useful for quake3-style chaingun

// Weapon indexes
float WEP_LASER				= 1; // float	IT_LASER				= 4096;
float WEP_SHOTGUN			= 2; // float	IT_SHOTGUN				= 1;
float WEP_UZI				= 3; // float	IT_UZI					= 2;
float WEP_GRENADE_LAUNCHER	= 4; // float	IT_GRENADE_LAUNCHER		= 4; 
float WEP_ELECTRO			= 5; // float	IT_ELECTRO				= 8;
float WEP_CRYLINK			= 6; // float	IT_CRYLINK				= 16;
float WEP_NEX				= 7; // float	IT_NEX					= 32;
float WEP_HAGAR				= 8; // float	IT_HAGAR				= 64;
float WEP_ROCKET_LAUNCHER	= 9; // float	IT_ROCKET_LAUNCHER		= 128;

// For weapon cycling commands
float WEP_FIRST				= 1;
float WEP_LAST				= 9;

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
};

float(entity cl, float wpn, float andammo) client_hasweapon =
{
	local float itemcode;

	itemcode = weapon_translateindextoflag(wpn);
	if (cl.items & itemcode)
	{
		if (andammo)
		{
			weapon_action(wpn, WR_CHECKAMMO);
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
	self.weaponentity.state = WS_CLEAR;
	setmodel(self.weaponentity, "");
	self.weaponentity.effects = 0;
};

void() w_ready =
{
	self.weaponentity.state = WS_READY;
	weapon_action(self.weapon, WR_IDLE); 
};

// FIXME: add qw-style client-custom weaponrating (cl_weaponrating)?
void() w_bestweapon
{// add new weapons here
	weapon_hasammo = TRUE;
	if (client_hasweapon(self, WEP_ROCKET_LAUNCHER, TRUE))
		self.switchweapon = WEP_ROCKET_LAUNCHER;
	else if (client_hasweapon(self, WEP_NEX, TRUE))
		self.switchweapon = WEP_NEX;
	else if (client_hasweapon(self, WEP_HAGAR, TRUE))
		self.switchweapon = WEP_HAGAR;
	else if (client_hasweapon(self, WEP_GRENADE_LAUNCHER, TRUE))
		self.switchweapon = WEP_GRENADE_LAUNCHER;
	else if (client_hasweapon(self, WEP_ELECTRO, TRUE))
		self.switchweapon = WEP_ELECTRO;
	else if (client_hasweapon(self, WEP_CRYLINK, TRUE))
		self.switchweapon = WEP_CRYLINK;
	else if (client_hasweapon(self, WEP_UZI, TRUE))
		self.switchweapon = WEP_UZI;
	else if (client_hasweapon(self, WEP_SHOTGUN, TRUE))
		self.switchweapon = WEP_SHOTGUN;
	else
		self.switchweapon = WEP_LASER;
};

// Setup weapon for client (after this raise frame will be launched)
void(float windex, string wmodel, float hudammo) weapon_setup =
{
	local string wdir, weaponmdl;

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
	// Change to best weapon if failed
	if (!(game & GAME_INSTAGIB) && !(game & GAME_ROCKET_ARENA))
	{
		if (!checkfunc1())
		{
			if (!checkfunc2())
				w_bestweapon();
			return;
		}
	}
	// Don't do shot if previos attack  not finished
	if (!(game & GAME_INSANE))
		if (time < self.attack_finished) 	    
			return; 
	// Can't do shot if changing weapon
	if (!(game & GAME_INSANE))
		if (self.weaponentity.state != WS_READY)	
			return;

	self.attack_finished = time + atktime;
	firefunc();
};

// perform weapon attack
void(float() checkfunc1, float() checkfunc2, void() firefunc) weapon_doattack
{
	// Change to best weapon if failed
	if (!(game & GAME_INSTAGIB) && !(game & GAME_ROCKET_ARENA))
	{
		if (!checkfunc1())
		{
			if (!checkfunc2())
				w_bestweapon();
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
