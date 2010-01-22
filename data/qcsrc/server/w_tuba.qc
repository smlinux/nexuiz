#ifdef REGISTER_WEAPON
REGISTER_WEAPON(TUBA, w_tuba, 0, 1, WEP_FLAG_HIDDEN | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "tuba", "tuba", "@!#%'n Tuba");
#else
//#define TUBA_NOTE(n) strcat("weapons/tuba_note", ftos(n), ".wav")
.float tuba_notecount;
.entity tuba_note;
.float tuba_smoketime;

float Tuba_GetNote(entity pl, float hittype)
{
	float note;
	float movestate;
	movestate = 5;
	if(pl.movement_x < 0) movestate -= 3;
	if(pl.movement_x > 0) movestate += 3;
	if(pl.movement_y < 0) movestate -= 1;
	if(pl.movement_y > 0) movestate += 1;
	switch(movestate)
	{
	// layout: originally I wanted
	//   eb e  e#=f
	//   B  c  d
	//   Gb G  G#
	// but then you only use forward and right key. So to make things more
	// interesting, I swapped B with e#. Har har har...
	//   eb e  B
	// f=e# c  d
	//   Gb G  G#
		case 1: note = -6; break; // Gb
		case 2: note = -5; break; // G
		case 3: note = -4; break; // G#
		case 4: note = +5; break; // e#
		case 5: note =  0; break; // c
		case 6: note = +2; break; // d
		case 7: note = +3; break; // eb
		case 8: note = +4; break; // e
		case 9: note = -1; break; // B
	}
	if(pl.BUTTON_CROUCH)
		note -= 12;
	if(pl.BUTTON_JUMP)
		note += 12;
	if(hittype & HITTYPE_SECONDARY)
		note += 7;
	
	// we support two kinds of tubas, those tuned in Eb and those tuned in C
	// kind of tuba currently is player slot number, or team number if in
	// teamplay
	// that way, holes in the range of notes are "plugged"
	if(teams_matter)
	{
		if(pl.team == COLOR_TEAM2 || pl.team == COLOR_TEAM4)
			note += 3;
	}
	else
	{
		if(pl.clientcolors & 1)
			note += 3;
	}
	
	// total range of notes:
	//                       0
	//                 ***  ** ****
	//                        ***  ** ****
	//     ***  ** ****
	//            ***  ** ****
	//     ***  ********************* ****
	//     -18.........................+12
	//        ***  ********************* ****
	//     -18............................+15
	//     with jump: ... +24
	//     ... +27
	return note;
}

float W_Tuba_NoteSendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_TUBANOTE);
	WriteByte(MSG_ENTITY, (sf & 1) | ((self.cnt + 42) * 2));
	if(sf & 1)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}
	return TRUE;
}

void W_Tuba_NoteThink()
{
	float needchange, dist_mult;
	float vol0, vol1;
	vector dir0, dir1;
	vector v;
	entity e;
	if(time > self.teleport_time)
	{
		self.owner.tuba_note = world;
		remove(self);
		return;
	}
	self.nextthink = time;
	dist_mult = cvar("g_balance_tuba_attenuation") / cvar("snd_soundradius");
	needchange = 0;
	FOR_EACH_REALCLIENT(e)
	if(e != self.owner)
	{
		v = self.origin - (e.origin + e.view_ofs);
		vol0 = max(0, 1 - vlen(v) * dist_mult);
		dir0 = normalize(v);
		v = self.owner.origin - (e.origin + e.view_ofs);
		vol1 = max(0, 1 - vlen(v) * dist_mult);
		dir1 = normalize(v);
		if(fabs(vol0 - vol1) > 0.005) // 0.5 percent change in volume
		{
			setorigin(self, self.owner.origin);
			self.SendFlags |= 1;
			break;
		}
		if(dir0 * dir1 < 0.9994) // 2 degrees change in angle
		{
			setorigin(self, self.owner.origin);
			self.SendFlags |= 1;
			break;
		}
	}
}

