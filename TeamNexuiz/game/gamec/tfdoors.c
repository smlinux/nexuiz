// TF DOORS	
void() door_go_down;
void() door_go_up;
float() DoorShouldOpen;

void() fd_secret_move1;
void() fd_secret_move2;
void() fd_secret_move3;
void() fd_secret_move4;
void() fd_secret_move5;
void() fd_secret_move6;
void() fd_secret_done;


float() DoorShouldOpen = 
{
	local entity ptr;
	local float plyrcount;
	local entity plyr1;
	local entity plyr2;
	if (coop != 2)
	{
		return TF_FLARE_OFF;
	}
	plyrcount = TF_FLARE_LIT;
	ptr = find(world, classname, "player");
	while (ptr != world)
	{
		if (!(ptr.tf_items & self.items) && ptr.playerclass != TF_FLARE_LIT && ptr.solid != TF_FLARE_LIT && ptr.model != string_null)
		{
			plyrcount = plyrcount + TF_FLARE_OFF;
			if (plyrcount == TF_FLARE_OFF)
			{
				plyr1 = ptr;
			}
			else
			{
				if (plyrcount == 2)
				{
					plyr2 = ptr;
				}
			}
		}
		ptr = find(ptr, classname, "player");
	}
	if (plyrcount != TF_FLARE_LIT)
	{
		if (plyrcount == TF_FLARE_OFF)
		{
			bprint(plyr1.netname);
			bprint(" needs");
		}
		else
		{
			if (plyrcount == 2)
			{
				bprint(plyr1.netname);
				bprint(" and ");
				bprint(plyr2.netname);
				bprint(" need");
			}
			else
			{
				bprint("More players need");
			}
		}
		bprint(" to unlock the ");
		if (self.items & 131072)
		{
			bprint("silver");
		}
		else
		{
			bprint("gold");
		}
		bprint(" door\n");
		return TF_FLARE_LIT;
	}
	bprint("The ");
	if (self.items & 131072)
	{
		bprint("silver");
	}
	else
	{
		bprint("gold");
	}
	bprint(" door has been unlocked\n");
	return TF_FLARE_OFF;
};

void() door_blocked = 
{
	T_Damage(other, self, self, self.dmg);
	if (self.wait >= TF_FLARE_LIT)
	{
		if (self.state == 3)
		{
			door_go_up();
		}
		else
		{
			door_go_down();
		}
	}
};

void() door_hit_top = 
{
	sound(self, 2, self.noise1, TF_FLARE_OFF, TF_FLARE_OFF);
	self.state = TF_FLARE_LIT;
	if (self.spawnflags & 32)
	{
		return;
	}
	self.think = door_go_down;
	self.nextthink = self.ltime + self.wait;
};

void() door_hit_bottom = 
{
	self.goal_state = 2;
	sound(self, 2, self.noise1, TF_FLARE_OFF, TF_FLARE_OFF);
	self.state = TF_FLARE_OFF;
};

void() door_go_down = 
{
	sound(self, 2, self.noise2, TF_FLARE_OFF, TF_FLARE_OFF);
	if (self.max_health)
	{
		self.takedamage = TF_FLARE_OFF;
		self.health = self.max_health;
	}
	self.state = 3;
	SUB_CalcMove(self.pos1, self.speed, door_hit_bottom);
};

void() door_go_up = 
{
	if (self.state == 2)
	{
		return;
	}
	if (self.state == TF_FLARE_LIT)
	{
		self.nextthink = self.ltime + self.wait;
		return;
	}
	sound(self, 2, self.noise2, TF_FLARE_OFF, TF_FLARE_OFF);
	self.state = 2;
	SUB_CalcMove(self.pos2, self.speed, door_hit_top);
	SUB_UseTargets();
};

