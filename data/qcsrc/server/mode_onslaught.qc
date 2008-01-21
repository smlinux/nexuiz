
.string target2;
.float iscaptured;
.float islinked;
.float isshielded;
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
			}
			if (l.enemy.islinked)
			{
				dprint(etos(l), " (link) is unshielding ", etos(l.goalentity), " (point) because its team does not match ", etos(l.enemy), " (point)\n");
				l.goalentity.isshielded = FALSE;
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
		bprint(ColoredTeamName(self.team), " generator has ", ftos(floor(self.health)), " health remaining\n");
	else
	{
		if (attacker == self)
			bprint(ColoredTeamName(self.team), " generator spontaneously exploded due to overtime!\n");
		else
			bprint(ColoredTeamName(self.team), " generator destroyed by ", ColoredTeamName(attacker.team), "!\n");
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
	self.max_health = self.health = 3000;
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
};

void(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) onslaught_controlpoint_icon_damage =
{
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
		bprint(ColoredTeamName(self.team), " ", self.message, " control point destroyed by ", ColoredTeamName(attacker.team), "\n");
		self.owner.goalentity = world;
		self.owner.islinked = FALSE;
		self.owner.iscaptured = FALSE;
		self.owner.team = 0;
		self.owner.colormap = 1024;
		onslaught_updatelinks();
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
	oself = self;

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
	if (other.classname != "player")
		return;
	// if there's already an icon built, nothing happens
	if (self.goalentity)
	{
		dprint("a\n");
		return;
	}
	// shielded points are definitely off-limits
	if (self.isshielded)
	{
		dprint("b\n");
		return;
	}
	// check to see if this player has a legitimate claim to capture this
	// control point - more specifically that there is a captured path of
	// points leading back to the team generator
	e = findchain(classname, "onslaught_link");
	while (e)
	{
		if (e.goalentity == self)
		{
			dprint(etos(e), " (link) connects to ", etos(e.enemy), " (point)");
			if (e.enemy.islinked)
			{
				dprint(" which is linked");
				if (e.enemy.team == other.team)
				{
					dprint(" and has the correct team!\n");
					break;
				}
				else
					dprint(" but has the wrong team\n");
			}
			else
				dprint("\n");
		}
		else if (e.enemy == self)
		{
			dprint(etos(e), " (link) connects to ", etos(e.goalentity), " (point)");
			if (e.goalentity.islinked)
			{
				dprint(" which is linked");
				if (e.goalentity.team == other.team)
				{
					dprint(" and has a team!\n");
					break;
				}
				else
					dprint(" but has the wrong team\n");
			}
			else
				dprint("\n");
		}
		e = e.chain;
	}
	if (!e)
	{
		dprint("c\n");
		return;
	}
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

void() onslaught_spawnpoint_use =
{
	self.team = activator.team;
};