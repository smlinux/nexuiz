
void() SUB_Null;
float() CheckExistence;
void() train_next;
void() func_train_find;
void() plat_center_touch;
void() plat_outside_touch;
void() plat_trigger_use;
void() plat_go_up;
void() plat_go_down;
void() plat_crush;



void() plat_spawn_inside_trigger = 
{
	local entity trigger;
	local vector tmin;
	local vector tmax;
	trigger = spawn();
	trigger.touch = plat_center_touch;
	trigger.movetype = 0;
	trigger.solid = 1;
	trigger.enemy = self;
	trigger.team_no = self.team_no;
	trigger.playerclass = self.playerclass;
	trigger.items_allowed = self.items_allowed;
	trigger.activate_goal_no = self.activate_goal_no;
	trigger.inactivate_goal_no = self.inactivate_goal_no;
	trigger.remove_goal_no = self.remove_goal_no;
	trigger.restore_goal_no = self.restore_goal_no;
	trigger.activate_group_no = self.activate_group_no;
	trigger.inactivate_group_no = self.inactivate_group_no;
	trigger.remove_group_no = self.remove_group_no;
	trigger.restore_group_no = self.restore_group_no;
	trigger.goal_activation = self.goal_activation;
	trigger.goal_effects = self.goal_effects;
	trigger.goal_result = self.goal_result;
	trigger.goal_group = self.goal_group;
	tmin = self.mins + '25 25 0';
	tmax = self.maxs - '25 25 -8';
	tmin_z = tmax_z - (self.pos1_z - self.pos2_z + 8);
	if (self.spawnflags & 1)
	{
		tmax_z = tmin_z + 8;
	}
	if (self.size_x <= 50)
	{
		tmin_x = (self.mins_x + self.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if (self.size_y <= 50)
	{
		tmin_y = (self.mins_y + self.maxs_y) / 2;
		tmax_y = tmin_y + 1;
	}
	setsize(trigger, tmin, tmax);
};

void() plat_hit_top = 
{
	sound(self, 2, self.noise1, 1, 1);
	self.state = 0;
	self.think = plat_go_down;
	self.nextthink = self.ltime + 3;
};

void() plat_hit_bottom = 
{
	sound(self, 2, self.noise1, 1, 1);
	self.state = 1;
};

void() plat_go_down = 
{
	sound(self, 2, self.noise, 1, 1);
	self.state = 3;
	SUB_CalcMove(self.pos2, self.speed, plat_hit_bottom);
};

void() plat_go_up = 
{
	sound(self, 2, self.noise, 1, 1);
	self.state = 2;
	SUB_CalcMove(self.pos1, self.speed, plat_hit_top);
};

void() plat_center_touch = 
{
	local entity te;
	if (other.classname != "player")
	{
		return;
	}
	if (!Activated(self, other))
	{
		if (self.else_goal != 0)
		{
			te = Findgoal(self.else_goal);
			if (te)
			{
				DoResults(te, other, self.goal_result & 2);
			}
		}
		return;
	}
	if (other.health <= 0)
	{
		return;
	}
	self = self.enemy;
	if (self.state == 1)
	{
		plat_go_up();
	}
	else
	{
		if (self.state == 0)
		{
			self.nextthink = self.ltime + 1;
		}
	}
};

void() plat_outside_touch = 
{
	local entity te;
	if (other.classname != "player")
	{
		return;
	}
	if (!Activated(self, other))
	{
		if (self.else_goal != 0)
		{
			te = Findgoal(self.else_goal);
			if (te)
			{
				DoResults(te, other, self.goal_result & 2);
			}
		}
		return;
	}
	if (other.health <= 0)
	{
		return;
	}
	self = self.enemy;
	if (self.state == 0)
	{
		plat_go_down();
	}
};

void() plat_trigger_use = 
{
	if (self.think)
	{
		return;
	}
	plat_go_down();
};

void() plat_crush = 
{
	T_Damage(other, self, self, 1);
	if (self.state == 2)
	{
		plat_go_down();
	}
	else
	{
		if (self.state == 3)
		{
			plat_go_up();
		}
		else
		{
			objerror("plat_crush: bad self.state\n");
		}
	}
};

void() plat_use = 
{
	self.use = SUB_Null;
	if (self.state != 2)
	{
		objerror("plat_use: not in up state");
	}
	plat_go_down();
};

void() func_plat = 
{
	// Q3F/ETF support
	if (self.allowteams == "red")
	{
		self.team_no = 2;
	}
	if (self.allowteams == "blue")
	{
		self.team_no = 1;
	}

	if (CheckExistence() == 0)
	{
		dremove(self);
		return;
	}
	if (!(self.t_length))
	{
		self.t_length = 80;
	}
	if (!(self.t_width))
	{
		self.t_width = 10;
	}
	if (self.sounds == 0)
	{
		self.sounds = 2;
	}
	if (self.sounds == 1)
	{
		precache_sound("plats/plat1.wav");
		precache_sound("plats/plat2.wav");
		self.noise = "plats/plat1.wav";
		self.noise1 = "plats/plat2.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound("plats/medplat1.wav");
		precache_sound("plats/medplat2.wav");
		self.noise = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}
	if (self.sounds == 4)
	{
		precache_sound("plats/track_st.wav");
		precache_sound("plats/track_e.wav");
		self.noise = "plats/track_st.wav";
		self.noise1 = "plats/track_e.wav";
	}
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.classname = "plat";
	self.solid = 4;
	self.movetype = 7;
	setorigin(self, self.origin);
	setmodel(self, self.model);
	setsize(self, self.mins, self.maxs);
	self.blocked = plat_crush;
	if (!(self.speed))
	{
		self.speed = 150;
	}
	self.pos1 = self.origin;
	self.pos2 = self.origin;
	if (self.height)
	{
		self.pos2_z = self.origin_z - self.height;
	}
	else
	{
		self.pos2_z = self.origin_z - self.size_z + 8;
	}
	self.use = plat_trigger_use;
	plat_spawn_inside_trigger();
	if (self.targetname)
	{
		self.state = 2;
		self.use = plat_use;
	}
	else
	{
		setorigin(self, self.pos2);
		self.state = 1;
	}
};

void() train_blocked = 
{
	if (time < self.attack_finished)
	{
		return;
	}
	self.attack_finished = time + 0.5;
	T_Damage(other, self, self, self.dmg);
};

void() train_use = 
{
	if (self.think != func_train_find)
	{
		return;
	}
	train_next();
};

void() train_wait = 
{
	if (self.wait)
	{
		self.nextthink = self.ltime + self.wait;
		if (self.wait == -1)
		{
			self.think = func_train_find;
		}
		self.sounds = 4;
		if (4)
		{
			sound(self, 2, self.noise, 1, 0);
		}
		else
		{
			sound(self, 2, self.noise, 1, 1);
		}
	}
	else
	{
		self.nextthink = self.ltime + 0.1;
	}
	self.think = train_next;
};

void() train_next = 
{
	local entity targ;
	targ = find(world, targetname, self.target);
	self.target = targ.target;
	if (!(self.target))
	{
		objerror("train_next: no next target");
	}
	if (targ.wait)
	{
		self.wait = targ.wait;
	}
	else
	{
		self.wait = 0;
	}
	self.sounds = 4;
//	if (4)
//	{
//		sound(self, 2, self.noise1, 1, 0);
//	}
//	else
//	{
		sound(self, 2, self.noise1, 1, 1);
//	}
	SUB_CalcMove(targ.origin - self.mins, self.speed, train_wait);
};

void() func_train_find = 
{
	local entity targ;
	targ = find(world, targetname, self.target);
	self.target = targ.target;
	setorigin(self, targ.origin - self.mins);
	if (!(self.targetname))
	{
		self.nextthink = self.ltime + 0.1;
		self.think = train_next;
	}
};

void() followtrain = 
{
	setorigin(self, self.owner.origin);
	self.nextthink = time + 0.1;
	self.think = followtrain;
};

void() func_train = 
{
	if (CheckExistence() == 0)
	{
		dremove(self);
		return;
	}
	if (!(self.speed))
	{
		self.speed = 100;
	}
	if (!(self.target))
	{
		objerror("func_train without a target");
	}
	if (!(self.dmg))
	{
		self.dmg = 2;
	}
	if (self.sounds == 0)
	{
		self.noise = "misc/null.wav";
		precache_sound("misc/null.wav");
		self.noise1 = "misc/null.wav";
		precache_sound("misc/null.wav");
	}
	if (self.sounds == 1)
	{
		self.noise = "plats/train2.wav";
		precache_sound("plats/train2.wav");
		self.noise1 = "plats/train1.wav";
		precache_sound("plats/train1.wav");
	}
	if (self.sounds == 4)
	{
		precache_sound("plats/track_st.wav");
		precache_sound("plats/track_e.wav");
		self.noise = "plats/track_e.wav";
		self.noise1 = "plats/track_st.wav";
	}
	self.cnt = 1;
	self.solid = 4;
	self.movetype = 7;
	self.blocked = train_blocked;
	self.use = train_use;
	self.classname = "train";
	setmodel(self, self.model);
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};

void() light_move = 
{
	if (CheckExistence() == 0)
	{
		dremove(self);
		return;
	}
	if (!(self.speed))
	{
		self.speed = 100;
	}
	if (!(self.target))
	{
		objerror("light_move without a target");
	}
	self.noise = "misc/null.wav";
	precache_sound("misc/null.wav");
	self.noise1 = "misc/null.wav";
	precache_sound("misc/null.wav");
	self.cnt = 1;
	if (!(self.effects))
	{
		self.effects = 4;
	}
	self.solid = 4;
	self.movetype = 7;
	self.classname = "movelight";
	precache_model("progs/s_null.spr");
	setmodel(self, "progs/s_null.spr");
	setsize(self, '0 0 0', '0 0 0');
	setorigin(self, self.origin);
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};

void() misc_teleporttrain = 
{
	if (CheckExistence() == 0)
	{
		dremove(self);
		return;
	}
	if (!(self.speed))
	{
		self.speed = 100;
	}
	if (!(self.target))
	{
		objerror("func_train without a target");
	}
	self.cnt = 1;
	self.solid = 0;
	self.movetype = 7;
	self.blocked = train_blocked;
	self.use = train_use;
	self.avelocity = '100 200 300';
	self.noise = "misc/null.wav";
	precache_sound("misc/null.wav");
	self.noise1 = "misc/null.wav";
	precache_sound("misc/null.wav");
	precache_model2("progs/teleport.mdl");
	setmodel(self, "progs/teleport.mdl");
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};


