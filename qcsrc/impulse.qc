
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

void PlayerDamage (vector hitloc, float damage, entity inflictor, entity attacker, float deathtype);
void CreateDummy (vector org)
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
	setmodel (self, oldself.model);
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
		CreateDummy (self.origin + self.view_ofs + v_forward * 64);
	}
	TetrisImpulses();
	self.impulse = 0;
}