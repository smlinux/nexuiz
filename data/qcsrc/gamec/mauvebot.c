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

string(float r) BotName =
{
	if (r == 1)
	{
		self.playermodel = "models/player/visitant.zym";
		self.playerskin = "0";
		return "Visitant";
	}
	else if (r == 2)
	{
		self.playermodel = "models/player/marine.zym";
		self.playerskin = "0";
		return "Marine";
	}
	else if (r == 3)
	{
		self.playermodel = "models/player/specop.zym";
		self.playerskin = "0";
		return "Specop";
	}
	else if (r == 4)
	{
		self.playermodel = "models/player/nexus.zym";
		self.playerskin = "0";
		return "Nexus";
	}
	else if (r == 5)
	{
		self.playermodel = "models/player/skadi.zym";
		self.playerskin = "0";
		return "Skadi";
	}
	else if (r == 6)
	{
		self.playermodel = "models/player/lurk.zym";
		self.playerskin = "0";
		return "Lurk";
	}
	else if (r == 7)
	{
		self.playermodel = "models/player/headhunter.zym";
		self.playerskin = "0";
		return "HeadHunter";
	}
	else if (r == 8)
	{
		self.playermodel = "models/player/carni.zym";
		self.playerskin = "0";
		return "Carni";
	}
	else if (r == 9)
	{
		self.playermodel = "models/player/grunt.zym";
		self.playerskin = "0";
		return "Grunt";
	}
	else if (r == 10)
	{
		self.playermodel = "models/player/insurrectionist.zym";
		self.playerskin = "0";
		return "Insurrectionist";
	}
	else if (r == 11)
	{
		self.playermodel = "models/player/jeandarc.zym";
		self.playerskin = "0";
		return "Jeandarc";
	}
	else if (r == 12)
	{
		self.playermodel = "models/player/lycanthrope.zym";
		self.playerskin = "0";
		return "Lycanthrope";
	}
	else if (r == 13)
	{
		self.playermodel = "models/player/pyria.zym";
		self.playerskin = "0";
		return "Pyria";
	}
	else if (r == 14)
	{
		self.playermodel = "models/player/shock.zym";
		self.playerskin = "0";
		return "Shock";
	}
	else if (r == 15)
	{
		self.playermodel = "models/player/marine.zym";
		self.playerskin = "1";
		return "Private";
	}
	else if (r == 16)
	{
		self.playermodel = "models/player/nexus.zym";
		self.playerskin = "1";
		return "Mulder";
	}
	else if (r == 17)
	{
		self.playermodel = "models/player/skadi.zym";
		self.playerskin = "1";
		return "Elite";
	}
	else if (r == 18)
	{
		self.playermodel = "models/player/lurk.zym";
		self.playerskin = "1";
		return "Reptile";
	}
	else if (r == 19)
	{
		self.playermodel = "models/player/crash.zym";
		self.playerskin = "2";
		return "mechanical";
	}
	else if (r == 20)
	{
		self.playermodel = "models/player/crash.zym";
		self.playerskin = "1";
		return "Quark";
	}
	else if (r == 21)
	{
		self.playermodel = "models/player/insurrectionist.zym";
		self.playerskin = "1";
		return "Anarchist";
	}
	else if (r == 22)
	{
		self.playermodel = "models/player/jeandarc.zym";
		self.playerskin = "1";
		return "Heroine";
	}
	else if (r == 23)
	{
		self.playermodel = "models/player/lycanthrope.zym";
		self.playerskin = "1";
		return "Wolf";
	}
	else if (r == 24)
	{
		self.playermodel = "models/player/pyria.zym";
		self.playerskin = "1";
		return "Soldier";
	}
	else if (r == 25)
	{
		self.playermodel = "models/player/shock.zym";
		self.playerskin = "1";
		return "Rebel";
	}
	else
	{
		self.playermodel = "models/player/crash.zym";
		self.playerskin = "0";
		return "Crash";
	}

};

string () PickARandomName =
{
	local float y, test;
	local string h;
	local entity t;

	t = find(world, classname, "player");
	while(t)
	{
		if (clienttype(self) == CLIENTTYPE_BOT)
			y = y + 1;
		t = find(t, classname, "player");
	}

	if (y > 25)
	{
		self.playermodel = "models/player/marine.zym";
		self.playerskin = "0";
		return "EJP_Tank";
	}

	y = TRUE;
	while(y)
	{
		test = ceil(random() * 25);
		h = BotName(test);
		t = find(world, netname, h);
		if (t == world)
			y = FALSE;
	}
	return h;
};

