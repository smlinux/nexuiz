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

float ons_sprite_cp_red, ons_sprite_cp_blue, ons_sprite_cp_neut;
float ons_sprite_cp_atck_red, ons_sprite_cp_atck_blue, ons_sprite_cp_atck_neut;
float ons_sprite_cp_dfnd_red, ons_sprite_cp_dfnd_blue;
float ons_sprite_gen_red, ons_sprite_gen_blue, ons_sprite_gen_shielded;

void() onslaught_updatelinks =
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

void() onslaught_generator_think =
{
	local float d;
	local entity e;
	self.nextthink = ceil(time + 1);
	if (cvar("timelimit"))
	if (time > cvar("timelimit") * 60 - 60)
	{
		// self.max_health / 300 gives 5 minutes of overtime.
		// control points reduce the overtime duration.
		sound(self, CHAN_AUTO, "sound/onslaught/generator_decay.wav", 1, ATTN_NORM);
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

void() onslaught_generator_deaththink =
{
	local vector org;
	if (self.count > 0)
	{
		self.nextthink = time + 0.1;
		self.count = self.count - 1;
		org = randompos(self.origin + self.mins + '8 8 8', self.origin + self.maxs + '-8 -8 -8');
		pointparticles(particleeffectnum("onslaught_generator_smallexplosion"), org, '0 0 0', 1);
		sound(self, CHAN_AUTO, "sound/weapons/grenade_impact.wav", 1, ATTN_NORM);
	}
	else
	{
		org = self.origin;
		pointparticles(particleeffectnum("onslaught_generator_finalexplosion"), org, '0 0 0', 1);
		sound(self, CHAN_AUTO, "sound/weapons/rocket_impact.wav", 1, ATTN_NORM);
	}
};

void(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) onslaught_generator_damage =
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
				play2(attacker, "sound/onslaught/damageblockedbyshield.wav");
				self.pain_finished = time + 1;
			}
			return;
		}
		if (time > self.pain_finished)
		{
			self.pain_finished = time + 5;
			bprint(ColoredTeamName(self.team), " generator under attack!\n");
			play2team(self.team, "sound/onslaught/generator_underattack.wav");
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
};

// update links after a delay
void() onslaught_generator_delayed =
{
	onslaught_updatelinks();
	// now begin normal thinking
	self.think = onslaught_generator_think;
	self.nextthink = time;
};

float onslaught_generator_waypointsprite_for_player(entity e)
{
	if(e.classname == "player")
		if(e.team == self.owner.team)
		{
			if(self.owner.team == COLOR_TEAM1)
				return ons_sprite_gen_red;
			else if(self.owner.team == COLOR_TEAM2)
				return ons_sprite_gen_blue;
		}
	if(self.owner.isshielded)
		return ons_sprite_gen_shielded;
	if(self.owner.team == COLOR_TEAM1)
		return ons_sprite_gen_red;
	else if(self.owner.team == COLOR_TEAM2)
		return ons_sprite_gen_blue;
	return 0;
}

float onslaught_controlpoint_waypointsprite_for_player(entity e)
{
	float a;
	if(e.classname == "player")
	{
		a = onslaught_controlpoint_attackable(self.owner, e.team);
		if(a == 3 || a == 4) // ATTACK/TOUCH THIS ONE NOW
		{
			if(self.owner.team == COLOR_TEAM1)
				return ons_sprite_cp_atck_red;
			else if(self.owner.team == COLOR_TEAM2)
				return ons_sprite_cp_atck_blue;
			else
				return ons_sprite_cp_atck_neut;
		}
		else if(a == -2) // DEFEND THIS ONE NOW
		{
			if(self.owner.team == COLOR_TEAM1)
				return ons_sprite_cp_dfnd_red;
			else if(self.owner.team == COLOR_TEAM2)
				return ons_sprite_cp_dfnd_blue;
		}
		else if(self.owner.team == e.team || a == -1 || a == 1) // own point, or fire at it
		{
			if(self.owner.team == COLOR_TEAM1)
				return ons_sprite_cp_red;
			else if(self.owner.team == COLOR_TEAM2)
				return ons_sprite_cp_blue;
		}
		else if(a == 2) // touch it
			return ons_sprite_cp_neut;
	}
	else
	{
		if(self.owner.team == COLOR_TEAM1)
			return ons_sprite_cp_red;
		else if(self.owner.team == COLOR_TEAM2)
			return ons_sprite_cp_blue;
		else
			return ons_sprite_cp_neut;
	}
	return 0;
}

