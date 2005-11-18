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
	else if (self.impulse == 99 && cvar("sv_cheats"))
	{
		self.items = IT_LASER | IT_UZI | IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER;
		self.ammo_shells = 999;
		self.ammo_nails = 999;
		self.ammo_rockets = 999;
		self.ammo_cells = 999;
	}
	// lms debug
	else if(self.impulse == 66)
	{
		bprint("^3total:    ");
		bprint(ftos(player_count));
		bprint("\n");
		bprint("^3dead:     ");
		bprint(ftos(lms_dead_count));
		bprint("\n");
		bprint("^3lowest:   ");
		bprint(ftos(lms_lowest_lives));
		bprint("\n");
	}
	//TetrisImpulses();
	self.impulse = 0;
}