// Adds a bot to the server
void() add_MauveBot =
{
	local entity oldself;
	local float flo;
	local string str;

	oldself = self;
	self = spawnclient();
	if (!self)
	{
		bprint("Can not add bot, server full.\n");
		str = ftos(bot_number);
		cvar_set("bot_number", str);
		self = oldself;
		return;
	}
	
	flo = floor(random() * 5);
	if (flo == 0)
		self.clientcolors = 0;
	else if (flo == 1)
		self.clientcolors = 3;
	else if (flo == 2)
		self.clientcolors = 4;
	else if (flo == 3)
		self.clientcolors = 12;
	else if (flo == 4)
		self.clientcolors = 13;
	self.clientcolors = self.clientcolors + self.clientcolors * 16;

	self.netname = PickARandomName();

	ClientConnect();
	PutClientInServer();
	self.autoswitch = 1; // bots currently need autoswitching
	self.skill_level = cvar("skill");
	if (self.skill_level > 10)
		self.skill_level = 10;
	if (self.skill_level < 1)
		self.skill_level = 1;
	self = oldself;

	bot_number = bot_number + 1;
};

void() remove_MauveBot = 
{
	local float flo, i;
	local entity ent;

	flo = floor(random() * bot_number);
	
	ent = find(world, classname, "player");
	
	while(ent)
	{
		if (clienttype(ent) == CLIENTTYPE_BOT)
		{
			if (flo == i)
			{
				dropclient(ent);
				if (bot_number > 0)
					bot_number = bot_number - 1;
				return;
			}
			i = i + 1;
		}
		ent = find(ent, classname, "player");
	}
};

float (entity targ) visible =
{
	local vector start, end, org;

//	if (self.skill_level < 3)
//		if (random() > self.skill_level / 10)
//			return FALSE;

	org = targ.origin;
	if (org == '0 0 0')
		org = (targ.absmin + targ.absmax) * 0.5;

	start = self.origin + self.view_ofs;
	end = org;
	traceline (start, end, TRUE, self);	
	if (!(trace_inopen && trace_inwater))	
		if (trace_fraction == 1)
			return TRUE;
	return FALSE;
};

void(entity ent) bot_set_angle =
{
	local vector view;
	local float flo;
	if (ent != world)
	{
                view = ent.origin;
                if (view == '0 0 0')
                        view = (ent.absmin + ent.absmax) * 0.5;
		
		if (self.skill_level < 6)
			view = view - ent.velocity * (0.5 / self.skill_level);

		flo = vlen(ent.origin - self.origin) / (self.skill_level * 4);

		view_x = view_x + (random() * flo * 2) - flo;
		view_y = view_y + (random() * flo * 2) - flo;
		view_z = view_z + (random() * flo * 2) - flo;

                view = view - (self.origin + self.view_ofs);
                self.v_angle = vectoangles(view);
                self.v_angle_x = self.v_angle_x * -1;
		self.angles = self.v_angle;
		self.angles_x = self.angles_x * -1;
		if (self.angles_x > 180)
			self.angles_x = self.angles_x - 360;
		if (self.angles_x != 0)
                        self.angles_x = self.angles_x / 6;
	}
	else
		self.angles_x = 0;// hack!
};

void() MauveToGoal =
{
	local vector vec, en, diff, dir;

	vec = self.origin;
	movetogoal(20);
	en = self.origin;
	self.origin = vec;

	diff = en - self.origin;
	if (diff == '0 0 0')
		diff = self.goalentity.origin - self.origin;

	if (self.search_time < time)
	{
		self.goalentity.search_time = time + 20;
		self.goalentity = world;
		return;
	}	

	dir = normalize(diff);
	dir = dir * cvar("sv_maxspeed");// - (self.velocity - dir * (self.velocity * dir));

	makevectors(self.v_angle);
	self.movement_x = dir * v_forward;
	self.movement_y = dir * v_right;
	self.movement_z = dir * v_up;
};

