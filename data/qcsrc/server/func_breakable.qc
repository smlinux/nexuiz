.entity sprite;

.float dmg;
.float dmg_edge;
.float dmg_radius;
.float dmg_force;

.string mdl_dead; // or "" to hide when broken
.string debris; // space separated list of debris models
// other fields:
//   mdl = particle effect name
//   count = particle effect multiplier
//   targetname = target to trigger to unbreak the model
//   target = targets to trigger when broken
//   health = amount of damage it can take
//   spawnflags:
//     1 = start disabled (needs to be triggered to activate)
//     2 = indicate damage
// notes:
//   for mdl_dead to work, origin must be set (using a common/origin brush).
//   Otherwise mdl_dead will be displayed at the map origin, and nobody would
//   want that!

.vector mins_save, maxs_save;

void func_breakable_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force);

//
// func_breakable
// - basically func_assault_destructible for general gameplay use
//
void LaunchDebris (string debrisname) =
{
	local	entity dbr;

	dbr = spawn();
	dbr.origin = self.origin + self.absmin
	           + '1 0 0' * random() * (self.absmax_x - self.absmin_x)
	           + '0 1 0' * random() * (self.absmax_y - self.absmin_y)
	           + '0 0 1' * random() * (self.absmax_z - self.absmin_z);
	setmodel (dbr, debrisname );
	dbr.movetype = MOVETYPE_BOUNCE;
	dbr.solid = SOLID_NOT;
	// TODO parametrize this
	dbr.velocity_x = 70 * crandom();
	dbr.velocity_y = 70 * crandom();
	dbr.velocity_z = 140 + 70 * random();
	dbr.avelocity_x = random()*600;
	dbr.avelocity_y = random()*600;
	dbr.avelocity_z = random()*600;
	SUB_SetFade(dbr, time + 1 + random() * 5, 1);
};

void func_breakable_colormod()
{
	float h;
	if not(self.spawnflags & 2)
		return;
	h = self.health / self.max_health;
	if(h < 0.25)
		self.colormod = '1 0 0';
	else if(h <= 0.75)
		self.colormod = '1 0 0' + '0 1 0' * (2 * h - 0.5);
	else
		self.colormod = '1 1 1';
}

void func_breakable_look_destroyed()
{
	local float floor_z;
	
	if(self.mdl_dead == "")
		self.model = "";
	else {
		setmodel(self, self.mdl_dead);
		if (self.origin == '0 0 0')	{	// probably no origin brush, so don't spawn in the middle of the map..
			floor_z = self.absmin_z;
			self.origin = ((self.absmax+self.absmin)*.5);
			self.origin_z = floor_z;
		}
	}
		
	self.solid = SOLID_NOT;
}

void func_breakable_look_restore()
{
	setmodel(self, self.mdl);
	self.solid = SOLID_BSP;
}

void func_breakable_behave_destroyed()
{
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;
	self.event_damage = SUB_Null;
	self.state = 1;
	setsize(self, '0 0 0', '0 0 0');
	func_breakable_colormod();
}

void func_breakable_behave_restore()
{
	self.health = self.max_health;
	self.takedamage = DAMAGE_AIM;
	self.event_damage = func_breakable_damage;
	self.state = 0;
	setsize(self, self.mins_save, self.maxs_save);
	func_breakable_colormod();
}

void func_breakable_destroyed()
{
	func_breakable_look_destroyed();
	func_breakable_behave_destroyed();
}

void func_breakable_restore()
{
	func_breakable_look_restore();
	func_breakable_behave_restore();
}

void func_breakable_destroy() {
	float n, i;

	activator = self.owner;

	func_breakable_destroyed();

	if(self.noise)
		sound (self, CHAN_AUTO, self.noise, VOL_BASE, ATTN_NORM);

	if(self.dmg)
		RadiusDamage(self, activator, self.dmg, self.dmg_edge, self.dmg_radius, self, self.dmg_force, DEATH_HURTTRIGGER, world);

	// now throw around the debris
	n = tokenize_sane(self.debris);
	for(i = 0; i < n; ++i)
		LaunchDebris(argv(i));

	if(self.cnt)
		pointparticles(self.cnt, self.absmin * 0.5 + self.absmax * 0.5, '0 0 0', self.count);

	SUB_UseTargets();
}

void func_breakable_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.state == 1)
		return;
	if(self.team)
		if(attacker.team == self.team)
			return;
	if(self.sprite)
		WaypointSprite_Ping(self.sprite);
	self.health = self.health - damage;
	func_breakable_colormod();

	if(self.health <= 0)
		W_PrepareExplosionByDamage(attacker, func_breakable_destroy);
}

void func_breakable_reset()
{
	self.team = self.team_saved;
	func_breakable_look_restore();
	if(self.spawnflags & 1)
		func_breakable_behave_destroyed();
	else
		func_breakable_behave_restore();
}

// destructible walls that can be used to trigger target_objective_decrease
void spawnfunc_func_breakable() {
	float n, i;
	if(!self.health)
		self.health = 100;
	self.max_health = self.health;

	if(self.mdl != "")
		self.cnt = particleeffectnum(self.mdl);
	if(self.count == 0)
		self.count = 1;

	if(!self.message)
		self.message = "got too close to an explosion";
	if(!self.message2)
		self.message2 = "was pushed into an explosion by";
	if(!self.dmg_radius)
		self.dmg_radius = 150;
	if(!self.dmg_force)
		self.dmg_force = 200;

	self.mdl = self.model;
	SetBrushEntityModel();
	self.mins_save = self.mins;
	self.maxs_save = self.maxs;

	self.use = func_breakable_restore;

	// precache all the models
	if (self.mdl_dead)
		precache_model(self.mdl_dead);
	n = tokenize_sane(self.debris);
	for(i = 0; i < n; ++i)
		precache_model(argv(i));
	if(self.noise)
		precache_sound(self.noise);

	self.team_saved = self.team;

	self.reset = func_breakable_reset;
	func_breakable_reset();
}
