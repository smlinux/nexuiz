
// changes by LordHavoc on 03/30/04
// cleaned up dummy code
// dummies are now removed eventually after being gibbed (norespawn = TRUE)
// dummy impulse now checks sv_cheats to prevent players from overwhelming server with dummies
// dummies now use player code where possible

void player_anim (void);
void DummyThink(void)
{
	self.think = DummyThink;
	self.nextthink = time;
	SV_PlayerPhysics();
	PlayerPreThink();
	//player_anim();
	PlayerPostThink();
}

void PlayerDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force);
void CreateDummy (vector org, float type)
{
	entity oldself;
	oldself = self;
	self = spawn ();
	self.norespawn = TRUE;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.classname = "corpse";
	self.takedamage = DAMAGE_YES;
	self.damageforcescale = oldself.damageforcescale;
	self.health = 100;
	self.weapon = IT_LASER;
	setsize (self, oldself.mins, oldself.maxs);
	setorigin (self, org);
	if (type==1)
		setmodel (self, "models/player/marine.zym");
	if (type==2)
		setmodel (self, "models/player/grunt.zym");
	if (type==3)
		setmodel (self, "models/player/specop.zym");
	if (type==4)
		setmodel (self, "models/player/pyria.zym");
	if (type==5)
		setmodel (self, "models/player/lurk.zym");
	if (type==6)
		setmodel (self, "models/player/visitant.zym");
	if (type==7)
		setmodel (self, "models/player/headhunter.zym");
	if (type==8)
		setmodel (self, "models/player/jeandarc.zym");
	if (type==9)
		setmodel (self, "models/player/mulder.zym");
	if (type==10)
		setmodel (self, "models/player/insurrectionist.zym");
	if (type==11)
		setmodel (self, "models/player/robot.zym");
	if (type==12)
		setmodel (self, "models/player/lycanthrope.zym");
	if (type==13)
		setmodel (self, "models/player/fshock.zym");
	setsize (self, PL_MIN, PL_MAX);
	self.event_damage = PlayerDamage;
	DummyThink();
	self = oldself;
}

void ImpulseCommands (void)
{
	if (self.impulse >= 1 && self.impulse <= 9)
		W_SwitchWeapon (self.impulse);
	else if (self.impulse == 10)
		W_NextWeapon ();
	else if (self.impulse == 12)
		W_PreviousWeapon ();
	else if (self.impulse == 13 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 1);
	}
	else if (self.impulse == 14 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 2);
	}
	else if (self.impulse == 15 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 3);
	}
	else if (self.impulse == 16 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 4);
	}
	else if (self.impulse == 17 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 5);
	}
	else if (self.impulse == 18 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 6);
	}
	else if (self.impulse == 19 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 7);
	}
	else if (self.impulse == 20 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 8);
	}
	else if (self.impulse == 21 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 9);
	}
	else if (self.impulse == 22 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 10);
	}
	else if (self.impulse == 23 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 11);
	}
	else if (self.impulse == 24 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 12);
	}
	else if (self.impulse == 25 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64, 13);
	}
	else if (self.impulse == 26)
	{
		setmodel (self, "models/player/marine.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 27)
	{
		setmodel (self, "models/player/grunt.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 28)
	{
		setmodel (self, "models/player/specop.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 29)
	{
		setmodel (self, "models/player/pyria.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 30)
	{
		setmodel (self, "models/player/lurk.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 31)
	{
		setmodel (self, "models/player/headhunter.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 32)
	{
		setmodel (self, "models/player/visitant.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 33)
	{
		setmodel (self, "models/player/jeandarc.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 34)
	{
		setmodel (self, "models/player/mulder.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 35)
	{
		setmodel (self, "models/player/insurrectionist.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 36)
	{
		setmodel (self, "models/player/robot.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 37)
	{
		setmodel (self, "models/player/lycanthrope.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 38)
	{
		setmodel (self, "models/player/fshock.zym");
		setsize (self, PL_MIN, PL_MAX);
	}
	else if (self.impulse == 97 && !self.crouch)
	{
		self.crouch = TRUE;
		self.view_ofs_z = self.view_ofs_z - 20;
	}
	else if (self.impulse == 98 && self.crouch) {
		self.crouch = FALSE;
		self.view_ofs_z = self.view_ofs_z + 20;
	}
	else if (self.impulse == 99)
	{
		self.items = IT_LASER | IT_UZI | IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER;
		self.ammo_shells = 100;
		self.ammo_nails = 200;
		self.ammo_rockets = 100;
		self.ammo_cells = 100;
	}
	//TetrisImpulses();
	self.impulse = 0;
}