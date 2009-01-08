
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
	self.enemy = oldself;
	self.lip = oldself.lip;
	self.colormap = oldself.colormap;
	self.iscreature = oldself.iscreature;
	self.angles = oldself.angles;
	self.avelocity = oldself.avelocity;
	self.classname = "body";
	self.damageforcescale = oldself.damageforcescale;
	self.effects = oldself.effects;
	self.event_damage = oldself.event_damage;
	self.animstate_startframe = oldself.animstate_startframe;
	self.animstate_numframes = oldself.animstate_numframes;
	self.animstate_framerate = oldself.animstate_framerate;
	self.animstate_starttime = oldself.animstate_starttime;
	self.animstate_endtime = oldself.animstate_endtime;
	self.animstate_override = oldself.animstate_override;
	self.animstate_looping = oldself.animstate_looping;
	self.frame = oldself.frame;
	self.dead_frame = oldself.dead_frame;
	self.pain_finished = oldself.pain_finished;
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

float animparseerror;
vector animparseline(float animfile)
{
	local string line;
	local float c;
	local vector anim;
	if (animfile < 0)
		return '0 1 2';
	line = fgets(animfile);
	c = tokenize_sane(line);
	if (c != 3)
	{
		animparseerror = TRUE;
		return '0 1 2';
	}
	anim_x = stof(argv(0));
	anim_y = stof(argv(1));
	anim_z = stof(argv(2));
	// don't allow completely bogus values
	if (anim_x < 0 || anim_y < 1 || anim_z < 0.001)
		anim = '0 1 2';
	return anim;
};

void player_setupanimsformodel()
{
	local string animfilename;
	local float animfile;
	// defaults for legacy .zym models without animinfo files
	self.anim_die1 = '0 1 0.5'; // 2 seconds
	self.anim_die2 = '1 1 0.5'; // 2 seconds
	self.anim_draw = '2 1 3'; // TODO: analyze models and set framerate
	self.anim_duck = '3 1 100'; // this anim seems bogus in most models, so make it play VERY briefly!
	self.anim_duckwalk = '4 1 1';
	self.anim_duckjump = '5 1 100'; // zym anims keep playing until changed, so this only has to start the anim, landing will end it
	self.anim_duckidle = '6 1 1';
	self.anim_idle = '7 1 1';
	self.anim_jump = '8 1 100'; // zym anims keep playing until changed, so this only has to start the anim, landing will end it
	self.anim_pain1 = '9 1 2'; // 0.5 seconds
	self.anim_pain2 = '10 1 2'; // 0.5 seconds
	self.anim_shoot = '11 1 5'; // TODO: analyze models and set framerate
	self.anim_taunt = '12 1 1'; // FIXME?  there is no code using this anim
	self.anim_run = '13 1 1';
	self.anim_runbackwards = '14 1 1';
	self.anim_strafeleft = '15 1 1';
	self.anim_straferight = '16 1 1';
	self.anim_dead1 = '17 1 1';
	self.anim_dead2 = '18 1 1';
	self.anim_forwardright = '19 1 1';
	self.anim_forwardleft = '20 1 1';
	self.anim_backright = '21 1 1';
	self.anim_backleft  = '22 1 1';
	animparseerror = FALSE;
	animfilename = strcat(self.model, ".animinfo");
	animfile = fopen(animfilename, FILE_READ);
	if (animfile >= 0)
	{
		self.anim_die1         = animparseline(animfile);
		self.anim_die2         = animparseline(animfile);
		self.anim_draw         = animparseline(animfile);
		self.anim_duck         = animparseline(animfile);
		self.anim_duckwalk     = animparseline(animfile);
		self.anim_duckjump     = animparseline(animfile);
		self.anim_duckidle     = animparseline(animfile);
		self.anim_idle         = animparseline(animfile);
		self.anim_jump         = animparseline(animfile);
		self.anim_pain1        = animparseline(animfile);
		self.anim_pain2        = animparseline(animfile);
		self.anim_shoot        = animparseline(animfile);
		self.anim_taunt        = animparseline(animfile);
		self.anim_run          = animparseline(animfile);
		self.anim_runbackwards = animparseline(animfile);
		self.anim_strafeleft   = animparseline(animfile);
		self.anim_straferight  = animparseline(animfile);
		self.anim_forwardright = animparseline(animfile);
		self.anim_forwardleft  = animparseline(animfile);
		self.anim_backright    = animparseline(animfile);
		self.anim_backleft     = animparseline(animfile);
		fclose(animfile);

		// derived anims
		self.anim_dead1 = '0 1 1' + '1 0 0' * (self.anim_die1_x + self.anim_die1_y - 1);
		self.anim_dead2 = '0 1 1' + '1 0 0' * (self.anim_die2_x + self.anim_die2_y - 1);

		if (animparseerror)
			print("Parse error in ", animfilename, ", some player animations are broken\n");
	}
	else
		dprint("File ", animfilename, " not found, assuming legacy .zym model animation timings\n");
	// reset animstate now
	player_setanim(self.anim_idle, TRUE, FALSE, TRUE);
};

