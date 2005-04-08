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

