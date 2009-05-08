void onslaught_generator_updatesprite(entity e);
void onslaught_controlpoint_updatesprite(entity e);
void onslaught_link_checkupdate();

.entity sprite;
.string target2;
.float iscaptured;
.float islinked;
.float isgenneighbor_red;
.float isgenneighbor_blue;
.float iscpneighbor_red;
.float iscpneighbor_blue;
.float isshielded;
.float lasthealth;
.float lastteam;
.float lastshielded;

.string model1, model2, model3;

void ons_gib_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
    self.velocity += vforce;
}

void ons_trowgib(
    vector v_from, vector v_to, vector v_colormod,
    string smodel,
    float f_lifetime, float f_fadetime, float b_burn)
{
    local entity gib;
    local entity burn;

    gib = spawn();

    gib.classname = "turret_gib";
    setmodel(gib,smodel);
    setorigin(gib,v_from);
    SUB_SetFade(gib,time + f_lifetime,2);

    gib.solid              = SOLID_BBOX;

    gib.movetype           = MOVETYPE_BOUNCE;
    gib.takedamage         = DAMAGE_YES;
    gib.event_damage       = ons_gib_damage;
    gib.health             = -1;
    gib.effects            = EF_LOWPRECISION;
    gib.flags              = FL_NOTARGET;
    gib.colormod           = v_colormod;
    gib.velocity           = v_to;

    if (b_burn)
    {
        burn = spawn();
        burn.effects        = EF_LOWPRECISION;//|EF_FLAME;
        setattachment(burn,gib,"");
        setorigin(burn,(gib.mins + gib.maxs) * 0.5);
        SUB_SetFade(burn,time + (f_lifetime * 0.5) ,2);
    }
}