/*QUAKED onslaught_generator (0 .5 .8) (-32 -32 -24) (32 32 64)
Base generator.

onslaught_link entities can target this.

keys:
"team" - team that owns this generator (5 = red, 14 = blue, etc), MUST BE SET.
"targetname" - name that onslaught_link entities will use to target this.
*/
void() onslaught_generator =
{
	if (!g_onslaught)
	{
		remove(self);
		return;
	}

	if(!ons_sprite_cp_blue)
	{
		precache_model("models/sprites/ons-cp-blue.sp2");
		setmodel(self, "models/sprites/ons-cp-blue.sp2");
		ons_sprite_cp_blue = self.modelindex;
		precache_model("models/sprites/ons-cp-red.sp2");
		setmodel(self, "models/sprites/ons-cp-red.sp2");
		ons_sprite_cp_red = self.modelindex;
		precache_model("models/sprites/ons-cp-neut.sp2");
		setmodel(self, "models/sprites/ons-cp-neut.sp2");
		ons_sprite_cp_neut = self.modelindex;
		precache_model("models/sprites/ons-cp-dfnd-blue.sp2");
		setmodel(self, "models/sprites/ons-cp-dfnd-blue.sp2");
		ons_sprite_cp_dfnd_blue = self.modelindex;
		precache_model("models/sprites/ons-cp-dfnd-red.sp2");
		setmodel(self, "models/sprites/ons-cp-dfnd-red.sp2");
		ons_sprite_cp_dfnd_red = self.modelindex;
		precache_model("models/sprites/ons-cp-atck-blue.sp2");
		setmodel(self, "models/sprites/ons-cp-atck-blue.sp2");
		ons_sprite_cp_atck_blue = self.modelindex;
		precache_model("models/sprites/ons-cp-atck-red.sp2");
		setmodel(self, "models/sprites/ons-cp-atck-red.sp2");
		ons_sprite_cp_atck_red = self.modelindex;
		precache_model("models/sprites/ons-cp-atck-neut.sp2");
		setmodel(self, "models/sprites/ons-cp-atck-neut.sp2");
		ons_sprite_cp_atck_neut = self.modelindex;
		precache_model("models/sprites/ons-gen-blue.sp2");
		setmodel(self, "models/sprites/ons-gen-blue.sp2");
		ons_sprite_gen_blue = self.modelindex;
		precache_model("models/sprites/ons-gen-red.sp2");
		setmodel(self, "models/sprites/ons-gen-red.sp2");
		ons_sprite_gen_red = self.modelindex;
		precache_model("models/sprites/ons-gen-shielded.sp2");
		setmodel(self, "models/sprites/ons-gen-shielded.sp2");
		ons_sprite_gen_shielded = self.modelindex;
	}

	local entity e;
	precache_model("models/onslaught/generator.md3");
	precache_model("models/onslaught/generator_shield.md3");
	precache_sound("sound/onslaught/generator_decay.wav");
	precache_sound("sound/weapons/grenade_impact.wav");
	precache_sound("sound/weapons/rocket_impact.wav");
	precache_sound("sound/onslaught/generator_underattack.wav");
	if (!self.team)
		objerror("team must be set");
	self.colormap = 1024 + (self.team - 1) * 17;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_NONE;
	self.lasthealth = self.max_health = self.health = 3000;
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

	WaypointSprite_SpawnFixed(string_null, e.origin + '0 0 1' * e.maxs_z, self, sprite);
	self.sprite.waypointsprite_for_player = onslaught_generator_waypointsprite_for_player;
};

void(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) onslaught_controlpoint_icon_damage =
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
			play2(attacker, "sound/onslaught/damageblockedbyshield.wav");
			self.pain_finished = time + 1;
		}
		return;
	}
	if (time > self.pain_finished)
	if (attacker.classname == "player")
	{
		play2team(self.team, "sound/onslaught/controlpoint_underattack.wav");
		self.pain_finished = time + 5;
	}
	self.health = self.health - damage;
	self.alpha = self.health / self.max_health;
	self.pain_finished = time + 1;
	// colormod flash when shot
	self.colormod = '2 2 2';
	if (self.health < 0)
	{
		sound(self, CHAN_AUTO, "sound/weapons/grenade_impact.wav", 1, ATTN_NORM);
		pointparticles(particleeffectnum("onslaught_controlpoint_explosion"), self.origin, '0 0 0', 1);
		{
			string t;
			t = ColoredTeamName(attacker.team);
			bprint(ColoredTeamName(self.team), " ", self.message, " control point destroyed by ", t, "\n");
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
		activator = self.owner;
		SUB_UseTargets ();
		self = oself;

		remove(self);
	}
};

