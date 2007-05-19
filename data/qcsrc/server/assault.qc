
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
	local entity oldself;	
	if(self.health < 0) {
		//self.effects = 0;
		local entity ent;
		ent = find(world, targetname, self.target);
		while(ent) {
			oldself = self;
			self = ent;
			self.use();
			self = oldself;
			ent = find(ent, targetname, self.target);
			
		}
	} else {
		//self.effects = EF_STARDUST;
		self.nextthink = time + 0.1;
	}
	
}

void target_objective() {
	self.classname = "target_objective";
	self.think = assault_objective_think;
	self.use = assault_objective_use;
	assault_objective_reset();
}


void assault_objective_decrease_think() {

	local entity objective;
	local float found;
	found = 0;
	objective = find(world, targetname, self.target);
	while(objective && found == 0) {
		if(objective.classname = "target_objective") {
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

	if(self.cnt == 0) {
		if(self.model != self.mdl)
			setmodel(self, self.mdl);
	} else {
		self.model = "";
	}

	self.nextthink = time + 0.2;
}


// decrease the health of targeted objectives
void assault_objective_decrease() {

	local entity ent;
	ent = find(world, targetname, self.target);
	while(ent) {
		if(ent.health > 0 && ent.health < ASSAULT_VALUE_INACTIVE)
			ent.health = ent.health - self.dmg;
		ent = find(ent, targetname, self.target);
	}

	self.cnt = 1;
}

// this entity should target an objective and be targeted by triggers
void target_objective_decrease() {

	self.classname = "target_objective_decrease";

	if(!self.dmg) {
		self.dmg = 101;
	}
	self.cnt = 0; // not used yet
	self.use = assault_objective_decrease;
	self.mdl = "models/sprites/here.sp2";
	self.effects = EF_NODEPTHTEST;
	self.health = ASSAULT_VALUE_INACTIVE;
	self.max_health = ASSAULT_VALUE_INACTIVE;
	self.think = assault_objective_decrease_think;
	self.nextthink = time;
}


void assault_destructible_reset() {
	self.health = self.max_health;
	self.model = self.mdl;
	self.solid = SOLID_BSP;
	self.cnt = 0; // not active
	if(self.spawnflags)
		self.use();
}

void assault_destructible_use() {
	self.cnt = 1; // mark active
	self.takedamage = DAMAGE_YES;
	self.nextthink = time + 0.1;
}

void assault_destructible_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) {
	// TODO: check for teams	

	if(self.cnt > 0)	
		self.health = self.health - damage;

}


void assault_destructible_think() {
	local entity oldself;

	if(self.cnt > 0 && self.health < 0) {
		self.model = "";
		self.takedamage = DAMAGE_NO;
		self.solid = SOLID_NOT;
		local entity ent;
		ent = find(world, targetname, self.target);
		while(ent) {
			oldself = self;
			self = ent;
			self.use();
			self = oldself;
			ent = find(ent, targetname, self.target);
		}
	} else {
		self.nextthink = time + 0.1;
	}
}

// destructible walls that can be used to trigger target_objective_decrease
void func_assault_destructible() {
	if(!self.health)
		self.health = 100;

	self.max_health = self.health;
	
	self.cnt = 0; // not yet activated

	self.classname = "func_assault_destructible";
	self.mdl = self.model;
	setmodel(self, self.mdl);

	self.solid = SOLID_BSP;
	self.think = assault_destructible_think;
	self.use = assault_destructible_use;
	self.event_damage = assault_destructible_damage;

	if(self.spawnflags) // active from start
		self.use();
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
	ent = find(world, classname, "target_objective");
	while (ent)
	{
		oldself = self;
		self = ent;
		assault_objective_reset();
		self = oldself;

		ent = find(ent, classname, "target_objective");
	} 

	// reset all target_object_decrease
	ent = find(world, classname, "target_objective_decrease");
	while (ent)
	{
		ent.cnt = 0;
		ent = find(ent, classname, "target_objective_decrease");
	} 

	// reset all func_assault_destructible
	ent = find(world, classname, "func_assault_destructible");
	while (ent)
	{
		oldself = self;
		self = ent;
		assault_destructible_reset();
		self = oldself;
		ent = find(ent, classname, "func_assault_destructible");
	}

	// actually restart round... how to do that?
}

void target_assault_roundend() {
	self.cnt = 0; // round counter
	self.classname = "target_assault_roundend";
	self.use = assault_new_round;
}


