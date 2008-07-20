//=============================================================================

/*QUAKED spawnfunc_info_player_attacker (1 0 0) (-16 -16 -24) (16 16 45) INITIAL
Normal attacker spawning location for Nexuiz Asssault
-------- KEYS --------
angle : direction in which player will look when spawning in the game. Does not apply to bots.
target : this should point to a spawnfunc_target_objective to decide when this spawning point is active.
nobots : when set to 1, bots will never use this spawn point to respawn in the game.
nohumans : when set to 1, human players will never use this spawn point to respawn in the game.
notfree : when set to 1, entity will not spawn in "Free for all" and "Tournament" modes.
notteam : when set to 1, entity will not spawn in "Teamplay" and "CTF" modes.
notsingle : when set to 1, entity will not spawn in Single Player mode (bot play mode).
-------- SPAWNFLAGS --------
INITIAL : makes the spawnpoint the initial place for the player to spawn at the beginning of the game.*/
void spawnfunc_info_player_attacker() {
	spawnfunc_info_player_deathmatch();
	self.team = COLOR_TEAM1; // red, gets swapped every round
}

//=============================================================================

/*QUAKED spawnfunc_info_player_defender (0 1 0) (-16 -16 -24) (16 16 45) INITIAL
Normal defender spawning location for Nexuiz Asssault
-------- KEYS --------
angle : direction in which player will look when spawning in the game. Does not apply to bots.
target : this should point to a spawnfunc_target_objective to decide when this spawning point is active.
nobots : when set to 1, bots will never use this spawn point to respawn in the game.
nohumans : when set to 1, human players will never use this spawn point to respawn in the game.
notfree : when set to 1, entity will not spawn in "Free for all" and "Tournament" modes.
notteam : when set to 1, entity will not spawn in "Teamplay" and "CTF" modes.
notsingle : when set to 1, entity will not spawn in Single Player mode (bot play mode).
-------- SPAWNFLAGS --------
INITIAL : makes the spawnpoint the initial place for the player to spawn at the beginning of the game.*/
void spawnfunc_info_player_defender() {
	spawnfunc_info_player_deathmatch();
	self.team = COLOR_TEAM2; // blue, gets swapped every round
}

// reset this objective. Used when spawning an objective
// and when a new round starts
void assault_objective_reset() {
	self.health = ASSAULT_VALUE_INACTIVE;
}

void assault_objective_use() {
	// activate objective
	self.health = 100; 
	self.nextthink = time + 0.1;
}

void assault_objective_think() {
	if(self.health < 0) {
		//self.effects = 0;
		activator = self;
		SUB_UseTargets();
	} else {
		//self.effects = EF_STARDUST;
		self.nextthink = time + 0.1;
	}
	
}
//=============================================================================

/*QUAKED spawnfunc_target_objective (0 .5 0) (-8 -8 -8) (8 8 8)
Objective controller for Nexuiz Assault. When active it has 100 health. If it falls below 0 then
it'll trigger the next targeted entity (usually the next objective or spawnfunc_target_assault_roundend etc.)
-------- KEYS --------
targetname : point to e.g. next objective*/
void spawnfunc_target_objective() {
	self.classname = "target_objective";
	self.think = assault_objective_think;
	self.use = assault_objective_use;
	assault_objective_reset();
}

float assault_objective_decrease_customizeforclient() {
	if(!self.spawnflags)
		return FALSE;

	if(self.cnt == 0) {
		if(other.team == assault_attacker_team)
			if(self.spawnflags == 1)
				setmodel(self, "models/sprites/push.sp2");
			else
				setmodel(self, "models/sprites/destroy.sp2");
		else
			setmodel(self, "models/sprites/defend.sp2");
	} else {
		return FALSE;
	}
	return TRUE;
}


