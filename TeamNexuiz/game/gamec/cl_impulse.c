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

void CopyBody2(float keepvelocity, float testbody);
void ImpulseCommands (void)
{
	local float swpn;

	if (self.team_no < 1)		// Bring up choose team menu if not on team
	{
		stuffcmd(self, "menu_showteamselect\n");

	}

	if (self.impulse == 71)
	{
		local string whee;
		whee = ftos (self.maxammo_rockets);
		sprint(self, whee);
		sprint(self, "\n");
	}

	if (self.impulse == 70) {		// reload impulse
		swpn = self.weapon;
			if(self.class == CLASS_SOLDIER)
			{
				if (swpn == WEP4)
					DoReload (3, (CLIP_MAX_ROCKETS - self.clip_rockets));	// weapon type 3 is RL, and reload X rockets.
			}
			else if(self.class == CLASS_PYRO)
			{
				if (swpn == WEP1)
					DoReload (4, (CLIP_MAX_PIPEGRENADES - self.clip_pipegrenades));
			}
			else if(self.class == CLASS_SCOUT || self.class == CLASS_ENGINEER)
			{
				if (swpn == WEP4)
					DoReload (2, (CLIP_MAX_CRYLINK - self.clip_crylink));
			}
	}
	if (self.impulse == 69) {
		local entity isneardoor;
		local string st;
		isneardoor = findradius (self.origin, 200);
		while (isneardoor)
		{
			if ((isneardoor.classname == "door"))
			{
//				st = stos(isneardoor.model);
				sprint (self, isneardoor.model);
				sprint (self, "\n");
				dremove(newmis);
				return;
			}
			isneardoor = isneardoor.chain;
		}
	}
	if (self.impulse == 8) {
	TeamFortress_ThrowGrenade(); }
	if ((self.impulse == 150))		// GREN TYPE 1
	{
		TeamFortress_PrimeGrenade();
	}
/*	if ((self.impulse == 151))		// GREN TYPE 2
	{
		TeamFortress_PrimeGrenade();
	}*/
	if ((self.impulse == 152))
	{
		TeamFortress_ThrowGrenade();
	}

	if (self.impulse >= 1 && self.impulse <= 5)
	{
		if(self.buttonuse)
		{
			if(self.impulse == 5 && self.wpn5.weapon)
			{
				weapon_action(self.weapon, WR_DROP);
				SpawnThrownWeapon (self.origin + (self.mins + self.maxs) * 0.5, self.wpn5.weapon);
				self.weapon = 0;
				ResetExtraWeapon();
				self.switchweapon = w_getbestweapon(self);
				if(self.switchweapon == WEP5)
					self.switchweapon = WEP1;
			}
		}
		else
			if (self.reload_time < time) { 
				W_SwitchWeapon (self.impulse); }
	}
	else if (self.impulse == 10)
		if (self.reload_time < time) { 
			W_NextWeapon (); }
	else if (self.impulse == 12)
		if (self.reload_time < time) { 
			W_PreviousWeapon (); }
	else if (self.impulse == 13 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		self.velocity = self.velocity + v_forward * 300;
		CopyBody2(1, TRUE);
		self.velocity = self.velocity - v_forward * 300;
	}
	else if (self.impulse == 14 && cvar("sv_cheats"))
		CopyBody2(0, TRUE);
	else if (self.impulse == 99 && cvar("sv_cheats"))
	{
		self.items = IT_WEP1 | IT_WEP2 | IT_WEP3 | IT_WEP4 | IT_WEP5;
		self.ammo_shells = 999;
		self.ammo_nails = 999;
		self.ammo_rockets = 999;
		self.ammo_cells = 999;
	}

	if(self.impulse == 20)
	{
		ClassSpecial();
	}

	if(self.impulse == 30)
	{
		ClassGrenade(WR_GRENADE1);
	}
	if(self.impulse == 31)
	{
		ClassGrenade(WR_GRENADE2);
	}

	// model/class test
	if(self.impulse == 57)
	{
		//self.class = GetPlayerClass();
		sprint(self, "Current class: ");
		sprint(self, NameOfClass(self.class));
		sprint(self, ", model: ");
		sprint(self, self.playermodel);
		sprint(self, "\n");
	}
	if(self.impulse == 211)		// XavioR test impulse
	{
		local string woottest;
		woottest = ftos(self.team_no);
		sprint (self, woottest);
		sprint (self, "\n");
	}
	//TetrisImpulses();
	self.impulse = 0;
}