void() door_fire = 
{
	local entity oself;
	local entity starte;
	if (self.owner != self)
	{
		objerror("door_fire: self.owner != self");
	}
	if (self.items)
	{
		sound(self, 2, self.noise4, TF_FLARE_OFF, TF_FLARE_OFF);
	}
	self.message = string_null;
	oself = self;
	if (self.spawnflags & 32)
	{
		if (self.state == 2 || self.state == TF_FLARE_LIT)
		{
			starte = self;
			do
			{
				door_go_down();
				self = self.enemy;
			} while (self != starte && self != world);
			self = oself;
			return;
		}
	}
	starte = self;
	do
	{
		door_go_up();
		self = self.enemy;
	} while (self != starte && self != world);
	self = oself;
};

void() door_use = 
{
	local entity oself;
	self.message = "";
	self.owner.message = "";
	self.enemy.message = "";
	oself = self;
	self = self.owner;
	door_fire();
	self = oself;
};

void() door_trigger_touch = 
{
	local entity te;
	if (other.health <= TF_FLARE_LIT)
	{
		return;
	}
	if (!Activated(self, other))
	{
		if (self.else_goal != TF_FLARE_LIT)
		{
			te = Findgoal(self.else_goal);
			if (te)
			{
				DoResults(te, other, self.goal_result & 2);
			}
		}
		return;
	}
	if (time < self.attack_finished)
	{
		return;
	}
	self.attack_finished = time + TF_FLARE_OFF;
	activator = other;
	self = self.owner;
	door_use();
};

void() door_killed = 
{
	local entity oself;
	oself = self;
	self = self.owner;
	self.health = self.max_health;
	self.takedamage = TF_FLARE_LIT;
	door_use();
	self = oself;
};

void() door_touch = 
{
	local entity te;
	if (other.classname != "player")
	{
		return;
	}
	if (self.owner.attack_finished > time)
	{
		return;
	}
	if (!Activated(self, other))
	{
		if (self.else_goal != TF_FLARE_LIT)
		{
			te = Findgoal(self.else_goal);
			if (te)
			{
				DoResults(te, other, self.goal_result & 2);
			}
		}
		return;
	}
	self.owner.attack_finished = time + 2;
	if (self.owner.message != "")
	{
		CenterPrint(other, self.owner.message);
		sound(other, 2, "misc/talk.wav", TF_FLARE_OFF, TF_FLARE_OFF);
	}
	if (!(self.items))
	{
		return;
	}
	if ((self.items & other.items) != self.items)
	{
		if (self.owner.items == 131072)
		{
			if (world.worldtype == 2)
			{
				CenterPrint(other, "You need the silver keycard");
				sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
			}
			else
			{
				if (world.worldtype == TF_FLARE_OFF)
				{
					CenterPrint(other, "You need the silver runekey");
					sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
				}
				else
				{
					if (world.worldtype == TF_FLARE_LIT)
					{
						CenterPrint(other, "You need the silver key");
						sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
					}
				}
			}
		}
		else
		{
			if (world.worldtype == 2)
			{
				CenterPrint(other, "You need the gold keycard\n");
				sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
			}
			else
			{
				if (world.worldtype == TF_FLARE_OFF)
				{
					CenterPrint(other, "You need the gold runekey");
					sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
				}
				else
				{
					if (world.worldtype == TF_FLARE_LIT)
					{
						CenterPrint(other, "You need the gold key");
						sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
					}
				}
			}
		}
		return;
	}
	other.items = other.items - self.items;
	other.tf_items = other.tf_items | self.items;
	if (DoorShouldOpen())
	{
		self.touch = SUB_Null;
		if (self.enemy)
		{
			self.enemy.touch = SUB_Null;
		}
		door_use();
	}
};

entity(vector fmins, vector fmaxs) spawn_field = 
{
	local entity trigger;
	local vector t1;
	local vector t2;
	trigger = spawn();
	trigger.movetype = TF_FLARE_LIT;
	trigger.solid = TF_FLARE_OFF;
	trigger.owner = self;
	trigger.touch = door_trigger_touch;
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
	t1 = fmins;
	t2 = fmaxs;
	setsize(trigger, t1 - '60 60 8', t2 + '60 60 8');
	return trigger;
};

