/*************************************
	Team:Nexuiz (NexTF) Definitions
*************************************/

/********************* General ***************************/
string TN_VERSION =				"alpha .01";

float TF_FLARE_LIT = 0;		// Woes of a decompiler, eh?
float TF_FLARE_OFF = 1;		////
float CTF_Map;
float (entity e, float healamount, float ignore) T_Heal;

// Temporary Defs (till I implement real systems for these)
//float joinorder;		// menu implemented :)
.float undercover_team;				// is undercover as team number... Are we gonna use this one, wazat?
.float is_undercover;				// is just undercover..

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

//These are the "Map_Rules" entity's class restricts.
.float team1_scout, team1_soldier, team1_medic, team1_pyro, team1_spy, team1_engineer;
.float team2_scout, team2_soldier, team2_medic, team2_pyro, team2_spy, team2_engineer;
.float team3_scout, team3_soldier, team3_medic, team3_pyro, team3_spy, team3_engineer;
.float team4_scout, team4_soldier, team4_medic, team4_pyro, team4_spy, team4_engineer;

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

// spy feign
.float is_feigning;

// Weapon Clips
.float reload_time;
.float clip_pistol;
.float clip_crylink;
.float clip_rockets;
.float clip_pipegrenades;
float CLIP_MAX_PISTOL = 10;
float CLIP_MAX_CRYLINK = 8;
float CLIP_MAX_ROCKETS = 4;
float CLIP_MAX_PIPEGRENADES = 6;

.vector head_shot_vector;		// vector railgun_hitlocation
.float leg_damage;				// amount of times a player has been hit in the legs

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
.float maxammo_metal;				// maximum amoutn of metal that can be carried
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

.float pistol_fired;				// has the pistol been fired? 1 - yes, 2- no
.float next_pistol_fire;			// pistol cannot be fired again until this value < time
									//// check W_WeaponFrame for more detail on these 2

// WEAPON STUFF
.float next_nuke;
.float heat;		// What tf uses for powering up weapons. Could be useful later?

.float uses_bloom;		// Does the client have bloom enabled? (used for flash bloom effect)

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
.float DropFlagDelay;		// next time player can drop a flag
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
.entity tent;				// player who touches flag (touch ent?)

// tfplats
.float height;
.entity movetarget;
void () SUB_CalcMoveDone;
void (vector tdest, float tspeed, void() func) SUB_CalcMove;
void (entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;

// tfq3fitems
.string is_converted_goal; // This is used to identify converted goals (helps me determine spawn in q3f maps)
.string groupname;		   // generally gets set to blueflag or redflag
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
void () SUB_Remove;

// tfsentry
.float super_damage_finished;		// turrets can get super charged too!
//DP_QC_GETTAGINFO
//idea: VorteX, LordHavoc (somebody else?)
//DarkPlaces implementation: VorteX
//builtin definitions:
float(entity ent, string tagname) gettagindex = #451;
vector(entity ent, float tagindex) gettaginfo = #452;
//description:
//gettagindex returns the number of a tag on an entity, this number is the same as set by setattachment (in the .tag_index field), allowing the qc to save a little cpu time by keeping the number around if it wishes (this could already be done by calling setattachment and saving off the tag_index).
//gettaginfo returns the origin of the tag in worldspace and sets v_forward, v_right, and v_up to the current orientation of the tag in worldspace, this automatically resolves all dependencies (attachments, including viewmodelforclient), this means you could fire a shot from a tag on a gun entity attached to the view for example.

//tftesla
float modelindex_null    = 0;
.float has_turretized_tesla;			// is the player's tesla turretized?
float modelindex_eyes    = 0;

//	 non-tf files
// cl_impulses
.float impulse_wait;		// time when player can next use an impulse

//	 classes
// engiener
.float is_building;			// is the player in the middle of building something
.float has_dispenser;		// player has dispenser
.float has_sentry;			// player has sentry gun
.float has_tesla;			// player has tesla coil
.float has_teleporter;		// player has telepad (2 max)
.float has_extractor;		// player has metal extractor (3 max)
.entity barrel_ent;			// sentry gun's barrel entity
.entity animation_ent;		// an object's entity that controls its animations (dirty, but effective)
.float weapons_carried;		// used with tesla
void () TeamFortress_FinishedBuilding;
void () lvl1_sentry_stand;
void (float tno, entity ignore, string st) teamsprint;
.entity real_owner;									// The building's real owner (the one who built it)
.entity oldenemy;
.float current_weapon;
.float waitmin;
.float waitmax;
.void(entity attacker, float damage) th_pain;		// Function the building calls when it gets hurt
													// fixme!  XavioR

/******************* End Moved From Section **************/
///////////////////////////////////////////////////////////
/*************** Defs that need functions ****************/
.float lives;			// Amount of lives
float toggleflags;
.float is_unabletospy;		// picking up tfgoal makes the spy unable to go undercover
.float owned_by;		// Item is owned by team #