void() look_for_stuff =
{
	local entity item, best, best2, best3;
	local float dist, tdist, dist2, topthreat;
	
        item = findradius(self.origin, 1000);
	
	if (self.search_time < time)
		self.enemy = world;

	if (self.enemy.health < 0)
		self.enemy = world;

	if (self.enemy.deadflag)
		self.enemy = world;
	
	dist = dist2 = SEARCH_DIST;
	topthreat = 0;

	while(item)
	{
                if (item.flags & FL_CLIENT)
		{
			if (item != self && !(cvar("teamplay") && (item.clientcolors == self.clientcolors)))
			{
				if ((item.health > 0) && (!item.deadflag))
				{
					if (visible(item))
					{
						tdist = vlen(item.origin - self.origin);
						if (tdist < dist)
						{
							best = item;
							dist = tdist;
						}
					}
				}
			}
		}
	        else if (( (item.flags & FL_ITEM) && item.model != string_null) && (item.search_time < time))
		{
			if (visible(item))
			{
				tdist = vlen(item.origin - self.origin);
				if (tdist < dist2)
				{
					best2 = item;
					dist2 = tdist;
				}
			}
		}
		if (item.threat == THREAT_UNFLAGGED)
		{
			if (item.classname == "missile")
				item.threat = 100;
			else if (item.classname == "laserbolt") 
				item.threat = 10;
			else if (item.classname == "grenade") 
				item.threat = 50;
			else if (item.classname == "plasma") 
				item.threat = 60;
			else if (item.classname == "spike")
				item.threat = 30;
			else
				item.threat = THREAT_IGNORE;
		}
		if (item.threat > 0)
		{
			if ((item.owner != self) || (item.velocity == '0 0 0'))
			{
				tdist = vlen(item.origin - self.origin);
				if (tdist < DODGE_DIST)
				{
					if (item.threat / tdist > topthreat)
					{
						topthreat = item.threat / tdist;
						best3 = item;
					}
				}
			}
		}
		item = item.chain;
        }
	if ((best != self.enemy) && (best != world))
		self.enemy = best;
	if ((best2 != self.goalentity) && (best2 != world))
	{
		self.goalentity = best2;
		self.search_time = time + 5;
	}
	self.dodgeent = best3;
};

void() DodgeProjectile =
{
	local vector vec;

	vec = vectoangles(self.dodgeent.origin - self.origin);
	makevectors(vec);
	
	self.goalentity = spawn();

	if (self.dodgeent.velocity != '0 0 0')
		setorigin(self.goalentity, self.origin + v_right * 50);
	else
		setorigin(self.goalentity, self.origin - v_forward * 50);
	
	MauveToGoal();

	remove(self.goalentity);
	self.goalentity = world;
};

void() MauveBot_AI =
{
	
	if (clienttype(self) != CLIENTTYPE_BOT)
	{
		local float flo;

		if (time >= 3)
		{
			float botnumbercvar;
			botnumbercvar = cvar("bot_number");
			flo = rint(botnumbercvar);
	                if(flo != botnumbercvar)
		                cvar_set("bot_number", ftos(flo));
	
			if (flo > bot_number)
				add_MauveBot();
			else if (flo < bot_number)
				remove_MauveBot();
		}
		else
			remove_MauveBot();
		return;
	}

	self.button0 = 0;
	self.button2 = 0;
	self.button3 = 0;

	self.movement = '0 0 0';

	if (self.deadflag == DEAD_RESPAWNABLE)
	{
		self.button0 = 1;
		return;
	}
	else if (self.deadflag)
		return;

	if (self.goalentity.model == string_null)
		self.goalentity = world;

	if (time > self.ai_time)
	{
		self.ai_time = time + (0.5 / self.skill_level) + (random() * (1 / self.skill_level));

		look_for_stuff();
	
		if (self.enemy)
		{
			bot_set_angle(self.enemy);
			if (visible(self.enemy))
			{
				self.button0 = 1;
				self.search_time = 100000;
			}
			else	if (self.search_time == 100000)
				self.search_time = time + 5;
			if (self.goalentity == world)
			{
				if (self.enemy)
				{
					self.goalentity = self.enemy;
					if (vlen(self.enemy.origin - self.origin) < 300)
						self.dodgeent = self.enemy;
				}
			}
		}
		else if (self.goalentity)
			bot_set_angle(self.goalentity);

		if (random() < 0.03)
			self.button2 = 1;
	}
	else
	{
		if (self.skill_level > 3)
		{
			if (visible(self.enemy))
			{
				self.button0 = 1;
				self.search_time = 100000;
			}
		}
	}

	if (self.dodgeent != world)
		DodgeProjectile();
	else if (self.goalentity != world)
		MauveToGoal();
};