void onslaught_updatelinks()
{
	local entity l, links;
	local float stop, t1, t2, t3, t4;
	// first check if the game has ended
	dprint("--- updatelinks ---\n");
	links = findchain(classname, "onslaught_link");
	// mark generators as being shielded and networked
	l = findchain(classname, "onslaught_generator");
	while (l)
	{
		if (l.iscaptured)
			dprint(etos(l), " (generator) belongs to team ", ftos(l.team), "\n");
		else
			dprint(etos(l), " (generator) is destroyed\n");
		l.islinked = l.iscaptured;
		l.isshielded = l.iscaptured;
		l = l.chain;
	}
	// mark points as shielded and not networked
	l = findchain(classname, "onslaught_controlpoint");
	while (l)
	{
		l.islinked = FALSE;
		l.isshielded = TRUE;
		l.isgenneighbor_red = FALSE;
		l.isgenneighbor_blue = FALSE;
		l.iscpneighbor_red = FALSE;
		l.iscpneighbor_blue = FALSE;
		dprint(etos(l), " (point) belongs to team ", ftos(l.team), "\n");
		l = l.chain;
	}
	// flow power outward from the generators through the network
	l = links;
	while (l)
	{
		dprint(etos(l), " (link) connects ", etos(l.goalentity), " with ", etos(l.enemy), "\n");
		l = l.chain;
	}
	stop = FALSE;
	while (!stop)
	{
		stop = TRUE;
		l = links;
		while (l)
		{
			// if both points are captured by the same team, and only one of
			// them is powered, mark the other one as powered as well
			if (l.enemy.iscaptured && l.goalentity.iscaptured)
			if (l.enemy.islinked != l.goalentity.islinked)
			if (l.enemy.team == l.goalentity.team)
			{
				if (!l.goalentity.islinked)
				{
					stop = FALSE;
					l.goalentity.islinked = TRUE;
					dprint(etos(l), " (link) is marking ", etos(l.goalentity), " (point) because its team matches ", etos(l.enemy), " (point)\n");
				}
				else if (!l.enemy.islinked)
				{
					stop = FALSE;
					l.enemy.islinked = TRUE;
					dprint(etos(l), " (link) is marking ", etos(l.enemy), " (point) because its team matches ", etos(l.goalentity), " (point)\n");
				}
			}
			l = l.chain;
		}
	}
	// now that we know which points are powered we can mark their neighbors
	// as unshielded if team differs
	l = links;
	while (l)
	{
		if (l.goalentity.team != l.enemy.team)
		{
			if (l.goalentity.islinked)
			{
				dprint(etos(l), " (link) is unshielding ", etos(l.enemy), " (point) because its team does not match ", etos(l.goalentity), " (point)\n");
				l.enemy.isshielded = FALSE;
				if(l.goalentity.classname == "onslaught_generator")
				{
					if(l.goalentity.team == COLOR_TEAM1)
						l.enemy.isgenneighbor_red = TRUE;
					else if(l.goalentity.team == COLOR_TEAM2)
						l.enemy.isgenneighbor_blue = TRUE;
				}
				else
				{
					if(l.goalentity.team == COLOR_TEAM1)
						l.enemy.iscpneighbor_red = TRUE;
					else if(l.goalentity.team == COLOR_TEAM2)
						l.enemy.iscpneighbor_blue = TRUE;
				}
			}
			if (l.enemy.islinked)
			{
				dprint(etos(l), " (link) is unshielding ", etos(l.goalentity), " (point) because its team does not match ", etos(l.enemy), " (point)\n");
				l.goalentity.isshielded = FALSE;
				if(l.enemy.classname == "onslaught_generator")
				{
					if(l.enemy.team == COLOR_TEAM1)
						l.goalentity.isgenneighbor_red = TRUE;
					else if(l.enemy.team == COLOR_TEAM2)
						l.goalentity.isgenneighbor_blue = TRUE;
				}
				else
				{
					if(l.enemy.team == COLOR_TEAM1)
						l.goalentity.iscpneighbor_red = TRUE;
					else if(l.enemy.team == COLOR_TEAM2)
						l.goalentity.iscpneighbor_blue = TRUE;
				}
			}
		}
		l = l.chain;
	}
	// now update the takedamage and alpha variables on generator shields
	l = findchain(classname, "onslaught_generator");
	while (l)
	{
		if (l.isshielded)
		{
			dprint(etos(l), " (generator) is shielded\n");
			l.enemy.alpha = 1;
			l.takedamage = DAMAGE_NO;
			l.bot_attack = FALSE;
		}
		else
		{
			dprint(etos(l), " (generator) is not shielded\n");
			l.enemy.alpha = -1;
			l.takedamage = DAMAGE_AIM;
			l.bot_attack = TRUE;
		}
		l = l.chain;
	}
	// now update the takedamage and alpha variables on control point icons
	l = findchain(classname, "onslaught_controlpoint");
	while (l)
	{
		if (l.isshielded)
		{
			dprint(etos(l), " (point) is shielded\n");
			l.enemy.alpha = 1;
			if (l.goalentity)
			{
				l.goalentity.takedamage = DAMAGE_NO;
				l.goalentity.bot_attack = FALSE;
			}
		}
		else
		{
			dprint(etos(l), " (point) is not shielded\n");
			l.enemy.alpha = -1;
			if (l.goalentity)
			{
				l.goalentity.takedamage = DAMAGE_AIM;
				l.goalentity.bot_attack = TRUE;
			}
		}
		onslaught_controlpoint_updatesprite(l);
		l = l.chain;
	}
	// count generators owned by each team
	t1 = t2 = t3 = t4 = 0;
	l = findchain(classname, "onslaught_generator");
	while (l)
	{
		if (l.iscaptured)
		{
			if (l.team == COLOR_TEAM1) t1 = 1;
			if (l.team == COLOR_TEAM2) t2 = 1;
			if (l.team == COLOR_TEAM3) t3 = 1;
			if (l.team == COLOR_TEAM4) t4 = 1;
		}
		onslaught_generator_updatesprite(l);
		l = l.chain;
	}
	// see if multiple teams remain (if not, it's game over)
	if (t1 + t2 + t3 + t4 < 2)
		dprint("--- game over ---\n");
	else
		dprint("--- done updating links ---\n");
};

float onslaught_controlpoint_can_be_linked(entity cp, float t)
{
	if(t == COLOR_TEAM1)
	{
		if(cp.isgenneighbor_red)
			return 2;
		if(cp.iscpneighbor_red)
			return 1;
	}
	else if(t == COLOR_TEAM2)
	{
		if(cp.isgenneighbor_blue)
			return 2;
		if(cp.iscpneighbor_blue)
			return 1;
	}
	return 0;
/*
	entity e;
	// check to see if this player has a legitimate claim to capture this
	// control point - more specifically that there is a captured path of
	// points leading back to the team generator
	e = findchain(classname, "onslaught_link");
	while (e)
	{
		if (e.goalentity == cp)
		{
			dprint(etos(e), " (link) connects to ", etos(e.enemy), " (point)");
			if (e.enemy.islinked)
			{
				dprint(" which is linked");
				if (e.enemy.team == t)
				{
					dprint(" and has the correct team!\n");
					return 1;
				}
				else
					dprint(" but has the wrong team\n");
			}
			else
				dprint("\n");
		}
		else if (e.enemy == cp)
		{
			dprint(etos(e), " (link) connects to ", etos(e.goalentity), " (point)");
			if (e.goalentity.islinked)
			{
				dprint(" which is linked");
				if (e.goalentity.team == t)
				{
					dprint(" and has a team!\n");
					return 1;
				}
				else
					dprint(" but has the wrong team\n");
			}
			else
				dprint("\n");
		}
		e = e.chain;
	}
	return 0;
*/
}