void() onslaught_controlpoint_icon_think =
{
	self.nextthink = time + 0.1;
	if (time > self.pain_finished + 1)
	{
		self.health = self.health + self.count;
		if (self.health >= self.max_health)
			self.health = self.max_health;
	}
	self.alpha = self.health / self.max_health;
	// colormod flash when shot
	self.colormod = '1 1 1' * (2 - bound(0, (self.pain_finished - time) / 10, 1));
};

void() onslaught_controlpoint_icon_buildthink =
{
	local entity oself;

	self.nextthink = time + 0.1;
	self.health = self.health + self.count;
	if (self.health >= self.max_health)
	{
		self.health = self.max_health;
		self.count = self.count * 0.2; // slow repair rate from now on
		self.think = onslaught_controlpoint_icon_think;
		sound(self, CHAN_BODY, "sound/onslaught/controlpoint_built.wav", 1, ATTN_NORM);
		bprint(ColoredTeamName(self.team), " captured ", self.owner.message, " control point\n");
		self.owner.iscaptured = TRUE;
		onslaught_updatelinks();

		// Use targets now (somebody make sure this is in the right place..)
		oself = self;
		self = self.owner;
		activator = self;
		SUB_UseTargets ();
		self = oself;
	}
	self.alpha = self.health / self.max_health;
	// colormod flash when shot
	self.colormod = '1 1 1' * (2 - bound(0, (self.pain_finished - time) / 10, 1));
};

void() onslaught_controlpoint_touch =
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
	e.owner = self;
	e.max_health = 1000;
	e.health = e.max_health * 0.1;
	e.alpha = e.health / e.max_health;
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
	sound(e, CHAN_BODY, "sound/onslaught/controlpoint_build.wav", 1, ATTN_NORM);
	self.team = e.team;
	self.colormap = e.colormap;
};

/*QUAKED onslaught_controlpoint (0 .5 .8) (-32 -32 0) (32 32 128)
Control point.  Be sure to give this enough clearance so that the shootable part has room to exist

This should link to an onslaught_controlpoint entity or onslaught_generator entity.

keys:
"targetname" - name that onslaught_link entities will use to target this.
"target" - target any entities that are tied to this control point, such as vehicles and buildable structure entities.
"message" - name of this control point (should reflect the location in the map, such as "center bridge", "north tower", etc)
*/
void() onslaught_controlpoint =
{
	local entity e;
	if (!g_onslaught)
	{
		remove(self);
		return;
	}
	precache_model("models/onslaught/controlpoint_pad.md3");
	precache_model("models/onslaught/controlpoint_shield.md3");
	precache_model("models/onslaught/controlpoint_icon.md3");
	precache_sound("sound/onslaught/controlpoint_build.wav");
	precache_sound("sound/onslaught/controlpoint_built.wav");
	precache_sound("sound/weapons/grenade_impact.wav");
	precache_sound("sound/onslaught/damageblockedbyshield.wav");
	precache_sound("sound/onslaught/controlpoint_underattack.wav");
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
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
	e.effects = EF_ADDITIVE;
	setmodel(e, "models/onslaught/controlpoint_shield.md3");
	//setsize(e, '-32 -32 0', '32 32 128');
	setorigin(e, self.origin);
	e.colormap = self.colormap;
	onslaught_updatelinks();

	WaypointSprite_SpawnFixed(string_null, e.origin + '0 0 1' * e.maxs_z, self, sprite);
	self.sprite.waypointsprite_for_player = onslaught_controlpoint_waypointsprite_for_player;
};

void() onslaught_link_delayed =
{
	self.goalentity = find(world, targetname, self.target);
	self.enemy = find(world, targetname, self.target2);
	if (!self.goalentity)
		objerror("can not find target\n");
	if (!self.enemy)
		objerror("can not find target2\n");
	dprint(etos(self.goalentity), " linked with ", etos(self.enemy), "\n");
}

/*QUAKED onslaught_link (0 .5 .8) (-16 -16 -16) (16 16 16)
Link between control points.

This entity targets two different onslaught_controlpoint or onslaught_generator entities, and suppresses shielding on both if they are owned by different teams.

keys:
"target" - first control point.
"target2" - second control point.
*/
void() onslaught_link =
{
	if (!g_onslaught)
	{
		remove(self);
		return;
	}
	if (self.target == "" || self.target2 == "")
		objerror("target and target2 must be set\n");
	self.think = onslaught_link_delayed;
	self.nextthink = time + 0.1;
};
