$frame die1 die2 draw duck duckwalk duckjump duckidle idle
$frame jump pain1 pain2 shoot taunt run runbackwards
$frame strafeleft straferight dead1 dead2 forwardright
$frame forwardleft backright backleft

// changes by LordHavoc on 03/29/04 and 03/30/04 at Vermeulen's request
// merged player_run and player_stand to player_anim
// added death animations to player_anim
// can now spawn thrown weapons from anywhere, not just from players
// thrown weapons now fade out after 20 seconds
// created PlayerGib function
// PlayerDie no longer uses hitloc or damage
// PlayerDie now supports dying animations as well as gibbing
// cleaned up PlayerDie a lot
// added CopyBody

.entity pusher;
.float pushltime;

void CopyBody(float keepvelocity)
{
	local entity oldself;
	if (self.effects & EF_NODRAW)
		return;
	oldself = self;
	self = spawn();
	self.colormap = oldself.colormap;
	self.iscreature = oldself.iscreature;
	self.angles = oldself.angles;
	self.avelocity = oldself.avelocity;
	self.classname = "body";
	self.damageforcescale = oldself.damageforcescale;
	self.effects = oldself.effects;
	self.event_damage = oldself.event_damage;
	self.frame = oldself.frame;
	self.health = oldself.health;
	self.armorvalue = oldself.armorvalue;
	self.armortype = oldself.armortype;
	self.model = oldself.model;
	self.modelindex = oldself.modelindex;
	self.movetype = oldself.movetype;
	self.nextthink = oldself.nextthink;
	self.skin = oldself.skin;
	self.solid = oldself.solid;
	self.takedamage = oldself.takedamage;
	self.think = oldself.think;
	self.gibrandom = oldself.gibrandom;
	self.customizeentityforclient = oldself.customizeentityforclient;
	if (keepvelocity == 1)
		self.velocity = oldself.velocity;
	self.oldvelocity = self.velocity;
	self.fade_time = oldself.fade_time;
	self.fade_rate = oldself.fade_rate;
	//self.weapon = oldself.weapon;
	setorigin(self, oldself.origin);
	setsize(self, oldself.mins, oldself.maxs);
	self.oldorigin = oldself.origin;
	self = oldself;
}

void player_anim (void)
{
	if (self.deadflag != DEAD_NO)
	{
		if (time > self.dead_time)
		{
			if (self.maxs_z > 5)
			{
				self.maxs_z = 5;
				setsize(self, self.mins, self.maxs);
			}
			self.frame = self.dead_frame;
		}
		else
			self.frame = self.die_frame;
		return;
	}


	if (self.crouch)
	{
		if (self.movement_x * self.movement_x + self.movement_y * self.movement_y > 20)
			self.frame = $duckwalk;
		else
			self.frame = $duckidle;
	}
	else if ((self.movement_x * self.movement_x + self.movement_y * self.movement_y) > 20)
	{
		if (self.movement_x > 0 && self.movement_y == 0)
			self.frame = $run;
		else if (self.movement_x < 0 && self.movement_y == 0)
			self.frame = $runbackwards;
		else if (self.movement_x == 0 && self.movement_y > 0)
			self.frame = $straferight;
		else if (self.movement_x == 0 && self.movement_y < 0)
			self.frame = $strafeleft;
		else if (self.movement_x > 0 && self.movement_y > 0)
			self.frame = $forwardright;
		else if (self.movement_x > 0 && self.movement_y < 0)
			self.frame = $forwardleft;
		else if (self.movement_x < 0 && self.movement_y > 0)
			self.frame = $backright;
		else if (self.movement_x < 0 && self.movement_y < 0)
			self.frame = $backleft;
		else
			self.frame = $run;
	}
	else if (self.pain_finished > time)
		self.frame = self.pain_frame;
	else if (self.attack_finished > time)
		self.frame = $shoot;
	else
		self.frame = $idle;

	if (!(self.flags & FL_ONGROUND))
	{
		if (self.crouch)
			self.frame = $duckidle;		// if player is crouching while in air, show crouch frame
		else
			self.frame = $jump;
	}
}
//End change by Supajoe on 11:44 PM EST 11/16/03 (Subject: Player animations)

void SpawnThrownWeapon (vector org, float w)
{
	if (!cvar("g_pickup_items"))
	if (!cvar("g_minstagib"))
		return;
	if (!w)
		return;
	if (w == IT_LASER)
		return;

	W_ThrowWeapon(randomvec() * 100 + '0 0 200', org - self.origin, FALSE);
}

void PlayerCorpseDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local float take, save;
	te_blood (hitloc, force, damage);
	// damage resistance (ignore most of the damage from a bullet or similar)
	damage = max(damage - 5, 1);

	save = bound(0, damage * cvar("g_balance_armor_blockpercent"), self.armorvalue);
	take = bound(0, damage - save, damage);

	if (save > 10)
		sound (self, CHAN_IMPACT, "misc/armorimpact.wav", 1, ATTN_NORM);
	else if (take > 30)
		sound (self, CHAN_IMPACT, "misc/bodyimpact2.wav", 1, ATTN_NORM);
	else if (take > 10)
		sound (self, CHAN_IMPACT, "misc/bodyimpact1.wav", 1, ATTN_NORM);

	if (take > 50)
		TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.1,1);
	if (take > 100)
		TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.2,1);

	if (!(self.flags & FL_GODMODE))
	{
		self.armorvalue = self.armorvalue - save;
		self.health = self.health - take;
		// pause regeneration for 5 seconds
		self.pauseregen_finished = max(self.pauseregen_finished, time + cvar("g_balance_pause_health_regen"));
	}
	self.dmg_save = self.dmg_save + save;//max(save - 10, 0);
	self.dmg_take = self.dmg_take + take;//max(take - 10, 0);
	self.dmg_inflictor = inflictor;

	if (self.health <= -50)
	{
		// don't use any animations as a gib
		self.frame = 0;
		self.dead_frame = 0;
		self.die_frame = 0;
		// view just above the floor
		self.view_ofs = '0 0 4';

		// make a juicy mess
		local float multiplier;
		multiplier = 1;
		if (cvar("ekg"))
			multiplier = 5;
		te_bloodshower (self.origin + self.mins, self.origin + self.maxs, 1200 * multiplier, 1000);

		// make a meaty mess
		TossGib (self, "models/gibs/eye.md3", self.origin, self.velocity,0);
		TossGib (world, "models/gibs/bloodyskull.md3", self.origin, '0 0 600',0);

		local float c;
		c = 0;
		while (c < multiplier)
		{
			c = c + 1;
			TossGib (world, "models/gibs/gib1.md3", self.origin, self.velocity,0);
			//TossGib (world, "models/gibs/gib2.md3", self.origin, self.velocity,0);
			TossGib (world, "models/gibs/gib1.mdl", self.origin, self.velocity,0);
			//TossGib (world, "models/gibs/gib3.md3", self.origin, self.velocity,0);
			TossGib (world, "models/gibs/gib2.mdl", self.origin, self.velocity,0);
			//TossGib (world, "models/gibs/gib4.md3", self.origin, self.velocity,0);
			TossGib (world, "models/gibs/gib3.mdl", self.origin, self.velocity,0);

			// these destory on impact
			TossGib (world, "models/gibs/gib5.md3", self.origin, '-500 0 450',1);
			//TossGib (world, "models/gibs/gib6.md3", self.origin, '0 500 450',1);
			TossGib (world, "models/gibs/chunk.mdl", self.origin, '0 -500 450',1);
			TossGib (world, "models/gibs/chunk.mdl", self.origin, '500 0 450',1);
			TossGib (world, "models/gibs/chunk.mdl", self.origin, self.velocity,1);
			TossGib (world, "models/gibs/chunk.mdl", self.origin, '0 0 450',1);
		}

		sound (self, CHAN_VOICE, "misc/gib.wav", 1, ATTN_NORM);
	}
}

void PlayerDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local float take, save, waves, sdelay;

	te_blood (hitloc, force, damage);
	if (self.pain_finished < time)		//Don't switch pain sequences like crazy
	{
		if (random() > 0.5)
			self.pain_frame = $pain1;
		else
			self.pain_frame = $pain2;
		self.pain_finished = time + 0.5;	//Supajoe

		// throw off bot aim temporarily
		local float shake;
		shake = damage * 5 / (bound(0,skill,100) + 1);
		self.v_angle_x = self.v_angle_x + (random() * 2 - 1) * shake;
		self.v_angle_y = self.v_angle_y + (random() * 2 - 1) * shake;
	}

	if(cvar("g_arena"))
	if(numspawned < 2)
		return;

	if (!cvar("g_minstagib"))
	{
		save = bound(0, damage * cvar("g_balance_armor_blockpercent"), self.armorvalue);
		take = bound(0, damage - save, damage);
	}
	else
	{
		save = 0;
		take = damage;
	}

	if (save > 10)
		sound (self, CHAN_IMPACT, "misc/armorimpact.wav", 1, ATTN_NORM);
	else if (take > 30)
		sound (self, CHAN_IMPACT, "misc/bodyimpact2.wav", 1, ATTN_NORM);
	else if (take > 10)
		sound (self, CHAN_IMPACT, "misc/bodyimpact1.wav", 1, ATTN_NORM);

	if (take > 50)
		TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.1,1);
	if (take > 100)
		TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.2,1);

	if (time > self.spawnshieldtime)
	{
		if (!(self.flags & FL_GODMODE))
		{
			self.armorvalue = self.armorvalue - save;
			self.health = self.health - take;
			// pause regeneration for 5 seconds
			self.pauseregen_finished = max(self.pauseregen_finished, time + cvar("g_balance_pause_health_regen"));
		}
		else
			self.max_armorvalue += (save + take);
	}
	self.dmg_save = self.dmg_save + save;//max(save - 10, 0);
	self.dmg_take = self.dmg_take + take;//max(take - 10, 0);
	self.dmg_inflictor = inflictor;

	if(attacker == self)
	{
		// don't reset pushltime for self damage as it may be an attempt to
		// escape a lava pit or similar
		//self.pushltime = 0;
	}
	else if(attacker.classname == "player" || attacker.classname == "gib")
	{
		self.pusher = attacker;
		self.pushltime = time + cvar("g_maxpushtime");
	}
	else if(time < self.pushltime)
	{
		attacker = self.pusher;
		self.pushltime = max(self.pushltime, time + 0.6);
	}
	else
		self.pushltime = 0;

	if (self.health < 1)
	{
		self.deaths += 1;

		// become fully visible
		self.alpha = 1;
		// clear selected player display
		ClearSelectedPlayer();
		// throw a weapon
		SpawnThrownWeapon (self.origin + (self.mins + self.maxs) * 0.5, self.switchweapon);
		// print an obituary message
		Obituary (attacker, self, deathtype);
		DropAllRunes(self);
		if(self == attacker)
			kh_Key_DropAll(self, TRUE);
		else if(attacker.classname == "player" || attacker.classname == "gib")
			kh_Key_DropAll(self, FALSE);
		else
			kh_Key_DropAll(self, TRUE);
		if(self.flagcarried)
			DropFlag(self.flagcarried);
		// clear waypoints
		WaypointSprite_PlayerDead();
		// make the corpse upright (not tilted)
		self.angles_x = 0;
		self.angles_z = 0;
		// don't spin
		self.avelocity = '0 0 0';
		// view from the floor
		self.view_ofs = '0 0 -8';
		// toss the corpse
		self.movetype = MOVETYPE_TOSS;
		// shootable corpse
		self.solid = SOLID_CORPSE;
		// don't stick to the floor
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		// dying animation
		self.deadflag = DEAD_DYING;
		// when to allow respawn
		sdelay = 0;
		waves = 0;
		if(cvar("g_respawn_mapsettings"))
		{
			sdelay = cvar("g_respawn_mapsettings_delay");
			waves = cvar("g_respawn_mapsettings_waves");
		}
		if(!sdelay)
			sdelay = cvar(strcat("g_", GetGametype(), "_respawn_delay"));
		if(!sdelay)
			sdelay = cvar("g_respawn_delay");
		if(!waves)
			waves = cvar(strcat("g_", GetGametype(), "_respawn_waves"));
		if(!waves)
			waves = cvar("g_respawn_waves");
		if(waves)
			self.death_time = ceil((time + sdelay) / waves) * waves;
		else
			self.death_time = time + sdelay;
		if((sdelay + waves >= 5.0) && (self.death_time - time > 1.75))
			self.respawn_countdown = 10; // first number to count down from is 10
		else
			self.respawn_countdown = -1; // do not count down
		// when to switch to the dead_frame
		self.dead_time = time + 2;
		if (random() < 0.5)
		{
			self.die_frame = $die1;
			self.dead_frame = $dead1;
		}
		else
		{
			self.die_frame = $die2;
			self.dead_frame = $dead2;
		}
		// start the animation
		player_anim();
		// set damage function to corpse damage
		self.event_damage = PlayerCorpseDamage;
		// call the corpse damage function just in case it wants to gib
		self.event_damage(inflictor, attacker, 0, deathtype, hitloc, force);
		// set up to fade out later
		SUB_SetFade (self, time + 12 + random () * 4, 1);

		// remove laserdot
		if(self.weaponentity)
			if(self.weaponentity.lasertarget)
				remove(self.weaponentity.lasertarget);

		if(clienttype(self) == CLIENTTYPE_REAL)
		{
			self.fixangle = TRUE;
			//msg_entity = self;
			//WriteByte (MSG_ONE, SVC_SETANGLE);
			//WriteAngle (MSG_ONE, self.v_angle_x);
			//WriteAngle (MSG_ONE, self.v_angle_y);
			//WriteAngle (MSG_ONE, 80);
		}

		if(cvar("g_arena"))
			Spawnqueue_Unmark(self);
	}
}