float onslaught_controlpoint_attackable(entity cp, float t)
// -2: SAME TEAM, attackable by enemy!
// -1: SAME TEAM!
// 0:  off limits
// 1:  attack it
// 2:  touch it
// 3:  attack it (HIGH PRIO)
// 4:  touch it (HIGH PRIO)
{
	float a;

	if(cp.isshielded)
	{
		return 0;
	}
	else if(cp.goalentity)
	{
		// if there's already an icon built, nothing happens
		if(cp.team == t)
		{
			a = onslaught_controlpoint_can_be_linked(cp, COLOR_TEAM1 + COLOR_TEAM2 - t);
			if(a) // attackable by enemy?
				return -2; // EMERGENCY!
			return -1;
		}
		// we know it can be linked, so no need to check
		// but...
		a = onslaught_controlpoint_can_be_linked(cp, t);
		if(a == 2) // near our generator?
			return 3; // EMERGENCY!
		return 1;
	}
	else
	{
		// free point
		if(onslaught_controlpoint_can_be_linked(cp, t))
		{
			a = onslaught_controlpoint_can_be_linked(cp, COLOR_TEAM1 + COLOR_TEAM2 - t);
			if(a == 2)
				return 4; // GET THIS ONE NOW!
			else
				return 2; // TOUCH ME
		}
	}
	return 0;
}

void onslaught_generator_think()
{
	local float d;
	local entity e;
	self.nextthink = ceil(time + 1);
	if (cvar("timelimit"))
	if (time > cvar("timelimit") * 60 - 60)
	{
		// self.max_health / 300 gives 5 minutes of overtime.
		// control points reduce the overtime duration.
		sound(self, CHAN_TRIGGER, "onslaught/generator_decay.wav", VOL_BASE, ATTN_NORM);
		d = 1;
		e = findchain(classname, "onslaught_controlpoint");
		while (e)
		{
			if (e.team != self.team)
			if (e.islinked)
				d = d + 1;
			e = e.chain;
		}
		d = d * self.max_health / 300;
		Damage(self, self, self, d, DEATH_HURTTRIGGER, self.origin, '0 0 0');
	}
};

void onslaught_generator_deaththink()
{
	local vector org;
	if (self.count > 0)
	{
		self.nextthink = time + 0.1;
		self.count = self.count - 1;
		org = randompos(self.origin + self.mins + '8 8 8', self.origin + self.maxs + '-8 -8 -8');
		pointparticles(particleeffectnum("onslaught_generator_smallexplosion"), org, '0 0 0', 1);
		sound(self, CHAN_TRIGGER, "weapons/grenade_impact.wav", VOL_BASE, ATTN_NORM);
	}
	else
	{
		org = self.origin;
		pointparticles(particleeffectnum("onslaught_generator_finalexplosion"), org, '0 0 0', 1);
		sound(self, CHAN_TRIGGER, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	}
};

void onslaught_generator_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (damage <= 0)
		return;
	if (attacker != self)
	{
		if (self.isshielded)
		{
			// this is protected by a shield, so ignore the damage
			if (time > self.pain_finished)
			if (attacker.classname == "player")
			{
				play2(attacker, "onslaught/damageblockedbyshield.wav");
				self.pain_finished = time + 1;
			}
			return;
		}
		if (time > self.pain_finished)
		{
			self.pain_finished = time + 5;
			bprint(ColoredTeamName(self.team), " generator under attack!\n");
			play2team(self.team, "onslaught/generator_underattack.wav");
		}
	}
	self.health = self.health - damage;
	// choose an animation frame based on health
	self.frame = 10 * bound(0, (1 - self.health / self.max_health), 1);
	// see if the generator is still functional, or dying
	if (self.health > 0)
	{
		float h, lh;
		lh = ceil(self.lasthealth / 100) * 100;
		h = ceil(self.health / 100) * 100;
		if(lh != h)
			bprint(ColoredTeamName(self.team), " generator has less than ", ftos(h), " health remaining\n");
		self.lasthealth = self.health;
	}
	else
	{
		if (attacker == self)
			bprint(ColoredTeamName(self.team), " generator spontaneously exploded due to overtime!\n");
		else
		{
			string t;
			t = ColoredTeamName(attacker.team);
			bprint(ColoredTeamName(self.team), " generator destroyed by ", t, "!\n");
		}
		self.iscaptured = FALSE;
		self.islinked = FALSE;
		self.isshielded = FALSE;
		self.takedamage = DAMAGE_NO; // can't be hurt anymore
		self.event_damage = SUB_Null; // won't do anything if hurt
		self.count = 30; // 30 explosions
		self.think = onslaught_generator_deaththink; // explosion sequence
		self.nextthink = time; // start exploding immediately
		self.think(); // do the first explosion now
		onslaught_updatelinks();
	}
	if(self.health < cvar("g_onslaught_gen_health") * 0.75)
		setmodel(self, "models/onslaught/generator_dmg1.md3");
	if(self.health < cvar("g_onslaught_gen_health") * 0.35)
		setmodel(self, "models/onslaught/generator_dmg2.md3");
	if(self.health <= 0)
		setmodel(self, "models/onslaught/generator_dead.md3");
};