void assault_objective_decrease_think() {

	local entity objective;
	local float found;
	found = 0;
	objective = find(world, targetname, self.target);
	while(objective && found == 0) {
		if(objective.classname == "target_objective") {
			found = 1;
			if(objective.health < ASSAULT_VALUE_INACTIVE) { // targeted objective is active
				if(self.cnt == 1 && self.max_health >= ASSAULT_VALUE_INACTIVE) { 
					// decrease was fired already, but objective did recover (round reset)
					self.cnt = 0;
				}
			} else { // objective isn't active
				self.cnt = 1;
			}
			self.max_health = objective.health; // save current objective status for next think
		}
	}

	if(!self.spawnflags) {
		local entity ent;
		ent = find(world, target, self.targetname);
		if(ent) {
			if(ent.classname == "func_assault_destructible")
				self.spawnflags = 2;
			else
				self.spawnflags = 1;
		}
	}

	self.nextthink = time + 0.2;
}


// decrease the health of targeted objectives
void assault_objective_decrease_use() {

	if(self.cnt > 0) {
		// did already fire
		return;
	}

	if(activator.team != assault_attacker_team) {
		// wrong team triggered decrease
		return;
	}

	local entity ent;
	ent = find(world, targetname, self.target);
	while(ent) {
		if(ent.health > 0 && ent.health < ASSAULT_VALUE_INACTIVE)
			ent.health = ent.health - self.dmg;
		ent = find(ent, targetname, self.target);
	}

	self.cnt = 1;
}

//=============================================================================

/*QUAKED target_objective_decrease (0 .5 0) (-8 -8 -8) (8 8 8)
When triggered decreases health of the targeted spawnfunc_target_objective.
-------- KEYS --------
targetname : point to a spawnfunc_target_objective entity*/
void spawnfunc_target_objective_decrease() {

	self.classname = "target_objective_decrease";

	precache_model("models/sprites/defend.sp2");
	precache_model("models/sprites/destroy.sp2");
	precache_model("models/sprites/push.sp2");

	if(!self.dmg) {
		self.dmg = 101;
	}
	self.cnt = 0; // not used yet
	self.use = assault_objective_decrease_use;
	self.mdl = "models/sprites/here.sp2";
	self.effects = EF_NODEPTHTEST;
	self.health = ASSAULT_VALUE_INACTIVE;
	self.max_health = ASSAULT_VALUE_INACTIVE;
	self.think = assault_objective_decrease_think;
	self.customizeentityforclient = assault_objective_decrease_customizeforclient;
	self.nextthink = time;
}


void assault_destructible_reset() {
	self.health = self.max_health;
	self.model = self.mdl;
	self.solid = SOLID_BSP;
	self.colormod = '1 1 1';
	self.cnt = 0; // not active
	if(self.spawnflags)
	{
		activator = self;
		self.use();
	}
}

void assault_destructible_use() {
	self.cnt = 1; // mark active
	self.takedamage = DAMAGE_YES;
}

void assault_destructible_destroy() {
	self.model = "";
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	SUB_UseTargets();
}

void assault_destructible_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) {

	if(self.cnt > 0 && assault_attacker_team == attacker.team) {
		self.health = self.health - damage;
		if(self.health / self.max_health < 0.25)
			self.colormod = '1 0 0';
		else if(self.health / self.max_health < 0.375)
			self.colormod = '1 0.25 0';
		else if(self.health / self.max_health < 0.50)
			self.colormod = '1 0.5 0';
		else if(self.health / self.max_health < 0.625)
			self.colormod = '1 0.75 0';
		else if(self.health / self.max_health < 0.75)
			self.colormod = '1 1 0';
		else
			self.colormod = '1 1 1';
	}

	if(self.health < 0) {
		activator = attacker;
		assault_destructible_destroy();
	}
}

// destructible walls that can be used to trigger target_objective_decrease
void spawnfunc_func_assault_destructible() {
	if(!self.health)
		self.health = 100;

	self.max_health = self.health;
	
	self.cnt = 0; // not yet activated

	self.classname = "func_assault_destructible";
	self.mdl = self.model;
	setmodel(self, self.mdl);

	self.solid = SOLID_BSP;
	self.use = assault_destructible_use;
	self.event_damage = assault_destructible_damage;

}

