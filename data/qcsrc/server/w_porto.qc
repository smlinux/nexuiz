.float portal_id;
.entity porto_current;
.vector porto_v_angle; // holds "held" view angles
.float porto_v_angle_held;
.vector right_vector;

void W_Porto_Success (void)
{
	self.owner.porto_current = world;
	remove(self);
}

float W_ThrowNewWeapon(entity own, float wpn, float doreduce, vector org, vector velo);
void W_Porto_Fail (float failhard)
{
	// no portals here!
	Portal_ClearWithID(self.owner, self.portal_id);
	self.owner.porto_current = world;

	if(!failhard && !(self.owner.weapons & WEPBIT_PORTO))
	{
		centerprint(self.owner, "^1Portal deployment failed.\n\n^2Catch it to try again!");
		setsize (self, '-16 -16 0', '16 16 32');
		setorigin(self, self.origin + trace_plane_normal);
		if(move_out_of_solid(self))
		{
			self.flags = FL_ITEM;
			self.velocity = trigger_push_calculatevelocity(self.origin, self.owner, 128);
			tracetoss(self, self);
			if(vlen(trace_endpos - self.owner.origin) > 128)
				self.velocity = '0 0 0';
			W_ThrowNewWeapon(self.owner, WEP_PORTO, 0, self.origin, self.velocity);
		}
		else
		{
			W_ThrowNewWeapon(self.owner, WEP_PORTO, 0, self.origin, '0 0 0');
		}
	}
	remove(self);
}

void W_Porto_Think (void)
{
	trace_plane_normal = '0 0 0';
	if(self.owner.playerid != self.playerid)
		remove(self);
	else
		W_Porto_Fail(0);
}

void W_Porto_Touch (void)
{
	vector norm;

	if(other.classname == "portal")
		return; // handled by the portal

	norm = trace_plane_normal;
	if(self.owner.playerid != self.playerid)
	{
		remove(self);
	}
	else if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SLICK)
	{
		// just reflect
		self.right_vector = self.right_vector - 2 * trace_plane_normal * (self.right_vector * trace_plane_normal);
		self.angles = vectoangles(self.velocity - 2 * trace_plane_normal * (self.velocity * trace_plane_normal));
	}
	else if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		W_Porto_Fail(0);
	}
	else if(self.effects & EF_RED)
	{
		self.effects += EF_BLUE - EF_RED;
		if(Portal_SpawnInPortalAtTrace(self.owner, self.right_vector, self.portal_id))
		{
			sound(self, CHAN_PROJECTILE, "misc/invshot.wav", VOL_BASE, ATTN_NORM);
			centerprint(self.owner, "^1In^7-portal created.\n");
			trace_plane_normal = norm;
			self.right_vector = self.right_vector - 2 * trace_plane_normal * (self.right_vector * trace_plane_normal);
			self.angles = vectoangles(self.velocity - 2 * trace_plane_normal * (self.velocity * trace_plane_normal));
		}
		else
		{
			trace_plane_normal = norm;
			W_Porto_Fail(0);
		}
	}
	else
	{
		if(Portal_SpawnOutPortalAtTrace(self.owner, self.right_vector, self.portal_id))
		{
			sound(self, CHAN_PROJECTILE, "misc/invshot.wav", VOL_BASE, ATTN_NORM);
			centerprint(self.owner, "^4Out^7-portal created.\n");
			W_Porto_Success();
		}
		else
		{
			trace_plane_normal = norm;
			W_Porto_Fail(0);
		}
	}

}

void W_Porto_Attack (void)
{
	local entity gren;

	if not(self.items & IT_UNLIMITED_AMMO)
		self.weapons = self.weapons - (self.weapons & WEPBIT_PORTO);
	W_SetupShot (self, '0 0 0', FALSE, 4, "weapons/grenade_fire.wav");

	//pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	gren = spawn ();
	gren.owner = self;
	gren.classname = "porto";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = 200;
	gren.movetype = MOVETYPE_BOUNCEMISSILE;
	gren.solid = SOLID_BBOX;
	gren.effects = EF_LOWPRECISION | EF_RED;
	gren.scale = 4;
	gren.modelflags = MF_GRENADE;
	setmodel(gren, "models/grenademodel.md3"); // precision set above
	setsize(gren, '0 0 0', '0 0 0');
	setorigin(gren, w_shotorg);

	gren.nextthink = time + cvar("g_balance_porto_primary_lifetime");
	gren.think = W_Porto_Think;
	gren.touch = W_Porto_Touch;
	gren.velocity = w_shotdir * cvar("g_balance_porto_primary_speed");
	W_SetupProjectileVelocity(gren);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	gren.portal_id = time;
	self.porto_current = gren;
	gren.playerid = self.playerid;
	fixedmakevectors(vectoangles(gren.velocity));
	gren.right_vector = v_right;

	gren.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
}

void spawnfunc_weapon_porto (void)
{
	weapon_defaultspawnfunc(WEP_PORTO);
}

float w_porto(float req)
{
	vector v_angle_save;

	if (req == WR_AIM)
	{
		self.BUTTON_ATCK = FALSE;
		self.BUTTON_ATCK2 = FALSE;
		if(bot_aim(cvar("g_balance_porto_primary_speed"), 0, cvar("g_balance_grenadelauncher_primary_lifetime"), FALSE))
			self.BUTTON_ATCK = TRUE;
	}
	else if (req == WR_THINK)
	{
		if(self.porto_v_angle_held)
		{
			if(!self.BUTTON_ATCK2)
			{
				msg_entity = self;
				WRITESPECTATABLE_MSG_ONE({
					WriteByte(MSG_ONE, SVC_TEMPENTITY);
					WriteByte(MSG_ONE, TE_CSQC_HOLDANGLES);
					WriteByte(MSG_ONE, WEP_PORTO);
					WriteByte(MSG_ONE, 0);
				});
				self.porto_v_angle_held = 0;
			}
		}
		else
		{
			if(self.BUTTON_ATCK2)
			{
				self.porto_v_angle = self.v_angle;
				msg_entity = self;
				WRITESPECTATABLE_MSG_ONE({
					WriteByte(MSG_ONE, SVC_TEMPENTITY);
					WriteByte(MSG_ONE, TE_CSQC_HOLDANGLES);
					WriteByte(MSG_ONE, WEP_PORTO);
					WriteByte(MSG_ONE, 1);
					WriteCoord(MSG_ONE, self.v_angle_x);
					WriteCoord(MSG_ONE, self.v_angle_y);
				});
				self.porto_v_angle_held = 1;
			}
		}
		v_angle_save = self.v_angle;
		if(self.porto_v_angle_held)
			makevectors(self.porto_v_angle); // override the previously set angles

		if (self.BUTTON_ATCK)
		if (!self.porto_current)
		if (weapon_prepareattack(0, cvar("g_balance_porto_primary_refire")))
		{
			W_Porto_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_porto_primary_animtime"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/grenademodel.md3");
		precache_model ("models/weapons/g_porto.md3");
		precache_model ("models/weapons/v_porto.md3");
		precache_model ("models/weapons/w_porto.zym");
		precache_sound ("weapons/grenade_fire.wav");
		precache_model ("models/portal.md3");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_PORTO);
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "did the impossible";
	else if (req == WR_KILLMESSAGE)
		w_deathtypestring = "felt # doing the impossible";
	return TRUE;
};
