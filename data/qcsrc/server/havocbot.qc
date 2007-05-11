
.void() havocbot_role;
void() havocbot_chooserole;
.float havocbot_keyboardskill;

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
.float havocbot_keyboardtime;
.float havocbot_ducktime;
.vector havocbot_keyboard;
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

	if(self.jumppadcount)
	{
		if(self.flags & FL_ONGROUND)
			self.jumppadcount = FALSE;
		else
			return;
	}

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
		// Since new update in air contol, we can move in air
		//if (!(self.flags & FL_ONGROUND))
		//{
		//	// prevent goal checks when we can't walk
		//	if (self.bot_strategytime < time + 0.1)
		//		self.bot_strategytime = time + 0.1;
		//	return;
		//}

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
	dodge = dodge * bound(0,3+skill*0.1,1);
	evadelava = evadelava * bound(1,3-skill,3); //Noobs fear lava a lot and take more distance from it
	traceline(self.origin, self.enemy.origin, TRUE, world);
	if(trace_ent.classname == "player")
		dir = dir * bound(0,skill/7,1);

	dir = normalize(dir + dodge + evadeobstacle + evadelava);



	// Emulate keyboard interface;
	local vector keyboard,flatangle;
	local float blend;
	keyboard = self.havocbot_keyboard;
	if (time >= self.havocbot_keyboardtime)
	{
		flatdir=dir; flatdir_z = 0;
		self.havocbot_keyboardtime =
			max(
				self.havocbot_keyboardtime
					+ bound(0,0.05/(skill+self.havocbot_keyboardskill),0.05)
					+random()*bound(0,0.025/(skill+self.havocbot_keyboardskill),100)
			, time);
		keyboard = '0 0 0';
		
		flatangle = self.v_angle; flatangle_z=0;
		makevectors(flatangle);
		
		local float trigger;
		local vector v_forward_right;
		local vector v_forward_left;
		blend = bound(0,skill*0.1,1);
		trigger = cvar("bot_ai_keyboard_treshold");
		v_forward_right = normalize(v_forward + v_right);
		v_forward_left  = normalize(v_forward - v_right);
		// Place in reverse order !! least important direction FIRST
		
		if (skill > 4.5)
		{
			if (flatdir * v_forward_right * -1 > trigger) keyboard = v_forward_right * -1;
			if (flatdir * v_forward_left  * -1 > trigger) keyboard = v_forward_left  * -1;
		}
		if (skill > 2.5)
		{
			if (flatdir * v_forward_right      > trigger) keyboard = v_forward_right;
			if (flatdir * v_forward_left       > trigger) keyboard = v_forward_left;
			if (flatdir * v_forward       *  1 > trigger) keyboard = v_forward * -1;
		}
		if (skill > 1.5)
		{
			if (flatdir * v_right              > trigger) keyboard = v_right;
			if (flatdir * v_right         * -1 > trigger) keyboard = v_right   * -1;
		}
			if (flatdir * v_forward            > trigger) keyboard = v_forward;
		//dprint(ftos(flatdir * v_forward),"\n");
		keyboard = normalize(keyboard);
		self.havocbot_keyboard = keyboard;
		if (self.havocbot_ducktime>time) self.button5=TRUE;
	}
	blend = bound(0,vlen(self.goalcurrent.origin-self.origin)/cvar("bot_ai_keyboard_distance"),1); // When getting close move with 360 degree
	dir = (keyboard * blend + dir * (1-blend))*cvar("sv_maxspeed");

	self.movement_x = dir * v_forward;
	self.movement_y = dir * v_right;
	if (self.flags & FL_INWATER) self.movement_z = dir * v_up; else self.movement_z = 0;

	if ((dir * v_up) >= cvar("sv_jumpvelocity")*0.5 && (self.flags & FL_ONGROUND)) self.button2=1;
	if (((dodge * v_up) > 0) && random()*frametime >= 0.2*bound(0,(10-skill)*0.1,1)) self.button2=TRUE;
	if (((dodge * v_up) < 0) && random()*frametime >= 0.5*bound(0,(10-skill)*0.1,1)) self.havocbot_ducktime=time+0.3/bound(0.1,skill,10);
	
};

