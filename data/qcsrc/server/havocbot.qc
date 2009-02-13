
.void() havocbot_role;
void() havocbot_chooserole;
.float havocbot_keyboardskill;
.float facingwalltime, ignoregoaltime;
.entity ignoregoal;

vector havocbot_dodge()
{
	// LordHavoc: disabled because this is too expensive
	return '0 0 0';
	/*
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
	*/
};

.float havocbot_keyboardtime;
.float havocbot_ducktime;
.vector havocbot_keyboard;
void havocbot_keyboard_movement(vector destorg)
{
	local vector keyboard;
	local float blend, maxspeed;

	maxspeed = cvar("sv_maxspeed");	

	if (time < self.havocbot_keyboardtime)
		return;

	self.havocbot_keyboardtime =
		max(
			self.havocbot_keyboardtime
				+ bound(0,0.05/(skill+self.havocbot_keyboardskill),0.05)
				+random()*bound(0,0.025/(skill+self.havocbot_keyboardskill),100)
		, time);
	keyboard = self.movement * (1.0 / maxspeed);

	local float trigger, trigger1;
	blend = bound(0,skill*0.1,1);
	trigger = cvar("bot_ai_keyboard_treshold");
	trigger1 = 0 - trigger;

	// categorize forward movement
	// at skill < 1.5 only forward
	// at skill < 2.5 only individual directions
	// at skill < 4.5 only individual directions, and forward diagonals
	// at skill >= 4.5, all cases allowed
	if (keyboard_x > trigger)
	{
		keyboard_x = 1;
		if (skill < 2.5)
			keyboard_y = 0;
	}
	else if (keyboard_x < trigger1 && skill > 1.5)
	{
		keyboard_x = -1;
		if (skill < 4.5)
			keyboard_y = 0;
	}
	else
	{
		keyboard_x = 0;
		if (skill < 1.5)
			keyboard_y = 0;
	}
	if (skill < 4.5)
		keyboard_z = 0;

	if (keyboard_y > trigger)
		keyboard_y = 1;
	else if (keyboard_y < trigger1)
		keyboard_y = -1;
	else
		keyboard_y = 0;

	if (keyboard_z > trigger)
		keyboard_z = 1;
	else if (keyboard_z < trigger1)
		keyboard_z = -1;
	else
		keyboard_z = 0;

	self.havocbot_keyboard = keyboard * maxspeed;
	if (self.havocbot_ducktime>time) self.BUTTON_CROUCH=TRUE;

	keyboard = self.havocbot_keyboard;
	blend = bound(0,vlen(destorg-self.origin)/cvar("bot_ai_keyboard_distance"),1); // When getting close move with 360 degree
	//dprint("movement ", vtos(self.movement), " keyboard ", vtos(keyboard), " blend ", ftos(blend), "\n");
	self.movement = self.movement + (keyboard - self.movement) * blend;
};

//.float havocbotignoretime;
//.vector bot_dodgevector;
//.float bot_dodgevector_time;
//.float bot_dodgevector_jumpbutton;
void havocbot_movetogoal()
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
	local float maxspeed;
	//local float dist;
	local vector dodge;
	//if (self.goalentity)
	//	te_lightning2(self, self.origin, (self.goalentity.absmin + self.goalentity.absmax) * 0.5);
	self.movement = '0 0 0';
	maxspeed = cvar("sv_maxspeed");

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
		if(self.alternativegoal==world)
		{
			// ran out of goals, rethink strategy as soon as possible
			self.bot_strategytime = 0;
			return;
		}
		// try to use the alternative goal
		navigation_findnearestwaypoint(self.alternativegoal, TRUE);
		navigation_routetogoal(self.alternativegoal);
		self.alternativegoal = world;
		return;
	}

