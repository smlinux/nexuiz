void spawnfunc_func_breakable();
void target_objective_decrease_activate();
.entity assault_decreaser;
.entity sprite;

void spawnfunc_info_player_attacker() {
	if(!g_assault)
	{
		remove(self);
		return;
	}
	self.team = COLOR_TEAM1; // red, gets swapped every round
	spawnfunc_info_player_deathmatch();
}

void spawnfunc_info_player_defender() {
	if(!g_assault)
	{
		remove(self);
		return;
	}
	self.team = COLOR_TEAM2; // blue, gets swapped every round
	spawnfunc_info_player_deathmatch();
}

// reset this objective. Used when spawning an objective
// and when a new round starts
void assault_objective_reset() {
	self.health = ASSAULT_VALUE_INACTIVE;
}

void assault_objective_use() {
	if(other.classname == "info_player_deathmatch") // a spawn, a spawn
		return;

	// activate objective
	self.health = 100;
	print("^2Activated objective ", self.targetname, "=", etos(self), "\n");
	print("Activator is ", activator.classname, "\n");

	entity oldself;
	oldself = self;

	for(self = world; (self = find(self, target, oldself.targetname)); )
	{
		if(self.classname == "target_objective_decrease")
			target_objective_decrease_activate();
	}

	self = oldself;
}

void spawnfunc_target_objective() {
	self.classname = "target_objective";
	self.use = assault_objective_use;
	assault_objective_reset();
}


// decrease the health of targeted objectives
void assault_objective_decrease_use() {
	if(activator.team != assault_attacker_team) {
		// wrong team triggered decrease
		return;
	}

	if(other.sprite.classname == "assault_decreaser_sprite")
		WaypointSprite_Disown(other.sprite, waypointsprite_deadlifetime);

	if(self.enemy.health < ASSAULT_VALUE_INACTIVE)
	{
		if(self.enemy.health - self.dmg > 0.5)
		{
			PlayerTeamScore_Add(activator, SP_SCORE, ST_SCORE, self.dmg);
			self.enemy.health = self.enemy.health - self.dmg;
		}
		else
		{
			PlayerTeamScore_Add(activator, SP_SCORE, ST_SCORE, self.enemy.health);
			PlayerTeamScore_Add(activator, SP_ASSAULT_OBJECTIVES, ST_ASSAULT_OBJECTIVES, 1);
			self.enemy.health = -1;

			entity oldself, oldactivator;

			oldself = self;
			self = oldself.enemy;
				oldactivator = activator;
				activator = oldself;
					SUB_UseTargets();
				activator = oldactivator;
			self = oldself;
		}
	}
}

void assault_setenemytoobjective()
{
	local entity objective;
	for(objective = world; (objective = find(objective, targetname, self.target)); ) {
		if(objective.classname == "target_objective") {
			if(self.enemy == world)
				self.enemy = objective;
			else
				objerror("more than one objective as target - fix the map!");
			break;
		}
	}

	if(self.enemy == world)
		objerror("no objective as target - fix the map!");
}

float assault_decreaser_sprite_visible(entity e)
{
	entity decreaser;
	entity object;

	decreaser = self.assault_decreaser;

	if(decreaser.enemy.health >= ASSAULT_VALUE_INACTIVE)
		return FALSE;

	return TRUE;
}

void target_objective_decrease_activate()
{
	entity ent, spr;
	self.owner = world;
	for(ent = world; (ent = find(ent, target, self.targetname)); )
	{
		if(ent.sprite != world)
			WaypointSprite_Disown(ent.sprite, waypointsprite_deadlifetime);

		spr = WaypointSprite_SpawnFixed("<placeholder>", 0.5 * (ent.absmin + ent.absmax), ent, sprite);
		spr.assault_decreaser = self;
		spr.waypointsprite_visible_for_player = assault_decreaser_sprite_visible;
		spr.classname = "assault_decreaser_sprite";
		WaypointSprite_UpdateRule(spr, assault_attacker_team, SPRITERULE_TEAMPLAY);
		if(ent.classname == "func_assault_destructible")
			WaypointSprite_UpdateSprites(spr, "as-defend", "as-destroy", "as-destroy");
		else
			WaypointSprite_UpdateSprites(spr, "as-defend", "as-push", "as-push");
	}
}

void target_objective_decrease_findtarget()
{
	assault_setenemytoobjective();
}

//=============================================================================

void spawnfunc_target_objective_decrease() {

	self.classname = "target_objective_decrease";

	precache_model("models/sprites/defend.sp2");
	precache_model("models/sprites/destroy.sp2");
	precache_model("models/sprites/push.sp2");

	if(!self.dmg) {
		self.dmg = 101;
	}
	self.use = assault_objective_decrease_use;
	self.health = ASSAULT_VALUE_INACTIVE;
	self.max_health = ASSAULT_VALUE_INACTIVE;
	self.enemy = world;

	InitializeEntity(self, target_objective_decrease_findtarget, INITPRIO_FINDTARGET);
}

// destructible walls that can be used to trigger target_objective_decrease
void spawnfunc_func_assault_destructible() {
	self.spawnflags = 3;
	spawnfunc_func_breakable();
}

void assault_wall_think() {
	if(self.enemy.health < 0) {
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
	InitializeEntity(self, assault_setenemytoobjective, INITPRIO_FINDTARGET);
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

	/*
#ifdef TTURRETS_ENABLED
entity ent,oldself;

	//(Re)spawn all turrets
	oldself = self;
	ent = find(world, classname, "turret_main");
	while(ent) {
	// Swap turret teams
	if(ent.team == COLOR_TEAM1)
	ent.team = COLOR_TEAM2;
	else
	ent.team = COLOR_TEAM1;

	self = ent;

	// Dubbles as teamchange
	turret_stdproc_respawn();
	//ent.turret_spawnfunc();

	ent = find(ent, classname, "turret_main");
	}
	self = oldself;
#endif
*/

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
	bprint("ASSAULT: new round\n");

	// up round counter
	self.winning = self.winning + 1;
	// set end time for next round
	self.cnt = time + self.health;

	// swap attacker/defender roles
	if(assault_attacker_team == COLOR_TEAM1) {
		assault_attacker_team = COLOR_TEAM2;
	} else {
		assault_attacker_team = COLOR_TEAM1;
	}

	// swap spawn point teams
	local entity ent;
	local entity oldself;
	ent = find(world, classname, "info_player_deathmatch");
	while (ent)
	{
		if(ent.team == COLOR_TEAM1) {
			ent.team = COLOR_TEAM2;
		} else {
			ent.team = COLOR_TEAM1;
		}
		ent = find(ent, classname, "info_player_deathmatch");
	}

	// swap all destructibles
	ent = find(world, classname, "func_assault_destructible");
	while (ent)
	{
		if(ent.team == COLOR_TEAM1)
			ent.team = COLOR_TEAM2;
		else
			ent.team = COLOR_TEAM1;
		ent = find(ent, classname, "func_assault_destructible");
	}

	// reset the level with a countdown
	cvar_set("timelimit", ftos(ceil(time - game_starttime) / 60));
	ReadyRestartForce(); // sets game_starttime
}