.float havocbot_chooseenemy_finished;
.float havocbot_stickenemy;
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
	traceline(self.origin+self.view_ofs, self.enemy.origin+self.enemy.view_ofs*0.5,FALSE,world);
	if (trace_ent.classname != "player")
		self.havocbot_stickenemy =0;
	else	if ( (trace_ent != self.enemy) || (vlen(self.enemy.origin - self.origin) > 1000) )
		{
			self.havocbot_stickenemy =0;
			if( (self.health < 30) || (self.enemy.health < 0))
			self.havocbot_chooseenemy_finished = time;
		}
	//dprint(ftos(self.havocbot_stickenemy));dprint(etos(self.enemy),"\n");
	//dprint(ftos(time),"-");dprint(ftos(self.havocbot_chooseenemy_finished),"\n");
	if (self.havocbot_stickenemy == 1)
	{
		// remain tracking him for a shot while (case he went after a small corner or pilar
		self.havocbot_chooseenemy_finished = time + bound(0,skill*0.1,1)*1.8;
		return;
	}
	if (time < self.havocbot_chooseenemy_finished)
	{
		self.havocbot_stickenemy = 1;
		return;
	}
	self.havocbot_chooseenemy_finished = time + cvar("bot_ai_enemydetectioninterval")*bound(0,(11-skill)*0.1,1);
	self.havocbot_chooseenemy_finished = time + 0.01;
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
	self.havocbot_stickenemy = 1;
};