//	te_wizspike(self.goalcurrent.origin);
//	te_lightning2(world, self.origin, self.goalcurrent.origin);

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

	//if (self.bot_dodgevector_time < time)
	{
	//	self.bot_dodgevector_time = time + cvar("bot_ai_dodgeupdateinterval");
	//	self.bot_dodgevector_jumpbutton = 1;
		evadeobstacle = '0 0 0';
		evadelava = '0 0 0';
		if (self.waterlevel)
		{
			makevectors(self.v_angle);
			self.BUTTON_JUMP = TRUE;
			evadelava_z = 1;
		}
		else
		{
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
						self.BUTTON_JUMP = 1;
				}
			}

			// avoiding dangers and obstacles
			// TODO: don't make this check every frame
			if(self.flags & FL_ONGROUND)
			{
				local vector dst_ahead, dst_down;
				dst_ahead = self.origin + self.view_ofs + (self.velocity * 0.3);
				dst_down = dst_ahead + '0 0 -1500';				
				
				traceline(self.origin + self.view_ofs , dst_ahead, TRUE, world);

				// Check head-banging against walls
				if(vlen(self.origin + self.view_ofs - trace_endpos) < 2)
				{
					if(self.facingwalltime && time > self.facingwalltime)
					{
						self.ignoregoal = self.goalcurrent;
						self.ignoregoaltime = time + cvar("bot_ai_ignoregoal_timeout");
						navigation_poproute();
					}
					else
					{
						self.facingwalltime = time + 0.05;
					}
				}
				else
				{
					self.facingwalltime = 0;

					if(self.ignoregoal != world && time > self.ignoregoaltime)
					{
						self.ignoregoal = world;
						self.ignoregoaltime = 0;
					}
				}
			
				// Check for water/slime/lava and edges
				if(trace_fraction == 1){
					traceline(dst_ahead , dst_down, TRUE, world);
					//	te_lightning2(world, self.origin, dst_ahead);	// Draw "ahead" look 
					s = pointcontents(trace_endpos + '0 0 1');
					if (s != CONTENT_SOLID)
					if (s == CONTENT_LAVA || s == CONTENT_SLIME)
						evadelava = normalize(self.velocity) * -1;
					else if (s == CONTENT_SKY)
						evadeobstacle = normalize(self.velocity) * -1;
					else if (tracebox_hits_trigger_hurt(dst_ahead, self.mins, self.maxs, trace_endpos))
					{
						//	te_lightning2(world, dst_ahead, dst_down);	// Draw "downwards" look
						// if ain't a safe goal with "holes" (like the soylent jumpad)
						if(!boxesoverlap(dst_ahead - self.view_ofs + self.mins, dst_ahead - self.view_ofs + self.maxs, 
								self.goalcurrent.absmin, self.goalcurrent.absmax))
						{
							// Remove dangerous dynamic goals from stack
							if (self.goalcurrent.classname == "player" || self.goalcurrent.classname == "droppedweapon")
								navigation_poproute();
							// try to stop
							flatdir = '0 0 0';
							evadeobstacle = normalize(self.velocity) * -1;
						}
					}
				}
			}

			dir = flatdir;
			evadeobstacle_z = 0;
			evadelava_z = 0;
			makevectors(self.v_angle_y * '0 1 0');
		}

		dodge = havocbot_dodge();
		dodge = dodge * bound(0,3+skill*0.1,1);
		evadelava = evadelava * bound(1,3-skill,3); //Noobs fear lava a lot and take more distance from it
		traceline(self.origin, self.enemy.origin, TRUE, world);
		if(trace_ent.classname == "player")
			dir = dir * bound(0,skill/7,1);

		dir = normalize(dir + dodge + evadeobstacle + evadelava);
	//	self.bot_dodgevector = dir;
	//	self.bot_dodgevector_jumpbutton = self.BUTTON_JUMP;
	}

	//dir = self.bot_dodgevector;
	//if (self.bot_dodgevector_jumpbutton)
	//	self.BUTTON_JUMP = 1;

	self.movement_x = dir * v_forward * maxspeed;
	self.movement_y = dir * v_right * maxspeed;
	self.movement_z = dir * v_up * maxspeed;

	// Emulate keyboard interface
	if (skill < 10)
		havocbot_keyboard_movement(destorg);

	if ((dir * v_up) >= cvar("sv_jumpvelocity")*0.5 && (self.flags & FL_ONGROUND)) self.BUTTON_JUMP=1;
	if (((dodge * v_up) > 0) && random()*frametime >= 0.2*bound(0,(10-skill)*0.1,1)) self.BUTTON_JUMP=TRUE;
	if (((dodge * v_up) < 0) && random()*frametime >= 0.5*bound(0,(10-skill)*0.1,1)) self.havocbot_ducktime=time+0.3/bound(0.1,skill,10);
};

