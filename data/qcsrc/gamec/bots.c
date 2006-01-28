float BOT_TYPE_AUTOURRE = 0;
float BOT_TYPE_AUTOMAUVE = 1;
float BOT_TYPE_URREBOT = 2;
float BOT_TYPE_MAUVEBOT = 3;
.float bot_type;
float bot_number;

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

float mauvebots;

entity(float bottype) add_MauveBot;
void() remove_MauveBot;

/*
UrreBot 1.5 for Nexuiz
*/

entity navnode_chain, urrebot_chain;
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

float urrebots, urrebots_strategytime, urrebots_combattime;

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
entity(float bottype) UrreBotAdd;
void() UrreBotRemove;

float(vector m1, vector m2, vector m3, vector m4) boxesoverlap = {return m2_x >= m3_x && m1_x <= m4_x && m2_y >= m3_y && m1_y <= m4_y && m2_z >= m3_z && m1_z <= m4_z;};
float(vector smins, vector smaxs, vector bmins, vector bmaxs) boxenclosed = {return smins_x >= bmins_x && smaxs_x <= bmaxs_x && smins_y >= bmins_y && smaxs_y <= bmaxs_y && smins_z >= bmins_z && smaxs_z <= bmaxs_z;};

entity newmis;
void() SUB_Remove;
float JoinBestTeam(entity pl, float only_return_best);
float sv_maxspeed;

void() AutoBotRemove =
{
	local entity ent, t;

	ent = findchain(classname, "player");
	while (ent)
	{
		if (clienttype(ent) == CLIENTTYPE_BOT)
		{
			if (ent.bot_type != BOT_TYPE_URREBOT && ent.bot_type != BOT_TYPE_MAUVEBOT)
			{
				if (self.list)
				{
					if (urrebot_chain == self)
						urrebot_chain = self.list;
					else
					{
						t = find(world, classname, "player");
						while(t)
						{
							if (t.list == ent)
								t.list = ent.list;
							t = find(t, classname, "player");
						}
					}
				}
				if (bot_number > 0)
					bot_number -= 1;
				//if(cvar("g_lms") && self.frags < 1) // DP_SV_BOTCLIENT handles this automaticly
				//	lms_dead_count -= 1;
				dropclient(ent);
			}
		}
		ent = ent.chain;
	}
};

void() Bots_Shared =
{
	local entity bot;
	local float f;

	if (time >= 3)
	{
		// UrreBots
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
		f = cvar("urrebots");
		urrebots_strategytime = cvar("urrebots_strategytime");
		urrebots_combattime = cvar("urrebots_combattime");
		stratsearch_distance = cvar("urrebots_stratsearch_dist");
		minisearch_distance = cvar("urrebots_minisearch_dist");
		if (urrebots < f)
		{
			bot = UrreBotAdd(BOT_TYPE_URREBOT);
			bot.bot_type = BOT_TYPE_URREBOT;
			urrebots = urrebots + 1;
		}
		if (urrebots > f)
			UrreBotRemove();

		// MauveBots
		f = cvar("mauvebots");
		if (f > mauvebots)
		{
			bot = add_MauveBot(BOT_TYPE_MAUVEBOT);
			bot.bot_type = BOT_TYPE_MAUVEBOT;
			mauvebots = mauvebots + 1;
		}
		else if (f < mauvebots)
			remove_MauveBot();

		// AutoBots
		f = cvar("bot_number");
		if (f > bot_number)
		{
			bot = world;
			if (navnodes)
			{
				bot = UrreBotAdd(BOT_TYPE_AUTOURRE);
				if (bot)
				{
					bot.bot_type = BOT_TYPE_AUTOURRE;
					bot_number += 1;
				}
			}
			else
			{
				bot = add_MauveBot(BOT_TYPE_AUTOMAUVE);
				if (bot)
				{
					bot.bot_type = BOT_TYPE_AUTOMAUVE;
					bot_number += 1;
				}
			}
		}
		else if (f < bot_number)
			AutoBotRemove();
	}
	else
	{
		AutoBotRemove();
		remove_MauveBot();
		UrreBotRemove();
	}
};