float BOTTYPE_MAUVEBOT = 0;
float BOTTYPE_URREBOT = 1;
.float bottype;

/*
MauveBot v1.0 for Nexuiz
*/

float intermission_running;

.float skill_level;

.float ai_time;
.float threat;
.entity dodgeent;

float THREAT_UNFLAGGED = 0;
float THREAT_IGNORE = -1;

float DODGE_DIST = 500;
float SEARCH_DIST = 1000;

.float search_time;

float bot_number;

void() add_MauveBot;
void() remove_MauveBot;

/*
UrreBot 1.5 for Nexuiz
*/

entity navnode_chain, bot_chain;
float navnodes, loadstep;
.entity list, link0, link1, link2, link3, link4, link5, link6, link7, link8, link9;
.entity link10, link11, link12, link13, link14, link15, link16, link17, link18, link19;
.float sflags;
.float lflags0, lflags1, lflags2, lflags3, lflags4, lflags5, lflags6, lflags7, lflags8, lflags9;
.float lflags10, lflags11, lflags12, lflags13, lflags14, lflags15, lflags16, lflags17, lflags18, lflags19;
.vector pointl;
.float costl;
.float lmark;
float search_distance;
float minisearch_distance;
float stratsearch_distance;
.entity goalcurrent;
.entity goallist;
.float strat_me;
.float(entity c_item) evalfunc;

vector nullvector;
.vector movepoint;
.float camptime;
.vector campcheck;

.vector aimpoint;
.float aimtime;
.float evaltime;
.float lead;

float skill;

float S_TELEPORT = 1;
float S_DOOR = 2;
float S_TOUCH = 4;

float LF_NOLINK = 1;
float LF_NOWALK = 2;
float LF_BAD = 4;
float LF_BIGDROP = 8;
float LF_REMOTE = 16;

.entity plane_chain;

float urrebots, actualurrebots, urrebots_strategytime, urrebots_combattime;

entity strategytoken;
float strategytime;
.float combattime;

entity(vector org, vector minss, vector maxss) FindCurrentNavNode;
void(float distance) UrreBotPath;
void() UrreBotSetup;
void() UrreBotThink;
void() LoadNavNodes;
void() LinkNavNodes;
void() ItemEvals;
void() UrreBotAdd;
void() UrreBotRemove;

float(vector m1, vector m2, vector m3, vector m4) boxesoverlap = {return m2_x >= m3_x && m1_x <= m4_x && m2_y >= m3_y && m1_y <= m4_y && m2_z >= m3_z && m1_z <= m4_z;};
float(vector smins, vector smaxs, vector bmins, vector bmaxs) boxenclosed = {return smins_x >= bmins_x && smaxs_x <= bmaxs_x && smins_y >= bmins_y && smaxs_y <= bmaxs_y && smins_z >= bmins_z && smaxs_z <= bmaxs_z;};

entity newmis;
void() SUB_Remove;
float JoinBestTeam(entity pl, float only_return_best);
float sv_maxspeed;

void() Bots_Shared =
{
	local float flo;

	if (time >= 3)
	{
		// MauveBots
		flo = cvar("bot_number");
		if (flo > bot_number)
			add_MauveBot();
		else if (flo < bot_number)
			remove_MauveBot();

		// UrreBots
		urrebots = cvar("urrebots");
		urrebots_strategytime = cvar("urrebots_strategytime");
		urrebots_combattime = cvar("urrebots_combattime");
		stratsearch_distance = cvar("urrebots_stratsearch_dist");
		minisearch_distance = cvar("urrebots_minisearch_dist");
		if (actualurrebots < urrebots)
		{
			if (loadstep == 0)
			{
				LoadNavNodes();
				loadstep = 1;
				return;
			}
			else if (loadstep == 1)
			{
				LinkNavNodes();
				loadstep = 2;
				return;
			}
			else if (loadstep == 2)
			{
				ItemEvals();
				loadstep = 3;
				return;
			}
			UrreBotAdd();
		}
		if (actualurrebots > urrebots)
			UrreBotRemove();
	}
	else
	{
		remove_MauveBot();
		UrreBotRemove();
	}
};