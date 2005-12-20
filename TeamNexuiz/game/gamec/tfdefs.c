/*************************************
	Team:Nexuiz (NexTF) Definitions
*************************************/

/********************* General ***************************/
float TF_FLARE_LIT = 0;		// Woes of a decompiler, eh?
float TF_FLARE_OFF = 1;		////
float CTF_Map;
float (entity e, float healamount, float ignore) T_Heal;

// Temporary Defs (till I implement real systems for these)
//float joinorder;		// menu implemented :)

// Team Scores
float team1score;
float team2score;
float team3score;
float team4score;

// Team Colors
float team1col;
float team2col;
float team3col;
float team4col;

// Legal Classes
float illegalclasses/*    = 0*/;
float illegalclasses1;
float illegalclasses2;
float illegalclasses3;
float illegalclasses4;
float civilianteams;

// Last Spawn Place of Team
entity lastspawn_team1;
entity lastspawn_team2;
entity lastspawn_team3;
entity lastspawn_team4;

.float playerclass;			// TF's recognition of players. This will be set in accordance to tf playerclasses

// TF Class Numbers
float TF_CLASS_SCOUT = 1;
float TF_CLASS_SNIPER = 2;		//not in NexTF
float TF_CLASS_SOLDIER = 3;
float TF_CLASS_DEMOMAN = 4;		//not in NexTF
float TF_CLASS_MEDIC = 5;
float TF_CLASS_HWGUY = 6;		//not in NexTF
float TF_CLASS_PYRO = 7;
float TF_CLASS_SPY = 8;
float TF_CLASS_ENGINEER = 9;
float TF_CLASS_RANDOM = 10;			// Need fucntions for these 2
float TF_CLASS_CIVILIAN = 11;		////
.float respawn_as_new_class;	// what class the player will respawn as in accordance to tf's .playerclass

// Death Message (we should incorporate this into Team:Nexuiz some time)
float deathmsg;

// Hmm?
.float has_abbreviated;		// for NetQuake's UpdateAbbreviation fucntion
.float hn_i_g;
.float hasnt_item_from_group;
float flagem_checked;
.float tp_grenades_1;
.float tp_grenades_2;
.float camdist;
.vector camangle;
.entity observer_list;
float cb_prematch_time;

float civilianteams;	// Are civilian teams allowed?

float parems_decoded;		// Have the parameters already been decoded - XavioR

//Team Frags			(old function -- possibly moot)
float team1frags;
float team2frags;
float team3frags;
float team4frags;

//FlagExists floats so that a team flag isnt spawned twice by the Q3F conversion code
float redflagexists;
float blueflagexists;

.void() th_die;		// wtf is this again..
.void() th_stand;
.void() th_walk;
.void() th_run;
.void() th_missile;
.void() th_melee;

// Weapon Clips
.float reload_time;
.float clip_crylink;
.float clip_rockets;
.float clip_pipegrenades;
float CLIP_MAX_CRYLINK = 8;
float CLIP_MAX_ROCKETS = 4;
float CLIP_MAX_PIPEGRENADES = 6;

.float is_dead;			// temp		// player is dead

.float immune_to_check;		// How long player is immune to cheat check?
							//// Personally i think I'm jsut gonna implement krimzon's
							//// ParseClientCommand to check color change cheats. - XavioR
.float axhitme;			// Goal Item (I think) -- if ax hits then blah
						// There's no axe in nexuiz tho.... :/
.float armor_allowed;		//
.float maxarmor;			////
.float ammo_medikit;
.float maxammo_medikit;
.float ammo_detpack;
.float maxammo_detpack;
.float maxammo_shells;
.float maxammo_nails;
.float maxammo_cells;
.float maxammo_rockets;
.float last_impulse;
.float real_frags;
.float items_allowed;
.float super_time;		// no idea(?)
.float super_sound;		////
.float invisible_finished;		// Not a NexTF function(?)
.float invisible_time;			////
.float radsuit_finished;		// BioSuit(?)
.float rad_time;				////
.float distance;		// My guess is that this is whatever TF uses to store entity distances
						// from each other?
.float volume;
.float option5;

.float worldtype;			// Not sure

.float armorclass;	// How will nexTF's armor class work? 
					// It's a good thing to have in anyways I guess.

.float weaponmode;	//	I think only demoman and HWGuy use this, and since they're not in nextf.. poof

					// The TF State
.float tfstate;	// State of the player according to quake TF.
				// I will try to satisfy it for NexTF after the goal porting is done.
.float maxfbspeed;
.float maxstrafespeed;
.float StatusRefreshTime;		// The Status Bar
.float StatusBarSize;			////
.float StatusBarRes;			////

// MENU STUFF
.float current_menu;
.float menu_count;

.float heat;		// What tf uses for powering up weapons. Could be useful later?

entity otemp;
entity stemp;

.entity trigger_field;

.string noise4;		// MTF fucntion -- possibly moot.
.string deathtype;		// "You have the flag"

.string team_str_home;
.string team_str_moved;
.string team_str_carried;

void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void (entity targ, entity inflictor, entity attacker, float damage, float T_flags, float T_AttackType) TF_T_Damage;
void (entity Viewer, float pc, float rpc) TeamFortress_PrintClassName;
void (float classnum) SetMaxAmmoFor;

/*********************************************************/
///////////////////////////////////////////////////////////
/******************* Moved from:**************************/
//tffunctions
.float nextpc;		// for qued next player class -- we gonna use this?
void (string halias, float himpulse1, float himpulse2) TeamFortress_Alias;
string () ChooseRandomClass;

// tfcombat:
.float invincible_time;		//Pent effect time
.float invincible_sound;	//Pent hit sound
void (entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage;

// tfmapitems:
.float tf_items;
.float tf_items_flags;
.float goal_no;
.float group_no;
.float goal_state;
.float goal_activation;
.float goal_effects;
.float goal_group;
.float activate_goal_no;
.float inactivate_goal_no;
.float if_goal_is_active;
.float if_goal_is_inactive;
.float if_goal_is_removed;
.float if_group_is_active;
.float if_group_is_inactive;
.float if_group_is_removed;
.float remove_goal_no;
.float restore_goal_no;
.float activate_group_no;
.float inactivate_group_no;
.float remove_group_no;
.float restore_group_no;
.float has_item_from_group;
.float remove_item_group;
.float return_item_no;

// tfplats
.float height;
.entity movetarget;
void () SUB_CalcMoveDone;
void (vector tdest, float tspeed, void() func) SUB_CalcMove;
void (entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;

// tfq3fitems
.string is_converted_goal; // This is used to identify converted goals (helps me determine spawn in q3f maps)
float q3fdetect;
.vector orig_origin;
.string activetarget;
.string allowteams;
void () i_p_t;

// tfgrenades
void () TeamFortress_PrimeGrenade;
void () TeamFortress_ThrowGrenade;
void () NormalGrenadeTouch;
void () NormalGrenadeExplode;
float () crandom;

// tfsubs
.float dont_do_triggerwork;
void (entity Goal, entity AP) DoGroupWork;
void (entity Goal, entity AP) DoGoalWork;
void () button_wait;

/******************* End Moved From Section **************/
///////////////////////////////////////////////////////////
/*************** Defs that need functions ****************/
.float lives;			// Amount of lives
float toggleflags;
.float is_unabletospy;		// picking up tfgoal makes the spy unable to go undercover
.float owned_by;		// Item is owned by team #