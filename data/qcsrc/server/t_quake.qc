//***********************
//QUAKE 1 ENTITIES - So people can play quake1 maps with the nexuiz weapons
//***********************
void spawnfunc_weapon_nailgun (void) {spawnfunc_weapon_electro();}
void spawnfunc_weapon_supernailgun (void) {spawnfunc_weapon_hagar();}
void spawnfunc_weapon_supershotgun (void) {spawnfunc_weapon_uzi();}

void spawnfunc_item_spikes (void) {spawnfunc_item_bullets();}
//void spawnfunc_item_armor1 (void) {spawnfunc_item_armor_medium;}  // FIXME: in Quake this is green armor, in Nexuiz maps it is an armor shard
void spawnfunc_item_armor2 (void) {spawnfunc_item_armor_large();}
void item_armorInv (void) {spawnfunc_item_armor_large();}
void spawnfunc_item_health (void) {if (self.spawnflags & 2) spawnfunc_item_health_mega();else spawnfunc_item_health_medium();}

//spawnfunc_item_spikes
//spawnfunc_item_health



// garbage function to reduce warnings in compiling about unused variables
void junk_function ()
{
	self.exteriormodeltoclient = world;
	self.glow_trail = 0;
	self.tag_entity = world;
	self.BUTTON_HOOK = 0;
	self.BUTTON_INFO = 0;
	self.button8 = 0;
	self.pitch_speed = 0;
	self.drawonlytoclient = world;
	self.nodrawtoclient = world;
	self.cursor_active = 0;
	self.cursor_screen = '0 0 0';
	self.cursor_trace_start = '0 0 0';
	self.cursor_trace_endpos = '0 0 0';
	self.ping = 0;
	self.roomtype = 0;
	self.radius = 0;
	self.pitch = 0;
	self.renderamt = 0;
	self.rendermode = 0;
	self.rendercolor = '0 0 0';
	self.light_lev = 0;
	self.color = '0 0 0';
	self.style = 0;
	self.jumppadsused = world;
	self.disableclientprediction = 0;
	self.contentstransition = SUB_Null;
	self.dphitcontentsmask = 0;
	self.modelflags = 0;
	self.attack_finished_for = 0; // why is this even valid? Spiiiiiiiiiiiiiiiiiiiiike!
	self.notsingle = 0;
	trace_dphittexturename = "";
	require_spawnfunc_prefix = 1;
	self.movetypesteplandevent = SUB_Null;
	self.viewzoom = 0;
	self.cvar_cl_weaponpriorities = "";
	self.scores = 0;
	self.teamscores = 0;
	gettaginfo_parent = 0;
	gettaginfo_name = "";
	gettaginfo_offset = '0 0 0';
	gettaginfo_forward = '0 0 0';
	gettaginfo_right = '0 0 0';
	gettaginfo_up = '0 0 0';
	self.mass = 0;
}