void assault_wall_think() {
	local entity ent;
	local float notvisible;
	notvisible = 0;
	ent = find(world, targetname, self.target);
	while(ent) {
		if(ent.classname == "target_objective" && ent.health < 0)
			notvisible = 1;
		ent = find(ent, targetname, self.target);
	}

	if(notvisible) {
		self.model = "";
		self.solid = SOLID_NOT;
	} else {
		self.model = self.mdl;
		self.solid = SOLID_BSP;
	}

	self.nextthink = time + 0.2;
}

void spawnfunc_func_assault_wall() {
	self.classname = "func_assault_wall";
	self.mdl = self.model;
	setmodel(self, self.mdl);
	self.solid = SOLID_BSP;
	self.think = assault_wall_think;
	self.nextthink = time;
}


void target_assault_roundend_reset() {
	self.cnt = self.cnt + 1; // up round counter
	self.winning = 0; // up round 
}

void target_assault_roundend_use() {
	self.winning = 1; // round has been won by attackers
}

void spawnfunc_target_assault_roundend() {
	if(!self.health)
		self.health = 300; // 5 minutes

	cvar_set("timelimit", ftos(self.health/60));
	self.winning = 0; // round not yet won by attackers
	self.classname = "target_assault_roundend";
	self.use = target_assault_roundend_use;
	self.cnt = 0; // first round
}

void assault_roundstart_use() {
	activator = self;
	SUB_UseTargets();
}

void spawnfunc_target_assault_roundstart() {
	assault_attacker_team = COLOR_TEAM1;
	self.classname = "target_assault_roundstart";
	self.use = assault_roundstart_use;
	self.think = assault_roundstart_use;
	self.nextthink = time + 0.1;
}

// trigger new round
// reset objectives, toggle spawnpoints, reset triggers, ...
void assault_new_round() {
	
	// up round counter
	self.winning = self.winning + 1;
	// set end time for next round
	self.cnt = time + self.health;

	// swap spawn point teams
	local entity ent;
	local entity oldself;

	// reward attackers for winning the round
	ent = find(world, classname, "player");
	while(ent) {
		if(ent.team == assault_attacker_team) {
			UpdateFrags(ent, 10);
		}
		ent = find(ent, classname, "player");
	}

	// swap attacker/defender roles
	if(assault_attacker_team == COLOR_TEAM1) {
		assault_attacker_team = COLOR_TEAM2;
	} else {
		assault_attacker_team = COLOR_TEAM1;
	}

	ent = find(world, classname, "info_player_deathmatch");
	while (ent)
	{
		oldself = self;
		self = ent;
		if(self.team == COLOR_TEAM1) {
			self.team = COLOR_TEAM2;
		} else {
			self.team = COLOR_TEAM1;
		}
		self = oldself;

		ent = find(ent, classname, "info_player_deathmatch");
	} 

	// reset all objectives
	ent = find(world, classname, "target_objective");
	while (ent)
	{
		oldself = self;
		self = ent;
		assault_objective_reset();
		self = oldself;

		ent = find(ent, classname, "target_objective");
	} 

	// reset round end triggers
	ent = find(world, classname, "target_assault_roundend");
	while (ent)
	{
		oldself = self;
		self = ent;
		target_assault_roundend_reset();
		self = oldself;

		ent = find(ent, classname, "target_assault_roundend");
	}

	// reset all target_object_decrease
	ent = find(world, classname, "target_objective_decrease");
	while (ent)
	{
		ent.cnt = 0;
		ent = find(ent, classname, "target_objective_decrease");
	} 

	// reset all spawnfunc_func_assault_destructible
	ent = find(world, classname, "func_assault_destructible");
	while (ent)
	{
		oldself = self;
		self = ent;
		assault_destructible_reset();
		self = oldself;
		ent = find(ent, classname, "func_assault_destructible");
	}

	ent = find(world, classname, "target_assault_roundstart");
	while (ent)
	{
		oldself = self;
		self = ent;
		self.use();
		self = oldself;
		ent = find(ent, classname, "target_assault_roundstart");
	}

	// actually restart round... how to do that?
	ent = find(world, classname, "player");
	while(ent) {
		oldself = self;
		self = ent;
		PutClientInServer();
		self = oldself;
		ent = find(ent, classname, "player");
	}


}


