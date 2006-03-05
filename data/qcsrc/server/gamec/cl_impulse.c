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

// from dpmod
void(entity e, vector v) printsurfaceinfo =
{
	local float surfnum, numpoints, vnum;
	local string s;
	local vector n;
	surfnum = getsurfacenearpoint(e, v);
	if (surfnum >= 0)
	{
		sprint(self, "texture: ");
		s = getsurfacetexture(e, surfnum);
		sprint(self, s);
		sprint(self, " normal: ");
		n = getsurfacenormal(e, surfnum);
		sprint(self, vtos(n));
		sprint(self, " ");
		numpoints = getsurfacenumpoints(e, surfnum);
		sprint(self, ftos(numpoints));
		sprint(self, " verts:");
		vnum = 0;
		while (vnum < numpoints)
		{
			sprint(self, " ");
			n = getsurfacepoint(e, surfnum, vnum);
			sprint(self, vtos(n));
			vnum = vnum + 1;
		}
		sprint(self, " point tested: ");
		sprint(self, vtos(v));
		sprint(self, " nearest point on surface: ");
		n = getsurfaceclippedpoint(e, surfnum, v);
		sprint(self, vtos(n));
		sprint(self, "\n");
	}
};

void ImpulseCommands (void)
{
	local float imp;
	imp = self.impulse;
	if (!imp)
		return;
	self.impulse = 0;
	if (imp >= 1 && imp <= 12)
	{
		// weapon switching impulses
		if (imp <= 9)
			W_SwitchWeapon (imp);
		else if (imp == 10)
			W_NextWeapon ();
		else if (imp == 12)
			W_PreviousWeapon ();
		else if (imp == 11) // last weapon
			W_SwitchWeapon (self.cnt);
	}
	else if (imp >= 13 && imp <= 16)
	{
		if (cvar("sv_cheats"))
		{
			if (imp == 13)
			{
				makevectors (self.v_angle);
				self.velocity = self.velocity + v_forward * 300;
				CopyBody(1);
				self.velocity = self.velocity - v_forward * 300;
			}
			else if (imp == 14)
				CopyBody(0);
			else if (imp == 15)
			{
				sprint(self, strcat("origin = ", vtos(self.origin), "\n"));
				sprint(self, strcat("angles = ", vtos(self.angles), "\n"));
			}
			else if (imp == 16)
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
		}
	}
	// throw weapon
	else if (imp == 17)
	{
		if (self.weapon != WEP_LASER
			&& !cvar("g_minstagib") && !cvar("g_instagib")
			&& !cvar("g_rocketarena") && !cvar("g_lms") && cvar("g_pickup_items"))
			W_ThrowWeapon();
	}
	else if(imp == 19)
	{
		if (cvar("sv_cheats"))
		{
			makevectors(self.v_angle);
			traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 4096, FALSE, self);
			if (trace_fraction < 1)
				printsurfaceinfo(trace_ent, trace_endpos);
		}
	}
	else if (imp == 99)
	{
		if (cvar("sv_cheats"))
		{
			self.items = IT_LASER | IT_UZI | IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER;
			self.ammo_shells = 999;
			self.ammo_nails = 999;
			self.ammo_rockets = 999;
			self.ammo_cells = 999;
		}
	}
	//TetrisImpulses();
}
