float weaponstats_buffer;

void WeaponStats_Init()
{
	if(cvar_string("sv_weaponstats_killfile") != "" || cvar_string("sv_weaponstats_damagefile") != "")
		weaponstats_buffer = buf_create();
	else
		weaponstats_buffer = -1;
}

#define WEAPONSTATS_GETINDEX(awep,vwep) ((vwep) + (awep) * (WEP_LAST - WEP_FIRST + 1) - (WEP_FIRST + WEP_FIRST * (WEP_LAST - WEP_FIRST + 1)))

void WeaponStats_Shutdown()
{
	float i, j, idx, f;
	float fh;
	string prefix;
	if(weaponstats_buffer < 0)
		return;
	prefix = strcat(cvar_string("hostname"), "\t", GetGametype(), "_", GetMapname(), "\t");
	if(cvar_string("sv_weaponstats_killfile") != "")
	{
		fh = fopen(cvar_string("sv_weaponstats_killfile"), FILE_APPEND);
		if(fh >= 0)
		{
			fputs(fh, "#begin killfile\n");
			fputs(fh, strcat("#date ", strftime(TRUE, "%a %b %e %H:%M:%S %Z %Y"), "\n"));
			fputs(fh, strcat("#config ", ftos(crc16(FALSE, cvar_changes)), "\n"));
			for(i = WEP_FIRST; i <= WEP_LAST; ++i)
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					idx = WEAPONSTATS_GETINDEX(i, j);
					f = stov(bufstr_get(weaponstats_buffer, idx)) * '0 1 0';
					if(f != 0)
						fputs(fh, strcat(prefix, ftos(i), "\t", ftos(j), "\t", ftos(f), "\n"));
				}
			fputs(fh, "#end\n\n");
			fclose(fh);
			print("Weapon kill stats written\n");
		}
	}
	if(cvar_string("sv_weaponstats_damagefile") != "")
	{
		fh = fopen(cvar_string("sv_weaponstats_damagefile"), FILE_APPEND);
		if(fh >= 0)
		{
			fputs(fh, "#begin damagefile\n");
			fputs(fh, strcat("#date ", strftime(TRUE, "%a %b %e %H:%M:%S %Z %Y"), "\n"));
			fputs(fh, strcat("#config ", ftos(crc16(FALSE, cvar_changes)), "\n"));
			for(i = WEP_FIRST; i <= WEP_LAST; ++i)
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					idx = WEAPONSTATS_GETINDEX(i, j);
					f = stov(bufstr_get(weaponstats_buffer, idx)) * '1 0 0';
					if(f != 0)
						fputs(fh, strcat(prefix, ftos(i), "\t", ftos(j), "\t", ftos(f), "\n"));
				}
			fputs(fh, "#end\n\n");
			fclose(fh);
			print("Weapon damage stats written\n");
		}
	}
	buf_del(weaponstats_buffer);
	weaponstats_buffer = -1;
}

