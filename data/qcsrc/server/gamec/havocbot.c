
.void() havocbot_role;
void() havocbot_chooserole;

vector() havocbot_dodge =
{
	local entity head;
	local vector dodge, v, n;
	local float danger, bestdanger, vl, d;
	dodge = '0 0 0';
	bestdanger = -20;
	// check for dangerous objects near bot or approaching bot
	head = findchainfloat(bot_dodge, TRUE);
	while(head)
	{
		if (head.owner != self)
		{
			vl = vlen(head.velocity);
			if (vl > sv_maxspeed * 0.3)
			{
				n = normalize(head.velocity);
				v = self.origin - head.origin;
				d = v * n;
				if (d > (0 - head.bot_dodgerating))
				if (d < (vl * 0.2 + head.bot_dodgerating))
				{
					// calculate direction and distance from the flight path, by removing the forward axis
					v = v - (n * (v * n));
					danger = head.bot_dodgerating - vlen(v);
					if (bestdanger < danger)
					{
						bestdanger = danger;
						// dodge to the side of the object
						dodge = normalize(v);
					}
				}
			}
			else
			{
				danger = head.bot_dodgerating - vlen(head.origin - self.origin);
				if (bestdanger < danger)
				{
					bestdanger = danger;
					dodge = normalize(self.origin - head.origin);
				}
			}
		}
		head = head.chain;
	}
	return dodge;
};

//.float havocbotignoretime;
void() havocbot_movetogoal =
{
	local vector destorg;
	local vector diff;
	local vector dir;
	local vector flatdir;
	local vector m1;
	local vector m2;
	local vector evadeobstacle;
	local vector evadelava;
	local float s;
	//local float dist;
	local vector dodge;
	//if (self.goalentity)
	//	te_lightning2(self, self.origin, (self.goalentity.absmin + self.goalentity.absmax) * 0.5);
	self.movement = '0 0 0';
	if (self.goalcurrent == world)
		return;
	navigation_poptouchedgoals();
	if (self.goalcurrent == world)
	{
		// ran out of goals, rethink strategy as soon as possible
		self.bot_strategytime = 0;
		return;
	}
	evadeobstacle = '0 0 0';
	evadelava = '0 0 0';
	m1 = self.goalcurrent.origin + self.goalcurrent.mins;
	m2 = self.goalcurrent.origin + self.goalcurrent.maxs;
	destorg = self.origin;
	destorg_x = bound(m1_x, destorg_x, m2_x);
	destorg_y = bound(m1_y, destorg_y, m2_y);
	destorg_z = bound(m1_z, destorg_z, m2_z);
	diff = destorg - self.origin;
	//dist = vlen(diff);
	dir = normalize(diff);
	flatdir = diff;flatdir_z = 0;
	flatdir = normalize(flatdir);
	if (!self.waterlevel)
	{
		if (!(self.flags & FL_ONGROUND))
		{
			// prevent goal checks when we can't walk
			if (self.bot_strategytime < time + 0.1)
				self.bot_strategytime = time + 0.1;
			return;
		}

		// jump if going toward an obstacle that doesn't look like stairs we
		// can walk up directly
		tracebox(self.origin, self.mins, self.maxs, self.origin + self.velocity * 0.2, FALSE, self);
		if (trace_fraction < 1)
		if (trace_plane_normal_z < 0.7)
		{
			s = trace_fraction;
			tracebox(self.origin + '0 0 16', self.mins, self.maxs, self.origin + self.velocity * 0.2 + '0 0 16', FALSE, self);
			if (trace_fraction < s + 0.01)
			if (trace_plane_normal_z < 0.7)
			{
				s = trace_fraction;
				tracebox(self.origin + '0 0 48', self.mins, self.maxs, self.origin + self.velocity * 0.2 + '0 0 48', FALSE, self);
				if (trace_fraction > s)
					self.button2 = 1;
			}
		}

		traceline(self.origin + self.velocity * 0.3, self.origin + self.velocity * 0.3 + '0 0 -1000', TRUE, world);
		s = pointcontents(trace_endpos + '0 0 1');
		if (s == CONTENT_LAVA || s == CONTENT_SLIME)
			evadelava = normalize(self.velocity) * -1;

		dir = flatdir;
	}
	dodge = havocbot_dodge();
	dir = normalize(dir + dodge + evadeobstacle + evadelava) * 400;
	makevectors(self.v_angle);
	self.movement_x = dir * v_forward;
	self.movement_y = dir * v_right;
	self.movement_z = dir * v_up;
};

.float havocbot_chooseenemy_finished;
void() havocbot_chooseenemy =
{
	local entity head, best;
	local float rating, bestrating;
	local vector eye, v;
	if (cvar("bot_nofire"))
	{
		self.enemy = world;
		return;
	}
	if (time < self.havocbot_chooseenemy_finished)
		return;
	self.havocbot_chooseenemy_finished = time + cvar("bot_ai_enemydetectioninterval");
	eye = (self.origin + self.view_ofs);
	best = world;
	bestrating = 100000000;
	head = findchainfloat(bot_attack, TRUE);
	while (head)
	{
		v = (head.absmin + head.absmax) * 0.5;
		rating = vlen(v - eye);
		if (bestrating > rating)
		if (bot_shouldattack(head))
		{
			traceline(eye, v, TRUE, self);
			if (trace_ent == head || trace_fraction >= 1)
			{
				best = head;
				bestrating = rating;
			}
		}
		head = head.chain;
	}
	self.enemy = best;
};

float(entity e) w_getbestweapon;
void() havocbot_chooseweapon =
{
	self.switchweapon = w_getbestweapon(self);
};

.float nextaim;
void() havocbot_aim =
{
	local vector selfvel, enemyvel;
	if (time < self.nextaim)
		return;
	self.nextaim = time + 0.1;
	selfvel = self.velocity;
	if (!self.waterlevel)
		selfvel_z = 0;
	if (self.enemy)
	{
		enemyvel = self.enemy.velocity;
		if (!self.enemy.waterlevel)
			enemyvel_z = 0;
		lag_additem(time + self.ping, 0, 0, self.enemy, self.origin, selfvel, self.enemy.origin, enemyvel);
	}
	else
		lag_additem(time + self.ping, 0, 0, world, self.origin, selfvel, self.goalcurrent.origin, '0 0 0');
};

void() havocbot_ai =
{
	if (bot_strategytoken == self)
		self.havocbot_role();
	havocbot_chooseenemy();
	havocbot_chooseweapon();
	havocbot_aim();
	lag_update();
	if (self.bot_aimtarg)
		weapon_action(self.weapon, WR_AIM);
	else if (self.goalcurrent)
	{
		local vector v;
		v = self.goalcurrent.origin - self.origin;
		//v = self.velocity;
		if (self.waterlevel < 2)
			v_z = 0;
		//dprint("walk at:", vtos(v), "\n");
		//te_lightning2(world, self.origin, self.goalcurrent.origin);
		bot_aimdir(v, -1);
	}
	havocbot_movetogoal();
};

void() havocbot_setupbot =
{
	self.bot_ai = havocbot_ai;
	// will be updated by think code
	havocbot_chooserole_dm();
}
