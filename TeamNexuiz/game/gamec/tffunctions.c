// TF fucntions
.float goal_no;		// goal number - pair with defs file
.float goal_result; // pair with defs
.float else_goal;	// not sure
.float goal_result;
.float is_removed;	// entity is removed?
float (entity _p_10934, entity _p_10935) Activated;
float (float tno) TeamFortress_TeamGetScore;
float (float tno) TeamFortress_TeamGetColor;
void (entity _p_10980, entity _p_10981, float _p_10982) DoResults; //< - score increase thing
void (entity Item, entity AP, float method) tfgoalitem_RemoveFromPlayer;
void(entity client, string s) CenterPrint = #73;

// misc stuff (move to TFDefs file)
entity newmis;		// This is what tf uses for spawning entities
.float has_disconnected;	//has the player disconnected?
.float no_grenades_1;
.float no_grenades_2;
.float no_grenades_3;
.float pausetime;	// not sure
float team1lives;
float team2lives;
float team3lives;
float team4lives;
float team1maxplayers;
float team2maxplayers;
float team3maxplayers;
float team4maxplayers;
float team1advantage;
float team2advantage;
float team3advantage;
float team4advantage;

// stuff that still needs a function
float number_of_teams; // Number of teams == IMPORTANT

// Color/Teamchange cheat detection (using DP functions instead of tf)
void (entity ent, float colors) setcolor;

void SV_ChangeTeam(float color)
{
//	if (self.playerclass == 8)		// Spies can change team color right?
//		return;
	if (self.team_no == 1 && color != 13)
	{
		setcolor(self, 13,13);
	}
	if (self.team_no == 2 && color != 4)
	{
		setcolor(self, 4,4);
//		stuffcmd(self, "color 4\n");
	}
};


void(entity targ, entity attacker) ClientObituary =
{
	ClientObituary(targ,attacker);		// TEMP -- SOON I WILL ADD REAL DEATH MESSAGES
};

void () DoTFAliases =
{
		TeamFortress_Alias("primeone", 150, TF_FLARE_LIT);
		TeamFortress_Alias("primetwo", 151, TF_FLARE_LIT);
		TeamFortress_Alias("throwgren", 152, TF_FLARE_LIT);
		TeamFortress_Alias("+gren1", 150, TF_FLARE_LIT);
		TeamFortress_Alias("+gren2", 151, TF_FLARE_LIT);
		TeamFortress_Alias("-gren1", 152, TF_FLARE_LIT);
		TeamFortress_Alias("-gren2", 152, TF_FLARE_LIT);
};

void (entity tempent) dremove =
{
	if ((tempent == world))
	{
		dprint ("***BUG BUG BUG BUG BUG BUG BUG BUG BUG BUG***\n");
		dprint ("WORLD has nearly been removed. Don't worry\n");
		dprint ("***BUG BUG BUG BUG BUG BUG BUG BUG BUG BUG***\n");
		return;
	}
	if ((tempent.is_removed == 1.000000))
	{
		return;
	}
	tempent.is_removed = 1.000000;
	remove (tempent);
};

entity (float gno) Findgoal =
{
	local entity tg;
	local string st;

	tg = find (world, classname, "info_tfgoal");
	while (tg)
	{
		if ((tg.goal_no == gno))
		{
			return (tg);
		}
		tg = find (tg, classname, "info_tfgoal");
	}
	dprint ("Could not find a goal with a goal_no of ");
	st = ftos (gno);
	dprint (st);
	dprint (".\n");
	//return (tg);
};

void(entity Goal, entity AP, entity ActivatingGoal) AttemptToActivate = 
{
	local entity te;
	local string st;
	if (Activated(Goal, AP))
	{
		if (ActivatingGoal == Goal)
		{
			DoResults(Goal, AP, TF_FLARE_OFF);
		}
		else
		{
			if (ActivatingGoal != world)
			{
				DoResults(Goal, AP, ActivatingGoal.goal_result & 2);
			}
			else
			{
				DoResults(Goal, AP, TF_FLARE_LIT);
			}
		}
	}
	else
	{
		if (Goal.else_goal != TF_FLARE_LIT)
		{
			te = Findgoal(Goal.else_goal);
			if (te)
			{
				AttemptToActivate(te, AP, ActivatingGoal);
			}
		}
	}
};