float(entity e1, entity e2) EntitiesTouching = 
{
	if (e1.mins_x > e2.maxs_x)
	{
		return TF_FLARE_LIT;
	}
	if (e1.mins_y > e2.maxs_y)
	{
		return TF_FLARE_LIT;
	}
	if (e1.mins_z > e2.maxs_z)
	{
		return TF_FLARE_LIT;
	}
	if (e1.maxs_x < e2.mins_x)
	{
		return TF_FLARE_LIT;
	}
	if (e1.maxs_y < e2.mins_y)
	{
		return TF_FLARE_LIT;
	}
	if (e1.maxs_z < e2.mins_z)
	{
		return TF_FLARE_LIT;
	}
	return TF_FLARE_OFF;
};

void() LinkDoors = 
{
	local entity t;
	local entity starte;
	local vector cmins;
	local vector cmaxs;
	if (self.enemy)
	{
		return;
	}
	if (self.spawnflags & 4)
	{
		self.enemy = self;
		self.owner = self;
		return;
	}
	cmins = self.mins;
	cmaxs = self.maxs;
	starte = self;
	t = self;
	do
	{
		self.owner = starte;
		if (self.health)
		{
			starte.health = self.health;
		}
		if (self.targetname)
		{
			starte.targetname = self.targetname;
		}
		if (self.message != "")
		{
			starte.message = self.message;
		}
		t = find(t, classname, self.classname);
		if (!t)
		{
			self.enemy = starte;
			self = self.owner;
			if (self.health)
			{
				return;
			}
			if (self.targetname)
			{
				return;
			}
			if (self.items)
			{
				return;
			}
			self.owner.trigger_field = spawn_field(cmins, cmaxs);
			return;
		}
		if (EntitiesTouching(self, t))
		{
			if (t.enemy)
			{
				objerror("cross connected doors");
			}
			self.enemy = t;
			self = t;
			if (t.mins_x < cmins_x)
			{
				cmins_x = t.mins_x;
			}
			if (t.mins_y < cmins_y)
			{
				cmins_y = t.mins_y;
			}
			if (t.mins_z < cmins_z)
			{
				cmins_z = t.mins_z;
			}
			if (t.maxs_x > cmaxs_x)
			{
				cmaxs_x = t.maxs_x;
			}
			if (t.maxs_y > cmaxs_y)
			{
				cmaxs_y = t.maxs_y;
			}
			if (t.maxs_z > cmaxs_z)
			{
				cmaxs_z = t.maxs_z;
			}
		}
	} while (TF_FLARE_OFF);
};