// update links after a delay
void onslaught_generator_delayed()
{
	onslaught_updatelinks();
	// now begin normal thinking
	self.think = onslaught_generator_think;
	self.nextthink = time;
};

string onslaught_generator_waypointsprite_for_team(entity e, float t)
{
	if(t == e.team)
	{
		if(e.team == COLOR_TEAM1)
			return "ons-gen-red";
		else if(e.team == COLOR_TEAM2)
			return "ons-gen-blue";
	}
	if(e.isshielded)
		return "ons-gen-shielded";
	if(e.team == COLOR_TEAM1)
		return "ons-gen-red";
	else if(e.team == COLOR_TEAM2)
		return "ons-gen-blue";
	return "";
}

void onslaught_generator_updatesprite(entity e)
{
	string s1, s2, s3;
	s1 = onslaught_generator_waypointsprite_for_team(e, COLOR_TEAM1);
	s2 = onslaught_generator_waypointsprite_for_team(e, COLOR_TEAM2);
	s3 = onslaught_generator_waypointsprite_for_team(e, -1);
	WaypointSprite_UpdateSprites(e.sprite, s1, s2, s3);

	if(e.lastteam != e.team + 2 || e.lastshielded != e.isshielded)
	{
		e.lastteam = e.team + 2;
		e.lastshielded = e.isshielded;
		if(e.lastshielded)
		{
			if(e.team == COLOR_TEAM1)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, '0.5 0 0');
			else if(e.team == COLOR_TEAM2)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, '0 0 0.5');
			else
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, '0.5 0.5 0.5');
		}
		else
		{
			if(e.team == COLOR_TEAM1)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, '1 0 0');
			else if(e.team == COLOR_TEAM2)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, '0 0 1');
			else
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, '0.75 0.75 0.75');
		}
		WaypointSprite_Ping(e.sprite);
	}
}

string onslaught_controlpoint_waypointsprite_for_team(entity e, float t)
{
	float a;
	if(t != -1)
	{
		a = onslaught_controlpoint_attackable(e, t);
		if(a == 3 || a == 4) // ATTACK/TOUCH THIS ONE NOW
		{
			if(e.team == COLOR_TEAM1)
				return "ons-cp-atck-red";
			else if(e.team == COLOR_TEAM2)
				return "ons-cp-atck-blue";
			else
				return "ons-cp-atck-neut";
		}
		else if(a == -2) // DEFEND THIS ONE NOW
		{
			if(e.team == COLOR_TEAM1)
				return "ons-cp-dfnd-red";
			else if(e.team == COLOR_TEAM2)
				return "ons-cp-dfnd-blue";
		}
		else if(e.team == t || a == -1 || a == 1) // own point, or fire at it
		{
			if(e.team == COLOR_TEAM1)
				return "ons-cp-red";
			else if(e.team == COLOR_TEAM2)
				return "ons-cp-blue";
		}
		else if(a == 2) // touch it
			return "ons-cp-neut";
	}
	else
	{
		if(e.team == COLOR_TEAM1)
			return "ons-cp-red";
		else if(e.team == COLOR_TEAM2)
			return "ons-cp-blue";
		else
			return "ons-cp-neut";
	}
	return "";
}

void onslaught_controlpoint_updatesprite(entity e)
{
	string s1, s2, s3;
	s1 = onslaught_controlpoint_waypointsprite_for_team(e, COLOR_TEAM1);
	s2 = onslaught_controlpoint_waypointsprite_for_team(e, COLOR_TEAM2);
	s3 = onslaught_controlpoint_waypointsprite_for_team(e, -1);
	WaypointSprite_UpdateSprites(e.sprite, s1, s2, s3);

	float sh;
	sh = !(onslaught_controlpoint_can_be_linked(e, COLOR_TEAM1) || onslaught_controlpoint_can_be_linked(e, COLOR_TEAM2));

	if(e.lastteam != e.team + 2 || e.lastshielded != sh)
	{
		e.lastteam = e.team + 2;
		e.lastshielded = sh;
		if(e.lastshielded)
		{
			if(e.team == COLOR_TEAM1)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, '0.5 0 0');
			else if(e.team == COLOR_TEAM2)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, '0 0 0.5');
			else
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, '0.5 0.5 0.5');
		}
		else
		{
			if(e.team == COLOR_TEAM1)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, '1 0 0');
			else if(e.team == COLOR_TEAM2)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, '0 0 1');
			else
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, '0.75 0.75 0.75');
		}
		WaypointSprite_Ping(e.sprite);
	}
}

