//***********************
//QUAKE 3 ENTITIES - So people can play quake3 maps with the nexuiz weapons
//***********************

// NOTE: for best experience, you need to swap MGs with SGs in the map or it won't have a MG

// SG -> SG
void spawnfunc_ammo_shells()         { item_shells();        }
                                                 
// MG -> MG                                      
void spawnfunc_weapon_machinegun()   { weapon_uzi();         }
void spawnfunc_ammo_bullets()        { item_bullets();       }
                                                 
// GL -> Mortar                                  
void spawnfunc_ammo_grenades()       { item_rockets();       }
                                                 
// LG -> Electro                                 
void spawnfunc_weapon_lightning()    { weapon_electro();     }
void spawnfunc_ammo_lightning()      { item_cells();         }
                                                 
// Plasma -> Crylink                             
void spawnfunc_weapon_plasmagun()    { weapon_crylink();     }
void spawnfunc_ammo_cells()          { item_cells();         }
                                                 
// Rail -> Nex                                   
void spawnfunc_weapon_railgun()      { weapon_nex();         }
void spawnfunc_ammo_slugs()          { item_cells();         }
                                                 
// BFG -> Hagar                                  
void spawnfunc_weapon_bfg()          { weapon_hagar();       }
void spawnfunc_ammo_bfg()            { item_cells();         }

// RL -> RL
void spawnfunc_ammo_rockets()        { item_rockets();       }
                          
// Armor                  
void spawnfunc_item_armor_body()     { item_armor_large();   }
void spawnfunc_item_armor_combat()   { item_armor_medium();  }
void spawnfunc_item_armor_shard()    { item_armor_small();   }
void spawnfunc_item_enviro()         { item_armor_medium();  }
//void spawnfunc_item_flight()       /* not supported */
//void spawnfunc_item_haste()        /* not supported */
//void spawnfunc_item_health()       /* handled in t_quake.qc */
void spawnfunc_item_health_large()   { item_health_large();  }
void spawnfunc_item_health_small()   { item_health_small();  }
void spawnfunc_item_health_mega()    { item_health_mega();   }
//void spawnfunc_item_invis()        /* not supported */
//void spawnfunc_item_regen()        /* not supported */
void spawnfunc_team_CTF_redflag()    { item_flag_team1();    }
void spawnfunc_team_CTF_blueflag()   { item_flag_team2();    }
void spawnfunc_team_CTF_redplayer()  { info_player_team1();  }
void spawnfunc_team_CTF_blueplayer() { info_player_team2();  }
void spawnfunc_team_CTF_redspawn()   { info_player_team1();  }
void spawnfunc_team_CTF_bluespawn()  { info_player_team2();  }
