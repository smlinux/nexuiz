
// attacker spawn point
void info_player_attacker() {
	self.team = COLOR_TEAM1; // red, gets swapped every round
	info_player_deathmatch();
}

// defender spawn point
void info_player_defender() {
	self.team = COLOR_TEAM2; // blue, gets swapped every round
	info_player_deathmatch();
}

// reset this objective. Used when spawning an objective
// and when a new round starts
void assault_objective_reset() {
	if(self.spawnflags) { // first objective
		self.health = 100;
		self.nextthink = time + 0.1;
	} else {
		self.health = ASSAULT_VALUE_INACTIVE;
	}
}

void assault_objective_use() {
	// activate objective
	self.health = 100; 
	self.nextthink = time + 0.1;
}

void assault_objective_think() {
	
	if(self.health < 0) {
		local entity ent;
		ent = find(world, targetname, self.target);
		self = ent;
		self.use();
	} else {
		self.nextthink = time + 0.1;
	}
	
}

void func_objective() {
	self.classname = "func_objective";
	self.think = assault_objective_think;
	self.use = assault_objective_use;
	assault_objective_reset();
}

// trigger new round
// reset objectives, toggle spawnpoints, reset triggers, ...
void assault_new_round() {
	
	// this assumes self.classname == "func_assault_roundend"!
	self.cnt = self.cnt + 1;

	// swap spawn point teams
	local entity ent;
	local entity oldself;

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

	ent = find(world, classname, "func_objective");
	while (ent)
	{
		oldself = self;
		self = ent;
		assault_objective_reset();
		self = oldself;

		ent = find(ent, classname, "func_objective");
	} 

	// actually restart round... how to do that?
}

void func_assault_roundend() {
	self.cnt = 0; // round counter
	self.classname = "func_assault_roundend";
	self.use = assault_new_round;
	
}