void onslaught_generator_reset()
{
	self.team = self.team_saved;
	self.lasthealth = self.max_health = self.health = cvar("g_onslaught_gen_health");
	self.takedamage = DAMAGE_AIM;
	self.bot_attack = TRUE;
	self.iscaptured = TRUE;
	self.islinked = TRUE;
	self.isshielded = TRUE;
	self.enemy.solid = SOLID_NOT;
	self.think = onslaught_generator_delayed;
	self.nextthink = time + 0.2;
}

/*QUAKED spawnfunc_onslaught_generator (0 .5 .8) (-32 -32 -24) (32 32 64)
Base generator.

spawnfunc_onslaught_link entities can target this.

keys:
"team" - team that owns this generator (5 = red, 14 = blue, etc), MUST BE SET.
"targetname" - name that spawnfunc_onslaught_link entities will use to target this.
*/
void spawnfunc_onslaught_generator()
{
	if (!g_onslaught)
	{
		remove(self);
		return;
	}

	local entity e;
	precache_model("models/onslaught/generator.md3");
	precache_model("models/onslaught/generator_shield.md3");
	precache_model("models/onslaught/generator_dmg1.md3");
	precache_model("models/onslaught/generator_dmg2.md3");
	precache_model("models/onslaught/generator_dead.md3");
	precache_sound("onslaught/generator_decay.wav");
	precache_sound("weapons/grenade_impact.wav");
	precache_sound("weapons/rocket_impact.wav");
	precache_sound("onslaught/generator_underattack.wav");
	if (!self.team)
		objerror("team must be set");
	self.team_saved = self.team;
	self.colormap = 1024 + (self.team - 1) * 17;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_NONE;
	self.lasthealth = self.max_health = self.health = cvar("g_onslaught_gen_health");
	setmodel(self, "models/onslaught/generator.md3");
	//setsize(self, '-32 -32 -24', '32 32 64');
	setorigin(self, self.origin);
	self.takedamage = DAMAGE_AIM;
	self.bot_attack = TRUE;
	self.event_damage = onslaught_generator_damage;
	self.iscaptured = TRUE;
	self.islinked = TRUE;
	self.isshielded = TRUE;
	// spawn shield model which indicates whether this can be damaged
	self.enemy = e = spawn();
	e.classname = "onslaught_generator_shield";
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
	e.effects = EF_ADDITIVE;
	setmodel(e, "models/onslaught/generator_shield.md3");
	//setsize(e, '-32 -32 0', '32 32 128');
	setorigin(e, self.origin);
	e.colormap = self.colormap;
	e.team = self.team;
	self.think = onslaught_generator_delayed;
	self.nextthink = time + 0.2;
	InitializeEntity(self, onslaught_generator_delayed, INITPRIO_LAST);

	WaypointSprite_SpawnFixed(string_null, e.origin + '0 0 1' * e.maxs_z, self, sprite);
	WaypointSprite_UpdateRule(self.sprite, COLOR_TEAM2, SPRITERULE_TEAMPLAY);

	onslaught_updatelinks();

	self.reset = onslaught_generator_reset;
};