float(entity e) w_getbestweapon;
.float havocbot_chooseweapon_timer;
.float havocbot_chooseweapon_lastbestscore;
void() havocbot_chooseweapon =
{
	// TODO: clean this up by moving it to weapon code
	if(self.enemy.classname!="player")
	{
		self.switchweapon = w_getbestweapon(self);
		return;
	}

	local float rocket  ; rocket   =-1000;
	local float nex     ; nex      =-1000;
	local float hagar   ; hagar    =-1000;
	local float grenade ; grenade  =-1000;
	local float electro ; electro  =-1000;
	local float crylink ; crylink  =-1000;
	local float uzi     ; uzi      =-1000;
	local float shotgun ; shotgun  =-1000;
	local float laser   ; laser    =-1000;
	local float bestscore; bestscore = 0;
	local float bestweapon; bestweapon=self.switchweapon;
	local float distance; distance=bound(10,vlen(self.origin-self.enemy.origin)-200,10000);
	local float maxdelaytime=0.5;
	local float spreadpenalty=10;
	local float distancefromfloor;
	traceline(self.enemy.origin,self.enemy.origin-'0 0 1000',TRUE,world);
	distancefromfloor = self.enemy.origin_z - trace_endpos_z;
	// Formula:
	//	(Damage/Sec * Weapon spefic change to get that damage)
	//	*(Time to get to target * weapon specfic hitchange bonus) / (in a time of maxdelaytime)
	//	*(Spread change of hit) // if it applies
	//	*(Penality for target beeing in air)
	if (client_hasweapon(self, WEP_ROCKET_LAUNCHER, TRUE, FALSE))
		rocket = (cvar("g_balance_rocketlauncher_damage")/cvar("g_balance_rocketlauncher_refire")*0.75)
			* bound(0,(cvar("g_balance_rocketlauncher_speed")/distance*maxdelaytime),1)*1.5;
	if (client_hasweapon(self, WEP_NEX, TRUE, FALSE))
		nex = (cvar("g_balance_nex_damage")/cvar("g_balance_nex_refire")*1.0)
			* (0.5);
	if (client_hasweapon(self, WEP_HAGAR, TRUE, FALSE))
		hagar = (cvar("g_balance_hagar_primary_damage")/cvar("g_balance_hagar_primary_refire")*1.0)
			* bound(0,(cvar("g_balance_hagar_primary_speed")/distance*maxdelaytime),1)*0.2;
	if (client_hasweapon(self, WEP_GRENADE_LAUNCHER, TRUE, FALSE))
		grenade = (cvar("g_balance_grenadelauncher_primary_damage")/cvar("g_balance_grenadelauncher_primary_refire")*1.0)
			* bound(0,(cvar("g_balance_grenadelauncher_primary_speed")/distance*maxdelaytime),1)*1.1;
	if (client_hasweapon(self, WEP_ELECTRO, TRUE, FALSE))
		electro = (cvar("g_balance_electro_primary_damage")/cvar("g_balance_electro_primary_refire")*0.75)
			* bound(0,(cvar("g_balance_electro_primary_speed")/distance*maxdelaytime),1)*1.0;
	if (client_hasweapon(self, WEP_CRYLINK, TRUE, FALSE))
		crylink = (cvar("g_balance_crylink_primary_damage")/cvar("g_balance_crylink_primary_refire")*1.0)
			* bound(0,(cvar("g_balance_crylink_primary_speed")/distance*maxdelaytime),1)*1.0
			* bound(0,1/cvar("g_balance_crylink_primary_spread")/distance*spreadpenalty,1);
	if (client_hasweapon(self, WEP_UZI, TRUE, FALSE))
		uzi = (cvar("g_balance_uzi_sustained_damage")/cvar("g_balance_uzi_sustained_refire")*1.0)
			* bound(0,1/cvar("g_balance_uzi_sustained_spread")/distance*spreadpenalty,1)*0.5;
	if (client_hasweapon(self, WEP_SHOTGUN, TRUE, FALSE))
		shotgun = (cvar("g_balance_shotgun_primary_damage")*cvar("g_balance_shotgun_primary_bullets")/cvar("g_balance_shotgun_primary_refire")*1.0)
			* bound(0,1/cvar("g_balance_shotgun_primary_spread")/distance*spreadpenalty,1);
	if (client_hasweapon(self, WEP_LASER, FALSE, FALSE))
		laser = (cvar("g_balance_laser_primary_damage")/cvar("g_balance_laser_primary_refire")*1.0)
			* bound(0,cvar("g_balance_laser_primary_speed")/distance*0.2*maxdelaytime,1);
	if((self.enemy.flags & FL_ONGROUND)==FALSE){
		rocket = rocket   * (1-bound(0, distancefromfloor/cvar("g_balance_rocketlauncher_radius"         ),0.9)); //slight bigger change
		grenade = grenade * (1-bound(0,distancefromfloor/cvar("g_balance_grenadelauncher_primary_radius"),0.95));
		electro = electro * (1-bound(0,distancefromfloor/cvar("g_balance_electro_primary_radius"        ),0.95));
		laser = laser     * (1-bound(0,distancefromfloor/cvar("g_balance_laser_primary_radius"                  ),0.95));
	}
/*
	dprint("Floor distance: ",ftos(distancefromfloor),"\n");
	dprint("Rocket: " , ftos(rocket  ), "\n");
	dprint("Nex: "    , ftos(nex     ), "\n");
	dprint("Hagar: "  , ftos(hagar   ), "\n");
	dprint("Grenade: ", ftos(grenade ), "\n");
	dprint("Electro: ", ftos(electro ), "\n");
	dprint("Crylink: ", ftos(crylink ), "\n");
	dprint("Uzi: "    , ftos(uzi     ), "\n");
	dprint("Shotgun :", ftos(shotgun ), "\n");
	dprint("Laser   :", ftos(laser   ), "\n\n");
*/
	if (rocket  > bestscore){ bestscore = rocket  ; bestweapon = WEP_ROCKET_LAUNCHER  ;}
	if (nex     > bestscore){ bestscore = nex     ; bestweapon = WEP_NEX              ;}
	if (hagar   > bestscore){ bestscore = hagar   ; bestweapon = WEP_HAGAR            ;}
	if (grenade > bestscore){ bestscore = grenade ; bestweapon = WEP_GRENADE_LAUNCHER ;}
	if (electro > bestscore){ bestscore = electro ; bestweapon = WEP_ELECTRO          ;}
	if (crylink > bestscore){ bestscore = crylink ; bestweapon = WEP_CRYLINK          ;}
	if (uzi     > bestscore){ bestscore = uzi     ; bestweapon = WEP_UZI              ;}
	if (shotgun > bestscore){ bestscore = shotgun ; bestweapon = WEP_SHOTGUN          ;}
	if (laser   > bestscore){ bestscore = laser   ; bestweapon = WEP_LASER            ;}

	if(time>self.havocbot_chooseweapon_timer || self.havocbot_chooseweapon_lastbestscore<bestscore/10) //Or when the new damage is SOO much larger ! Or my gun runs out of ammo
	{
		self.havocbot_chooseweapon_timer=max(self.havocbot_chooseweapon_timer+cvar("g_balance_weaponswitchdelay")*120*(10-skill)*0.1,time);
		if( self.havocbot_chooseweapon_lastbestscore*1.5<bestscore*bound(1,1+(skill*skill)*0.01,2))
		{
			self.switchweapon = bestweapon; 
			self.havocbot_chooseweapon_lastbestscore=bestscore;
		}
	}
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
		local vector now,v,next;//,heading;
		local float distance,skillblend,distanceblend;
		now = self.goalcurrent.origin - self.origin;
		distance = vlen(now);
		//heading = self.velocity;
		//dprint(self.goalstack01.classname,etos(self.goalstack01),"\n");
		if(self.goalstack01 != self && self.goalstack01 != world)
			next = self.goalstack01.origin - self.origin;
		else
			next = now;
		skillblend=bound(0,(skill-2.5)*0.5,1); //lower skill player can't preturn
		distanceblend=bound(0,distance/cvar("bot_ai_keyboard_distance"),1); 
		v = (now * (distanceblend) + next * (1-distanceblend)) * (skillblend) + now * (1-skillblend);
		//v = now * (distanceblend) + next * (1-distanceblend);
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
	//Generate some random skill levels
	self.havocbot_keyboardskill=random()-0.5;
	havocbot_chooserole();
}
