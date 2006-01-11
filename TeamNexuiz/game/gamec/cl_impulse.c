void CopyBody(float keepvelocity);
void () DropFlag;

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

	if (self.impulse_wait > time)	// So the GUI menus doesnt flicker
		return;

	if (self.playerclass < 1)		// Bring up menu if no team/class
	{
		if (self.team_no < 1)
		{
			stuffcmd(self, "set scmenu_directmenu TeamSelect; togglemenu\n");
		}
		else 
		{
			stuffcmd(self, "set scmenu_directmenu ClassSelect; togglemenu\n");
		}
		self.impulse = 0;
		self.impulse_wait = time + .5;	
		return;
	}
	if (self.impulse == DROP_FLAG_IMPULSE)
	{
		DropFlag();
	}

	if (self.impulse == 71)
	{
		local string whee;
		whee = ftos (self.maxammo_rockets);
		sprint(self, whee);
		sprint(self, "\n");
	}

	if (self.impulse == 73)
	{
		stuffcmd(self, "cmd changeclass\n");
		self.impulse = 0;
		return;
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
	if (self.impulse == 68) {
			local entity barrel;
 			barrel = spawn();
 			barrel.mdl = "models/sentry/turr1_barrel.md3";
 			barrel.yaw_speed = 10;
 			setmodel(barrel, barrel.mdl);
 			setorigin(barrel, self.origin + '8 0 8');
			barrel.angles_y = barrel.angles_y;

			local entity barrel2;
 			barrel2 = spawn();
 			barrel2.mdl = "models/sentry/turr1_barrel.md3";
 			barrel2.yaw_speed = 10;
			barrel2.angles_y = barrel2.angles_z + 90;
 			setmodel(barrel2, barrel.mdl);
 			setorigin(barrel2, '0 0 0');

			setattachment(barrel2, barrel, "tag_barrel_bullet1");
			
			local float barrel_tag;
			local vector fire_from;
			barrel_tag = gettagindex (barrel2, "tag_barrel_bullet1");
			fire_from = gettaginfo (barrel2, barrel_tag);
			bprint(vtos(fire_from));
			bprint("\n");

			local entity e;
			e = spawn();
			e.scale = 4;
			setmodel(e, "models/plasmatrail.mdl");
			setorigin (e, fire_from);
			bprint(vtos(e.origin));
			bprint("\n");

	}
	if (self.impulse == 67) {
		TeamFortress_Build (3);
		//self.current_menu = 18;
	}
	if (self.impulse == 69) {
/*		local entity isneardoor;
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
		}*/
		TeamFortress_Build (2);
	}
	if (self.impulse == 8) {
	TeamFortress_ThrowGrenade(); }
	if ((self.impulse == 150))		// GREN TYPE 1
	{
		TeamFortress_PrimeGrenade();
	}
	if ((self.impulse == 151))		// GREN TYPE 2
	{
		TeamFortress_PrimeGrenade();
	}
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
		else if (self.reload_time < time) { 
				W_SwitchWeapon (self.impulse); }
	}
	else if (self.impulse == 10) {
		if (self.reload_time < time) { 
			W_NextWeapon (); }
	}
	else if (self.impulse == 12) {
		if (self.reload_time < time) { 
			W_PreviousWeapon (); }
	}
		
	if (self.impulse == 13 && cvar("sv_cheats"))
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