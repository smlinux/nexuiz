//***********************
//QUAKE 1 ENTITIES - So people can play quake1 maps with the nexuiz weapons
//***********************
void weapon_nailgun (void) {weapon_electro();}
void weapon_supernailgun (void) {weapon_hagar();}
void weapon_supershotgun (void) {weapon_uzi();}

void item_spikes (void) {item_bullets();}
void item_armor2 (void) {item_armor25();}
void item_armorInv (void) {item_armor25();}
void item_health (void) {if (self.spawnflags & 2) item_health100();else item_health25();}

//item_spikes
//item_health



// garbage function to reduce warnings in compiling about unused variables
void junk_function ()
{
	self.exteriormodeltoclient = world;
	self.glow_trail = 0;
	self.tag_entity = world;
	self.button6 = 0;
	self.button7 = 0;
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
	trace_dphittexturename = "";
}