void player_setanim(vector anim, float looping, float override, float restart)
{
	if (!restart)
	if (anim_x == self.animstate_startframe)
	if (anim_y == self.animstate_numframes)
	if (anim_z == self.animstate_framerate)
		return;
	self.animstate_startframe = anim_x;
	self.animstate_numframes = anim_y;
	self.animstate_framerate = anim_z;
	self.animstate_starttime = time;
	self.animstate_endtime = time + self.animstate_numframes / self.animstate_framerate;
	self.animstate_looping = looping;
	self.animstate_override = override;
	self.frame = self.animstate_startframe;
};

void player_updateframe()
{
	if (time >= self.animstate_endtime)
	{
		if (self.animstate_looping)
		{
			self.animstate_starttime = self.animstate_endtime;
			self.animstate_endtime = self.animstate_endtime + self.animstate_numframes / self.animstate_framerate;
		}
		self.animstate_override = FALSE;
	}
	self.frame = self.animstate_startframe + bound(0, (time - self.animstate_starttime) * self.animstate_framerate, self.animstate_numframes - 1);
};

void player_anim (void)
{
	player_updateframe();

	if (self.deadflag != DEAD_NO)
	{
		if (time > self.animstate_endtime)
		{
			if (self.maxs_z > 5)
			{
				self.maxs_z = 5;
				setsize(self, self.mins, self.maxs);
			}
			self.frame = self.dead_frame;
		}
		return;
	}

	if (!self.animstate_override)
	{
		if (!(self.flags & FL_ONGROUND))
		{
			if (self.crouch)
				player_setanim(self.anim_duckjump, FALSE, TRUE, FALSE);
			else
				player_setanim(self.anim_jump, FALSE, TRUE, FALSE);
		}
		else if (self.crouch)
		{
			if (self.movement_x * self.movement_x + self.movement_y * self.movement_y > 20)
				player_setanim(self.anim_duckwalk, TRUE, FALSE, FALSE);
			else
				player_setanim(self.anim_duckidle, TRUE, FALSE, FALSE);
		}
		else if ((self.movement_x * self.movement_x + self.movement_y * self.movement_y) > 20)
		{
			if (self.movement_x > 0 && self.movement_y == 0)
				player_setanim(self.anim_run, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y == 0)
				player_setanim(self.anim_runbackwards, TRUE, FALSE, FALSE);
			else if (self.movement_x == 0 && self.movement_y > 0)
				player_setanim(self.anim_straferight, TRUE, FALSE, FALSE);
			else if (self.movement_x == 0 && self.movement_y < 0)
				player_setanim(self.anim_strafeleft, TRUE, FALSE, FALSE);
			else if (self.movement_x > 0 && self.movement_y > 0)
				player_setanim(self.anim_forwardright, TRUE, FALSE, FALSE);
			else if (self.movement_x > 0 && self.movement_y < 0)
				player_setanim(self.anim_forwardleft, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y > 0)
				player_setanim(self.anim_backright, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y < 0)
				player_setanim(self.anim_backleft, TRUE, FALSE, FALSE);
			else
				player_setanim(self.anim_run, TRUE, FALSE, FALSE);
		}
		else
			player_setanim(self.anim_idle, TRUE, FALSE, FALSE);
	}
}
//End change by Supajoe on 11:44 PM EST 11/16/03 (Subject: Player animations)

void SpawnThrownWeapon (vector org, float w)
{
	W_ThrowWeapon(randomvec() * 100 + '0 0 200', org - self.origin, FALSE);
}

void PlayerCorpseDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local float take, save;
	if(sv_gentle < 1)	
		pointparticles(particleeffectnum("blood"), hitloc, force, bound(0, damage, 200));
	// damage resistance (ignore most of the damage from a bullet or similar)
	damage = max(damage - 5, 1);

	save = bound(0, damage * cvar("g_balance_armor_blockpercent"), self.armorvalue);
	take = bound(0, damage - save, damage);

	if (save > 10)
		sound (self, CHAN_PROJECTILE, "misc/armorimpact.wav", VOL_BASE, ATTN_NORM);
	else if (take > 30)
		sound (self, CHAN_PROJECTILE, "misc/bodyimpact2.wav", VOL_BASE, ATTN_NORM);
	else if (take > 10)
		sound (self, CHAN_PROJECTILE, "misc/bodyimpact1.wav", VOL_BASE, ATTN_NORM);

	if(independent_players)
	if(sv_gentle < 1) {	
		if (take > 50)
			TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.1,1);
		if (take > 100)
			TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.2,1);
	}

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

	if (self.health <= -75)
	{
		// don't use any animations as a gib
		self.frame = 0;
		self.dead_frame = 0;
		// view just above the floor
		self.view_ofs = '0 0 4';

		// make a juicy mess
		local float multiplier;
		multiplier = 1;
		if (cvar("ekg"))
			multiplier = 5;


		// make a meaty mess
		if(independent_players)
		{
			TossGib (self, "models/gibs/eye.md3", self.origin + self.view_ofs, self.velocity + randomvec() * 150,0);
			self.solid = SOLID_TRIGGER; // undo SOLID_CORPSE
			self.takedamage = DAMAGE_NO; // can't damage this gib, to prevent better jumps from it
		}
		else
			TossGib (self, "models/gibs/eye.md3", self.origin + self.view_ofs, self.velocity + randomvec() * 150,0);
		
		if not(independent_players)
		if(sv_gentle < 1) {
			te_bloodshower (self.origin + self.mins, self.origin + self.maxs, 1200 * multiplier, 1000);
			TossGib (world, "models/gibs/bloodyskull.md3", self.origin + self.view_ofs, self.velocity,0);

			local float c;
			c = 0;

			while (c < multiplier)
			{
				c = c + 1;
				//TossGib (world, "models/gibs/gib1.md3", self.origin, self.velocity + randomvec() * 450,0);
				//TossGib (world, "models/gibs/gib2.md3", self.origin, self.velocity + randomvec() * 450,0);
				//TossGib (world, "models/gibs/gib3.md3", self.origin, self.velocity + randomvec() * 450,0);
				//TossGib (world, "models/gibs/gib4.md3", self.origin, self.velocity + randomvec() * 450,0);
				//TossGib (world, "models/gibs/gib5.md3", self.origin, self.velocity + randomvec() * 450,0);
				//TossGib (world, "models/gibs/gib6.md3", self.origin, self.velocity + randomvec() * 450,0);

				TossGib (world, "models/gibs/arm.md3", self.origin + self.view_ofs, self.velocity + randomvec() * (random() * 120 + 90),0);
				TossGib (world, "models/gibs/arm.md3", self.origin + self.view_ofs, self.velocity + randomvec() * (random() * 120 + 90),0);
				//TossGib (world, "models/gibs/arm.md3", self.origin + self.view_ofs, self.velocity + randomvec() * 150,0);
				//TossGib (world, "models/gibs/arm.md3", self.origin + self.view_ofs, self.velocity + randomvec() * 150,0);
				TossGib (world, "models/gibs/chest.md3", self.origin + self.view_ofs * 0.5, self.velocity + randomvec() * (random() * 120 + 80),0);
				//TossGib (world, "models/gibs/smallchest.md3", self.origin + self.view_ofs, self.velocity + randomvec() * 150,0);
				TossGib (world, "models/gibs/smallchest.md3", self.origin + self.view_ofs, self.velocity + randomvec() * (random() * 120 + 80),0);
				TossGib (world, "models/gibs/leg1.md3", self.origin + self.view_ofs * -0.2, self.velocity + randomvec() * (random() * 120 + 85),0);
				TossGib (world, "models/gibs/leg2.md3", self.origin + self.view_ofs * -0.4, self.velocity + randomvec() * (random() * 120 + 85),0);
				//TossGib (world, "models/gibs/leg1.md3", self.origin + self.view_ofs * -0.2, self.velocity + randomvec() * 150,0);
				//TossGib (world, "models/gibs/leg2.md3", self.origin + self.view_ofs * -0.4, self.velocity + randomvec() * 150,0);

				// these splat on impact
				TossGib (world, "models/gibs/chunk.mdl", self.origin, self.velocity + randomvec() * 450,1);
				TossGib (world, "models/gibs/chunk.mdl", self.origin, self.velocity + randomvec() * 450,1);
				TossGib (world, "models/gibs/chunk.mdl", self.origin, self.velocity + randomvec() * 450,1);
				TossGib (world, "models/gibs/chunk.mdl", self.origin, self.velocity + randomvec() * 450,1);
			}
			sound (self, CHAN_PLAYER, "misc/gib.wav", VOL_BASE, ATTN_NORM);
		}
	}
}