void() func_door = 
{
	//	Q3F/ETF Map Support
	if (self.allowteams == "red")
	{
		self.team_no = 2;
	}
	if (self.allowteams == "blue")
	{
		self.team_no = 1;
	}

	if(self.noise2) precache_sound (self.noise2);	//tz 05 11 10

	if (CheckExistence() == TF_FLARE_LIT)
	{
		dremove(self);
		return;
	}
	if (world.worldtype == TF_FLARE_LIT)
	{
		precache_sound("doors/medtry.wav");
		precache_sound("doors/meduse.wav");
		self.noise3 = "doors/medtry.wav";
		self.noise4 = "doors/meduse.wav";
	}
	else
	{
		if (world.worldtype == TF_FLARE_OFF)
		{
			precache_sound("doors/runetry.wav");
			precache_sound("doors/runeuse.wav");
			self.noise3 = "doors/runetry.wav";
			self.noise4 = "doors/runeuse.wav";
		}
		else
		{
			if (world.worldtype == 2)
			{
				precache_sound("doors/basetry.wav");
				precache_sound("doors/baseuse.wav");
				self.noise3 = "doors/basetry.wav";
				self.noise4 = "doors/baseuse.wav";
			}
			else
			{
				dprint("no worldtype set!\n");
			}
		}
	}
	if (self.sounds == TF_FLARE_LIT)
	{
		precache_sound("misc/null.wav");
		precache_sound("misc/null.wav");
		self.noise1 = "misc/null.wav";
		if (!self.noise2)
			self.noise2 = "misc/null.wav";
	}
	if (self.sounds == TF_FLARE_OFF)
	{
		precache_sound("doors/drclos4.wav");
		precache_sound("doors/doormv1.wav");
		self.noise1 = "doors/drclos4.wav";
		if (!self.noise2)
			self.noise2 = "doors/doormv1.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound("doors/hydro1.wav");
		precache_sound("doors/hydro2.wav");
		self.noise2 = "doors/hydro1.wav";
		self.noise1 = "doors/hydro2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound("doors/stndr1.wav");
		precache_sound("doors/stndr2.wav");
		self.noise2 = "doors/stndr1.wav";
		self.noise1 = "doors/stndr2.wav";
	}
	if (self.sounds == 4)
	{
		precache_sound("doors/ddoor1.wav");
		precache_sound("doors/ddoor2.wav");
		self.noise1 = "doors/ddoor2.wav";
		self.noise2 = "doors/ddoor1.wav";
	}
	if (self.armorclass == TF_FLARE_OFF)
	{
		precache_sound("doors/creekdr1.wav");
		precache_sound("doors/creekdr2.wav");
		self.noise2 = "doors/creekdr1.wav";
		self.noise1 = "doors/creekdr2.wav";
	}
	if (self.armorclass == 2)
	{
		precache_sound("doors/metaldr1.wav");
		precache_sound("doors/metaldr2.wav");
		self.noise2 = "doors/metaldr1.wav";
		self.noise1 = "doors/metaldr2.wav";
	}
	if (self.armorclass == 3)
	{
		precache_sound("doors/electdr1.wav");
		precache_sound("doors/electdr2.wav");
		self.noise2 = "doors/electdr1.wav";
		self.noise1 = "doors/electdr2.wav";
	}
	if (self.armorclass == 4)
	{
		precache_sound("doors/track_st.wav");
		precache_sound("doors/track_e.wav");
		self.noise2 = "doors/track_st.wav";
		self.noise1 = "doors/track_e.wav";
	}
	SetMovedir();
	self.max_health = self.health;
	self.solid = 4;
	self.movetype = 7;
	setorigin(self, self.origin);
	setmodel(self, self.model);
	self.classname = "door";
	self.blocked = door_blocked;
	self.use = door_use;
	if (self.spawnflags & 16)
	{
		self.items = 131072;
	}
	if (self.spawnflags & 8)
	{
		self.items = 262144;
	}
	if (!(self.speed))
	{
		self.speed = 100;
	}
	if (!(self.wait))
	{
		self.wait = 3;
	}
	if (!(self.lip))
	{
		self.lip = 8;
	}
	if (!(self.dmg))
	{
		self.dmg = 2;
	}
	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir * (fabs(self.movedir * self.size) - self.lip);
	if (self.spawnflags & TF_FLARE_OFF)
	{
		setorigin(self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
	}
	self.state = TF_FLARE_OFF;
	if (self.health)
	{
		self.takedamage = TF_FLARE_OFF;
		self.th_die = door_killed;
	}
	if (self.items)
	{
		self.wait = -1;
	}
	self.touch = door_touch;
	self.think = LinkDoors;
	self.nextthink = self.ltime + 0.1;
};

void() fd_secret_use = 
{
	local float temp;
	self.health = 10000;
	if (self.origin != self.oldorigin)
	{
		return;
	}
	if (self.spawnflags & 32)
	{
		return;
	}
	self.message = string_null;
	SUB_UseTargets();
	if (!(self.spawnflags & 8))
	{
		self.th_pain = SUB_Null;
		self.takedamage = TF_FLARE_LIT;
	}
	self.velocity = '0 0 0';
	sound(self, 2, self.noise1, TF_FLARE_OFF, TF_FLARE_OFF);
	self.nextthink = self.ltime + 0.1;
	temp = TF_FLARE_OFF - (self.spawnflags & 2);
	makevectors(self.mangle);
	if (!(self.t_width))
	{
		if (self.spawnflags & 4)
		{
			self.t_width = fabs(v_up * self.size);
		}
		else
		{
			self.t_width = fabs(v_right * self.size);
		}
	}
	if (!(self.t_length))
	{
		self.t_length = fabs(v_forward * self.size);
	}
	if (self.spawnflags & 4)
	{
		self.dest1 = self.origin - v_up * self.t_width;
	}
	else
	{
		self.dest1 = self.origin + v_right * (self.t_width * temp);
	}
	self.dest2 = self.dest1 + v_forward * self.t_length;
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move1);
	sound(self, 2, self.noise2, TF_FLARE_OFF, TF_FLARE_OFF);
};

