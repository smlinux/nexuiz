void CopyBody(float keepvelocity);

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
		self.velocity = self.velocity + v_forward * 300;
		CopyBody(1);
		self.velocity = self.velocity - v_forward * 300;
	}
	else if (self.impulse == 14 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		CopyBody(0);
	}
	else if (self.impulse == 99 && cvar("sv_cheats"))
	{
		self.items = IT_LASER | IT_UZI | IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER;
		self.ammo_shells = 999;
		self.ammo_nails = 999;
		self.ammo_rockets = 999;
		self.ammo_cells = 999;
	}
	//TetrisImpulses();
	self.impulse = 0;
}