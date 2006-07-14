/*
===========================================================================

  CLIENT WEAPONSYSTEM CODE
  Bring back W_Weaponframe

===========================================================================
*/

// VorteX: static frame globals
float WFRAME_FIRE1 = 0;
float WFRAME_FIRE2 = 1;
float WFRAME_IDLE = 2;

void(float fr, float t, void() func) weapon_thinkf;

vector w_shotorg;
vector w_shotdir;

// this function calculates w_shotorg and w_shotdir based on the weapon model
// offset, trueaim and antilag, and won't put w_shotorg inside a wall.
// make sure you call makevectors first (FIXME?)
void(entity ent, vector vecs, float antilag, float recoil, string snd) W_SetupShot =
{
	local vector trueaimpoint;

	traceline_hitcorpse(self, self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * MAX_SHOT_DISTANCE, MOVE_NOMONSTERS, self);
	trueaimpoint = trace_endpos;

	// if aiming at a player and the original trace won't hit that player
	// anymore, try aiming at the player's new position
	if (antilag)
	if (self.cursor_trace_ent)
	if (self.cursor_trace_ent.takedamage)
	if (trace_ent != self.cursor_trace_ent)
	if (cvar("g_antilag"))
		trueaimpoint = self.cursor_trace_ent.origin;

	/*
	// don't allow the shot to start inside a wall
	local vector startorg;
	local vector idealorg;
	startorg = ent.origin + ent.view_ofs;// - '0 0 8';
	idealorg = ent.origin + ent.view_ofs + v_forward * vecs_x + v_right * vecs_y + v_up * vecs_z;
	traceline_hitcorpse (ent, startorg, idealorg, MOVE_NOMONSTERS, ent);
	w_shotorg = trace_endpos;
	*/
	// all positions in the code are now required to be inside the player box
	w_shotorg = ent.origin + ent.view_ofs + v_forward * vecs_x + v_right * vecs_y + v_up * vecs_z;

	w_shotdir = normalize(trueaimpoint - w_shotorg);

	if (!cvar("g_norecoil"))
		self.punchangle_x = recoil * -1;

	if (snd != "")
		sound (self, CHAN_WEAPON, snd, 1, ATTN_NORM);

	if (self.items & IT_STRENGTH)
	if (!cvar("g_minstagib"))
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);
};

void LaserTarget_Think()
{
	entity e;
	vector offset;
	float uselaser;
	uselaser = 0;

	// list of weapons that will use the laser, and the options that enable it
	if(self.owner.laser_on && self.owner.weapon == WEP_ROCKET_LAUNCHER && cvar("g_laserguided_missile"))
		uselaser = 1;
	// example
	//if(self.owner.weapon == WEP_ELECTRO && cvar("g_laserguided_electro"))
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
	traceline(self.owner.origin + offset, self.owner.origin + offset + v_forward * MAX_SHOT_DISTANCE, FALSE, self); // trace forward until you hit something, like a player or wall
	setorigin(e, trace_endpos + v_forward*8); // move me to where the traceline ended
	if(trace_plane_normal != '0 0 0')
		e.angles = vectoangles(trace_plane_normal);
	else
		e.angles = vectoangles(v_forward);
}

.string weaponname;
void() CL_Weaponentity_Think =
{
	self.nextthink = time;
	if (intermission_running)
		self.frame = WFRAME_IDLE;
	if (self.owner.weaponentity != self)
	{
		remove(self);
		return;
	}
	if (self.owner.deadflag != DEAD_NO)
	{
		self.model = "";
		return;
	}
	if (self.cnt != self.owner.weapon || self.dmg != self.owner.modelindex || self.deadflag != self.owner.deadflag)
	{
		self.cnt = self.owner.weapon;
		self.dmg = self.owner.modelindex;
		self.deadflag = self.owner.deadflag;
		if (self.owner.weaponname != "")
			setmodel(self, strcat("models/weapons/w_", self.owner.weaponname, ".zym"));
		else
			self.model = "";
	}
	self.effects = self.owner.effects;

	if (self.flags & FL_FLY)
		// owner is currently being teleported, so don't apply EF_NODRAW otherwise the viewmodel would "blink"
		self.effects = self.effects - (self.effects & EF_NODRAW);

	self.alpha = self.owner.alpha;
	self.colormap = self.owner.colormap;

	self.angles = '0 0 0';
	local float f;
	f = 0;
	if (self.state == WS_RAISE)
		f = (self.owner.weapon_nextthink - time) / cvar("g_balance_weaponswitchdelay");
	else if (self.state == WS_DROP)
		f = 1 - (self.owner.weapon_nextthink - time) / cvar("g_balance_weaponswitchdelay");
	else if (self.state == WS_CLEAR)
		f = 1;
	self.angles_x = -90 * f * f;

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
	if (self.owner.deadflag != DEAD_NO)
	{
		self.model = "";
		return;
	}
	if (self.cnt != self.owner.weapon || self.dmg != self.owner.modelindex || self.deadflag != self.owner.deadflag)
	{
		self.cnt = self.owner.weapon;
		self.dmg = self.owner.modelindex;
		self.deadflag = self.owner.deadflag;
		if (self.owner.weaponname != "")
			setmodel(self, strcat("models/weapons/v_", self.owner.weaponname, ".md3"));
		else
			self.model = "";
		setattachment(self, self.owner, "bip01 r hand");
		// if that didn't find a tag, hide the exterior weapon model
		if (!self.tag_index)
			self.model = "";
	}
	self.effects = self.owner.effects;
	self.colormap = self.owner.colormap;
};