float UpdateSelectedPlayer_countvalue(float v)
{
	return max(0, (v - 1.0) / 0.5);
}

// returns: -2 if no hit, otherwise cos of the angle
// uses the global v_angle
float UpdateSelectedPlayer_canSee(entity p, float mincosangle, float maxdist)
{
	vector so, d;
	float c;

	if(p == self)
		return -2;

	if(p.deadflag)
		return -2;

	so = self.origin + self.view_ofs;
	d = p.origin - so;

	// misaimed?
	if(dist_point_line(d, '0 0 0', v_forward) > maxdist)
		return -2;

	// now find the cos of the angle...
	c = normalize(d) * v_forward;

	if(c <= mincosangle)
		return -2;

	traceline(so, p.origin, MOVE_NOMONSTERS, self);
	if(trace_fraction < 1)
		return -2;

	return c;
}

void ClearSelectedPlayer()
{
	if(self.selected_player)
	{
		centerprint_expire(self, CENTERPRIO_POINT);
		self.selected_player = world;
		self.selected_player_display_needs_update = FALSE;
	}
}

void UpdateSelectedPlayer()
{
	entity selected;
	float selected_score;
	selected = world;
	selected_score = 0.95; // 18 degrees

	if(!cvar("sv_allow_shownames"))
		return;

	if(clienttype(self) != CLIENTTYPE_REAL)
		return;

	if(self.cvar_cl_shownames == 0)
		return;

	if(self.cvar_cl_shownames == 1 && !teams_matter)
		return;

	makevectors(self.v_angle); // sets v_forward

	// 1. cursor trace is always right
	if(self.cursor_trace_ent && self.cursor_trace_ent.classname == "player" && !self.cursor_trace_ent.deadflag)
	{
		selected = self.cursor_trace_ent;
	}
	else
	{
		// 2. if we don't have a cursor trace, find the player which is least
		//    mis-aimed at
		entity p;
		FOR_EACH_PLAYER(p)
		{
			float c;
			c = UpdateSelectedPlayer_canSee(p, selected_score, 100); // 100 = 2.5 meters
			if(c >= -1)
			{
				selected = p;
				selected_score = c;
			}
		}
	}

	if(selected)
	{
		self.selected_player_display_timeout = time + self.cvar_scr_centertime;
	}
	else
	{
		if(time < self.selected_player_display_timeout)
			if(UpdateSelectedPlayer_canSee(self.selected_player, 0.7, 200) >= -1) // 5 meters, 45 degrees
				selected = self.selected_player;
	}

	if(selected)
	{
		if(selected == self.selected_player)
		{
			float save;
			save = UpdateSelectedPlayer_countvalue(self.selected_player_count);
			self.selected_player_count = self.selected_player_count + frametime;
			if(save != UpdateSelectedPlayer_countvalue(self.selected_player_count))
			{
				string namestr, healthstr;
				namestr = playername(selected);
				if(teams_matter)
				{
					healthstr = ftos(floor(selected.health));
					if(self.team == selected.team)
					{
						namestr = strcat(namestr, " (", healthstr, "%)");
						self.selected_player_display_needs_update = TRUE;
					}
				}
				centerprint_atprio(self, CENTERPRIO_POINT, namestr);
			}
		}
		else
		{
			ClearSelectedPlayer();
			self.selected_player = selected;
			self.selected_player_time = time;
			self.selected_player_count = 0;
			self.selected_player_display_needs_update = FALSE;
		}
	}
	else
	{
		ClearSelectedPlayer();
	}

	if(self.selected_player)
		self.last_selected_player = self.selected_player;
}
