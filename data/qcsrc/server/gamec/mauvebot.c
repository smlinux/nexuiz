/*
MauveBot v1.0 for Nexuiz
*/

const float names = 18;

string(float r) BotName =
{
	if (r == 1)
	{
		self.playermodel = "models/player/visitant.zym";
		self.playerskin = "1";
		return "Fricka";
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
		self.playermodel = "models/player/lycanthrope.zym";
		self.playerskin = "0";
		return "Lycanthrope";
	}
	else if (r == 12)
	{
		self.playermodel = "models/player/pyria.zym";
		self.playerskin = "0";
		return "Pyria";
	}
	else if (r == 13)
	{
		self.playermodel = "models/player/shock.zym";
		self.playerskin = "0";
		return "Shock";
	}
	else if (r == 14)
	{
		self.playermodel = "models/player/lurk.zym";
		self.playerskin = "1";
		return "Reptile";
	}
	else if (r == 15)
	{
		self.playermodel = "models/player/crash.zym";
		self.playerskin = "0";
		return "Quark";
	}
	else if (r == 16)
	{
		self.playermodel = "models/player/insurrectionist.zym";
		self.playerskin = "1";
		return "Anarchist";
	}
	else if (r == 17)
	{
		self.playermodel = "models/player/carni.zym";
		self.playerskin = "1";
		return "Armored Carni";
	}
	else if (r == 18)
	{
		self.playermodel = "models/player/nexus.zym";
		self.playerskin = "1";
		return "Mulder";
	}
	else
	{
		self.playermodel = "models/player/carni.zym";
		self.playerskin = "0";
		return "Carni";
	}
};

string () PickARandomName =
{
	local float y, test;
	local string h;
	local entity t;

	t = findflags(world, flags, FL_CLIENT);
	while(t)
	{
		if (clienttype(self) == CLIENTTYPE_BOT)
			y = y + 1;
		t = findflags(t, flags, FL_CLIENT);
	}

	if (y > names)
	{
		self.playermodel = "models/player/marine.zym";
		self.playerskin = "0";
		return "EJP_Tank";
	}

	test = ceil(random() * names);
	y = names;
	
	while(y)
	{
		h = BotName(test);
		t = find(world, netname, h);
		if (t == world)
			y = FALSE;
		else
			--y;
		test = math_mod(test+1, names);
	}
	return h;
};

// Adds a bot to the server
entity(float bottype) add_MauveBot =
{
	local entity oldself, ret;
	local float shirt, pants;

	oldself = self;
	self = spawnclient();
	if (!self)
	{
		bprint("Can not add bot, server full.\n");
		if (bottype == BOT_TYPE_MAUVEBOT)
			cvar_set("mauvebots", ftos(mauvebots));
		else
			cvar_set("bot_number", ftos(bot_number));
		self = oldself;
		return world;
	}

	if(teamplay)
	{
		// keep teams balanced
		JoinBestTeam(self, 0);
	}
	else
	{
		shirt = floor(random()*15);
		pants = floor(random()*15);
		self.clientcolors = pants + shirt * 16;
	}

	self.netname = PickARandomName();
 
	ClientConnect();
	PutClientInServer();
	self.autoswitch = 1; // bots currently need autoswitching
	self.skill_level = cvar("skill");
	if (self.skill_level > 10)
		self.skill_level = 10;
	if (self.skill_level < 1)
		self.skill_level = 1;
	ret = self;
	self = oldself;

	return ret;
};

void() remove_MauveBot = 
{
	local float flo, i;
	local entity ent;

	flo = floor(random() * mauvebots);
	
	ent = findflags(world, flags, FL_CLIENT);
	
	while(ent)
	{
		if (clienttype(ent) == CLIENTTYPE_BOT)
		{
			if (ent.bot_type == BOT_TYPE_MAUVEBOT)
			{
				if (flo == i)
				{
					self = ent;
					dropclient(ent);
					if (mauvebots > 0)
						mauvebots = mauvebots - 1;
					return;
				}
				i = i + 1;
			}
		}
		ent = findflags(ent, flags, FL_CLIENT);
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
			if (!(item.flags & FL_NOTARGET))
			if (item != self && !(cvar("teamplay") && (item.clientcolors == self.clientcolors)))
			if ((item.health > 0) && (!item.deadflag))
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