.float waslinked;
.float cp_bob_spd;
.vector cp_origin, cp_bob_origin, cp_bob_dmg;
void onslaught_controlpoint_icon_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	entity oself;
	if (damage <= 0)
		return;
	if (self.owner.isshielded)
	{
		// this is protected by a shield, so ignore the damage
		if (time > self.pain_finished)
		if (attacker.classname == "player")
		{
			play2(attacker, "onslaught/damageblockedbyshield.wav");
			self.pain_finished = time + 1;
		}
		return;
	}
	if (time > self.pain_finished)
	if (attacker.classname == "player")
	{
		play2team(self.team, "onslaught/controlpoint_underattack.wav");
		self.pain_finished = time + 5;
	}
	self.health = self.health - damage;
	self.pain_finished = time + 1;
	self.punchangle = (2 * randomvec() - '1 1 1') * 45;
	self.cp_bob_dmg_z = (2 * random() - 1) * 15;
	// colormod flash when shot
	self.colormod = '2 2 2';
	if (self.health < 0)
	{
		sound(self, CHAN_TRIGGER, "weapons/grenade_impact.wav", VOL_BASE, ATTN_NORM);
		pointparticles(particleeffectnum("onslaught_controlpoint_explosion"), self.origin, '0 0 0', 1);
		{
			string t;
			t = ColoredTeamName(attacker.team);
			bprint(ColoredTeamName(self.team), " ", self.message, " control point destroyed by ", t, "\n");
			ons_trowgib(self.origin, (2 * randomvec() - '1 1 1') * 25,'1 1 1',"models/onslaught/controlpoint_icon_gib1.md3",5,1,1);
			ons_trowgib(self.origin, (2 * randomvec() - '1 1 1') * 45,'1 1 1',"models/onslaught/controlpoint_icon_gib2.md3",5,1,1);
			ons_trowgib(self.origin, (2 * randomvec() - '1 1 1') * 45,'1 1 1',"models/onslaught/controlpoint_icon_gib2.md3",5,1,1);
			ons_trowgib(self.origin, (2 * randomvec() - '1 1 1') * 75,'1 1 1',"models/onslaught/controlpoint_icon_gib4.md3",5,1,1);
			ons_trowgib(self.origin, (2 * randomvec() - '1 1 1') * 75,'1 1 1',"models/onslaught/controlpoint_icon_gib4.md3",5,1,1);
			ons_trowgib(self.origin, (2 * randomvec() - '1 1 1') * 75,'1 1 1',"models/onslaught/controlpoint_icon_gib4.md3",5,1,1);
			ons_trowgib(self.origin, (2 * randomvec() - '1 1 1') * 75,'1 1 1',"models/onslaught/controlpoint_icon_gib4.md3",5,1,1);
		}
		self.owner.goalentity = world;
		self.owner.islinked = FALSE;
		self.owner.iscaptured = FALSE;
		self.owner.team = 0;
		self.owner.colormap = 1024;
		onslaught_updatelinks();

		// Use targets now (somebody make sure this is in the right place..)
		oself = self;
		self = self.owner;
		activator = self;
		SUB_UseTargets ();
		self = oself;

		self.owner.waslinked = self.owner.islinked;
		if(self.owner.model != "models/onslaught/controlpoint_pad.md3")
			setmodel(self.owner, "models/onslaught/controlpoint_pad.md3");

		remove(self);
	}
};

void onslaught_controlpoint_icon_think()
{
	entity oself;
	self.nextthink = time + 0.05;
	if (time > self.pain_finished + 5)
	{
		self.health = self.health + self.count;
		if (self.health >= self.max_health)
			self.health = self.max_health;
	}
	if (self.health < self.max_health * 0.90)
		setmodel(self, "models/onslaught/controlpoint_icon.md3");
	if (self.health < self.max_health * 0.75)
		setmodel(self, "models/onslaught/controlpoint_icon_dmg1.md3");
	if (self.health < self.max_health * 0.50)
		setmodel(self, "models/onslaught/controlpoint_icon_dmg2.md3");
	if (self.health < self.max_health * 0.25)
		setmodel(self, "models/onslaught/controlpoint_icon_dmg3.md3");
	// colormod flash when shot
	self.colormod = '1 1 1' * (2 - bound(0, (self.pain_finished - time) / 10, 1));

	if(self.owner.islinked != self.owner.waslinked)
	{
		// unteam the spawnpoint if needed
		float t;
		t = self.owner.team;
		if(!self.owner.islinked)
			self.owner.team = 0;

		oself = self;
		self = self.owner;
		activator = self;
		SUB_UseTargets ();
		self = oself;

		self.owner.team = t;

		self.owner.waslinked = self.owner.islinked;
	}
	if (self.punchangle_x > 2)
		self.punchangle_x = self.punchangle_x - 2;
	else if (self.punchangle_x < -2)
		self.punchangle_x = self.punchangle_x + 2;
	else
		self.punchangle_x = 0;
	if (self.punchangle_y > 2)
		self.punchangle_y = self.punchangle_y - 2;
	else if (self.punchangle_y < -2)
		self.punchangle_y = self.punchangle_y + 2;
	else
		self.punchangle_y = 0;
	if (self.punchangle_z > 2)
		self.punchangle_z = self.punchangle_z - 2;
	else if (self.punchangle_z < -2)
		self.punchangle_z = self.punchangle_z + 2;
	else
		self.punchangle_z = 0;
	self.angles_x = self.punchangle_x;
	self.angles_y = self.angles_y + self.punchangle_y + 2;
	self.angles_z = self.punchangle_z;

	self.cp_bob_origin_z = 4 * PI * (1 - cos(self.cp_bob_spd / 8));
	self.cp_bob_spd = self.cp_bob_spd + 0.5;
	if(self.cp_bob_dmg_z > 0)
		self.cp_bob_dmg_z = self.cp_bob_dmg_z - 0.1;
	else
		self.cp_bob_dmg_z = 0;
	self.origin = self.cp_origin + self.cp_bob_origin + self.cp_bob_dmg;
};

