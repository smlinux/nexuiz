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
	if (self.impulse >= 1 && self.impulse <= 9 && !cvar("g_minstagib"))
		W_SwitchWeapon (self.impulse);
	else if (self.impulse == 10 && !cvar("g_minstagib"))
		W_NextWeapon ();
	else if (self.impulse == 12 && !cvar("g_minstagib"))
		W_PreviousWeapon ();
	else if (self.impulse == 13 && cvar("sv_cheats"))
	{
		makevectors (self.v_angle);
		self.velocity = self.velocity + v_forward * 300;
		CopyBody(1);
		self.velocity = self.velocity - v_forward * 300;
	}
	else if (self.impulse == 14 && cvar("sv_cheats"))
		CopyBody(0);
	else if (self.impulse == 15 && cvar("sv_cheats"))
	{
		sprint(self, strcat("origin = ", vtos(self.origin), "\n"));
	}
	else if (self.impulse == 16 && cvar("sv_cheats"))
	{
		float i;
		string s;
		i=1;
		while(i <= 10)
		{
			s = ftos(i);
			sprint(self, strcat(s, ": ^", s, "color\n"));
			i = i + 1;
		}
		sprint(self, strcat("origin = ", vtos(self.origin), "\n"));
	}
	// throw weapon
	else if (self.impulse == 17 && self.weapon != WEP_LASER 
			&& !cvar("g_minstagib") && !cvar("g_instagib") 
			&& !cvar("g_rocketarena") && !cvar("g_lms") && cvar("g_pickup_items"))
	{
		W_ThrowWeapon();
	}
	else if(self.impulse == 18)
	{
		self.welcomemessage_time = time + cvar("welcome_message_time");
		self.welcomemessage_time2 = 0; 
		PrintWelcomeMessage(self);
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