void WeaponStats_LogItem(float awep, float vwep, vector item)
{
	float idx;
	if(weaponstats_buffer < 0)
		return;
	if(awep < WEP_FIRST || vwep < WEP_FIRST)
		return;
	if(awep > WEP_LAST || vwep > WEP_LAST)
		return;
	idx = WEAPONSTATS_GETINDEX(awep,vwep);
	bufstr_set(weaponstats_buffer, idx, vtos(stov(bufstr_get(weaponstats_buffer, idx)) + item));
}
void WeaponStats_LogDamage(float awep, float vwep, float damage)
{
	if(damage < 0)
		error("negative damage?");
	WeaponStats_LogItem(awep, vwep, '1 0 0' * damage);
}
void WeaponStats_LogKill(float awep, float vwep)
{
	WeaponStats_LogItem(awep, vwep, '0 1 0');
}

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
	self.modelindex_lod0 = oldself.modelindex_lod0;
	self.modelindex_lod0_from_nexuiz = oldself.modelindex_lod0_from_nexuiz;
	self.modelindex_lod1 = oldself.modelindex_lod1;
	self.modelindex_lod2 = oldself.modelindex_lod2;
	self.skinindex = oldself.skinindex;
	self.species = oldself.species;
	self.movetype = oldself.movetype;
	self.nextthink = oldself.nextthink;
	self.solid = oldself.solid;
	self.takedamage = oldself.takedamage;
	self.think = oldself.think;
	self.customizeentityforclient = oldself.customizeentityforclient;
	self.uncustomizeentityforclient = oldself.uncustomizeentityforclient;
	self.uncustomizeentityforclient_set = oldself.uncustomizeentityforclient_set;
	if (keepvelocity == 1)
		self.velocity = oldself.velocity;
	self.oldvelocity = self.velocity;
	self.fade_time = oldself.fade_time;
	self.fade_rate = oldself.fade_rate;
	//self.weapon = oldself.weapon;
	setorigin(self, oldself.origin);
	setsize(self, oldself.mins, oldself.maxs);
	self.prevorigin = oldself.origin;
	self.reset = SUB_Remove;

	Drag_MoveDrag(oldself, self);

	self = oldself;
}

float player_getspecies()
{
	local float glob, i, j, fh, len, s, sk;
	local string fn, l;

	s = -1;

	glob = search_begin("models/player/*.txt", TRUE, TRUE);
	if(glob < 0)
		return s;
	for(j = 0; j <= 1; ++j)
	{
		for(i = 0; i < search_getsize(glob); ++i)
		{
			fn = search_getfilename(glob, i);
			fh = fopen(fn, FILE_READ);
			if(fh < 0)
				continue;
			fgets(fh); fgets(fh);
			sk = stof(fgets(fh));
			if(sk == (j ? 0 : self.skinindex)) // 2nd pass skips the skin test
			if(fgets(fh) == self.model)
			{
				l = fgets(fh);
				len = tokenize_console(l);
				if (len != 2)
					goto nospecies;
				if (argv(0) != "species")
					goto nospecies;
				switch(argv(1))
				{
					case "human":       s = SPECIES_HUMAN;       break;
					case "alien":       s = SPECIES_ALIEN;       break;
					case "robot_shiny": s = SPECIES_ROBOT_SHINY; break;
					case "robot_rusty": s = SPECIES_ROBOT_RUSTY; break;
					case "robot_solid": s = SPECIES_ROBOT_SOLID; break;
					case "animal":      s = SPECIES_ANIMAL;      break;
					case "reserved":    s = SPECIES_RESERVED;    break;
				}
			}
:nospecies
			fclose(fh);
		}
		if (s >= 0)
			break;
	}
	search_end(glob);

	if (s < 0)
		s = SPECIES_HUMAN;

	return s;
}

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
	self.anim_taunt = '12 1 0.33'; // FIXME?  there is no code using this anim
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
	setanim(self, self.anim_idle, TRUE, FALSE, TRUE);
};

