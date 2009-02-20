//***********************
//QUAKE 3 ENTITIES - So people can play quake3 maps with the nexuiz weapons
//***********************

// NOTE: for best experience, you need to swap MGs with SGs in the map or it won't have a MG

// SG -> SG
void spawnfunc_ammo_shells()         { spawnfunc_item_shells();        }
                                                 
// MG -> MG                                      
void spawnfunc_weapon_machinegun()   { spawnfunc_weapon_uzi();         }
void spawnfunc_ammo_bullets()        { spawnfunc_item_bullets();       }
                                                 
// GL -> Mortar                                  
void spawnfunc_ammo_grenades()       { spawnfunc_item_rockets();       }
                                                 
// LG -> Electro                                 
void spawnfunc_weapon_lightning()    { spawnfunc_weapon_electro();     }
void spawnfunc_ammo_lightning()      { spawnfunc_item_cells();         }
                                                 
// Plasma -> Hagar                             
void spawnfunc_weapon_plasmagun()    { spawnfunc_weapon_hagar();       }
void spawnfunc_ammo_cells()          { spawnfunc_item_rockets();       }
                                                 
// Rail -> Nex                                   
void spawnfunc_weapon_railgun()      { spawnfunc_weapon_nex();         }
void spawnfunc_ammo_slugs()          { spawnfunc_item_cells();         }
                                                 
// BFG -> Crylink                                  
void spawnfunc_weapon_bfg()          { spawnfunc_weapon_crylink();     }
void spawnfunc_ammo_bfg()            { spawnfunc_item_cells();         }

// RL -> RL
void spawnfunc_ammo_rockets()        { spawnfunc_item_rockets();       }
                          
// Armor                  
void spawnfunc_item_armor_body()     { spawnfunc_item_armor_large();   }
void spawnfunc_item_armor_combat()   { spawnfunc_item_armor_big();  }
void spawnfunc_item_armor_shard()    { spawnfunc_item_armor_small();   }
void spawnfunc_item_enviro()         { spawnfunc_item_armor_medium();  }
//void spawnfunc_item_flight()       /* not supported */
//void spawnfunc_item_haste()        /* not supported */
//void spawnfunc_item_health()       /* handled in t_quake.qc */
//void spawnfunc_item_health_large() /* handled in t_items.qc */
//void spawnfunc_item_health_small() /* handled in t_items.qc */
//void spawnfunc_item_health_mega()  /* handled in t_items.qc */
//void spawnfunc_item_invis()        /* not supported */
//void spawnfunc_item_regen()        /* not supported */
void spawnfunc_team_CTF_redflag()    { spawnfunc_item_flag_team1();    }
void spawnfunc_team_CTF_blueflag()   { spawnfunc_item_flag_team2();    }
void spawnfunc_team_CTF_redplayer()  { spawnfunc_info_player_team1();  }
void spawnfunc_team_CTF_blueplayer() { spawnfunc_info_player_team2();  }
void spawnfunc_team_CTF_redspawn()   { spawnfunc_info_player_team1();  }
void spawnfunc_team_CTF_bluespawn()  { spawnfunc_info_player_team2();  }
