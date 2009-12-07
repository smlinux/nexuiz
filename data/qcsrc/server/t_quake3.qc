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
void spawnfunc_item_armor_combat()   { spawnfunc_item_armor_big();     }
void spawnfunc_item_armor_shard()    { spawnfunc_item_armor_small();   }
void spawnfunc_item_enviro()         { spawnfunc_item_invincible();    }

// weapon remove ent from defrag
void spawnfunc_target_init()         
{
	self.spawnflags = 0; // remove all weapons except the ones listed below
	self.netname = "laser uzi"; // keep these weapons through the remove trigger
	spawnfunc_target_items();
}

// weapon give ent from defrag
void target_give_init()
{
	entity targ;
	for (targ = world; (targ = find(targ, targetname, self.target)); ) {
		if (targ.classname == "weapon_rocketlauncher") {
			self.ammo_rockets += targ.count * cvar("g_balance_rocketlauncher_ammo");
			self.netname = "rocketlauncher";
		}
		else if (targ.classname == "weapon_plasmagun") {
			self.ammo_rockets += targ.count * cvar("g_balance_hagar_primary_ammo");
			if(self.netname == "")
				self.netname = "hagar";
			else
				self.netname = strcat(self.netname, " hagar");
		}
		else if (targ.classname == "weapon_bfg") {
			self.ammo_cells += targ.count * cvar("g_balance_crylink_primary_ammo");
			if(self.netname == "")
				self.netname = "crylink";
			else
				self.netname = strcat(self.netname, " crylink");
		}
		else if (targ.classname == "weapon_grenadelauncher") {
			self.ammo_rockets += targ.count * cvar("g_balance_grenadelauncher_primary_ammo");
			if(self.netname == "")
				self.netname = "grenadelauncher";
			else
				self.netname = strcat(self.netname, " grenadelauncher");
		}
		else if (targ.classname == "item_armor_body")
			self.armorvalue = 100;
		else if (targ.classname == "item_health_mega")
			self.health = 200;
		remove(targ);
	}
	self.spawnflags = 2;
	spawnfunc_target_items();
}

void spawnfunc_target_give()
{
	InitializeEntity(self, target_give_init, INITPRIO_FINDTARGET);
}

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

void spawnfunc_item_flight()         { spawnfunc_item_jetpack();       }