void ClientKill_Now_TeamChange();

void PlayerDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local float take, save, waves, sdelay;

	if(!DEATH_ISSPECIAL(deathtype))
	{
		damage *= sqrt(bound(1.0, self.cvar_cl_handicap, 100.0));
		if(self != attacker)
			damage /= sqrt(bound(1.0, attacker.cvar_cl_handicap, 100.0));
	}

	if(sv_gentle > 0) {
		pointparticles(particleeffectnum("damage_hit"), hitloc, force, bound(0, damage, 200));
	} else {
		pointparticles(particleeffectnum("blood"), hitloc, force, bound(0, damage, 200));
	}

	if(g_arena)
	if(numspawned < 2)
		return;

	if (!g_minstagib)
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
		sound (self, CHAN_PROJECTILE, "misc/armorimpact.wav", VOL_BASE, ATTN_NORM);
	else if (take > 30)
		sound (self, CHAN_PROJECTILE, "misc/bodyimpact2.wav", VOL_BASE, ATTN_NORM);
	else if (take > 10)
		sound (self, CHAN_PROJECTILE, "misc/bodyimpact1.wav", VOL_BASE, ATTN_NORM); // FIXME possibly remove them?

	if(sv_gentle < 1)
	if not(independent_players)
	{
		if (take > 50)
			TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.1,1);
		if (take > 100)
			TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.2,1);
	}

	if (time > self.spawnshieldtime)
	{
		if (!(self.flags & FL_GODMODE))
		{
			self.armorvalue = self.armorvalue - save;
			self.health = self.health - take;
			// pause regeneration for 5 seconds
			self.pauseregen_finished = max(self.pauseregen_finished, time + cvar("g_balance_pause_health_regen"));

			if (time > self.pain_finished)		//Don't switch pain sequences like crazy
			{
				self.pain_finished = time + 0.5;	//Supajoe

				if(sv_gentle < 1) {		
					if (random() > 0.5)
						player_setanim(self.anim_pain1, FALSE, TRUE, TRUE);
					else
						player_setanim(self.anim_pain2, FALSE, TRUE, TRUE);

					if(!DEATH_ISWEAPON(deathtype, WEP_LASER) || attacker != self || self.health < 2 * cvar("g_balance_laser_primary_damage") * cvar("g_balance_selfdamagepercent") + 1)
					// exclude pain sounds for laserjumps as long as you aren't REALLY low on health and would die of the next two
					{
						if(self.health > 75) // TODO make a "gentle" version?
							PlayerSound(playersound_pain100, CHAN_PAIN, 0);
						else if(self.health > 50)
							PlayerSound(playersound_pain75, CHAN_PAIN, 0);
						else if(self.health > 25)
							PlayerSound(playersound_pain50, CHAN_PAIN, 0);
						else if(self.health > 1)
							PlayerSound(playersound_pain25, CHAN_PAIN, 0);
					}
				}

				// throw off bot aim temporarily
				local float shake;
				shake = damage * 5 / (bound(0,skill,100) + 1);
				self.v_angle_x = self.v_angle_x + (random() * 2 - 1) * shake;
				self.v_angle_y = self.v_angle_y + (random() * 2 - 1) * shake;
			}
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
		float defer_ClientKill_Now_TeamChange;
		defer_ClientKill_Now_TeamChange = FALSE;

		if(sv_gentle < 1) // TODO make a "gentle" version?
		{
			if(deathtype == DEATH_DROWN)
				PlayerSound(playersound_drown, CHAN_PAIN, 0);
			else
				PlayerSound(playersound_death, CHAN_PAIN, 0);
		}

		// get rid of kill indicator
		if(self.killindicator)
		{
			remove(self.killindicator);
			self.killindicator = world;
			if(self.killindicator_teamchange)
				defer_ClientKill_Now_TeamChange = TRUE;

			if(self.classname == "body")
			if(deathtype == DEATH_KILL)
			{
				// for the lemmings fans, a small harmless explosion
				pointparticles(particleeffectnum("rocket_explode"), self.origin, '0 0 0', 1);
			}
		}

		// become fully visible
		self.alpha = 1;
		// clear selected player display
		ClearSelectedPlayer();
		// throw a weapon
		SpawnThrownWeapon (self.origin + (self.mins + self.maxs) * 0.5, self.switchweapon);
		// print an obituary message
		Obituary (attacker, inflictor, self, deathtype);
		race_PreDie();
		DropAllRunes(self);
		if(self == attacker)
			kh_Key_DropAll(self, TRUE);
		else if(attacker.classname == "player" || attacker.classname == "gib")
			kh_Key_DropAll(self, FALSE);
		else
			kh_Key_DropAll(self, TRUE);
		if(self.flagcarried)
		{
			if(attacker.classname != "player" && attacker.classname != "gib")
				DropFlag(self.flagcarried, self, attacker); // penalty for flag loss by suicide
			else if(attacker.team == self.team)
				DropFlag(self.flagcarried, attacker, attacker); // penalty for flag loss by suicide/teamkill
			else
				DropFlag(self.flagcarried, world, attacker);
		}
		Portal_ClearAllLater(self);
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
		if (random() < 0.5)
		{
			player_setanim(self.anim_die1, FALSE, TRUE, TRUE);
			self.dead_frame = self.anim_dead1_x;
		}
		else
		{
			player_setanim(self.anim_die2, FALSE, TRUE, TRUE);
			self.dead_frame = self.anim_dead2_x;
		}
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

		if(g_arena)
			Spawnqueue_Unmark(self);

		if(defer_ClientKill_Now_TeamChange)
			ClientKill_Now_TeamChange();

		if(sv_gentle > 0) {
			// remove corpse
			PlayerCorpseDamage (inflictor, attacker, 100.0, deathtype, hitloc, force);
			pointparticles(particleeffectnum("damage_dissolve"), self.origin, force, 1);
		}
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

float GetVoiceMessageTeamsayType(string type)
{
	if(type == "taunt")
		return 5;
	if(type == "teamshoot")
		return 2;
	return 1;
}

string allvoicesamples;
float GetPlayerSoundSampleField_notFound;
float GetPlayerSoundSampleField_fixed;
.string GetVoiceMessageSampleField(string type)
{
	GetPlayerSoundSampleField_notFound = 0;
	GetPlayerSoundSampleField_fixed = 0;
	switch(type)
	{
#define _VOICEMSG(m) case #m: return playersound_##m;
		ALLVOICEMSGS
#undef _VOICEMSG
	}
	GetPlayerSoundSampleField_notFound = 1;
	return playersound_taunt;
}

.string GetPlayerSoundSampleField(string type)
{
	GetPlayerSoundSampleField_notFound = 0;
	GetPlayerSoundSampleField_fixed = 0;
	switch(type)
	{
#define _VOICEMSG(m) case #m: return playersound_##m;
		ALLPLAYERSOUNDS
#undef _VOICEMSG
	}
	GetPlayerSoundSampleField_notFound = 1;
	return playersound_taunt;
}

void PrecacheGlobalSound(string samplestring)
{
	float n, i;
	tokenize_sane(samplestring);
	n = stof(argv(1));
	if(n > 0)
	{
		for(i = 1; i <= n; ++i)
			precache_sound(strcat(argv(0), ftos(i), ".wav"));
	}
	else
	{
		precache_sound(strcat(argv(0), ".wav"));
	}
}

void PrecachePlayerSounds(string f)
{
	float fh;
	string s;
	fh = fopen(f, FILE_READ);
	if(fh < 0)
		return;
	while((s = fgets(fh)))
	{
		if(tokenize_sane(s) != 3)
		{
			dprint("Invalid sound info line: ", s, "\n");
			continue;
		}
		PrecacheGlobalSound(strcat(argv(1), " ", argv(2)));
	}
	fclose(fh);

	if not(allvoicesamples)
	{
#define _VOICEMSG(m) allvoicesamples = strcat(allvoicesamples, " ", #m);
		ALLVOICEMSGS
#undef _VOICEMSG
		allvoicesamples = strzone(substring(allvoicesamples, 1, strlen(allvoicesamples) - 1));
	}
}

void ClearPlayerSounds()
{
#define _VOICEMSG(m) if(self.playersound_##m) { strunzone(self.playersound_##m); self.playersound_##m = string_null; }
	ALLPLAYERSOUNDS
	ALLVOICEMSGS
#undef _VOICEMSG
}

void LoadPlayerSounds(string f, float first)
{
	float fh;
	string s;
	var .string field;
	fh = fopen(f, FILE_READ);
	if(fh < 0)
		return;
	while((s = fgets(fh)))
	{
		if(tokenize_sane(s) != 3)
			continue;
		field = GetPlayerSoundSampleField(argv(0));
		if(GetPlayerSoundSampleField_notFound)
			field = GetVoiceMessageSampleField(argv(0));
		if(GetPlayerSoundSampleField_notFound)
			continue;
		if(GetPlayerSoundSampleField_fixed)
			if not(first)
				continue;
		if(self.field)
			strunzone(self.field);
		self.field = strzone(strcat(argv(1), " ", argv(2)));
	}
	fclose(fh);
}

.float modelindex_for_playersound;
void UpdatePlayerSounds()
{
	if(self.modelindex == self.modelindex_for_playersound)
		return;
	self.modelindex_for_playersound = self.modelindex;
	ClearPlayerSounds();
	LoadPlayerSounds("sound/player/default.sounds", 1);
	LoadPlayerSounds(strcat(self.model, ".sounds"), 0);
}

void GlobalSound(string sample, float chan, float teamsay)
{
	float n;

	if(sample == "")
		return;

	tokenize_sane(sample);
	n = stof(argv(1));
	if(n > 0)
		sample = strcat(argv(0), ftos(floor(random() * n + 1)), ".wav"); // randomization
	else
		sample = strcat(argv(0), ".wav"); // randomization
	
	if(teamsay == 3) // only to last attacker
	{
		if(self.pusher)
			if(self.pusher.team == self.team)
			{
				msg_entity = self.pusher;
				if(clienttype(msg_entity) == CLIENTTYPE_REAL)
					soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NONE);
			}
	}
	else if(teamsay == 2) // only to last attacker and self
	{
		if(self.pusher)
			if(self.pusher.team == self.team)
			{
				msg_entity = self.pusher;
				if(clienttype(msg_entity) == CLIENTTYPE_REAL)
					soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NONE);
				msg_entity = self;
				if(clienttype(msg_entity) == CLIENTTYPE_REAL)
					soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NONE);
			}
	}
	else if(teamsay == 0) // to everyone
	{
		// broadcast the sound, but it's directional
		sound(self, chan, sample, VOL_BASE, ATTN_NORM);
	}
	else if(teamsay == 1) // to the same team
	{
		if(teams_matter)
		{
			entity e;
			FOR_EACH_REALCLIENT(e)
				if(!teams_matter || e.team == self.team)
				{
					msg_entity = e;
					soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NONE);
				}
		}
		else
		{
			sound(self, chan, sample, VOL_BASE, ATTN_NONE);
		}
	}
	else if(teamsay == 4) // auto taunt
	{
		float tauntrand;
		tauntrand = random();
		FOR_EACH_REALCLIENT(e)
		if (tauntrand < e.cvar_cl_autotaunt)
		{
			msg_entity = e;
			if (e.cvar_cl_taunt_directional)
				soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_MIN);
			else
				soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NONE);
		}
	}
	else if(teamsay == 5) // manual taunt
	{
		FOR_EACH_REALCLIENT(e)
		{
			msg_entity = e;
			if (e.cvar_cl_taunt_directional)
				soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_MIN);
			else
				soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NONE);
		}
	}
}

void PlayerSound(.string samplefield, float chan, float teamsay)
{
	string sample;
	sample = self.samplefield;
	GlobalSound(sample, chan, teamsay);
}

void VoiceMessage(string type)
{
	var .string sample;
	var float teamsay;
	sample = GetVoiceMessageSampleField(type);

	if(GetPlayerSoundSampleField_notFound)
	{
		sprint(self, strcat("Invalid voice. Use one of: ", allvoicesamples, "\n"));
		return;
	}

	teamsay = GetVoiceMessageTeamsayType(type);

	PlayerSound(sample, CHAN_VOICE, teamsay);
}