// spawning weaponentity for client
void() CL_SpawnWeaponentity =
{
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
	self.weaponentity.scale = 0.61;

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

float(entity cl, float wpn, float andammo, float complain) client_hasweapon =
{
	local float itemcode, f;
	local entity oldself;

	if (wpn < WEP_FIRST || wpn > WEP_LAST)
	{
		if (complain)
			sprint(self, "Invalid weapon\n");
		return FALSE;
	}
	itemcode = weapon_translateindextoflag(wpn);
	if (cl.items & itemcode)
	{
		if (andammo)
		{
			oldself = self;
			self = cl;
			f = weapon_action(wpn, WR_CHECKAMMO1);
			f = f + weapon_action(wpn, WR_CHECKAMMO2);
			self = oldself;
			if (!f)
			{
				if (complain)
					sprint(self, "You don't have any ammo for that weapon\n");
				return FALSE;
			}
		}
		return TRUE;
	}
	if (complain)
		sprint(self, "You don't own that weapon\n");
	return FALSE;
};

// Weapon subs
void() w_clear =
{
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
	if (self.weaponentity)
	{
		self.weaponentity.state = WS_READY;
		weapon_thinkf(WFRAME_IDLE, 0.1, w_ready);
	}
};

// FIXME: add qw-style client-custom weaponrating (cl_weaponrating)?
float(entity e) w_getbestweapon
{// add new weapons here
	if (client_hasweapon(e, WEP_ROCKET_LAUNCHER, TRUE, FALSE))
		return WEP_ROCKET_LAUNCHER;
	else if (client_hasweapon(e, WEP_NEX, TRUE, FALSE))
		return WEP_NEX;
	else if (client_hasweapon(e, WEP_HAGAR, TRUE, FALSE))
		return WEP_HAGAR;
	else if (client_hasweapon(e, WEP_GRENADE_LAUNCHER, TRUE, FALSE))
		return WEP_GRENADE_LAUNCHER;
	else if (client_hasweapon(e, WEP_ELECTRO, TRUE, FALSE))
		return WEP_ELECTRO;
	else if (client_hasweapon(e, WEP_CRYLINK, TRUE, FALSE))
		return WEP_CRYLINK;
	else if (client_hasweapon(e, WEP_UZI, TRUE, FALSE))
		return WEP_UZI;
	else if (client_hasweapon(e, WEP_SHOTGUN, TRUE, FALSE))
		return WEP_SHOTGUN;
	else if (client_hasweapon(e, WEP_LASER, FALSE, FALSE))
		return WEP_LASER;
	else
		return 0;
};

// Setup weapon for client (after this raise frame will be launched)
void(float windex, string wname, float hudammo) weapon_setup =
{
	self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
	self.items = self.items | hudammo;

	// the two weapon entities will notice this has changed and update their models
	self.weapon = windex;
	self.weaponname = wname;
};

// perform weapon to attack (weaponstate and attack_finished check is here)
float(float secondary, float attacktime) weapon_prepareattack =
{
	if (!weapon_action(self.weapon, WR_CHECKAMMO1 + secondary))
	{
		self.switchweapon = w_getbestweapon(self);
		if (self.switchweapon != self.weapon)
			self.cnt = self.weapon;
		return FALSE;
	}
	// don't fire if previous attack is not finished
	if (self.attack_finished > time)
		return FALSE;
	// don't fire while changing weapon
	if (self.weaponentity.state != WS_READY)
		return FALSE;
	self.weaponentity.state = WS_INUSE;
	self.attack_finished = max(time, self.attack_finished + attacktime);
	return TRUE;
};

void(float fr, float t, void() func) weapon_thinkf =
{
	if (fr >= 0)
	{
		if (self.weaponentity != world)
			self.weaponentity.frame = fr;
	}

	if(self.weapon_think == w_ready && func != w_ready && self.weaponentity.state == WS_RAISE)
	{
		backtrace("Tried to override initial weapon think function - should this really happen?");
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
	self.weapon_nextthink = max(time, self.weapon_nextthink_lastframe + t);
	self.weapon_think = func;
};

void(float spd, vector org) weapon_boblayer1 =
{
	// VorteX: haste can be added here
};