void onslaught_controlpoint_icon_buildthink()
{
	local entity oself;
	float a;

	self.nextthink = time + 0.05;

	// only do this if there is power
	a = onslaught_controlpoint_can_be_linked(self.owner, self.owner.team);
	if(!a)
		return;

	self.health = self.health + (self.count / 2);

	if (self.health >= self.max_health)
	{
		self.health = self.max_health;
		self.count = self.count * 0.1; // slow repair rate from now on
		self.think = onslaught_controlpoint_icon_think;
		sound(self, CHAN_TRIGGER, "onslaught/controlpoint_built.wav", VOL_BASE, ATTN_NORM);
		bprint(ColoredTeamName(self.team), " captured ", self.owner.message, " control point\n");
		self.owner.iscaptured = TRUE;
		onslaught_updatelinks();

		// Use targets now (somebody make sure this is in the right place..)
		oself = self;
		self = self.owner;
		activator = self;
		SUB_UseTargets ();
		self = oself;
		self.cp_origin = self.origin;
		self.cp_bob_origin = '0 0 0.1';
		self.cp_bob_spd = 0;
	}
	self.alpha = self.health / self.max_health;
	// colormod flash when shot
	self.colormod = '1 1 1' * (2 - bound(0, (self.pain_finished - time) / 10, 1));
	if(self.owner.model != "models/onslaught/controlpoint_pad2.md3")
		setmodel(self.owner, "models/onslaught/controlpoint_pad2.md3");
};

void onslaught_controlpoint_touch()
{
	local entity e;
	float a;
	if (other.classname != "player")
		return;
	a = onslaught_controlpoint_attackable(self, other.team);
	if(a != 2 && a != 4)
		return;
	// we've verified that this player has a legitimate claim to this point,
	// so start building the captured point icon (which only captures this
	// point if it successfully builds without being destroyed first)
	self.goalentity = e = spawn();
	e.classname = "onslaught_controlpoint_icon";
	e.owner = self;
	e.max_health = cvar("g_onslaught_cp_health");
	e.health = e.max_health * 0.1;
	e.solid = SOLID_BBOX;
	e.movetype = MOVETYPE_NONE;
	setmodel(e, "models/onslaught/controlpoint_icon.md3");
	setsize(e, '-32 -32 -32', '32 32 32');
	setorigin(e, self.origin + '0 0 96');
	e.takedamage = DAMAGE_AIM;
	e.bot_attack = TRUE;
	e.event_damage = onslaught_controlpoint_icon_damage;
	e.team = other.team;
	e.colormap = 1024 + (e.team - 1) * 17;
	e.think = onslaught_controlpoint_icon_buildthink;
	e.nextthink = time + 0.1;
	e.count = e.max_health / 50; // how long it takes to build
	sound(e, CHAN_TRIGGER, "onslaught/controlpoint_build.wav", VOL_BASE, ATTN_NORM);
	self.team = e.team;
	self.colormap = e.colormap;
};

void onslaught_controlpoint_reset()
{
	if(self.goalentity && self.goalentity != world)
		remove(self.goalentity);
	self.goalentity = world;
	self.team = 0;
	self.colormap = 1024;
	self.iscaptured = FALSE;
	self.islinked = FALSE;
	self.isshielded = TRUE;
	self.enemy.solid = SOLID_NOT;
	self.enemy.colormap = self.colormap;
	self.think = self.enemy.think = SUB_Null;
	self.nextthink = 0; // don't like SUB_Null :P
	
	onslaught_updatelinks();

	activator = self;
	SUB_UseTargets(); // to reset the structures, playerspawns etc.
}

/*QUAKED spawnfunc_onslaught_controlpoint (0 .5 .8) (-32 -32 0) (32 32 128)
Control point.  Be sure to give this enough clearance so that the shootable part has room to exist

This should link to an spawnfunc_onslaught_controlpoint entity or spawnfunc_onslaught_generator entity.

keys:
"targetname" - name that spawnfunc_onslaught_link entities will use to target this.
"target" - target any entities that are tied to this control point, such as vehicles and buildable structure entities.
"message" - name of this control point (should reflect the location in the map, such as "center bridge", "north tower", etc)
*/
void spawnfunc_onslaught_controlpoint()
{
	local entity e;
	if (!g_onslaught)
	{
		remove(self);
		return;
	}
	precache_model("models/onslaught/controlpoint_pad.md3");
	precache_model("models/onslaught/controlpoint_pad2.md3");
	precache_model("models/onslaught/controlpoint_shield.md3");
	precache_model("models/onslaught/controlpoint_icon.md3");
	precache_model("models/onslaught/controlpoint_icon_dmg1.md3");
	precache_model("models/onslaught/controlpoint_icon_dmg2.md3");
	precache_model("models/onslaught/controlpoint_icon_dmg3.md3");
	precache_model("models/onslaught/controlpoint_icon_gib1.md3");
	precache_model("models/onslaught/controlpoint_icon_gib2.md3");
	precache_model("models/onslaught/controlpoint_icon_gib4.md3");
	precache_sound("onslaught/controlpoint_build.wav");
	precache_sound("onslaught/controlpoint_built.wav");
	precache_sound("weapons/grenade_impact.wav");
	precache_sound("onslaught/damageblockedbyshield.wav");
	precache_sound("onslaught/controlpoint_underattack.wav");
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_NONE;
	setmodel(self, "models/onslaught/controlpoint_pad.md3");
	//setsize(self, '-32 -32 0', '32 32 8');
	setorigin(self, self.origin);
	self.touch = onslaught_controlpoint_touch;
	self.team = 0;
	self.colormap = 1024;
	self.iscaptured = FALSE;
	self.islinked = FALSE;
	self.isshielded = TRUE;
	// spawn shield model which indicates whether this can be damaged
	self.enemy = e = spawn();
	e.classname = "onslaught_controlpoint_shield";
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
	e.effects = EF_ADDITIVE;
	setmodel(e, "models/onslaught/controlpoint_shield.md3");
	//setsize(e, '-32 -32 0', '32 32 128');
	setorigin(e, self.origin);
	e.colormap = self.colormap;

	waypoint_spawnforitem(self);

	WaypointSprite_SpawnFixed(string_null, e.origin + '0 0 1' * e.maxs_z, self, sprite);
	WaypointSprite_UpdateRule(self.sprite, COLOR_TEAM2, SPRITERULE_TEAMPLAY);

	onslaught_updatelinks();

	self.reset = onslaught_controlpoint_reset;
};