void() fd_secret_move1 = 
{
	self.nextthink = self.ltime + TF_FLARE_OFF;
	self.think = fd_secret_move2;
	sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
};

void() fd_secret_move2 = 
{
	sound(self, 2, self.noise2, TF_FLARE_OFF, TF_FLARE_OFF);
	SUB_CalcMove(self.dest2, self.speed, fd_secret_move3);
};

void() fd_secret_move3 = 
{
	sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
	if (!(self.spawnflags & TF_FLARE_OFF))
	{
		self.nextthink = self.ltime + self.wait;
		self.think = fd_secret_move4;
	}
};

void() fd_secret_move4 = 
{
	sound(self, 2, self.noise2, TF_FLARE_OFF, TF_FLARE_OFF);
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move5);
};

void() fd_secret_move5 = 
{
	self.nextthink = self.ltime + TF_FLARE_OFF;
	self.think = fd_secret_move6;
	sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
};

void() fd_secret_move6 = 
{
	sound(self, 2, self.noise2, TF_FLARE_OFF, TF_FLARE_OFF);
	SUB_CalcMove(self.oldorigin, self.speed, fd_secret_done);
};

void() fd_secret_done = 
{
	if (!(self.targetname) || (self.spawnflags & 16))
	{
		self.health = 10000;
		self.takedamage = TF_FLARE_OFF;
		self.th_pain = fd_secret_use;
		self.th_die = fd_secret_use;
	}
	sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
};

void() secret_blocked = 
{
	if (time < self.attack_finished)
	{
		return;
	}
	self.attack_finished = time + 0.5;
	T_Damage(other, self, self, self.dmg);
};

void() secret_touch = 
{
	if (other.classname != "player")
	{
		return;
	}
	if (self.attack_finished > time)
	{
		return;
	}
	if (self.spawnflags & 32)
	{
		return;
	}
	self.attack_finished = time + 2;
	if (self.message)
	{
		CenterPrint(other, self.message);
		sound(other, 4, "misc/talk.wav", TF_FLARE_OFF, TF_FLARE_OFF);
	}
};

void() func_door_secret = 
{
	if (CheckExistence() == TF_FLARE_LIT)
	{
		dremove(self);
		return;
	}
	if (self.sounds == TF_FLARE_LIT)
	{
		self.sounds = 3;
	}
	if (self.sounds == TF_FLARE_OFF)
	{
		precache_sound("doors/latch2.wav");
		precache_sound("doors/winch2.wav");
		precache_sound("doors/drclos4.wav");
		self.noise1 = "doors/latch2.wav";
		self.noise2 = "doors/winch2.wav";
		self.noise3 = "doors/drclos4.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound("doors/airdoor1.wav");
		precache_sound("doors/airdoor2.wav");
		self.noise2 = "doors/airdoor1.wav";
		self.noise1 = "doors/airdoor2.wav";
		self.noise3 = "doors/airdoor2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound("doors/basesec1.wav");
		precache_sound("doors/basesec2.wav");
		self.noise2 = "doors/basesec1.wav";
		self.noise1 = "doors/basesec2.wav";
		self.noise3 = "doors/basesec2.wav";
	}
	if (!(self.dmg))
	{
		self.dmg = 2;
	}
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.solid = 4;
	self.movetype = 7;
	self.classname = "door";
	setmodel(self, self.model);
	setorigin(self, self.origin);
	self.touch = secret_touch;
	self.blocked = secret_blocked;
	self.speed = 50;
	self.use = fd_secret_use;
	if (!(self.targetname) || (self.spawnflags & 16))
	{
		self.health = 10000;
		self.takedamage = TF_FLARE_OFF;
		self.th_pain = fd_secret_use;
	}
	self.oldorigin = self.origin;
	if (!(self.wait))
	{
		self.wait = 5;
	}
};