.float havocbot_chooseenemy_finished;
.float havocbot_stickenemy;
void havocbot_chooseenemy()
{
	local entity head, best;
	local float rating, bestrating;
	local vector eye, v;
	if (cvar("bot_nofire") || IS_INDEPENDENT_PLAYER(self))
	{
		self.enemy = world;
		return;
	}
	if (self.enemy)
	{
		if (!bot_shouldattack(self.enemy))
		{
			// enemy died or something, find a new target
			self.enemy = world;
			self.havocbot_chooseenemy_finished = time;
		}
		else if (self.havocbot_stickenemy)
		{
			// tracking last chosen enemy
			// if enemy is visible
			// and not really really far away
			// and we're not severely injured
			// then keep tracking for a half second into the future
			traceline(self.origin+self.view_ofs, self.enemy.origin+self.enemy.view_ofs*0.5,FALSE,world);
			if (trace_ent == self.enemy || trace_fraction == 1)
			if (vlen(self.enemy.origin - self.origin) < 1000)
			if (self.health > 30)
			{
				// remain tracking him for a shot while (case he went after a small corner or pilar
				self.havocbot_chooseenemy_finished = time + cvar("bot_ai_enemydetectioninterval");
				return;
			}
			// enemy isn't visible, or is far away, or we're injured severely
			// so stop preferring this enemy
			// (it will still take a half second until a new one is chosen)
			self.havocbot_stickenemy = 0;
		}
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
	self.havocbot_stickenemy = TRUE;
};

.float bot_chooseweapontime;
float(entity e) w_getbestweapon;
void havocbot_chooseweapon()
{
	// TODO: clean this up by moving it to weapon code
	if(self.enemy.classname!="player")
	{
		self.switchweapon = w_getbestweapon(self);
		return;
	}

	local float w, s;
	local float rocket  ; rocket   =-1000;
	local float nex     ; nex      =-1000;
	local float hagar   ; hagar    =-1000;
	local float grenade ; grenade  =-1000;
	local float electro ; electro  =-1000;
	local float crylink ; crylink  =-1000;
	local float uzi     ; uzi      =-1000;
	local float shotgun ; shotgun  =-1000;
	local float campingrifle ; campingrifle  =-1000;
	local float laser   ; laser    =-1000;
	local float minstanex ; minstanex =-1000;
	local float currentscore;
	local float bestscore; bestscore = 0;
	local float bestweapon; bestweapon=self.switchweapon;
	local float distance; distance=bound(10,vlen(self.origin-self.enemy.origin)-200,10000);
	local float maxdelaytime=0.5;
	local float spreadpenalty=10;
	local float distancefromfloor;

	local float af, ct, combo_time;

	traceline(self.enemy.origin,self.enemy.origin-'0 0 1000',TRUE,world);
	distancefromfloor = self.enemy.origin_z - trace_endpos_z;
	
	af = ATTACK_FINISHED(self);
	ct = cvar("bot_ai_weapon_combo_threshold");

	// Bots with no skill will be 4 times more slower than "godlike" bots when doing weapon combos
	// Ideally this 4 should be calculated as longest_weapon_refire / bot_ai_weapon_combo_threshold
	combo_time = time + ct + (ct * ((-0.3*skill)+3));

	// Custom weapon list based on distance to the enemy
	local float i; i = 0;
	if(bot_custom_weapon){

		// Choose weapons for far distance
		if ( distance > bot_distance_far ) {
			for(i=0; i < WEP_LAST && bot_weapons_far[i] != -1 ; ++i){
				w = bot_weapons_far[i];
				if ( client_hasweapon(self, w, TRUE, FALSE) ){
					if ( self.weapon == w){
						if( cvar("bot_ai_weapon_combo") && af > combo_time)
							continue;
					} else {
						self.switchweapon = w;
					}
					return;
				}
			}
		}

		// Choose weapons for mid distance
		if ( distance > bot_distance_close ) {
			for(i=0; i < WEP_LAST && bot_weapons_mid[i] != -1 ; ++i){
				w = bot_weapons_mid[i];
				if ( client_hasweapon(self, w, TRUE, FALSE) ){
					if ( self.weapon == w){
						if( cvar("bot_ai_weapon_combo") && af > combo_time)
							continue;
					} else {
						self.switchweapon = w;
					}
					return;
				}
			}
		}

		// Choose weapons for close distance
		for(i=0; i < WEP_LAST && bot_weapons_close[i] != -1 ; ++i){
			w = bot_weapons_close[i];
			if ( client_hasweapon(self, w, TRUE, FALSE) ){
				if ( self.weapon == w){
					if( cvar("bot_ai_weapon_combo") && af > combo_time)
						continue;
				} else {
					self.switchweapon = w;
				}
				return;
			}
		}
		// If now weapon was chosen by this system fall back to the previous one
	}

	// Formula:
	//	(Damage/Sec * Weapon spefic change to get that damage)
	//	*(Time to get to target * weapon specfic hitchange bonus) / (in a time of maxdelaytime)
	//	*(Spread change of hit) // if it applies
	//	*(Penality for target beeing in air)
	// %weaponaddpoint
	if (client_hasweapon(self, WEP_MINSTANEX, TRUE, FALSE))
		minstanex = (1000/cvar("g_balance_minstanex_refire")*1.0)
			* (0.5);

	if (client_hasweapon(self, WEP_ROCKET_LAUNCHER, TRUE, FALSE)  && 
		!(	cvar("bot_ai_weapon_combo") && self.weapon == WEP_ROCKET_LAUNCHER && 
			af > combo_time
		)
	)
		rocket = (cvar("g_balance_rocketlauncher_damage")/cvar("g_balance_rocketlauncher_refire")*0.75)
			* bound(0,(cvar("g_balance_rocketlauncher_speed")/distance*maxdelaytime),1)*1.5;
			
	if (client_hasweapon(self, WEP_NEX, TRUE, FALSE)  && 
		!( 	cvar("bot_ai_weapon_combo") && self.weapon == WEP_NEX && 
			af > combo_time
		)
	)
		nex = (cvar("g_balance_nex_damage")/cvar("g_balance_nex_refire")*1.0)
			* (0.5);
			
	if (client_hasweapon(self, WEP_HAGAR, TRUE, FALSE) ) // && 
	//	!( cvar("bot_ai_weapon_combo") && self.weapon == WEP_HAGAR &&  time < self.bot_lastshot + cvar("g_balance_hagar_primary_refire") ))
		hagar = (cvar("g_balance_hagar_primary_damage")/cvar("g_balance_hagar_primary_refire")*1.0)
			* bound(0,(cvar("g_balance_hagar_primary_speed")/distance*maxdelaytime),1)*0.2;
			
	if (client_hasweapon(self, WEP_GRENADE_LAUNCHER, TRUE, FALSE) && 
		!( 
			cvar("bot_ai_weapon_combo") && self.weapon == WEP_GRENADE_LAUNCHER && 
			af > combo_time
		)
	)
		grenade = (cvar("g_balance_grenadelauncher_primary_damage")/cvar("g_balance_grenadelauncher_primary_refire")*1.0)
			* bound(0,(cvar("g_balance_grenadelauncher_primary_speed")/distance*maxdelaytime),1)*1.1;
			
	if (client_hasweapon(self, WEP_ELECTRO, TRUE, FALSE) && 
		!( 	cvar("bot_ai_weapon_combo") && self.weapon == WEP_ELECTRO && 
			af > combo_time
		)
	)
		electro = (cvar("g_balance_electro_primary_damage")/cvar("g_balance_electro_primary_refire")*0.75)
			* bound(0,(cvar("g_balance_electro_primary_speed")/distance*maxdelaytime),1)*1.0;
			
	if (client_hasweapon(self, WEP_CRYLINK, TRUE, FALSE) ) // && 
	//	!( self.weapon == WEP_CRYLINK &&  time < self.bot_lastshot + cvar("g_balance_crylink_primary_refire") ))
		crylink = (cvar("g_balance_crylink_primary_damage")/cvar("g_balance_crylink_primary_refire")*1.0)
			* bound(0,(cvar("g_balance_crylink_primary_speed")/distance*maxdelaytime),1)*(64/(32+cvar("g_balance_crylink_primary_spread")*distance))*1.0;
			
	if (client_hasweapon(self, WEP_UZI, TRUE, FALSE) ) // && 
	//	!( self.weapon == WEP_UZI &&  time < self.bot_lastshot + cvar("g_balance_uzi_sustained_refire") ))
		uzi = (cvar("g_balance_uzi_sustained_damage")/cvar("g_balance_uzi_sustained_refire")*1.0)
			* bound(0,32/(32+cvar("g_balance_uzi_sustained_spread")*distance),1);
			
	if (client_hasweapon(self, WEP_SHOTGUN, TRUE, FALSE) && 
		!(	cvar("bot_ai_weapon_combo") && self.weapon == WEP_SHOTGUN && 
			af > combo_time
		)
	)
		shotgun = (cvar("g_balance_shotgun_primary_damage")*cvar("g_balance_shotgun_primary_bullets")/cvar("g_balance_shotgun_primary_refire")*1.0)
			* bound(0,32/(32+cvar("g_balance_shotgun_primary_spread")*distance),1);
			
	if (client_hasweapon(self, WEP_LASER, FALSE, FALSE) && 
		!(	cvar("bot_ai_weapon_combo") && self.weapon == WEP_LASER && 
			af > combo_time
		)
	)
		laser = (cvar("g_balance_laser_primary_damage")/cvar("g_balance_laser_primary_refire")*1.0)
			* bound(0,cvar("g_balance_laser_primary_speed")/distance*maxdelaytime,1);
			
	if((self.enemy.flags & FL_ONGROUND)==FALSE){
		rocket = rocket   * (1.5-bound(0, distancefromfloor/cvar("g_balance_rocketlauncher_radius"         ),0.9)); //slight bigger change
		grenade = grenade * (1.5-bound(0,distancefromfloor/cvar("g_balance_grenadelauncher_primary_radius"),0.95));
		electro = electro * (1.5-bound(0,distancefromfloor/cvar("g_balance_electro_primary_radius"        ),0.95));
		laser = laser     * (1.5-bound(0,distancefromfloor/cvar("g_balance_laser_primary_radius"                  ),0.95));
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
	currentscore = -1;
	w = WEP_MINSTANEX        ;s = minstanex;if (s > bestscore){bestscore = s;bestweapon = w;} if (self.switchweapon == w) currentscore = s;
	w = WEP_ROCKET_LAUNCHER  ;s = rocket   ;if (s > bestscore){bestscore = s;bestweapon = w;} if (self.switchweapon == w) currentscore = s;
	w = WEP_NEX              ;s = nex      ;if (s > bestscore){bestscore = s;bestweapon = w;} if (self.switchweapon == w) currentscore = s;
	w = WEP_HAGAR            ;s = hagar    ;if (s > bestscore){bestscore = s;bestweapon = w;} if (self.switchweapon == w) currentscore = s;
	w = WEP_GRENADE_LAUNCHER ;s = grenade  ;if (s > bestscore){bestscore = s;bestweapon = w;} if (self.switchweapon == w) currentscore = s;
	w = WEP_ELECTRO          ;s = electro  ;if (s > bestscore){bestscore = s;bestweapon = w;} if (self.switchweapon == w) currentscore = s;
	w = WEP_CRYLINK          ;s = crylink  ;if (s > bestscore){bestscore = s;bestweapon = w;} if (self.switchweapon == w) currentscore = s;
	w = WEP_UZI              ;s = uzi      ;if (s > bestscore){bestscore = s;bestweapon = w;} if (self.switchweapon == w) currentscore = s;
	w = WEP_SHOTGUN          ;s = shotgun  ;if (s > bestscore){bestscore = s;bestweapon = w;} if (self.switchweapon == w) currentscore = s;
	w = WEP_LASER            ;s = laser    ;if (s > bestscore){bestscore = s;bestweapon = w;} if (self.switchweapon == w) currentscore = s;

	// switch if the best weapon would provide a significant damage increase
	if (bestscore > currentscore*1.5){
		self.switchweapon = bestweapon;
		
		// buys time for detonating the rocket. not tested yet
		if ( cvar("bot_ai_weapon_combo") && bestweapon == WEP_ROCKET_LAUNCHER )
			self.bot_chooseweapontime += (distance  / cvar("g_balance_rocketlauncher_speed"));
	}
};

.float nextaim;
void havocbot_aim()
{
	local vector selfvel, enemyvel;
	if(self.flags & FL_INWATER)
		return;
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

void havocbot_ai()
{
	if (bot_strategytoken == self)
	if (!bot_strategytoken_taken)
	{
		self.havocbot_role();
		// token has been used this frame
		bot_strategytoken_taken = TRUE;
	}
	if(self.deadflag)
		return;

	havocbot_chooseenemy();
	if (self.bot_chooseweapontime < time )
	{
		self.bot_chooseweapontime = time + cvar("bot_ai_chooseweaponinterval");
		havocbot_chooseweapon();
	}
	havocbot_aim();
	lag_update();
	if (self.bot_aimtarg)
	{
		weapon_action(self.weapon, WR_AIM);
		if (cvar("bot_nofire") || IS_INDEPENDENT_PLAYER(self))
		{
			self.BUTTON_ATCK = FALSE;
			self.BUTTON_ATCK2 = FALSE;
		}
	}
	else if (self.goalcurrent)
	{
		local vector now,v,next;//,heading;
		local float distance,skillblend,distanceblend,blend;
		next = now = self.goalcurrent.origin - (self.origin + self.view_ofs);
		distance = vlen(now);
		//heading = self.velocity;
		//dprint(self.goalstack01.classname,etos(self.goalstack01),"\n");
		if(self.goalstack01 != self && self.goalstack01 != world)
			next = self.goalstack01.origin - (self.origin + self.view_ofs);
		skillblend=bound(0,(skill-2.5)*0.5,1); //lower skill player can't preturn
		distanceblend=bound(0,distance/cvar("bot_ai_keyboard_distance"),1);
		blend = skillblend * (1-distanceblend);
		//v = (now * (distanceblend) + next * (1-distanceblend)) * (skillblend) + now * (1-skillblend);
		//v = now * (distanceblend) * (skillblend) + next * (1-distanceblend) * (skillblend) + now * (1-skillblend);
		//v = now * ((1-skillblend) + (distanceblend) * (skillblend)) + next * (1-distanceblend) * (skillblend);
		v = now + blend * (next - now);
		//dprint(etos(self), " ");
		//dprint(vtos(now), ":", vtos(next), "=", vtos(v), " (blend ", ftos(blend), ")\n");
		//v = now * (distanceblend) + next * (1-distanceblend);
		if (self.waterlevel < 2)
			v_z = 0;
		//dprint("walk at:", vtos(v), "\n");
		//te_lightning2(world, self.origin, self.goalcurrent.origin);
		bot_aimdir(v, -1);
	}
	havocbot_movetogoal();
};

void havocbot_setupbot()
{
	self.bot_ai = havocbot_ai;
	// will be updated by think code
	//Generate some random skill levels
	self.havocbot_keyboardskill=random()-0.5;
	havocbot_chooserole();
}