float onslaught_link_send(entity to, float sendflags)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_RADARLINK);
	WriteByte(MSG_ENTITY, sendflags);
	if(sendflags & 1)
	{
		WriteCoord(MSG_ENTITY, self.goalentity.origin_x);
		WriteCoord(MSG_ENTITY, self.goalentity.origin_y);
		WriteCoord(MSG_ENTITY, self.goalentity.origin_z);
	}
	if(sendflags & 2)
	{
		WriteCoord(MSG_ENTITY, self.enemy.origin_x);
		WriteCoord(MSG_ENTITY, self.enemy.origin_y);
		WriteCoord(MSG_ENTITY, self.enemy.origin_z);
	}
	if(sendflags & 4)
	{
		WriteByte(MSG_ENTITY, self.clientcolors); // which is goalentity's color + enemy's color * 16
	}
	return TRUE;
}

void onslaught_link_checkupdate()
{
	// TODO check if the two sides have moved (currently they won't move anyway)
	float redpower, bluepower;

	redpower = bluepower = 0;
	if(self.goalentity.islinked)
	{
		if(self.goalentity.team == COLOR_TEAM1)
			redpower = 1;
		else if(self.goalentity.team == COLOR_TEAM2)
			bluepower = 1;
	}
	if(self.enemy.islinked)
	{
		if(self.enemy.team == COLOR_TEAM1)
			redpower = 2;
		else if(self.enemy.team == COLOR_TEAM2)
			bluepower = 2;
	}

	float cc;
	if(redpower == 1 && bluepower == 2)
		cc = (COLOR_TEAM1 - 1) * 0x01 + (COLOR_TEAM2 - 1) * 0x10;
	else if(redpower == 2 && bluepower == 1)
		cc = (COLOR_TEAM1 - 1) * 0x10 + (COLOR_TEAM2 - 1) * 0x01;
	else if(redpower)
		cc = (COLOR_TEAM1 - 1) * 0x11;
	else if(bluepower)
		cc = (COLOR_TEAM2 - 1) * 0x11;
	else
		cc = 0;

	if(cc != self.clientcolors)
	{
		self.clientcolors = cc;
		self.SendFlags |= 4;
	}

	self.nextthink = time;
}

void onslaught_link_delayed()
{
	self.goalentity = find(world, targetname, self.target);
	self.enemy = find(world, targetname, self.target2);
	if (!self.goalentity)
		objerror("can not find target\n");
	if (!self.enemy)
		objerror("can not find target2\n");
	dprint(etos(self.goalentity), " linked with ", etos(self.enemy), "\n");

	self.SendFlags |= 3;
	self.think = onslaught_link_checkupdate;
	self.nextthink = time;
}

/*QUAKED spawnfunc_onslaught_link (0 .5 .8) (-16 -16 -16) (16 16 16)
Link between control points.

This entity targets two different spawnfunc_onslaught_controlpoint or spawnfunc_onslaught_generator entities, and suppresses shielding on both if they are owned by different teams.

keys:
"target" - first control point.
"target2" - second control point.
*/
void spawnfunc_onslaught_link()
{
	if (!g_onslaught)
	{
		remove(self);
		return;
	}
	if (self.target == "" || self.target2 == "")
		objerror("target and target2 must be set\n");
	InitializeEntity(self, onslaught_link_delayed, INITPRIO_FINDTARGET);
	Net_LinkEntity(self, FALSE, 0, onslaught_link_send);
};