void (entity p) TeamFortress_SetSpeed =
{
	local string sp;
	local float tf;
	local entity te;

	stuffcmd (p, "cl_movespeedkey 1\n");
	if ((p.tfstate & 65536))
	{
		if ((0 == 1))
		{
			stuffcmd (p, "m_forward 0\n");
			stuffcmd (p, "m_side 0\n");
		}
		p.velocity = '0 0 0';
		stuffcmd (p, "cl_backspeed 0\n");
		stuffcmd (p, "cl_forwardspeed 0\n");
		stuffcmd (p, "cl_sidespeed 0\n");
		return;
	}
	else
	{
		if ((0 == 1))
		{
			stuffcmd (p, "m_forward 1\n");
			stuffcmd (p, "m_side 0.8\n");
		}
	}
	if ((p.class == 1))		//scout speed
	{
		p.maxfbspeed = 450;
		p.maxstrafespeed = 450;
	}
	else
	{
		if ((p.class == 2.1))			// No sniper in nextf
		{
			p.maxfbspeed = 300;
			p.maxstrafespeed = 300;
		}
		else
		{
			if ((p.class == 4))		//soldier speed
			{
				p.maxfbspeed = 240;
				p.maxstrafespeed = 240;
			}
			else
			{
				if ((p.class == 4.1))		// No demoman in nextf
				{
					p.maxfbspeed = 280;
					p.maxstrafespeed = 280;
				}
				else
				{
					if ((p.class == 16))		// Medic Speed
					{
						p.maxfbspeed = 320;
						p.maxstrafespeed = 320;
					}
					else
					{
						if ((p.class == 6.1))		// No HWGuy in nextf
						{
							p.maxfbspeed = 230;
							p.maxstrafespeed = 230;
						}
						else
						{
							if ((p.class == 8))		// Pyro Speed
							{
								p.maxfbspeed = 300;
								p.maxstrafespeed = 300;
							}
							else
							{
								if ((p.class == 11))		// Wazat -- We need a Civ class
								{
									p.maxfbspeed = 240;
									p.maxstrafespeed = 240;
								}
								else
								{
									if ((p.class == 2))		// Spy Speed
									{
										p.maxfbspeed = 300;
										p.maxstrafespeed = 300;
									}
									else
									{
										if ((p.class == 32))		// Engineer Speed
										{
											p.maxfbspeed = 300;
											p.maxstrafespeed = 300;
										}
										else
										{
											if ((p.class == 0))		// No class
											{
												p.maxfbspeed = 320;
												p.maxstrafespeed = 320;
												return;
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	tf = 0;
	te = find (world, classname, "item_tfgoal");
	while (((te != world) && (tf == 0)))
	{
		if ((te.owner == p))
		{
			if ((te.goal_activation & 2))
			{
				tf = 1;
				p.maxfbspeed = (p.maxfbspeed / 2);
				p.maxstrafespeed = (p.maxstrafespeed / 2);
			}
		}
		te = find (te, classname, "item_tfgoal");
	}
	if ((p.tfstate & 32768))
	{
		p.maxfbspeed = (p.maxfbspeed / 2);
		p.maxstrafespeed = (p.maxstrafespeed / 2);
	}
	/* (p.leg_damage)			// No leg damage if no snipers, eh?
	{
		if ((p.leg_damage > 6))
		{
			p.leg_damage = 6;
		}
		p.maxfbspeed = (p.maxfbspeed * ((10 - p.leg_damage) / 10));
		p.maxstrafespeed = ((p.maxstrafespeed * (10 - p.leg_damage)) / 10);
	}*/
	if ((p.tfstate & 2048))
	{
		if ((p.maxfbspeed > 80))
		{
			p.maxfbspeed = 80;
		}
		if ((p.maxstrafespeed > 80))
		{
			p.maxstrafespeed = 80;
		}
	}
	sp = ftos (p.maxfbspeed);
	stuffcmd (p, "cl_backspeed ");
	stuffcmd (p, sp);
	stuffcmd (p, "\n");
	stuffcmd (p, "cl_forwardspeed ");
	stuffcmd (p, sp);
	stuffcmd (p, "\n");
	sp = ftos (p.maxstrafespeed);
	stuffcmd (p, "cl_sidespeed ");
	stuffcmd (p, sp);
	stuffcmd (p, "\n");
};

float (entity Retriever, float AmmoType) TeamFortress_GetMaxAmmo =
{
	if ((AmmoType == 256))
	{
		return (Retriever.maxammo_shells);
	}
	else
	{
		if ((AmmoType == 512))
		{
			return (Retriever.maxammo_nails);
		}
		else
		{
			if ((AmmoType == 2048))
			{
				return (Retriever.maxammo_cells);
			}
			else
			{
				if ((AmmoType == 1024))
				{
					return (Retriever.maxammo_rockets);
				}
				else
				{
					if ((AmmoType == 4))
					{
						return (Retriever.maxammo_medikit);
					}
					else
					{
						if ((AmmoType == 131072))
						{
							return (Retriever.maxammo_detpack);
						}
					}
				}
			}
		}
	}
	dprint ("Error in TeamFortress_GetMaxAmmo()\n");
	dprint ("Invalid ammo type passed.\n");
	return (0);
};

void () TeamFortress_CheckClassStats =
{
//		Wazat - Implement your armor system here, eh?
/*	if ((self.armortype > self.armor_allowed))
	{
		self.armortype = self.armor_allowed;
	}*/
	if ((self.armorvalue > self.max_armor))
	{
		self.armorvalue = self.max_armor;
	}
	if ((self.armortype < 0))
	{
		self.armortype = 0;
	}
	if ((self.armorvalue < 0))
	{
		self.armorvalue = 0;
	}
	if ((self.ammo_shells > TeamFortress_GetMaxAmmo (self, 256)))
	{
		self.ammo_shells = TeamFortress_GetMaxAmmo (self, 256);
	}
	if ((self.ammo_shells < 0))
	{
		self.ammo_shells = 0;
	}
	if ((self.ammo_nails > TeamFortress_GetMaxAmmo (self, 512)))
	{
		self.ammo_nails = TeamFortress_GetMaxAmmo (self, 512);
	}
	if ((self.ammo_nails < 0))
	{
		self.ammo_nails = 0;
	}
	if ((self.ammo_rockets > (TeamFortress_GetMaxAmmo (self, 1024) * 3)))
	{
		self.ammo_rockets = (TeamFortress_GetMaxAmmo (self, 1024) * 3);
	}
	if ((self.ammo_rockets < 0))
	{
		self.ammo_rockets = 0;
	}
	if ((self.ammo_cells > TeamFortress_GetMaxAmmo (self, 2048)))
	{
		self.ammo_cells = TeamFortress_GetMaxAmmo (self, 2048);
	}
	if ((self.ammo_cells < 0))
	{
		self.ammo_cells = 0;
	}
	if ((self.ammo_medikit > TeamFortress_GetMaxAmmo (self, 4)))
	{
		self.ammo_medikit = TeamFortress_GetMaxAmmo (self, 4);
	}
	if ((self.ammo_medikit < 0))
	{
		self.ammo_medikit = 0;
	}
	if ((self.ammo_detpack > TeamFortress_GetMaxAmmo (self, 131072)))
	{
		self.ammo_detpack = TeamFortress_GetMaxAmmo (self, 131072);
	}
	if ((self.ammo_detpack < 0))
	{
		self.ammo_detpack = 0;
	}
	if ((self.no_grenades_1 < 0))
	{
		self.no_grenades_1 = 0;
	}
	if ((self.no_grenades_2 < 0))
	{
		self.no_grenades_2 = 0;
	}
//		NexTF uses auto-rot, so there's no need for this function.
//	if (((self.health > self.max_health) && !(self.items & 65536)))
//	{
//		TF_T_Damage (self, world, world, (self.max_health - self.health), 0, 256);
//	}
	if ((self.health < 0))
	{
		T_Heal (self, (self.health - self.health), 0);
	}
	self.items = (self.items - (self.items & ((8192 | 16384) | 32768)));
	if ((self.armortype >= 0.8))
	{
		self.items = (self.items | 32768);
	}
	else
	{
		if ((self.armortype >= 0.6))
		{
			self.items = (self.items | 16384);
		}
		else
		{
			if ((self.armortype >= 0.3))
			{
				self.items = (self.items | 8192);
			}
		}
	}
	weapon_action(self.weapon, WR_UPDATECOUNTS); // update ammo now
};

// TF Get Score Frags
float (float tno) TeamFortress_TeamGetScoreFrags =
{
	if (((toggleflags & 128) || (toggleflags & 2048)))
	{
		if ((tno == 1))
		{
			return (team1score);
		}
		if ((tno == 2))
		{
			return (team2score);
		}
		if ((tno == 3))
		{
			return (team3score);
		}
		if ((tno == 4))
		{
			return (team4score);
		}
	}
	else
	{
		if ((tno == 1))
		{
			return (team1frags);
		}
		if ((tno == 2))
		{
			return (team2frags);
		}
		if ((tno == 3))
		{
			return (team3frags);
		}
		if ((tno == 4))
		{
			return (team4frags);
		}
	}
	return (0);
};

// TF Get Team Winner
float () TeamFortress_TeamGetWinner =
{
	local float i;
	local float j;
	local float highest;
	local float highestteam;

	i = 1;
	highest = 0;
	highestteam = 0;
	while ((i < (number_of_teams + 1)))
	{
		j = TeamFortress_TeamGetScoreFrags (i);
		if ((j > highest))
		{
			highest = j;
			highestteam = i;
		}
		i = (i + 1);
	}
	return (highestteam);
};

// TF Score Increaser
void (float tno, float scoretoadd) TeamFortress_TeamIncreaseScore =
{
	local entity e;

	if (((tno == 0) || (scoretoadd == 0)))
	{
		return;
	}
	if ((tno == 1))
	{
		team1score = (team1score + scoretoadd);
	}
	if ((tno == 2))
	{
		team2score = (team2score + scoretoadd);
	}
	if ((tno == 3))
	{
		team3score = (team3score + scoretoadd);
	}
	if ((tno == 4))
	{
		team4score = (team4score + scoretoadd);
	}
	if (((toggleflags & 128) || (toggleflags & 2048)))
	{
		e = find (world, classname, "player");
		while (e)
		{
			if ((e.team_no == tno))
			{
				e.frags = TeamFortress_TeamGetScore (tno);
			}
			e = find (e, classname, "player");
		}
	}
};

// Returns Team Color Name (String)
string (float tno) TeamFortress_TeamGetColorString =
{
	local float col;

	col = TeamFortress_TeamGetColor (tno);
	if ((col == 1))
	{
		return ("White");
	}
	if ((col == 2))
	{
		return ("Brown");
	}
	if ((col == 3))
	{
		return ("Blue");
	}
	if ((col == 4))
	{
		return ("Green");
	}
	if ((col == 5))
	{
		return ("Red");
	}
	if ((col == 6))
	{
		return ("Tan");
	}
	if ((col == 7))
	{
		return ("Pink");
	}
	if ((col == 8))
	{
		return ("Orange");
	}
	if ((col == 9))
	{
		return ("Purple");
	}
	if ((col == 10))
	{
		return ("DarkPurple");
	}
	if ((col == 11))
	{
		return ("Grey");
	}
	if ((col == 12))
	{
		return ("DarkGreen");
	}
	if ((col == 13))
	{
		return ("Yellow");
	}
	return ("DarkBlue");
};

// Is civilian?
float (float tno) TeamFortress_TeamIsCivilian =
{
	local entity te;

	if ((tno == 1))
	{
		if ((civilianteams & 1))
		{
			return (1);
		}
	}
	else
	{
		if ((tno == 2))
		{
			if ((civilianteams & 2))
			{
				return (1);
			}
		}
		else
		{
			if ((tno == 3))
			{
				if ((civilianteams & 4))
				{
					return (1);
				}
			}
			else
			{
				if ((civilianteams & 8))
				{
					return (1);
				}
			}
		}
	}
	return (0);
};

// Change Class
//		You use a different method of handling this tho Wazat?
void () TeamFortress_ChangeClass;
/*void () TeamFortress_ChangeClass =
{
	local entity spot;
	local entity te;
	local float tc;
	local string st;

	if ((self.playerclass != 0))
	{
		if (((deathmatch != 3) && (cb_prematch_time < time)))
		{
			return;
		}
		if (TeamFortress_TeamIsCivilian (self.team_no))
		{
			sprint (self, "You cannot change class.\n");
			return;
		}
		if (!IsLegalClass ((self.impulse - 100)))
		{
			sprint (self, "Your team cannot play that class.\n");
			TeamFortress_DisplayLegalClasses ();
			return;
		}
		if (((spy_off == 1) && ((self.impulse - 100) == 8)))
		{
			sprint (self, "The spy class has been disabled on the server by the administrator.\n");
			return;
		}
		self.nextpc = (self.impulse - 100);
		sprint (self, "After dying, you will return as a ");
		TeamFortress_PrintClassName (self, self.nextpc, (self.tfstate & 8));
		self.immune_to_check = (time + 10);
		return;
	}
	if ((teamplay && (self.team_no == 0)))
	{
		if ((toggleflags & 64))
		{
			if ((TeamFortress_TeamPutPlayerInTeam () == 0))
			{
				return;
			}
		}
		else
		{
			sprint (self, "You must join a team first. \n");
			sprint (self, "use imin1, imin2, imin3, or imin4\n");
			return;
		}
	}
	if ((self.lives == 0))
	{
		sprint (self, "You have no lives left.\n");
		return;
	}
	if ((!IsLegalClass ((self.impulse - 100)) && (self.impulse != 1)))
	{
		sprint (self, "You cannot play that playerclass on this map. \n");
		TeamFortress_DisplayLegalClasses ();
		return;
	}
	if (((spy_off == 1) && ((self.impulse - 100) == 8)))
	{
		sprint (self, "The spy class has been disabled on the server by the administrator.\n");
		return;
	}
	if ((self.impulse != 1))
	{
		self.playerclass = (self.impulse - 100);
	}
	else
	{
		self.playerclass = 11;
	}
	self.nextpc = 0;
	self.takedamage = 2;
	self.movetype = 3;
	self.flags = (8 | 512);
	self.waterlevel = 0;
	self.air_finished = (time + 12);
	self.solid = 3;
	self.pausetime = 0;
	spot = SelectSpawnPoint ();
	self.origin = (spot.origin + '0 0 1');
	self.angles = spot.angles;
	self.fixangle = 1;
	setmodel (self, string_null);
	modelindex_null = self.modelindex;
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;
	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;
	setsize (self, '-16 -16 -24', '16 16 32');
	self.view_ofs = '0 0 22';
	player_stand1 ();
	if ((deathmatch || coop))
	{
		makevectors (self.angles);
		spawn_tfog ((self.origin + (v_forward * 20)));
	}
	if ((self.playerclass == 10))
	{
		sprint (self, "Random Playerclass.\n");
		self.tfstate = (self.tfstate | 8);
		self.playerclass = (1 + floor ((random () * (10 - 1))));
	}
	if (((spot.classname == "info_player_teamspawn") && (cb_prematch_time < time)))
	{
		if ((spot.items != 0))
		{
			te = Finditem (spot.items);
			if (te)
			{
				tfgoalitem_GiveToPlayer (te, self, self);
			}
			if (!(spot.goal_activation & 1))
			{
				spot.items = 0;
			}
		}
		if (spot.message)
		{
			CenterPrint (self, spot.message);
			if (!(spot.goal_activation & 2))
			{
				spot.message = string_null;
			}
		}
		if ((spot.activate_goal_no != 0))
		{
			te = Findgoal (spot.activate_goal_no);
			if (te)
			{
				AttemptToActivate (te, self, spot);
			}
		}
		if ((spot.goal_effects == 1))
		{
			spot.classname = "deadpoint";
			spot.team_str_home = string_null;
			spot.nextthink = (time + 1);
			spot.think = SUB_Remove;
		}
	}
	spot = find (world, classname, "player");
	while (spot)
	{
		if (((spot.team_no == self.team_no) && (spot != self)))
		{
			sprint (spot, 2, self.netname);
			sprint (spot, 2, " is playing as a ");
			TeamFortress_PrintClassName (spot, self.playerclass, (self.tfstate & 8));
		}
		spot = find (spot, classname, "player");
	}
	TeamFortress_PrintClassName (self, self.playerclass, (self.tfstate & 8));
	TeamFortress_SetEquipment ();
	TeamFortress_SetHealth ();
	TeamFortress_SetSpeed (self);
	TeamFortress_SetSkin (self);
	if (cease_fire)
	{
		sprint (self, "\n\nCEASE FIRE MODE\n");
		self.immune_to_check = (time + 10);
		self.tfstate = (self.tfstate | 65536);
		TeamFortress_SetSpeed (self);
	}
};*/

// Show what class each member of the team is -- NEEDS AN IMPULSE CALL FUNCTION
void (entity Player) TeamFortress_TeamShowMemberClasses =
{
	local entity e;
	local float found;

	found = 0;
	e = find (world, classname, "player");
	while (e)
	{
		if ((((e.team_no == Player.team_no) || (e.team_no == 0)) && (e != Player)))
		{
			if ((e.model != string_null))
			{
				if (!found)
				{
					found = 1;
					sprint (self, "The other members of your team are:\n");
				}
				sprint (Player, e.netname);
				sprint (Player, " : ");
//				TeamFortress_PrintClassName (Player, e.playerclass, (e.tfstate & 8));
				TeamFortress_PrintClassName (Player, e.class, (e.tfstate & 8));
			}
		}
		e = find (e, classname, "player");
	}
	if (!found)
	{
		sprint (Player, "There are no other players on your team.\n");
	}
};

// Returns class name value
string (float pc) TeamFortress_GetClassName =
{
	if ((pc == 1))			// Scout is class 1 (normal)
	{
		return ("Scout");
	}
	else
	{
		if ((pc == 2.1))
		{
			return ("Sniper");		// Player Class 2 is Spy in NexTF -- no Snipers
		}
		else
		{
			if ((pc == 4))				// Player Class 4 is soldier in NexTF
			{
				return ("Soldier");
			}
			else
			{
				if ((pc == 4.1))			// No DemoMan in NexTF
				{
					return ("Demolitions Man");
				}
				else
				{
					if ((pc == 16))
					{
						return ("Combat Medic");		// Medic is Class 16 in NexTF
					}
					else
					{
						if ((pc == 6.1))
						{
							return ("Heavy Weapons Guy");		// No HWGuy in NexTF
						}
						else
						{
							if ((pc == 8))
							{
								return ("Pyro");		// Pyro is class 8 in NexTF
							}
							else
							{
								if ((pc == 2))
								{
									return ("Spy");			// Spy is class 2 in NexTF
								}
								else
								{
									if ((pc == 32))
									{
										return ("Engineer");		// Engineer is class 32 in nextf
									}
									else
									{
										if ((pc == 11))			// Wazat- we need to make civ class
										{
											return ("Civilian");
										}
										else
										{
											if ((pc == 0))
											{
												return ("Observer");
											}
											else
											{
												if ((pc == 10))			// Wazat- we need to add "random class" feature
												{
													return ("Random Playerclass");
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};

// Prints the classname using TeamFortress_GetClassName function
void (entity Viewer, float pc, float rpc) TeamFortress_PrintClassName =
{
	local string st;

	st = TeamFortress_GetClassName (pc);
	sprint (Viewer, st);
	if ((rpc != 0))
	{
		sprint (Viewer, " (Random)");
	}
	sprint (Viewer, "\n");
};

// Returns Team Color Value
//				This is causing crashes in bringit -- I will attempt to fix
float (float tno) TeamFortress_TeamGetColor =
{
	if ((tno == 1))
	{
		return (14);
	}
	if ((tno == 2))
	{
		return (5);
	}
	if ((tno == 3))
	{
		return (13);
	}
	if ((tno == 4))
	{
		return (12);
	}
	return (0);
};

// Returns Team Score Value
float (float tno) TeamFortress_TeamGetScore =
{
	if ((tno == 1))
	{
		return (team1score);
	}
	if ((tno == 2))
	{
		return (team2score);
	}
	if ((tno == 3))
	{
		return (team3score);
	}
	if ((tno == 4))
	{
		return (team4score);
	}
	return (0);
};

// Get Team Lives
float (float tno) TeamFortress_TeamGetLives =
{
	if ((tno == 1))
	{
		return (team1lives);
	}
	if ((tno == 2))
	{
		return (team2lives);
	}
	if ((tno == 3))
	{
		return (team3lives);
	}
	if ((tno == 4))
	{
		return (team4lives);
	}
	return (0);
};

// Show Team Scores
void (float all) TeamFortress_TeamShowScores =
{
	local string st;
	local float i;
	local float j;

	i = 1;
	if ((all == 2))
	{
		while ((i <= number_of_teams))
		{
			if ((TeamFortress_TeamGetColor (i) > 0))
			{
				j = TeamFortress_TeamGetScore (i);
				st = TeamFortress_TeamGetColorString (i);
//				bprint (st);
//				bprint (": ");
				bprint (st);
				bprint (": ");
				st = ftos (j);
				//bprint (st);
				//bprint (" ");
				bprint (st);
				bprint (" ");
			}
			i = (i + 1);
		}
//		bprint ("\n");
		bprint ("\n");
		return;
	}
	while ((i <= number_of_teams))
	{
		if ((TeamFortress_TeamGetColor (i) > 0))
		{
			if (all)
			{
				bprint ("Team ");
			}
			else
			{
				sprint (self, "Team ");
			}
			st = ftos (i);
			if (all)
			{
				bprint (st);
			}
			else
			{
				sprint (self, st);
			}
			if (all)
			{
				bprint (" (");
			}
			else
			{
				sprint (self, " (");
			}
			st = TeamFortress_TeamGetColorString (i);
			if (all)
			{
				bprint (st);
			}
			else
			{
				sprint (self, st);
			}
			if (all)
			{
				bprint (") : ");
			}
			else
			{
				sprint (self, ") : ");
			}
			j = TeamFortress_TeamGetScore (i);
			st = ftos (j);
			if (all)
			{
				bprint (st);
			}
			else
			{
				sprint (self, st);
			}
			if (all)
			{
				bprint ("\n");
			}
			else
			{
				sprint (self, "\n");
			}
		}
		i = (i + 1);
	}
};

// Get Number Of Players On Team
float (float tno) TeamFortress_TeamGetNoPlayers =
{
	local float size_team;
	local entity search;

	search = find (world, classname, "player");
	while ((search != world))
	{
		if ((search.team_no == tno))
		{
			size_team = (size_team + 1);
		}
		search = find (search, classname, "player");
	}
	return (size_team);
};

// Get general number of players
float () TeamFortress_GetNoPlayers =
{
	local float nump;
	local entity search;

	search = find (world, classname, "player");
	while ((search != world))
	{
		if ((search.netname != string_null))
		{
			nump = (nump + 1);
		}
		search = find (search, classname, "player");
	}
	return (nump);
};

// Get max players for a team
float (float tno) TeamFortress_TeamGetMaxPlayers =
{
	if ((tno == 1))
	{
		return (team1maxplayers);
	}
	if ((tno == 2))
	{
		return (team2maxplayers);
	}
	if ((tno == 3))
	{
		return (team3maxplayers);
	}
	if ((tno == 4))
	{
		return (team4maxplayers);
	}
	return (0);
};

// Set The Team Color
void (float tno) TeamFortress_TeamSetColor =
{
	if ((tno == 1))
	{
		team1col = 14;
		return;
	}
	if ((tno == 2))
	{
		team2col = 5;
		return;
	}
	if ((tno == 3))
	{
		team3col = 13;
		return;
	}
	if ((tno == 4))
	{
		team4col = 12;
		return;
	}
};

// Set The Team Number
float (float tno) TeamFortress_TeamSet =
{
	local string st;
	local float tc;

	if ((teamplay < 1))
	{
		sprint (self, "Teamplay is not On, so FortressTeams are inactive.\n");
		return (0);
	}
	if (((tno > number_of_teams) && (number_of_teams != 0)))
	{
		sprint (self, "There can be only ");
		st = ftos (number_of_teams);
		sprint (self, st);
		sprint (self, " teams on this map.\nTry again\n");
		return (0);
	}
	if ((self.team_no > 0))
	{
		sprint (self, "You're already in Team No ");
		st = ftos (self.team_no);
		sprint (self, st);
		sprint (self, ".\n");
		return (0);
	}
	tc = TeamFortress_TeamGetNoPlayers (tno);
	if ((tc >= TeamFortress_TeamGetMaxPlayers (tno)))
	{
		sprint (self, "That team is full. Pick another.\n");
		return (0);
	}
	if ((TeamFortress_TeamGetColor (tno) == 0))
	{
		TeamFortress_TeamSetColor (tno);
		if ((TeamFortress_TeamGetColor (tno) == 0))
		{
			sprint (self, "You can't start a new team with your color, since another ");
			sprint (self, "already using that color. Change your pants color, then try again.\n");
			return (0);
		}
		bprint (self.netname);
		bprint (" has started Team No ");
		st = ftos (tno);
		bprint (st);
		bprint (".\n");
		self.immune_to_check = (time + 10);
		if (((toggleflags & 128) || (toggleflags & 2048)))
		{
			self.frags = TeamFortress_TeamGetScore (tno);
		}
		stuffcmd (self, "color ");
		tc = (TeamFortress_TeamGetColor (tno) - 1);
		st = ftos (tc);
		stuffcmd (self, st);
		stuffcmd (self, "\n");
		self.team_no = tno;
		self.lives = TeamFortress_TeamGetLives (tno);
		//if ((self.playerclass == 0))
		if ((self.class == 0))
		{
			if (TeamFortress_TeamIsCivilian (self.team_no))
			{
				self.impulse = 1;
				TeamFortress_ChangeClass ();
			}
		}
		return (1);
	}
	bprint (self.netname);
	bprint (" has joined Team No ");
	st = ftos (tno);
	bprint (st);
	bprint (".\n");
	stuffcmd (self, "color ");
	tc = (TeamFortress_TeamGetColor (tno) - 1);
	st = ftos (tc);
	stuffcmd (self, st);
	stuffcmd (self, "\n");
	self.team_no = tno;
	self.immune_to_check = (time + 10);
	self.lives = TeamFortress_TeamGetLives (tno);
	if (((toggleflags & 128) || (toggleflags & 2048)))
	{
		self.frags = TeamFortress_TeamGetScore (tno);
	}
	TeamFortress_TeamShowMemberClasses (self);
	//if ((self.playerclass == 0))
	if ((self.class == 0))
	{
		if (TeamFortress_TeamIsCivilian (self.team_no))
		{
			self.impulse = 1;
			TeamFortress_ChangeClass ();
		}
	}
	return (1);
};

// Get team score (used in conjunction with autoteam..)
float (float tno) TeamFortress_GetRealScore =
{
	local entity te;
	local float total;

	te = find (world, classname, "player");
	while (te)
	{
		if (te.team_no == tno)
		{			
			total = total + te.real_frags;
		}
		te = find (te, classname, "player");
	}
	return total;
}

// Find best team for player (autoteam?)
float() TeamFortress_TeamPutPlayerInTeam = 
{
	local float i;
	local float j;
	local float score1;
	local float score2;

	local float lowest;
	local float likely_team;

	i = 1;
	likely_team = random() * number_of_teams;
	likely_team = ceil(likely_team);
	if (likely_team == 0)
	{
		likely_team = number_of_teams;
	}

	lowest = 33;
	while (i < number_of_teams + 1)
	{
		j = TeamFortress_TeamGetNoPlayers(i);
		
		if (j < lowest)
		{
			if (TeamFortress_TeamGetMaxPlayers(i) > j)
			{
				lowest = j;
				likely_team = i;
			}
		}
		// pablo. fancier autoteam for even teams.
		else if (j == lowest)
		{
			
			if (TeamFortress_TeamGetMaxPlayers(i) > j)
			{
				score1 = TeamFortress_GetRealScore(i);
				score2 = TeamFortress_GetRealScore(likely_team);

				if ( score1 < score2 )
				{
					likely_team = i;
				}
				else if (score1 == score2)
				{
					if (random() > 0.5)
					{
						likely_team = i;
					}
				}
			}
		}
		//
		i = i + 1;
	}
	return TeamFortress_TeamSet(likely_team);
};

// Remove item_tfgoal timers
void() TeamFortress_RemoveTimers = 
{
	local entity te;
//	self.leg_damage = 0;		// No Snipers
//	self.is_undercover = 0;		// I think this function is called in PlayerKill
//	self.is_building = 0;		// To Be Added ?
//	self.building = world;		// To Be Added ?
	if (self.tfstate & 2048)
	{
		self.tfstate = self.tfstate - 2048;
		TeamFortress_SetSpeed(self);
		self.heat = 0;
	}
	te = find(world, classname, "timer");
	while (te != world)
	{
		if (te.owner == self)
		{
			dremove(te);
			te = find(world, classname, "timer");
		}
		else
		{
			te = find(te, classname, "timer");
		}
	}
	te = find(world, classname, "item_tfgoal");
	while (te)
	{
		if (te.owner == self)
		{
			if (!(te.goal_activation & 256))
			{
				tfgoalitem_RemoveFromPlayer(te, self, 0);
			}
			if (CTF_Map == 1 && te.goal_no == 1)
			{
				bprint(self.netname);
				bprint(" лост the блуе flag!\n");
			}
			else
			{
				if (CTF_Map == 1 && te.goal_no == 2)
				{
					bprint(self.netname);
					bprint(" лост the ред flag!\n");
				}
			}
		}
		te = find(te, classname, "item_tfgoal");
	}
	te = find(world, classname, "detpack");
	while (te)
	{
		if (te.weaponmode == 1 && te.enemy == self)
		{
			te.weaponmode = 0;
		}
		te = find(te, classname, "detpack");
	}
//	TeamFortress_DetonatePipebombs(); gold. this is the old code for removing pipebombs on quitting.  new one written by pablo is below.
	// NO PIPEBOMBS IN NEXTF
/*	te = find(world, classname, "pipebomb");
	while (te != world)
	{
		if(te.owner == self)
		{
			decrement_team_pipebombs(self.team_no);
			deathmsg = te.weapon;
			te.weapon = 10;
			T_RadiusDamage(te, self, 120, world);
			WriteByte(4, 23);
			WriteByte(4, 3);
			WriteCoord(4, te.origin_x);
			WriteCoord(4, te.origin_y);
			WriteCoord(4, te.origin_z);
			multicast(te.origin, TF_FLARE_OFF);
			dremove(te);
		}
	te = find(te, classname, "pipebomb");
	}*/
//	stuffcmd(self, "v_idlescale 0\n");
//	stuffcmd(self, "v_cshift 0 0 0 0\n");
//	self.item_list = 0;			// To Be Added?
//	self.FlashTime = 0;
	CenterPrint(self, "\n");
	self.menu_count = 25;		// Menu Stuff - important
	self.current_menu = 1;		////
	self.impulse = 0;
};

// TF's Become Explosion
void() BecomeExplosion = 
{
	dremove(self);
};

// TF Alias Maker
void(string halias, float himpulse1, float himpulse2) TeamFortress_Alias = 
{
	local string imp;
	stuffcmd(self, "alias ");
	stuffcmd(self, halias);
	stuffcmd(self, " \"impulse ");
	imp = ftos(himpulse1);
	stuffcmd(self, imp);
	if (himpulse2 != 0)
	{
		stuffcmd(self, ";wait; impulse ");
		imp = ftos(himpulse2);
		stuffcmd(self, imp);
	}
	stuffcmd(self, "\"\n");
};

float (float tno) TeamFortress_TeamGetIllegalClasses =
{
	if ((tno == 1))
	{
		return (illegalclasses1);
	}
	if ((tno == 2))
	{
		return (illegalclasses2);
	}
	if ((tno == 3))
	{
		return (illegalclasses3);
	}
	if ((tno == 4))
	{
		return (illegalclasses4);
	}
	return (0);
};

// Check if legal class
float (float pc) IsLegalClass =
{
	local float bit;

/*	if (((spy_off == 1) && (pc == 8)))
	{
		return (0);
	}*/
	if ((pc == 1))
	{
		bit = 1;
	}
	else
	{
		if ((pc == 2))
		{
			bit = 2;
		}
		else
		{
			if ((pc == 3))
			{
				bit = 4;
			}
			else
			{
				if ((pc == 4))
				{
					bit = 8;
				}
				else
				{
					if ((pc == 5))
					{
						bit = 16;
					}
					else
					{
						if ((pc == 6))
						{
							bit = 32;
						}
						else
						{
							if ((pc == 7))
							{
								bit = 64;
							}
							else
							{
								if ((pc == 8))
								{
									bit = 256;
								}
								else
								{
									if ((pc == 9))
									{
										bit = 512;
									}
									else
									{
										if ((pc == 10))
										{
											bit = 128;
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	if (((illegalclasses & bit) || (TeamFortress_TeamGetIllegalClasses (self.team_no) & bit)))
	{
		return (0);
	}
	return (1);
};

// Display legal classes for map
void () TeamFortress_DisplayLegalClasses =
{
	local float gotone;
	local float ill;

	sprint (self, "Legal Classes for your team are:\n");
	gotone = 0;
	ill = TeamFortress_TeamGetIllegalClasses (self.team_no);
	if ((!(illegalclasses & 1) && !(ill & 1)))
	{
		if (gotone)
		{
			sprint (self, ", ");
		}
		gotone = 1;
		sprint (self, "Scout");
	}
	if ((!(illegalclasses & 2) && !(ill & 2)))
	{
		if (gotone)
		{
			sprint (self, ", ");
		}
		gotone = 1;
		sprint (self, "Sniper");
	}
	if ((!(illegalclasses & 4) && !(ill & 4)))
	{
		if (gotone)
		{
			sprint (self, ", ");
		}
		gotone = 1;
		sprint (self, "Soldier");
	}
	if ((!(illegalclasses & 8) && !(ill & 8)))
	{
		if (gotone)
		{
			sprint (self, ", ");
		}
		gotone = 1;
		sprint (self, "Demolitions Man");
	}
	if ((!(illegalclasses & 16) && !(ill & 16)))
	{
		if (gotone)
		{
			sprint (self, ", ");
		}
		gotone = 1;
		sprint (self, "Combat Medic");
	}
	if ((!(illegalclasses & 32) && !(ill & 32)))
	{
		if (gotone)
		{
			sprint (self, ", ");
		}
		gotone = 1;
		sprint (self, "Heavy Weapons Guy");
	}
	if ((!(illegalclasses & 64) && !(ill & 64)))
	{
		if (gotone)
		{
			sprint (self, ", ");
		}
		gotone = 1;
		sprint (self, "Pyro");
	}
	if ((!(illegalclasses & 256) && !(ill & 256)))
	{
		if (gotone)
		{
			sprint (self, ", ");
		}
		gotone = 1;
		sprint (self, "Spy");
	}
	if ((!(illegalclasses & 512) && !(ill & 512)))
	{
		if (gotone)
		{
			sprint (self, ", ");
		}
		gotone = 1;
		sprint (self, "Engineer");
	}
	if ((!(illegalclasses & 128) && !(ill & 128)))
	{
		if (gotone)
		{
			sprint (self, ", ");
		}
		gotone = 1;
		sprint (self, "RandomPC");
	}
	sprint (self, "\n");
};

// TF class change/select function
void() TeamFortress_ChangeClass = 
{
	local entity spot;
	local entity te;
	local float tc;
	local string st;

	self.impulse += 100;		//temp

	if (self.playerclass != 0)
	{
//		if (deathmatch != 3)
//		{
//			return;
//		}
		if (TeamFortress_TeamIsCivilian(self.team_no))
		{
			sprint(self, "You cannot change class.\n");
			return;
		}
		if (!IsLegalClass(self.impulse - 100))
		{
			sprint(self, "Your team cannot play that class.\n");
			TeamFortress_DisplayLegalClasses();
			return;
		}
/*		tc = IsRestrictedClass(self.impulse - 100);			// TBA ADD THIS FUNCTION
		if (tc != 0)
		{
			if (tc > 0)
			{
				sprint(self, "That class is restricted to ");
				st = ftos(tc);
				sprint(self, st);
				sprint(self, " per team.\n");
			}
			else
			{
				sprint(self, "That class is disabled.\n");
			}
			return;
		}*/
		self.nextpc = self.impulse - 100;
		sprint(self, "After dying, you will return as a ");
		TeamFortress_PrintClassName(self, self.nextpc, self.tfstate & 8);
		self.immune_to_check = time + 10;
		return;
	}
/*if (teamplay && self.team_no == 0)		//handled in cmd function
	{
		if (toggleflags & 64)
		{
			if (TeamFortress_TeamPutPlayerInTeam() == 0)
			{
				return;
			}
		}
		else
		{
			sprint(self, "You must join a team first. \n");
			sprint(self, "use imin1, imin2, imin3, or imin4\n");
			return;
		}
	}*/
	if (self.lives == 0)
	{
		sprint(self, "You have no lives left.\n");
		return;
	}
	if (!IsLegalClass(self.impulse - 100) && self.impulse != 1)
	{
		sprint(self, "You cannot play that playerclass on this map. \n");
		TeamFortress_DisplayLegalClasses();
		return;
	}

/*	tc = IsRestrictedClass(self.impulse - 100);			// TBA
	if (tc != 0)
	{
		if (tc > 0)
		{
			sprint(self, "That class is restricted to ");
			st = ftos(tc);
			sprint(self, st);
			sprint(self, " per team.\n");
		}
		else
		{
			sprint(self, "That class is disabled.\n");
		}
		return;
	}*/
	if (self.impulse != 1)
	{
		self.playerclass = self.impulse - 100;
	}
	else
	{
		self.playerclass = 11;
	}
	if (self.playerclass == 10)
	{		
		sprint(self, "Random Playerclass.\n");
		self.tfstate = self.tfstate | 8;
/*		tc = 1 + floor(random() * (10 - 1));
		while (IsRestrictedClass(tc) != 0)
		{
			tc = 1 + floor(random() * (10 - 1));
		}*/
//		self.playerclass = tc;
		self.playerclass = 10;
		ChooseRandomClass();
	}
	//ftos(TeamFortress_TeamGetIllegalClasses (self.team_no) & bit)

	PutClientInServer ();		//temp
};

// XavioR's new TF reload function
void (float o, float m, void () g) weapon_thinkf;
void () Reload_Restore_Weapon =
{
	if (self.owner.weaponentity.pos1 != '0 0 0')
	{
		self.owner.weaponentity.pos1 = '0 0 0';
		self.owner.weaponentity.lip = PLAYER_WEAPONSELECTION_SPEED;
	}
};

void (float rweapon, float amount) DoReload =
{
	local float rtime;

	if (self.reload_time > time)
		return;
	if (amount == 0)
		return;

	weapon_action(self.weapon, WR_UPDATECOUNTS); // update ammo now
	if (rweapon != 5)
		sprint(self, "Reloading...\n");

	if (rweapon == 2)		// CryLink (flak cannon)
	{
		rtime = (amount * .80);
		self.clip_crylink = CLIP_MAX_CRYLINK;
	}
	if (rweapon == 3)		// Rocket launcher
	{
		rtime = (amount * 1.30);
		self.clip_rockets = 4;
	}
	if (rweapon == 4)		// Pipe Grenade Launcher
	{
		rtime = (amount * 1.05);
		self.clip_pipegrenades = 6;
	}
	if (rweapon == 5)		// Building something... (senrtry gun, tesla, etc.)
	{
		rtime = amount;
	}

	self.weaponentity.pos1 = PLAYER_WEAPONSELECTION_RANGE;
	self.weaponentity.lip = PLAYER_WEAPONSELECTION_SPEED;
	newmis = spawn();
	newmis.owner = self;
	newmis.think = Reload_Restore_Weapon;
	newmis.nextthink = time + rtime;
	if (rweapon != 5)
		self.reload_time = time + rtime;
};

// Xavior's self.playerclass to self.class conversion
string(string s1, ...) strcat;
void () Do_TFClass_Conversion =
{
	local float cl;
	local string cst;

	if (self.respawn_as_new_class > 0)
	{
		self.playerclass = self.respawn_as_new_class;
		self.respawn_as_new_class = 0;
		return;
	}

	if (self.playerclass == TF_CLASS_SCOUT) {
		self.class = CLASS_SCOUT;
		cst = "scout"; }
	if (self.playerclass == TF_CLASS_SOLDIER) {
		self.class = CLASS_SOLDIER;
		cst = "soldier"; }
	if (self.playerclass == TF_CLASS_MEDIC) {
		self.class = CLASS_MEDIC;
		cst = "medic"; }
	if (self.playerclass == TF_CLASS_PYRO) {
		self.class = CLASS_PYRO;
		cst = "pyro"; }
	if (self.playerclass == TF_CLASS_SPY) {
		self.class = CLASS_SPY;
		cst = "spy"; }
	if (self.playerclass == TF_CLASS_ENGINEER) {
		self.class = CLASS_ENGINEER;
		cst = "engineer"; }
	if (self.playerclass == TF_CLASS_RANDOM || self.tfstate == self.tfstate | 8) {
		cst = ChooseRandomClass(); }
	// Note to self: add Random and Civilian

	cl = GetPlayerClass();

	if (!self.class == cl)
	{
		if (cst == "engineer")
		{
			self.playermodel = strcat("models/class/",cst,"_other.zym");
		}
		else
		{
			self.playermodel = strcat("models/class/",cst,"_mechanical.zym");
		}
	}
	SetPlayerSpeed(self);
};

// XavioR's Random Class select
string () ChooseRandomClass =
{
	local float choose;
	local float good;

	while (good < 1)
	{
		choose = (1 + floor ((random () * (10 - 1))));
		if (IsLegalClass(choose) && choose != TF_CLASS_SNIPER && choose != TF_CLASS_DEMOMAN && choose != TF_CLASS_HWGUY)
		{
			good = 1;
//			sprint (self, ftos(choose));
//			sprint (self, "\n");
			if (choose == TF_CLASS_SCOUT) {
				self.class = CLASS_SCOUT;
				return ("scout"); }
			if (choose == TF_CLASS_SOLDIER) {
				self.class = CLASS_SOLDIER;
				return ("soldier"); }
			if (choose == TF_CLASS_PYRO) {
				self.class = CLASS_PYRO;
				return ("pyro"); }
			if (choose == TF_CLASS_ENGINEER) {
				self.class = CLASS_ENGINEER;
				return ("engineer"); }
			if (choose == TF_CLASS_MEDIC) {
				self.class = CLASS_MEDIC;
				return ("medic"); }
			if (choose == TF_CLASS_SPY) {
				self.class = CLASS_SPY;
				return ("spy"); }
		}
	}
};

// Nail projectile and blood
float current_yaw;
float (float fl) anglemod =
{
	while (fl >= 360)
	{
		fl = fl - 360;
	}
	while (fl < 0)
	{
		fl = fl + 360;
	}
	return (fl);
};

vector () wall_velocity =
{
	local vector vel;

	vel = normalize (self.velocity);
	vel = normalize (((vel + (v_up * (random () - 0.5))) + (v_right * (random () - 0.5))));
	vel = (vel + (2 * trace_plane_normal));
	vel = (vel * 200);
	return (vel);
};

void (vector org, float damage) SpawnBlood =
{
	particle (org, '0 0 0', 73, (damage * 2));
};

void (float damage) spawn_touchblood =
{
	local vector vel;

	vel = (wall_velocity () * 0.2);
	SpawnBlood ((self.origin + (vel * 0.01)), damage);
};

void () superspike_touch =
{
	local float ndmg;

/*	if (self.voided)				// temp?
	{
		return;
	}
	self.voided = 1;*/
	if (other == self.owner)
	{
		return;
	}
	if (other.solid == 1)
	{
		return;
	}
	if (pointcontents (self.origin) == -6)
	{
		dremove (self);
		return;
	}
	if (other.takedamage)
	{
		spawn_touchblood (18);
		deathmsg = self.weapon;
		if ((deathmsg == 9))
		{
			ndmg = 13;
		}
		else
		{
			ndmg = 26;
		}
		if (self.owner.classname == "grenade")
		{
			TF_T_Damage (other, self, self.owner.owner, ndmg, 2, 2);
		}
		else
		{
			TF_T_Damage (other, self, self.owner, ndmg, 2, 2);
		}
	}
	else
	{
		WriteByte (0, 23);
		WriteByte (0, 1);
		WriteCoord (0, self.origin_x);
		WriteCoord (0, self.origin_y);
		WriteCoord (0, self.origin_z);
	}
	dremove (self);
};

void () spike_touch =
{
	local float flt;

	if (other.solid == 1)
	{
		return;
	}
	if (pointcontents (self.origin) == -6)
	{
		dremove (self);
		return;
	}
	if (other.takedamage)
	{
		spawn_touchblood (9);
		deathmsg = self.weapon;
		if (self.owner.classname == "grenade")
		{
			TF_T_Damage (other, self, self.owner.owner, 9, 2, 2);
		}
		else
		{
			TF_T_Damage (other, self, self.owner, 9, 2, 2);
		}
	}
	else
	{
		WriteByte (4, 23);
		if ((self.classname == "wizspike"))
		{
			WriteByte (4, 7);
		}
		else
		{
			if ((self.classname == "knightspike"))
			{
				WriteByte (4, 8);
			}
			else
			{
				WriteByte (4, 0);
			}
		}
		WriteCoord (4, self.origin_x);
		WriteCoord (4, self.origin_y);
		WriteCoord (4, self.origin_z);
	}
	dremove (self);
};

void(vector org) te_gunshot;
float   EF_ADDITIVE/*     = 32*/;
void () ChangeModelTime =
{
	if (self.owner)
		setmodel (self.owner, self.classname);
	dremove(self);
};

void (entity ent, string st, float wait_time) soonmodel =
{
	local entity x;
	x = spawn ();
	x.classname = st;
	x.owner = ent;
	x.nextthink = time + wait_time;
	x.think = ChangeModelTime;
};

.float scale;

void (vector vect_a, vector vect_b) launch_spike =
{
	local entity e;			// bullet trail

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = 9;
	newmis.solid = 2;
	newmis.angles = vectoangles (vect_b);
	newmis.touch = spike_touch;
	newmis.weapon = 3;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = (time + 3);
	if (deathmsg != 9)
	{
		setmodel (newmis, "progs/syringe.mdl");
	}
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, vect_a);
	newmis.velocity = (vect_b * 2000);

		e = spawn();
		e.owner = self;
		e.movetype = MOVETYPE_FLY;
		e.solid = SOLID_NOT;
		e.think = SUB_Remove;
		e.nextthink = time + vlen(trace_endpos - self.origin) / 6000;
		e.velocity = vect_b * 4000;
		e.angles = vectoangles (vect_b);
		e.scale = .3;
//		soonmodel (e, "models/tracer.mdl", .1);
		setmodel (e, "models/tracer.mdl");
		setsize (e, '0 0 0', '0 0 0');
		setorigin (e, vect_a);
		e.effects = e.effects | EF_ADDITIVE;
};

// TF's Ammo-Updater
void () W_SetCurrentAmmo =
{
	weapon_action(self.weapon, WR_UPDATECOUNTS);
};

// TF Team Sprint
void (float tno, entity ignore, string st) teamsprint =
{
	local entity te;

	if ((tno == 0))
	{
		return;
	}
	te = find (world, classname, "player");
	while (te)
	{
		if (((te.team_no == tno) && (te != ignore)))
		{
			sprint (te, st);
		}
		te = find (te, classname, "player");
	}
};

// CENTERPRINT
void (entity pl, string s1, string s2) CenterPrint2 =
{
	centerprint (pl, s1, s2);
	pl.StatusRefreshTime = (time + 1.5);
};

// another ammo check caleld by the menu system. I dont know exactly what function this is for. - XavioR
void(entity p) bound_other_ammo = 
{
	if (p.ammo_shells > TeamFortress_GetMaxAmmo(p, 256))
	{
		p.ammo_shells = TeamFortress_GetMaxAmmo(p, 256);
	}
	if (p.ammo_nails > TeamFortress_GetMaxAmmo(p, 512))
	{
		p.ammo_nails = TeamFortress_GetMaxAmmo(p, 512);
	}
	if (p.ammo_rockets > TeamFortress_GetMaxAmmo(p, 1024))
	{
		p.ammo_rockets = TeamFortress_GetMaxAmmo(p, 1024);
	}
	if (p.ammo_cells > TeamFortress_GetMaxAmmo(p, 2048))
	{
		p.ammo_cells = TeamFortress_GetMaxAmmo(p, 2048);
	}
/*	if (p.ammo_medikit > p.maxammo_medikit)				// addme
	{
		p.ammo_medikit = p.maxammo_medikit;
	}*/
	if (p.armorvalue > p.maxarmor)
	{
		p.armorvalue = p.max_armor;
	}
	if (p.no_grenades_1 > 4)
	{
		p.no_grenades_1 = 4;
	}
	if (p.no_grenades_2 > 4)
	{
		p.no_grenades_2 = 4;
	}
};