void player_anim (void)
{
	updateanim(self);
	if (self.weaponentity)
		updateanim(self.weaponentity);

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
				setanim(self, self.anim_duckjump, FALSE, TRUE, self.restart_jump);
			else
				setanim(self, self.anim_jump, FALSE, TRUE, self.restart_jump);
			self.restart_jump = FALSE;
		}
		else if (self.crouch)
		{
			if (self.movement_x * self.movement_x + self.movement_y * self.movement_y > 20)
				setanim(self, self.anim_duckwalk, TRUE, FALSE, FALSE);
			else
				setanim(self, self.anim_duckidle, TRUE, FALSE, FALSE);
		}
		else if ((self.movement_x * self.movement_x + self.movement_y * self.movement_y) > 20)
		{
			if (self.movement_x > 0 && self.movement_y == 0)
				setanim(self, self.anim_run, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y == 0)
				setanim(self, self.anim_runbackwards, TRUE, FALSE, FALSE);
			else if (self.movement_x == 0 && self.movement_y > 0)
				setanim(self, self.anim_straferight, TRUE, FALSE, FALSE);
			else if (self.movement_x == 0 && self.movement_y < 0)
				setanim(self, self.anim_strafeleft, TRUE, FALSE, FALSE);
			else if (self.movement_x > 0 && self.movement_y > 0)
				setanim(self, self.anim_forwardright, TRUE, FALSE, FALSE);
			else if (self.movement_x > 0 && self.movement_y < 0)
				setanim(self, self.anim_forwardleft, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y > 0)
				setanim(self, self.anim_backright, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y < 0)
				setanim(self, self.anim_backleft, TRUE, FALSE, FALSE);
			else
				setanim(self, self.anim_run, TRUE, FALSE, FALSE);
		}
		else
			setanim(self, self.anim_idle, TRUE, FALSE, FALSE);
	}

	if (self.weaponentity)
	if (!self.weaponentity.animstate_override)
		setanim(self.weaponentity, self.weaponentity.anim_idle, TRUE, FALSE, FALSE);
}

void SpawnThrownWeapon (vector org, float w)
{
	if(g_minstagib)
	if(self.ammo_cells <= 0)
		return;

	if(g_pinata)
	{
		float j;
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			if(self.weapons & W_WeaponBit(j))
				if(W_IsWeaponThrowable(j))
					W_ThrowNewWeapon(self, j, FALSE, self.origin, randomvec() * 175 + '0 0 325');
		}
	}
	else
		W_ThrowWeapon(randomvec() * 125 + '0 0 200', org - self.origin, FALSE);
}

void PlayerCorpseDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local float take, save;
	vector v;
	Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 16, self, attacker);

	// damage resistance (ignore most of the damage from a bullet or similar)
	damage = max(damage - 5, 1);

	v = healtharmor_applydamage(self.armorvalue, cvar("g_balance_armor_blockpercent"), damage);
	take = v_x;
	save = v_y;

	if(sound_allowed(MSG_BROADCAST, attacker))
	{
		if (save > 10)
			sound (self, CHAN_PROJECTILE, "misc/armorimpact.wav", VOL_BASE, ATTN_NORM);
		else if (take > 30)
			sound (self, CHAN_PROJECTILE, "misc/bodyimpact2.wav", VOL_BASE, ATTN_NORM);
		else if (take > 10)
			sound (self, CHAN_PROJECTILE, "misc/bodyimpact1.wav", VOL_BASE, ATTN_NORM);
	}

	if (take > 50)
		Violence_GibSplash_At(hitloc, force * -0.1, 3, 1, self, attacker);
	if (take > 100)
		Violence_GibSplash_At(hitloc, force * -0.2, 3, 1, self, attacker);

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

	if (self.health <= -75 && self.modelindex != 0)
	{
		// don't use any animations as a gib
		self.frame = 0;
		self.dead_frame = 0;
		// view just above the floor
		self.view_ofs = '0 0 4';

		Violence_GibSplash(self, 1, 1, attacker);
		self.modelindex = 0; // restore later
		self.solid = SOLID_NOT; // restore later
	}
}

void ClientKill_Now_TeamChange();

void PlayerDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local float take, save, waves, sdelay, dh, da, j;
	vector v;
	float valid_damage_for_weaponstats;

	dh = max(self.health, 0);
	da = max(self.armorvalue, 0);

	if(!DEATH_ISSPECIAL(deathtype))
	{
		damage *= sqrt(bound(1.0, self.cvar_cl_handicap, 100.0));
		if(self != attacker)
			damage /= sqrt(bound(1.0, attacker.cvar_cl_handicap, 100.0));
	}

	if(DEATH_ISWEAPON(deathtype, WEP_TUBA))
	{
		// tuba causes blood to come out of the ears
		vector ear1, ear2;
		vector d;
		float f;
		ear1 = self.origin;
		ear1_z += 0.125 * self.view_ofs_z + 0.875 * self.maxs_z; // 7/8
		ear2 = ear1;
		makevectors(self.angles);
		ear1 += v_right * -10;
		ear2 += v_right * +10;
		d = inflictor.origin - self.origin;
		f = (d * v_right) / vlen(d); // this is cos of angle of d and v_right!
		force = v_right * vlen(force);
		Violence_GibSplash_At(ear1, force * -1, 2, bound(0, damage, 25) / 2 * (0.5 - 0.5 * f), self, attacker);
		Violence_GibSplash_At(ear2, force,      2, bound(0, damage, 25) / 2 * (0.5 + 0.5 * f), self, attacker);
		if(f > 0)
		{
			hitloc = ear1;
			force = force * -1;
		}
		else
		{
			hitloc = ear2;
			// force is already good
		}
	}
	else
		Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 16, self, attacker);

	if((g_arena && numspawned < 2) || (g_ca && player_cnt < 2) && !inWarmupStage)
		return;

	if (!g_minstagib)
	{
		v = healtharmor_applydamage(self.armorvalue, cvar("g_balance_armor_blockpercent"), damage);
		take = v_x;
		save = v_y;
	}
	else
	{
		save = 0;
		take = damage;
	}

	if(sound_allowed(MSG_BROADCAST, attacker))
	{
		if (save > 10)
			sound (self, CHAN_PROJECTILE, "misc/armorimpact.wav", VOL_BASE, ATTN_NORM);
		else if (take > 30)
			sound (self, CHAN_PROJECTILE, "misc/bodyimpact2.wav", VOL_BASE, ATTN_NORM);
		else if (take > 10)
			sound (self, CHAN_PROJECTILE, "misc/bodyimpact1.wav", VOL_BASE, ATTN_NORM); // FIXME possibly remove them?
	}

	if (take > 50)
		Violence_GibSplash_At(hitloc, force * -0.1, 3, 1, self, attacker);
	if (take > 100)
		Violence_GibSplash_At(hitloc, force * -0.2, 3, 1, self, attacker);

	if (time >= self.spawnshieldtime)
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
					if(self.classname != "body") // pain anim is BORKED on our ZYMs, FIXME remove this once we have good models
					{
						if (random() > 0.5)
							setanim(self, self.anim_pain1, FALSE, TRUE, TRUE);
						else
							setanim(self, self.anim_pain2, FALSE, TRUE, TRUE);
					}

					if(sound_allowed(MSG_BROADCAST, attacker))
					if(!DEATH_ISWEAPON(deathtype, WEP_LASER) || attacker != self || self.health < 2 * cvar("g_balance_laser_primary_damage") * cvar("g_balance_selfdamagepercent") + 1)
					// exclude pain sounds for laserjumps as long as you aren't REALLY low on health and would die of the next two
					{
						if(self.health > 75) // TODO make a "gentle" version?
							PlayerSound(playersound_pain100, CHAN_PAIN, VOICETYPE_PLAYERSOUND);
						else if(self.health > 50)
							PlayerSound(playersound_pain75, CHAN_PAIN, VOICETYPE_PLAYERSOUND);
						else if(self.health > 25)
							PlayerSound(playersound_pain50, CHAN_PAIN, VOICETYPE_PLAYERSOUND);
						else if(self.health > 1)
							PlayerSound(playersound_pain25, CHAN_PAIN, VOICETYPE_PLAYERSOUND);
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

	valid_damage_for_weaponstats = 0;
	if(clienttype(self) == CLIENTTYPE_REAL)
	if(clienttype(attacker) == CLIENTTYPE_REAL)
	if(self != attacker)
	if(!DEATH_ISSPECIAL(deathtype))
	if(IsDifferentTeam(self, attacker))
		valid_damage_for_weaponstats = 1;
	
	if(valid_damage_for_weaponstats)
	{
		dh = dh - max(self.health, 0);
		da = da - max(self.armorvalue, 0);
		WeaponStats_LogDamage(DEATH_WEAPONOF(deathtype), self.weapon, dh + da);
	}

	if (self.health < 1)
	{
		float defer_ClientKill_Now_TeamChange;
		defer_ClientKill_Now_TeamChange = FALSE;

		if(valid_damage_for_weaponstats)
			WeaponStats_LogKill(DEATH_WEAPONOF(deathtype), self.weapon);

		if(sv_gentle < 1) // TODO make a "gentle" version?
		if(sound_allowed(MSG_BROADCAST, attacker))
		{
			if(deathtype == DEATH_DROWN)
				PlayerSound(playersound_drown, CHAN_PAIN, VOICETYPE_PLAYERSOUND);
			else
				PlayerSound(playersound_death, CHAN_PAIN, VOICETYPE_PLAYERSOUND);
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
		if(self.ballcarried)
			DropBall(self.ballcarried, self.origin, self.velocity);
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
		self.flags &~= FL_ONGROUND;
		// dying animation
		self.deadflag = DEAD_DYING;
		// when to allow respawn
		sdelay = 0;
		waves = 0;
		sdelay = cvar(strcat("g_", GetGametype(), "_respawn_delay"));
		if(!sdelay)
			sdelay = cvar("g_respawn_delay");
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
			setanim(self, self.anim_die1, FALSE, TRUE, TRUE);
			self.dead_frame = self.anim_dead1_x;
		}
		else
		{
			setanim(self, self.anim_die2, FALSE, TRUE, TRUE);
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

		if(sv_gentle > 0 || cvar("ekg")) {
			// remove corpse
			PlayerCorpseDamage (inflictor, attacker, 100.0, deathtype, hitloc, force);
		}

		// reset fields the weapons may use just in case
        for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
            weapon_action(j, WR_RESETPLAYER);
			ATTACK_FINISHED_FOR(self, j) = 0;
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

	// not visible in any way? forget it
	if(!checkpvs(so, p))
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
	WarpZone_crosshair_trace(self);
	if(trace_ent && trace_ent.classname == "player" && !trace_ent.deadflag)
	{
		selected = trace_ent;
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

.float muted; // to be used by prvm_edictset server playernumber muted 1
void Say(entity source, float teamsay, entity privatesay, string msgin, float floodcontrol)
{
	string msgstr, colorstr, cmsgstr, namestr, fullmsgstr, sourcemsgstr, fullcmsgstr, sourcecmsgstr, privatemsgprefix;
	float flood, privatemsgprefixlen;
	entity head;

	if(Ban_MaybeEnforceBan(source))
		return;

	if(!teamsay && !privatesay)
		if(substring(msgin, 0, 1) == " ")
			msgin = substring(msgin, 1, strlen(msgin) - 1); // work around DP say bug (say_team does not have this!)

	msgin = formatmessage(msgin);

	if(msgin == "")
		return;

	if(source.classname != "player")
		colorstr = "^0"; // black for spectators
	else if(teams_matter)
		colorstr = Team_ColorCode(source.team);
	else
		teamsay = FALSE;

	if(intermission_running)
		teamsay = FALSE;

	msgin = trigger_magicear_processmessage_forallears(source, teamsay, privatesay, msgin);
	if(msgin == "")
		return;

	/*
	 * using bprint solves this... me stupid
	// how can we prevent the message from appearing in a listen server?
	// for now, just give "say" back and only handle say_team
	if(!teamsay)
	{
		clientcommand(self, strcat("say ", msgin));
		return;
	}
	*/

	if(cvar("g_chat_teamcolors"))
		namestr = playername(source);
	else
		namestr = source.netname;

	if(privatesay)
	{
		msgstr = strcat("\{1}\{13}* ^3", namestr, "^3 tells you: ^7");
		privatemsgprefixlen = strlen(msgstr);
		msgstr = strcat(msgstr, msgin);
		cmsgstr = strcat(colorstr, "^3", namestr, "^3 tells you:\n^7", msgin);
		if(cvar("g_chat_teamcolors"))
			privatemsgprefix = strcat("\{1}\{13}* ^3You tell ", playername(privatesay), ": ^7");
		else
			privatemsgprefix = strcat("\{1}\{13}* ^3You tell ", privatesay.netname, ": ^7");
	}
	else if(teamsay)
	{
		msgstr = strcat("\{1}\{13}", colorstr, "(^3", namestr, colorstr, ") ^7", msgin);
		cmsgstr = strcat(colorstr, "(^3", namestr, colorstr, ")\n^7", msgin);
	}
	else
	{
		msgstr = strcat("\{1}", namestr, "^7: ", msgin);
		cmsgstr = "";
	}

	msgstr = strcat(strreplace("\n", " ", msgstr), "\n"); // newlines only are good for centerprint
	fullmsgstr = msgstr;
	fullcmsgstr = cmsgstr;

	// FLOOD CONTROL
	flood = 0;
	if(floodcontrol)
	{
		float flood_spl;
		float flood_burst;
		float flood_lmax;
		var .float flood_field;
		float lines;
		if(privatesay)
		{
			flood_spl = cvar("g_chat_flood_spl_tell");
			flood_burst = cvar("g_chat_flood_burst_tell");
			flood_lmax = cvar("g_chat_flood_lmax_tell");
			flood_field = floodcontrol_chattell;
		}
		else if(teamsay)
		{
			flood_spl = cvar("g_chat_flood_spl_team");
			flood_burst = cvar("g_chat_flood_burst_team");
			flood_lmax = cvar("g_chat_flood_lmax_team");
			flood_field = floodcontrol_chatteam;
		}
		else
		{
			flood_spl = cvar("g_chat_flood_spl");
			flood_burst = cvar("g_chat_flood_burst");
			flood_lmax = cvar("g_chat_flood_lmax");
			flood_field = floodcontrol_chat;
		}
		flood_burst = max(0, flood_burst - 1);
		// to match explanation in default.cfg, a value of 3 must allow three-line bursts and not four!

		// do flood control for the default line size
		getWrappedLine_remaining = msgstr;
		msgstr = "";
		lines = 0;
		while(getWrappedLine_remaining && (!flood_lmax || lines <= flood_lmax))
		{
			msgstr = strcat(msgstr, " ", getWrappedLineLen(82.4289758859709, strlennocol)); // perl averagewidth.pl < gfx/vera-sans.width
			++lines;
		}
		msgstr = substring(msgstr, 1, strlen(msgstr) - 1);

		if(getWrappedLine_remaining != "")
		{
			msgstr = strcat(msgstr, "\n");
			flood = 2;
		}

		if(time >= source.flood_field)
		{
			source.flood_field = max(time - flood_burst * flood_spl, source.flood_field) + lines * flood_spl;
		}
		else
		{
			flood = 1;
			msgstr = fullmsgstr;
		}
	}

	if (timeoutStatus == 2) //when game is paused, no flood protection
		source.flood_field = flood = 0;

	if(flood == 2)
	{
		if(cvar("g_chat_flood_notify_flooder"))
		{
			sourcemsgstr = strcat(msgstr, "\n^3FLOOD CONTROL: ^7message too long, trimmed\n");
			sourcecmsgstr = "";
		}
		else
		{
			sourcemsgstr = fullmsgstr;
			sourcecmsgstr = fullcmsgstr;
		}
		cmsgstr = "";
	}
	else
	{
		sourcemsgstr = msgstr;
		sourcecmsgstr = cmsgstr;
	}

	if(!privatesay)
	if(source.classname != "player")
	{
		if(teamsay || (cvar("g_chat_nospectators") == 1) || (cvar("g_chat_nospectators") == 2 && !inWarmupStage))
			teamsay = -1; // spectators
	}

	if(flood)
		print("NOTE: ", playername(source), "^7 is flooding.\n");

	// build sourcemsgstr by cutting off a prefix and replacing it by the other one
	if(privatesay)
		sourcemsgstr = strcat(privatemsgprefix, substring(sourcemsgstr, privatemsgprefixlen, -1));

	if(source.muted)
	{
		// always fake the message
		sprint(source, sourcemsgstr);
		if(cmsgstr != "" && !privatesay)
			centerprint(source, sourcecmsgstr);
	}
	else if(flood == 1)
	{
		if(cvar("g_chat_flood_notify_flooder"))
			sprint(source, strcat("^3FLOOD CONTROL: ^7wait ^1", ftos(source.flood_field - time), "^3 seconds\n"));
		else
		{
			sprint(source, sourcemsgstr);
			if(cmsgstr != "" && !privatesay)
				centerprint(source, sourcecmsgstr);
		}
	}
	else if(privatesay)
	{
		sprint(source, sourcemsgstr);
		sprint(privatesay, msgstr);
		if(cmsgstr != "")
			centerprint(privatesay, cmsgstr);
	}
	else if(teamsay > 0)
	{
		sprint(source, sourcemsgstr);
		if(sourcecmsgstr != "")
			centerprint(source, sourcecmsgstr);
		FOR_EACH_REALPLAYER(head) if(head.team == source.team)
			if(head != source)
			{
				sprint(head, msgstr);
				if(cmsgstr != "")
					centerprint(head, cmsgstr);
			}
	}
	else if(teamsay < 0)
	{
		sprint(source, sourcemsgstr);
		FOR_EACH_REALCLIENT(head) if(head.classname != "player")
			if(head != source)
				sprint(head, msgstr);
	}
	else if(sourcemsgstr != msgstr)
	{
		sprint(source, sourcemsgstr);
		FOR_EACH_REALCLIENT(head)
			if(head != source)
				sprint(head, msgstr);
	}
	else
		bprint(msgstr);
}

float GetVoiceMessageVoiceType(string type)
{
	if(type == "taunt")
		return VOICETYPE_TAUNT;
	if(type == "teamshoot")
		return VOICETYPE_LASTATTACKER;
	return VOICETYPE_TEAMRADIO;
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
	tokenize_console(samplestring);
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
		if(tokenize_console(s) != 3)
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
		if(tokenize_console(s) != 3)
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

void GlobalSound(string sample, float chan, float voicetype)
{
	float n;
	float tauntrand;

	if(sample == "")
		return;

	tokenize_console(sample);
	n = stof(argv(1));
	if(n > 0)
		sample = strcat(argv(0), ftos(floor(random() * n + 1)), ".wav"); // randomization
	else
		sample = strcat(argv(0), ".wav"); // randomization

	switch(voicetype)
	{
		case VOICETYPE_LASTATTACKER_ONLY:
			if(self.pusher)
				if(self.pusher.team == self.team)
				{
					msg_entity = self.pusher;
					if(clienttype(msg_entity) == CLIENTTYPE_REAL)
					{
						if(msg_entity.cvar_cl_voice_directional == 1)
							soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_MIN);
						else
							soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
					}
				}
			break;
		case VOICETYPE_LASTATTACKER:
			if(self.pusher)
				if(self.pusher.team == self.team)
				{
					msg_entity = self.pusher;
					if(clienttype(msg_entity) == CLIENTTYPE_REAL)
					{
						if(msg_entity.cvar_cl_voice_directional == 1)
							soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_MIN);
						else
							soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
					}
					msg_entity = self;
					if(clienttype(msg_entity) == CLIENTTYPE_REAL)
						soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NONE);
				}
			break;
		case VOICETYPE_TEAMRADIO:
			FOR_EACH_REALCLIENT(msg_entity)
				if(!teams_matter || msg_entity.team == self.team)
				{
					if(msg_entity.cvar_cl_voice_directional == 1)
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_MIN);
					else
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
				}
			break;
		case VOICETYPE_AUTOTAUNT:
			if(!sv_autotaunt)
				break;
			if(!sv_taunt)
				break;
			if(sv_gentle)
				break;
			tauntrand = random();
			FOR_EACH_REALCLIENT(msg_entity)
				if (tauntrand < msg_entity.cvar_cl_autotaunt)
				{
					if (msg_entity.cvar_cl_voice_directional >= 1)
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, bound(ATTN_MIN, msg_entity.cvar_cl_voice_directional_taunt_attenuation, ATTN_MAX));
					else
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
				}
			break;
		case VOICETYPE_TAUNT:
			if(self.classname == "player")
				if(self.deadflag == DEAD_NO)
					setanim(self, self.anim_taunt, FALSE, TRUE, TRUE);
			if(!sv_taunt)
				break;
			if(sv_gentle)
				break;
			FOR_EACH_REALCLIENT(msg_entity)
			{
				if (msg_entity.cvar_cl_voice_directional >= 1)
					soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, bound(ATTN_MIN, msg_entity.cvar_cl_voice_directional_taunt_attenuation, ATTN_MAX));
				else
					soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
			}
		case VOICETYPE_PLAYERSOUND:
			sound(self, chan, sample, VOL_BASE, ATTN_NORM);
			break;
		default:
			backtrace("Invalid voice type!");
			break;
	}
}