void W_Tuba_Attack(float hittype)
{
	vector o;
	float c, n;
	W_SetupShot(self, FALSE, 2, "", cvar("g_balance_tuba_damage"));
	if(self.tuba_notecount)
	{
		self.tuba_notecount = FALSE;
		c = CHAN_WEAPON;
	}
	else
	{
		self.tuba_notecount = TRUE;
		c = CHAN_WEAPON2;
	}

	n = Tuba_GetNote(self, hittype);

	if(self.tuba_note)
	{
		if(self.tuba_note.cnt != n)
		{
			/*
			self.tuba_note.cnt = n;
			self.tuba_note.SendFlags |= 2;
			*/
			remove(self.tuba_note);
			self.tuba_note = world;
		}
	}

	if not(self.tuba_note)
	{
		self.tuba_note = spawn();
		self.tuba_note.owner = self;
		self.tuba_note.cnt = n;
		self.tuba_note.think = W_Tuba_NoteThink;
		self.tuba_note.nextthink = time;
		Net_LinkEntity(self.tuba_note, FALSE, 0, W_Tuba_NoteSendEntity);
	}

	self.tuba_note.teleport_time = time + cvar("g_balance_tuba_refire") * 2; // so it can get prolonged safely

	//sound(self, c, TUBA_NOTE(n), bound(0, VOL_BASE * cvar("g_balance_tuba_volume"), 1), cvar("g_balance_tuba_attenuation"));
	RadiusDamage(self, self, cvar("g_balance_tuba_damage"), cvar("g_balance_tuba_edgedamage"), cvar("g_balance_tuba_radius"), world, cvar("g_balance_tuba_force"), hittype | WEP_TUBA, world);

	o = gettaginfo(self.exteriorweaponentity, 0);
	if(time > self.tuba_smoketime)
	{
		pointparticles(particleeffectnum("smoke_ring"), o + v_up * 45 + v_right * -6 + v_forward * 8, v_up * 100, 1);
		self.tuba_smoketime = time + 0.25;
	}
}

void spawnfunc_weapon_tuba (void)
{
	weapon_defaultspawnfunc(WEP_TUBA);
}

float w_tuba(float req)
{
	if (req == WR_AIM)
	{
		// bots cannot play the Tuba well yet
		// I think they should start with the recorder first
		if(vlen(self.origin - self.enemy.origin) < cvar("g_balance_tuba_radius"))
		{
			if(random() > 0.5)
				self.BUTTON_ATCK = 1;
			else
				self.BUTTON_ATCK2 = 1;
		}
	}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_tuba_refire")))
		{
			W_Tuba_Attack(0);
			//weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_tuba_animtime"), w_ready);
			weapon_thinkf(WFRAME_IDLE, cvar("g_balance_tuba_animtime"), w_ready);
		}
		if (self.BUTTON_ATCK2)
		if (weapon_prepareattack(1, cvar("g_balance_tuba_refire")))
		{
			W_Tuba_Attack(HITTYPE_SECONDARY);
			//weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_tuba_animtime"), w_ready);
			weapon_thinkf(WFRAME_IDLE, cvar("g_balance_tuba_animtime"), w_ready);
		}
		if(self.tuba_note)
		{
			if(!self.BUTTON_ATCK && !self.BUTTON_ATCK2)
			{
				remove(self.tuba_note);
				self.tuba_note = world;
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_tuba.md3");
		precache_model ("models/weapons/v_tuba.md3");
		precache_model ("models/weapons/h_tuba.dpm");

		//float i;
		//for(i = -18; i <= +27; ++i)
		//	precache_sound(TUBA_NOTE(i));
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_TUBA);
	else if (req == WR_CHECKAMMO1)
		return TRUE; // TODO use fuel?
	else if (req == WR_CHECKAMMO2)
		return TRUE; // TODO use fuel?
	else if (req == WR_SUICIDEMESSAGE)
	{
		w_deathtypestring = "hurt his own ears with the @!#%'n Tuba";
	}
	else if (req == WR_KILLMESSAGE)
	{
		w_deathtypestring = "died of #'s great playing on the @!#%'n Tuba";
	}
	return TRUE;
};
#endif