void PlayerSound(.string samplefield, float chan, float voicetype)
{
	string sample;
	sample = self.samplefield;
	GlobalSound(sample, chan, voicetype);
}

void VoiceMessage(string type, string msg)
{
	var .string sample;
	var float voicetype, ownteam;
	sample = GetVoiceMessageSampleField(type);

	if(GetPlayerSoundSampleField_notFound)
	{
		sprint(self, strcat("Invalid voice. Use one of: ", allvoicesamples, "\n"));
		return;
	}

	voicetype = GetVoiceMessageVoiceType(type);
	ownteam = (voicetype == VOICETYPE_TEAMRADIO);

	float flood;
	float flood_spv;
	var .float flood_field;

	flood = 0;
	if(ownteam)
	{
		flood_spv = cvar("g_voice_flood_spv_team");
		flood_field = floodcontrol_voiceteam;
	}
	else
	{
		flood_spv = cvar("g_voice_flood_spv");
		flood_field = floodcontrol_voice;
	}

	if(time >= self.flood_field)
		self.flood_field = max(time, self.flood_field) + flood_spv;
	else
		flood = 1;

	if (timeoutStatus == 2) //when game is paused, no flood protection
		self.flood_field = flood = 0;

	if (msg != "")
		Say(self, ownteam, world, msg, 0);

	if (!flood)
		PlayerSound(sample, CHAN_VOICE, voicetype);
}

void MoveToTeam(entity client, float team_colour, float type, float show_message)
{
// 	show_message
// 	0 (00) automove centerprint, admin message
// 	1 (01) automove centerprint, no admin message
// 	2 (10) no centerprint, admin message
// 	3 (11) no centerprint, no admin message

	float lockteams_backup;

	lockteams_backup = lockteams;  // backup any team lock

	lockteams = 0;  // disable locked teams

	TeamchangeFrags(client);  // move the players frags
	SetPlayerColors(client, team_colour - 1);  // set the players colour
	Damage(client, client, client, 100000, ((show_message & 2) ? DEATH_QUIET : DEATH_AUTOTEAMCHANGE), client.origin, '0 0 0');  // kill the player

	lockteams = lockteams_backup;  // restore the team lock

	LogTeamchange(client.playerid, client.team, type);

	if not(show_message & 1) // admin message
		sprint(client, strcat("\{1}\{13}^3", admin_name(), "^7: You have been moved to the ", Team_ColorNameLowerCase(team_colour), " team\n"));  // send a chat message

	bprint(strcat(client.netname, " joined the ", ColoredTeamName(client.team), "\n"));
}
