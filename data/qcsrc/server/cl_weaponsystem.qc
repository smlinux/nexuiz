/*
===========================================================================

  CLIENT WEAPONSYSTEM CODE
  Bring back W_Weaponframe

===========================================================================
*/

.float weapon_frametime;

float W_WeaponRateFactor()
{
	float t;
	t = 1.0 / g_weaponratefactor;

	if(g_runematch)
	{
		if(self.runes & RUNE_SPEED)
		{
			if(self.runes & CURSE_SLOW)
				t = t * cvar("g_balance_rune_speed_combo_atkrate");
			else
				t = t * cvar("g_balance_rune_speed_atkrate");
		}
		else if(self.runes & CURSE_SLOW)
		{
			t = t * cvar("g_balance_curse_slow_atkrate");
		}
	}

	return t;
}

void W_SwitchWeapon_Force(entity e, float w)
{
	e.cnt = e.switchweapon;
	e.switchweapon = w;
}

.float antilag_debug;

// VorteX: static frame globals
float WFRAME_DONTCHANGE = -1;
float WFRAME_FIRE1 = 0;
float WFRAME_FIRE2 = 1;
float WFRAME_IDLE = 2;
float WFRAME_RELOAD = 3;
.float wframe;

void(float fr, float t, void() func) weapon_thinkf;

vector W_HitPlotUnnormalizedUntransform(vector screenforward, vector screenright, vector screenup, vector v)
{
	vector ret;
	ret_x = screenright * v;
	ret_y = screenup * v;
	ret_z = screenforward * v;
	return ret;
}

vector W_HitPlotNormalizedUntransform(vector org, entity targ, vector screenforward, vector screenright, vector screenup, vector v)
{
	float i, j, k;
	vector mi, ma, thisv, myv, ret;

	myv = W_HitPlotUnnormalizedUntransform(screenforward, screenright, screenup, org);

	// x = 0..1 relative to hitbox; y = 0..1 relative to hitbox; z = distance

	for(i = 0; i < 2; ++i) for(j = 0; j < 2; ++j) for(k = 0; k < 2; ++k)
	{
		thisv = targ.origin;
		if(i) thisv_x += targ.maxs_x; else thisv_x += targ.mins_x;
		if(j) thisv_y += targ.maxs_y; else thisv_y += targ.mins_y;
		if(k) thisv_z += targ.maxs_z; else thisv_z += targ.mins_z;
		thisv = W_HitPlotUnnormalizedUntransform(screenforward, screenright, screenup, thisv);
		if(i || j || k)
		{
			if(mi_x > thisv_x) mi_x = thisv_x; if(ma_x < thisv_x) ma_x = thisv_x;
			if(mi_y > thisv_y) mi_y = thisv_y; if(ma_y < thisv_y) ma_y = thisv_y;
			//if(mi_z > thisv_z) mi_z = thisv_z; if(ma_z < thisv_z) ma_y = thisv_z;
		}
		else
		{
			// first run
			mi = ma = thisv;
		}
	}

	thisv = W_HitPlotUnnormalizedUntransform(screenforward, screenright, screenup, v);
	ret_x = (thisv_x - mi_x) / (ma_x - mi_x);
	ret_y = (thisv_y - mi_y) / (ma_y - mi_y);
	ret_z = thisv_z - myv_z;
	return ret;
}

void W_HitPlotAnalysis(entity player, vector screenforward, vector screenright, vector screenup)
{
	vector hitplot;
	vector org;
	float lag;

	if(player.hitplotfh >= 0)
	{
		lag = ANTILAG_LATENCY(player);
		if(lag < 0.001)
			lag = 0;
		if(clienttype(player) != CLIENTTYPE_REAL)
			lag = 0; // only antilag for clients

		org = player.origin + player.view_ofs;
		traceline_antilag_force(player, org, org + screenforward * MAX_SHOT_DISTANCE, MOVE_NORMAL, player, lag);
		if(trace_ent.flags & FL_CLIENT)
		{
			antilag_takeback(trace_ent, time - lag);
			hitplot = W_HitPlotNormalizedUntransform(org, trace_ent, screenforward, screenright, screenup, trace_endpos);
			antilag_restore(trace_ent);
			fputs(player.hitplotfh, strcat(ftos(hitplot_x), " ", ftos(hitplot_y), " ", ftos(hitplot_z), " ", ftos(player.switchweapon), "\n"));
			//print(strcat(ftos(hitplot_x), " ", ftos(hitplot_y), " ", ftos(hitplot_z), "\n"));
		}
	}
}

vector w_shotorg;
vector w_shotdir;

// this function calculates w_shotorg and w_shotdir based on the weapon model
// offset, trueaim and antilag, and won't put w_shotorg inside a wall.
// make sure you call makevectors first (FIXME?)
void W_SetupShot_Dir_ProjectileSize(entity ent, vector s_forward, vector mi, vector ma, float antilag, float recoil, string snd, float maxdamage)
{
	float nudge = 1; // added to traceline target and subtracted from result
	local vector trueaimpoint;
	local float oldsolid;
	vector vecs, dv;
	oldsolid = ent.dphitcontentsmask;
	if(ent.weapon == WEP_CAMPINGRIFLE)
		ent.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	else
		ent.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	if(antilag)
		WarpZone_traceline_antilag(world, ent.origin + ent.view_ofs, ent.origin + ent.view_ofs + s_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, ent, ANTILAG_LATENCY(ent));
		// passing world, because we do NOT want it to touch dphitcontentsmask
	else
		WarpZone_TraceLine(ent.origin + ent.view_ofs, ent.origin + ent.view_ofs + s_forward * MAX_SHOT_DISTANCE, MOVE_NOMONSTERS, ent);
	ent.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;

	vector vf, vr, vu;
	vf = v_forward;
	vr = v_right;
	vu = v_up;
	trueaimpoint = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos); // warpzone support
	v_forward = vf;
	v_right = vr;
	v_up = vu;

	// track max damage
	if not(inWarmupStage) {
		entity w;
		w = get_weaponinfo(ent.weapon);
		if(w.spawnflags & WEP_TYPE_SPLASH) {  // splash damage
			ent.stats_fired[ent.weapon - 1] += maxdamage;
			ent.stat_fired = ent.weapon + 64 * floor(ent.stats_fired[ent.weapon - 1]);
		}
	}

	W_HitPlotAnalysis(ent, v_forward, v_right, v_up);

	if(ent.weaponentity.movedir_x > 0)
	{
		vecs = ent.weaponentity.movedir;
		vecs_y = -vecs_y;
	}
	else
		vecs = '0 0 0';

	if(debug_shotorg != '0 0 0')
		vecs = debug_shotorg;

	dv = v_right * vecs_y + v_up * vecs_z;
	w_shotorg = ent.origin + ent.view_ofs + dv;

	// now move the shotorg forward as much as requested if possible
	if(antilag)
	{
		if(ent.antilag_debug)
			tracebox_antilag(ent, w_shotorg, mi, ma, w_shotorg + v_forward * (vecs_x + nudge), MOVE_NORMAL, ent, ent.antilag_debug);
		else
			tracebox_antilag(ent, w_shotorg, mi, ma, w_shotorg + v_forward * (vecs_x + nudge), MOVE_NORMAL, ent, ANTILAG_LATENCY(ent));
	}
	else
		tracebox(w_shotorg, mi, ma, w_shotorg + v_forward * (vecs_x + nudge), MOVE_NORMAL, ent);
	w_shotorg = trace_endpos - v_forward * nudge;
	// calculate the shotdir from the chosen shotorg
	w_shotdir = normalize(trueaimpoint - w_shotorg);

	if (antilag)
	if (!ent.cvar_cl_noantilag)
	{
		if (cvar("g_antilag") == 1) // switch to "ghost" if not hitting original
		{
			traceline(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, ent);
			if (!trace_ent.takedamage)
			{
				traceline_antilag_force (ent, w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, ent, ANTILAG_LATENCY(ent));
				if (trace_ent.takedamage && trace_ent.classname == "player")
				{
					entity e;
					e = trace_ent;
					traceline(w_shotorg, e.origin, MOVE_NORMAL, ent);
					if(trace_ent == e)
						w_shotdir = normalize(trace_ent.origin - w_shotorg);
				}
			}
		}
		else if(cvar("g_antilag") == 3) // client side hitscan
		{
			// this part MUST use prydon cursor
			if (ent.cursor_trace_ent)                 // client was aiming at someone
			if (ent.cursor_trace_ent != ent)         // just to make sure
			if (ent.cursor_trace_ent.takedamage)      // and that person is killable
			if (ent.cursor_trace_ent.classname == "player") // and actually a player
			{
				// verify that the shot would miss without antilag
				// (avoids an issue where guns would always shoot at their origin)
				traceline(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, ent);
				if (!trace_ent.takedamage)
				{
					// verify that the shot would hit if altered
					traceline(w_shotorg, ent.cursor_trace_ent.origin, MOVE_NORMAL, ent);
					if (trace_ent == ent.cursor_trace_ent)
						w_shotdir = normalize(ent.cursor_trace_ent.origin - w_shotorg);
					else
						print("antilag fail\n");
				}
			}
		}
	}

	ent.dphitcontentsmask = oldsolid; // restore solid type (generally SOLID_SLIDEBOX)

	if (!g_norecoil)
		ent.punchangle_x = recoil * -1;

	if (snd != "")
	{
		sound (ent, CHAN_WEAPON, snd, VOL_BASE, ATTN_NORM);
	}

	if (ent.items & IT_STRENGTH)
	if (!g_minstagib)
		sound (ent, CHAN_AUTO, "weapons/strength_fire.wav", VOL_BASE, ATTN_NORM);
};

#define W_SetupShot_ProjectileSize(ent,mi,ma,antilag,recoil,snd,maxdamage) W_SetupShot_Dir_ProjectileSize(ent, v_forward, mi, ma, antilag, recoil, snd, maxdamage)
#define W_SetupShot_Dir(ent,s_forward,antilag,recoil,snd,maxdamage) W_SetupShot_Dir_ProjectileSize(ent, s_forward, '0 0 0', '0 0 0', antilag, recoil, snd, maxdamage)
#define W_SetupShot(ent,antilag,recoil,snd,maxdamage) W_SetupShot_ProjectileSize(ent, '0 0 0', '0 0 0', antilag, recoil, snd, maxdamage)

void LaserTarget_Think()
{
	entity e;
	vector offset;
	float uselaser;
	uselaser = 0;

	// list of weapons that will use the laser, and the options that enable it
	if(self.owner.laser_on && self.owner.weapon == WEP_ROCKET_LAUNCHER && g_laserguided_missile)
		uselaser = 1;
	// example
	//if(self.owner.weapon == WEP_ELECTRO && cvar("g_laserguided_electro"))
	//	uselaser = 1;



	// if a laser-enabled weapon isn't selected, delete any existing laser and quit
	if(!uselaser)
	{
		// rocket launcher isn't selected, so no laser target.
		if(self.lasertarget != world)
		{
			remove(self.lasertarget);
			self.lasertarget = world;
		}
		return;
	}

	if(!self.lasertarget)
	{
		// we don't have a lasertarget entity, so spawn one
		//bprint("create laser target\n");
		e = self.lasertarget = spawn();
		e.owner = self.owner;			// Its owner is my owner
		e.classname = "laser_target";
		e.movetype = MOVETYPE_NOCLIP;	// don't touch things
		setmodel(e, "models/laser_dot.mdl");	// what it looks like, precision set below
		e.scale = 1.25;				// make it larger
		e.alpha = 0.25;				// transparency
		e.colormod = '255 0 0' * (1/255) * 8;	// change colors
		e.effects = EF_FULLBRIGHT | EF_LOWPRECISION;
		// make it dynamically glow
		// you should avoid over-using this, as it can slow down the player's computer.
		e.glow_color = 251; // red color
		e.glow_size = 12;
	}
	else
		e = self.lasertarget;

	// move the laser dot to where the player is looking

	makevectors(self.owner.v_angle); // set v_forward etc to the direction the player is looking
	offset = '0 0 26' + v_right*3;
	traceline(self.owner.origin + offset, self.owner.origin + offset + v_forward * MAX_SHOT_DISTANCE, FALSE, self); // trace forward until you hit something, like a player or wall
	setorigin(e, trace_endpos + v_forward*8); // move me to where the traceline ended
	if(trace_plane_normal != '0 0 0')
		e.angles = vectoangles(trace_plane_normal);
	else
		e.angles = vectoangles(v_forward);
}

float CL_Weaponentity_CustomizeEntityForClient()
{
	self.viewmodelforclient = self.owner;
	if(other.classname == "spectator")
		if(other.enemy == self.owner)
			self.viewmodelforclient = other;
	return TRUE;
}

float qcweaponanimation;
vector weapon_offset = '0 -10 0';
vector weapon_adjust = '10 0 -15';
.vector weapon_morph0origin;
.vector weapon_morph0angles;
.float  weapon_morph0time;
.vector weapon_morph1origin;
.vector weapon_morph1angles;
.float  weapon_morph1time;
.vector weapon_morph2origin;
.vector weapon_morph2angles;
.float  weapon_morph2time;
.vector weapon_morph3origin;
.vector weapon_morph3angles;
.float  weapon_morph3time;
.vector weapon_morph4origin;
.vector weapon_morph4angles;
.float  weapon_morph4time;
.string weaponname;
#define QCWEAPONANIMATION_ORIGIN(e) ((weapon_offset_x + e.view_ofs_x) * v_forward - (weapon_offset_y + e.view_ofs_y) * v_right + (weapon_offset_z + e.view_ofs_z) * v_up + weapon_adjust)

/*
 * supported formats:
 *
 * 1. simple animated model, muzzle flash handling on h_ model:
 *    h_tuba.dpm, h_tuba.dpm.framegroups - invisible model controlling the animation
 *      tags:
 *        shot = muzzle end (shot origin, also used for muzzle flashes)
 *        shell = casings ejection point (must be on the right hand side of the gun)
 *        weapon = attachment for v_tuba.md3
 *    v_tuba.md3 - first and third person model
 *    g_tuba.md3 - pickup model
 *
 * 2. simple animated model, muzzle flash handling on v_ model:
 *    h_tuba.dpm, h_tuba.dpm.framegroups - invisible model controlling the animation
 *      tags:
 *        weapon = attachment for v_tuba.md3
 *    v_tuba.md3 - first and third person model
 *      tags:
 *        shot = muzzle end (shot origin, also used for muzzle flashes)
 *        shell = casings ejection point (must be on the right hand side of the gun)
 *    g_tuba.md3 - pickup model
 *
 * 3. fully animated model, muzzle flash handling on h_ model:
 *    h_tuba.dpm, h_tuba.dpm.framegroups - animated first person model
 *      tags:
 *        shot = muzzle end (shot origin, also used for muzzle flashes)
 *        shell = casings ejection point (must be on the right hand side of the gun)
 *        handle = corresponding to the origin of v_tuba.md3 (used for muzzle flashes)
 *    v_tuba.md3 - third person model
 *    g_tuba.md3 - pickup model
 *
 * 4. fully animated model, muzzle flash handling on v_ model:
 *    h_tuba.dpm, h_tuba.dpm.framegroups - animated first person model
 *      tags:
 *        shot = muzzle end (shot origin)
 *        shell = casings ejection point (must be on the right hand side of the gun)
 *    v_tuba.md3 - third person model
 *      tags:
 *        shot = muzzle end (for muzzle flashes)
 *    g_tuba.md3 - pickup model
 */

void CL_Weaponentity_Think()
{
	float tb, v_shot_idx;
	self.nextthink = time;
	if (intermission_running)
		self.frame = self.anim_idle_x;
	if (self.owner.weaponentity != self)
	{
		if (self.weaponentity)
			remove(self.weaponentity);
		remove(self);
		return;
	}
	if (self.owner.deadflag != DEAD_NO)
	{
		self.model = "";
		if (self.weaponentity)
			self.weaponentity.model = "";
		return;
	}
	if (self.cnt != self.owner.weapon || self.dmg != self.owner.modelindex || self.deadflag != self.owner.deadflag)
	{
		self.cnt = self.owner.weapon;
		self.dmg = self.owner.modelindex;
		self.deadflag = self.owner.deadflag;

		string animfilename;
		float animfile;
		if (self.owner.weaponname != "")
		{
			// if there is a child entity, hide it until we're sure we use it
			if (self.weaponentity)
				self.weaponentity.model = "";
			setmodel(self, strcat("models/weapons/v_", self.owner.weaponname, ".md3")); // precision set below
			v_shot_idx = gettagindex(self, "shot"); // used later
			if(!v_shot_idx)
				v_shot_idx = gettagindex(self, "tag_shot");

			if(qcweaponanimation)
			{
				self.angles = '0 0 0';
				makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
				self.movedir = weapon_offset_x * v_forward - weapon_offset_y * v_right + weapon_offset_z * v_up + weapon_adjust;
				self.movedir_x += 32;
				self.spawnorigin = self.movedir;
				// oldorigin - not calculated here
			}
			else
			{
				setmodel(self, strcat("models/weapons/h_", self.owner.weaponname, ".dpm")); // precision set below
				animfilename = strcat("models/weapons/h_", self.owner.weaponname, ".dpm.animinfo");
				animfile = fopen(animfilename, FILE_READ);
				// preset some defaults that work great for renamed zym files (which don't need an animinfo)
				self.anim_fire1  = '0 1 0.01';
				self.anim_fire2  = '1 1 0.01';
				self.anim_idle   = '2 1 0.01';
				self.anim_reload = '3 1 0.01';
				if (animfile >= 0)
				{
					animparseerror = FALSE;
					self.anim_fire1  = animparseline(animfile);
					self.anim_fire2  = animparseline(animfile);
					self.anim_idle   = animparseline(animfile);
					self.anim_reload = animparseline(animfile);
					fclose(animfile);
					if (animparseerror)
						print("Parse error in ", animfilename, ", some player animations are broken\n");
				}

				// if we have a "weapon" tag, let's attach the v_ model to it ("invisible hand" style model)
				// if we don't, this is a "real" animated model
				if(gettagindex(self, "weapon"))
				{
					if (!self.weaponentity)
						self.weaponentity = spawn();
					setmodel(self.weaponentity, strcat("models/weapons/v_", self.owner.weaponname, ".md3")); // precision does not matter
					setattachment(self.weaponentity, self, "weapon");
				}
				else if(gettagindex(self, "tag_weapon"))
				{
					if (!self.weaponentity)
						self.weaponentity = spawn();
					setmodel(self.weaponentity, strcat("models/weapons/v_", self.owner.weaponname, ".md3")); // precision does not matter
					setattachment(self.weaponentity, self, "tag_weapon");
				}
				else
				{
					if(self.weaponentity)
						remove(self.weaponentity);
					self.weaponentity = world;
				}

				setorigin(self,'0 0 0');
				self.angles = '0 0 0';
				self.frame = 0;
				self.viewmodelforclient = world;

				float idx;

				if(v_shot_idx) // v_ model attached to invisible h_ model
				{
					self.movedir = gettaginfo(self.weaponentity, v_shot_idx);
				}
				else
				{
					idx = gettagindex(self, "shot");
					if(!idx)
						idx = gettagindex(self, "tag_shot");
					if(idx)
						self.movedir = gettaginfo(self, idx);
					else
					{
						print("WARNING: weapon model ", self.model, " does not support the 'shot' tag, will display shots TOTALLY wrong\n");
						self.movedir = '0 0 0';
					}
				}

				if(self.weaponentity) // v_ model attached to invisible h_ model
				{
					idx = gettagindex(self.weaponentity, "shell");
					if(!idx)
						idx = gettagindex(self.weaponentity, "tag_shell");
					if(idx)
						self.spawnorigin = gettaginfo(self.weaponentity, idx);
				}
				else
					idx = 0;
				if(!idx)
				{
					idx = gettagindex(self, "shell");
					if(!idx)
						idx = gettagindex(self, "tag_shell");
					if(idx)
						self.spawnorigin = gettaginfo(self, idx);
					else
					{
						print("WARNING: weapon model ", self.model, " does not support the 'shell' tag, will display casings wrong\n");
						self.spawnorigin = self.movedir;
					}
				}

				if(v_shot_idx)
				{
					self.oldorigin = '0 0 0'; // use regular attachment
				}
				else
				{
					if(self.weaponentity)
					{
						idx = gettagindex(self, "weapon");
						if(!idx)
							idx = gettagindex(self, "tag_weapon");
					}
					else
					{
						idx = gettagindex(self, "handle");
						if(!idx)
							idx = gettagindex(self, "tag_handle");
					}
					if(idx)
					{
						self.oldorigin = self.movedir - gettaginfo(self, idx);
					}
					else
					{
						print("WARNING: weapon model ", self.model, " does not support the 'handle' tag and neither does the v_ model support the 'shot' tag, will display muzzle flashes TOTALLY wrong\n");
						self.oldorigin = '0 0 0'; // there is no way to recover from this
					}
				}

				self.viewmodelforclient = self.owner;
			}
		}
		else
		{
			self.model = "";
			if(self.weaponentity)
				remove(self.weaponentity);
			self.weaponentity = world;
			self.movedir = '0 0 0';
			self.spawnorigin = '0 0 0';
			self.oldorigin = '0 0 0';
			self.anim_fire1  = '0 1 0.01';
			self.anim_fire2  = '0 1 0.01';
			self.anim_idle   = '0 1 0.01';
			self.anim_reload = '0 1 0.01';
		}

		self.view_ofs = '0 0 0';

		if(self.movedir_x >= 0)
		{
			vector v0;
			v0 = self.movedir;
			self.movedir = shotorg_adjust(v0, FALSE, FALSE);
			self.view_ofs = shotorg_adjust(v0, FALSE, TRUE) - v0;
		}
		self.owner.stat_shotorg = compressShotOrigin(self.movedir);
		self.movedir = decompressShotOrigin(self.owner.stat_shotorg); // make them match perfectly

		self.spawnorigin += self.view_ofs; // offset the casings origin by the same amount

		// check if an instant weapon switch occurred
		if (qcweaponanimation)
		{
			if (self.state == WS_READY)
			{
				self.angles = '0 0 0';
				makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
				setorigin(self, QCWEAPONANIMATION_ORIGIN(self));
			}
		}
		else
			setorigin(self, self.view_ofs);
		// reset animstate now
		self.wframe = WFRAME_IDLE;
		self.weapon_morph0time = 0;
		self.weapon_morph1time = 0;
		self.weapon_morph2time = 0;
		self.weapon_morph3time = 0;
		self.weapon_morph4time = 0;
		setanim(self, self.anim_idle, TRUE, FALSE, TRUE);
	}

	tb = (self.effects & (EF_TELEPORT_BIT | EF_RESTARTANIM_BIT));
	self.effects = self.owner.effects & EFMASK_CHEAP;
	self.effects &~= EF_LOWPRECISION;
	self.effects &~= EF_FULLBRIGHT; // can mask team color, so get rid of it
	self.effects &~= EF_TELEPORT_BIT;
	self.effects &~= EF_RESTARTANIM_BIT;
	self.effects |= tb;

	if(self.owner.alpha == default_player_alpha)
		self.alpha = default_weapon_alpha;
	else if(self.owner.alpha != 0)
		self.alpha = self.owner.alpha;
	else
		self.alpha = 1;

	self.colormap = self.owner.colormap;
	if (self.weaponentity)
	{
		self.weaponentity.effects = self.effects;
		self.weaponentity.alpha = self.alpha;
		self.weaponentity.colormap = self.colormap;
	}

	self.angles = '0 0 0';
	local float f;
	f = 0;
	if (self.state == WS_RAISE && !intermission_running)
	{
		f = (self.owner.weapon_nextthink - time) * g_weaponratefactor / cvar("g_balance_weaponswitchdelay");
		self.angles_x = -90 * f * f;
		if (qcweaponanimation)
		{
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
			setorigin(self, QCWEAPONANIMATION_ORIGIN(self));
		}
	}
	else if (self.state == WS_DROP && !intermission_running)
	{
		f = 1 - (self.owner.weapon_nextthink - time) * g_weaponratefactor / cvar("g_balance_weaponswitchdelay");
		self.angles_x = -90 * f * f;
		if (qcweaponanimation)
		{
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
			setorigin(self, QCWEAPONANIMATION_ORIGIN(self));
		}
	}
	else if (self.state == WS_CLEAR)
	{
		f = 1;
		self.angles_x = -90 * f * f;
		if (qcweaponanimation)
		{
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
			setorigin(self, QCWEAPONANIMATION_ORIGIN(self));
		}
	}
	else if (qcweaponanimation && time < self.owner.weapon_morph1time)
	{
		f = (time - self.owner.weapon_morph0time) / (self.owner.weapon_morph1time - self.owner.weapon_morph0time);
		f = 1 - pow(1 - f, 3);
		self.angles = self.owner.weapon_morph0angles * (1 - f) + self.owner.weapon_morph1angles * f;
		setorigin(self, self.owner.weapon_morph0origin * (1 - f) + self.owner.weapon_morph1origin * f);
	}
	else if (qcweaponanimation && time < self.owner.weapon_morph2time)
	{
		f = (time - self.owner.weapon_morph1time) / (self.owner.weapon_morph2time - self.owner.weapon_morph1time);
		f = 1 - pow(1 - f, 3);
		self.angles = self.owner.weapon_morph1angles * (1 - f) + self.owner.weapon_morph2angles * f;
		setorigin(self, self.owner.weapon_morph1origin * (1 - f) + self.owner.weapon_morph2origin * f);
	}
	else if (qcweaponanimation && time < self.owner.weapon_morph3time)
	{
		f = (time - self.owner.weapon_morph2time) / (self.owner.weapon_morph3time - self.owner.weapon_morph2time);
		f = 1 - pow(1 - f, 3);
		self.angles = self.owner.weapon_morph2angles * (1 - f) + self.owner.weapon_morph3angles * f;
		setorigin(self, self.owner.weapon_morph2origin * (1 - f) + self.owner.weapon_morph3origin * f);
	}
	else if (qcweaponanimation && time < self.owner.weapon_morph4time)
	{
		f = (time - self.owner.weapon_morph3time) / (self.owner.weapon_morph4time - self.owner.weapon_morph3time);
		f = 1 - pow(1 - f, 3);
		self.angles = self.owner.weapon_morph3angles * (1 - f) + self.owner.weapon_morph4angles * f;
		setorigin(self, self.owner.weapon_morph3origin * (1 - f) + self.owner.weapon_morph4origin * f);
	}
	else if (qcweaponanimation)
	{
		// begin a new idle morph
		self.owner.weapon_morph0time   = time;
		self.owner.weapon_morph0angles = self.angles;
		self.owner.weapon_morph0origin = self.origin;

		float r;
		float t;

		r = random();
		if (r < 0.1)
		{
			// turn gun to the left to look at it
			t = 2;
			self.owner.weapon_morph1time   = time + t * 0.2;
			self.owner.weapon_morph1angles = randomvec() * 3 + '-5 30 0';
			makevectors(self.owner.weapon_morph1angles_x * '-1 0 0' + self.owner.weapon_morph1angles_y * '0 1 0' + self.owner.weapon_morph1angles_z * '0 0 1');
			self.owner.weapon_morph1origin = QCWEAPONANIMATION_ORIGIN(self);

			self.owner.weapon_morph2time   = time + t * 0.6;
			self.owner.weapon_morph2angles = randomvec() * 3 + '-5 30 0';
			makevectors(self.owner.weapon_morph2angles_x * '-1 0 0' + self.owner.weapon_morph2angles_y * '0 1 0' + self.owner.weapon_morph2angles_z * '0 0 1');
			self.owner.weapon_morph2origin = QCWEAPONANIMATION_ORIGIN(self);

			self.owner.weapon_morph3time   = time + t;
			self.owner.weapon_morph3angles = '0 0 0';
			makevectors(self.owner.weapon_morph3angles_x * '-1 0 0' + self.owner.weapon_morph3angles_y * '0 1 0' + self.owner.weapon_morph3angles_z * '0 0 1');
			self.owner.weapon_morph3origin = QCWEAPONANIMATION_ORIGIN(self);
		}
		else if (r < 0.2)
		{
			// raise the gun a bit
			t = 2;
			self.owner.weapon_morph1time   = time + t * 0.2;
			self.owner.weapon_morph1angles = randomvec() * 3 + '30 -10 0';
			makevectors(self.owner.weapon_morph1angles_x * '-1 0 0' + self.owner.weapon_morph1angles_y * '0 1 0' + self.owner.weapon_morph1angles_z * '0 0 1');
			self.owner.weapon_morph1origin = QCWEAPONANIMATION_ORIGIN(self);

			self.owner.weapon_morph2time   = time + t * 0.5;
			self.owner.weapon_morph2angles = randomvec() * 3 + '30 -10 5';
			makevectors(self.owner.weapon_morph2angles_x * '-1 0 0' + self.owner.weapon_morph2angles_y * '0 1 0' + self.owner.weapon_morph2angles_z * '0 0 1');
			self.owner.weapon_morph2origin = QCWEAPONANIMATION_ORIGIN(self);

			self.owner.weapon_morph3time   = time + t;
			self.owner.weapon_morph3angles = '0 0 0';
			makevectors(self.owner.weapon_morph3angles_x * '-1 0 0' + self.owner.weapon_morph3angles_y * '0 1 0' + self.owner.weapon_morph3angles_z * '0 0 1');
			self.owner.weapon_morph3origin = QCWEAPONANIMATION_ORIGIN(self);
		}
		else if (r < 0.3)
		{
			// tweak it a bit
			t = 5;
			self.owner.weapon_morph1time   = time + t * 0.3;
			self.owner.weapon_morph1angles = randomvec() * 6;
			makevectors(self.owner.weapon_morph1angles_x * '-1 0 0' + self.owner.weapon_morph1angles_y * '0 1 0' + self.owner.weapon_morph1angles_z * '0 0 1');
			self.owner.weapon_morph1origin = QCWEAPONANIMATION_ORIGIN(self);

			self.owner.weapon_morph2time   = time + t * 0.7;
			self.owner.weapon_morph2angles = randomvec() * 6;
			makevectors(self.owner.weapon_morph2angles_x * '-1 0 0' + self.owner.weapon_morph2angles_y * '0 1 0' + self.owner.weapon_morph2angles_z * '0 0 1');
			self.owner.weapon_morph2origin = QCWEAPONANIMATION_ORIGIN(self);

			self.owner.weapon_morph3time   = time + t;
			self.owner.weapon_morph3angles = '0 0 0';
			makevectors(self.owner.weapon_morph3angles_x * '-1 0 0' + self.owner.weapon_morph3angles_y * '0 1 0' + self.owner.weapon_morph3angles_z * '0 0 1');
			self.owner.weapon_morph3origin = QCWEAPONANIMATION_ORIGIN(self);
		}
		else
		{
			// hold it mostly steady
			t = random() * 6 + 4;
			self.owner.weapon_morph1time   = time + t * 0.2;
			self.owner.weapon_morph1angles = randomvec() * 1;
			makevectors(self.owner.weapon_morph1angles_x * '-1 0 0' + self.owner.weapon_morph1angles_y * '0 1 0' + self.owner.weapon_morph1angles_z * '0 0 1');
			self.owner.weapon_morph1origin = QCWEAPONANIMATION_ORIGIN(self);

			self.owner.weapon_morph2time   = time + t * 0.5;
			self.owner.weapon_morph2angles = randomvec() * 1;
			makevectors(self.owner.weapon_morph2angles_x * '-1 0 0' + self.owner.weapon_morph2angles_y * '0 1 0' + self.owner.weapon_morph2angles_z * '0 0 1');
			self.owner.weapon_morph2origin = QCWEAPONANIMATION_ORIGIN(self);

			self.owner.weapon_morph3time   = time + t * 0.7;
			self.owner.weapon_morph3angles = randomvec() * 1;
			makevectors(self.owner.weapon_morph3angles_x * '-1 0 0' + self.owner.weapon_morph3angles_y * '0 1 0' + self.owner.weapon_morph3angles_z * '0 0 1');
			self.owner.weapon_morph3origin = QCWEAPONANIMATION_ORIGIN(self);
		}

		self.owner.weapon_morph4time   = time + t;
		self.owner.weapon_morph4angles = '0 0 0';
		makevectors(self.owner.weapon_morph4angles_x * '-1 0 0' + self.owner.weapon_morph4angles_y * '0 1 0' + self.owner.weapon_morph4angles_z * '0 0 1');
		self.owner.weapon_morph4origin = QCWEAPONANIMATION_ORIGIN(self);

	}

	// create or update the lasertarget entity
	LaserTarget_Think();
};

void CL_ExteriorWeaponentity_Think()
{
	float tag_found;
	vector ang;
	self.nextthink = time;
	if (self.owner.exteriorweaponentity != self)
	{
		remove(self);
		return;
	}
	if (self.owner.deadflag != DEAD_NO)
	{
		self.model = "";
		return;
	}
	if (self.cnt != self.owner.weapon || self.dmg != self.owner.modelindex || self.deadflag != self.owner.deadflag)
	{
		self.cnt = self.owner.weapon;
		self.dmg = self.owner.modelindex;
		self.deadflag = self.owner.deadflag;
		if (self.owner.weaponname != "")
			setmodel(self, strcat("models/weapons/v_", self.owner.weaponname, ".md3")); // precision set below
		else
			self.model = "";

		if((tag_found = gettagindex(self.owner, "tag_weapon")))
		{
			self.tag_index = tag_found;
			self.tag_entity = self.owner;
		}
		else
			setattachment(self, self.owner, "bip01 r hand");

		// if that didn't find a tag, hide the exterior weapon model
		if (!self.tag_index)
			self.model = "";
	}
	self.effects = self.owner.effects;
	if(sv_pitch_min == sv_pitch_max)
		self.effects |= EF_LOWPRECISION;
	else
		self.effects &~= EF_LOWPRECISION;
	self.effects = self.effects & EFMASK_CHEAP; // eat performance
	if(self.owner.alpha == default_player_alpha)
		self.alpha = default_weapon_alpha;
	else if(self.owner.alpha != 0)
		self.alpha = self.owner.alpha;
	else
		self.alpha = 1;

	ang_x = bound(sv_pitch_min, self.owner.v_angle_x, sv_pitch_max);
	ang_y = 0;
	ang_z = 0;

	if(sv_pitch_fixyaw) // workaround for stupid player models that don't aim forward
	{
		ang_y = self.owner.v_angle_y;
		makevectors(ang);
		var vector v = v_forward;
		var float t = self.tag_entity.frame1time;
		var float f = self.tag_entity.frame;
		self.tag_entity.frame1time = time;
		self.tag_entity.frame = self.tag_entity.anim_idle_x;
		gettaginfo(self.tag_entity, self.tag_index);
		self.tag_entity.frame1time = t;
		self.tag_entity.frame = f;
		// untransform v according to this coordinate space
		vector w;
		w_x = v_forward * v;
		w_y = -v_right * v;
		w_z = v_up * v;
		self.angles = vectoangles(w);
	}
	else
	{
		ang_x = -/* don't ask */ang_x;
		self.angles = ang;
	}

	self.colormap = self.owner.colormap;
};

// spawning weaponentity for client
void CL_SpawnWeaponentity()
{
	self.weaponentity = spawn();
	self.weaponentity.classname = "weaponentity";
	self.weaponentity.solid = SOLID_NOT;
	self.weaponentity.owner = self;
	setmodel(self.weaponentity, ""); // precision set when changed
	setorigin(self.weaponentity, '0 0 0');
	self.weaponentity.angles = '0 0 0';
	self.weaponentity.viewmodelforclient = self;
	self.weaponentity.flags = 0;
	self.weaponentity.think = CL_Weaponentity_Think;
	self.weaponentity.customizeentityforclient = CL_Weaponentity_CustomizeEntityForClient;
	self.weaponentity.nextthink = time;

	self.exteriorweaponentity = spawn();
	self.exteriorweaponentity.classname = "exteriorweaponentity";
	self.exteriorweaponentity.solid = SOLID_NOT;
	self.exteriorweaponentity.exteriorweaponentity = self.exteriorweaponentity;
	self.exteriorweaponentity.owner = self;
	setorigin(self.exteriorweaponentity, '0 0 0');
	self.exteriorweaponentity.angles = '0 0 0';
	self.exteriorweaponentity.think = CL_ExteriorWeaponentity_Think;
	self.exteriorweaponentity.nextthink = time;
};

.float hasweapon_complain_spam;

float client_hasweapon(entity cl, float wpn, float andammo, float complain)
{
	local float weaponbit, f;
	local entity oldself;

	if(time < self.hasweapon_complain_spam)
		complain = 0;
	if(complain)
		self.hasweapon_complain_spam = time + 0.2;

	if (wpn < WEP_FIRST || wpn > WEP_LAST)
	{
		if (complain)
			sprint(self, "Invalid weapon\n");
		return FALSE;
	}
	weaponbit = W_WeaponBit(wpn);
	if (cl.weapons & weaponbit)
	{
		if (andammo)
		{
			if(cl.items & IT_UNLIMITED_WEAPON_AMMO)
			{
				f = 1;
			}
			else
			{
				oldself = self;
				self = cl;
				f = weapon_action(wpn, WR_CHECKAMMO1);
				f = f + weapon_action(wpn, WR_CHECKAMMO2);
				self = oldself;
			}
			if (!f)
			{
				if (complain)
				if(clienttype(cl) == CLIENTTYPE_REAL)
				{
					play2(cl, "weapons/unavailable.wav");
					sprint(cl, strcat("You don't have any ammo for the ^2", W_Name(wpn), "\n"));
				}
				return FALSE;
			}
		}
		return TRUE;
	}
	if (complain)
	{
		// DRESK - 3/16/07
		// Report Proper Weapon Status / Modified Weapon Ownership Message
		if(weaponsInMap & weaponbit)
		{
			sprint(cl, strcat("You do not have the ^2", W_Name(wpn), "\n") );

			if(cvar("g_showweaponspawns"))
			{
				entity e;
				string s;

				e = get_weaponinfo(wpn);
				s = e.model2;

				for(e = world; (e = findfloat(e, weapons, weaponbit)); )
				{
					if(e.classname == "droppedweapon")
						continue;
					if not(e.flags & FL_ITEM)
						continue;
					WaypointSprite_Spawn(
						s,
						1, 0,
						world, e.origin,
						self, 0,
						world, enemy,
						0
					);
				}
			}
		}
		else
			sprint(cl, strcat("The ^2", W_Name(wpn), "^7 is ^1NOT AVAILABLE^7 in this map\n") );

		play2(cl, "weapons/unavailable.wav");
	}
	return FALSE;
};

// Weapon subs
void w_clear()
{
	if (self.weapon != -1)
		self.weapon = 0;
	if (self.weaponentity)
	{
		self.weaponentity.state = WS_CLEAR;
		self.weaponentity.effects = 0;
	}
};

void w_ready()
{
	if (self.weaponentity)
		self.weaponentity.state = WS_READY;
	weapon_thinkf(WFRAME_IDLE, 1000000, w_ready);
};

// Setup weapon for client (after this raise frame will be launched)
void weapon_setup(float windex)
{
	entity e;
	qcweaponanimation = cvar("sv_qcweaponanimation");
	e = get_weaponinfo(windex);
	self.items &~= IT_AMMO;
	self.items = self.items | e.items;

	// the two weapon entities will notice this has changed and update their models
	self.weapon = windex;
	self.weaponname = e.mdl;
	self.bulletcounter = 0;
};

// perform weapon to attack (weaponstate and attack_finished check is here)
.float race_penalty;
float weapon_prepareattack(float secondary, float attacktime)
{
	//if sv_ready_restart_after_countdown is set, don't allow the player to shoot
	//if all players readied up and the countdown is running
	if(time < game_starttime || time < self.race_penalty) {
		return FALSE;
	}

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
	if (!weapon_action(self.weapon, WR_CHECKAMMO1 + secondary))
	{
		// hack to ensure it switches to an OTHER weapon (in case the other fire mode still has ammo, we want that anyway)
		float w, ww;
		w = W_WeaponBit(self.weapon);
		self.weapons &~= w;
		ww = w_getbestweapon(self);
		self.weapons |= w;
		if(ww)
			W_SwitchWeapon_Force(self, ww);
		return FALSE;
	}

	if (timeoutStatus == 2) //don't allow the player to shoot while game is paused
		return FALSE;

	// do not even think about shooting if switching
	if(self.switchweapon != self.weapon)
		return FALSE;

	if(attacktime >= 0)
	{
		// don't fire if previous attack is not finished
		if (ATTACK_FINISHED(self) > time + self.weapon_frametime * 0.5)
			return FALSE;
		// don't fire while changing weapon
		if (self.weaponentity.state != WS_READY)
			return FALSE;
	}
	self.weaponentity.state = WS_INUSE;

	self.spawnshieldtime = min(self.spawnshieldtime, time); // kill spawn shield when you fire

	// if the weapon hasn't been firing continuously, reset the timer
	if(attacktime >= 0)
	{
		if (ATTACK_FINISHED(self) < time - self.weapon_frametime * 1.5)
		{
			ATTACK_FINISHED(self) = time;
			//dprint("resetting attack finished to ", ftos(time), "\n");
		}
		ATTACK_FINISHED(self) = ATTACK_FINISHED(self) + attacktime * W_WeaponRateFactor();
	}
	self.bulletcounter += 1;
	//dprint("attack finished ", ftos(ATTACK_FINISHED(self)), "\n");
	return TRUE;
};

void weapon_thinkf(float fr, float t, void() func)
{
	vector a;
	vector of, or, ou;
	float restartanim;

	if(fr == WFRAME_DONTCHANGE)
	{
		fr = self.weaponentity.wframe;
		restartanim = FALSE;
	}
	else if (fr == WFRAME_IDLE)
		restartanim = FALSE;
	else
		restartanim = TRUE;

	of = v_forward;
	or = v_right;
	ou = v_up;

	if (self.weaponentity)
	{
		self.weaponentity.wframe = fr;
		if (qcweaponanimation)
		{
			if (fr != WFRAME_IDLE)
			{
				self.weapon_morph0time = time;
				self.weapon_morph0angles = self.weaponentity.angles;
				self.weapon_morph0origin = self.weaponentity.origin;

				self.weapon_morph1angles = '0 0 0';
				self.weapon_morph1time = time + t;
				makevectors(self.weapon_morph1angles_x * '-1 0 0' + self.weapon_morph1angles_y * '0 1 0' + self.weapon_morph1angles_z * '0 0 1');
				self.weapon_morph1origin = QCWEAPONANIMATION_ORIGIN(self.weaponentity);

				self.weapon_morph2angles = '0 0 0';
				self.weapon_morph2time = time + t;
				makevectors(self.weapon_morph2angles_x * '-1 0 0' + self.weapon_morph2angles_y * '0 1 0' + self.weapon_morph2angles_z * '0 0 1');
				self.weapon_morph2origin = QCWEAPONANIMATION_ORIGIN(self.weaponentity);

				self.weapon_morph3angles = '0 0 0';
				self.weapon_morph3time = time + t;
				makevectors(self.weapon_morph3angles_x * '-1 0 0' + self.weapon_morph3angles_y * '0 1 0' + self.weapon_morph3angles_z * '0 0 1');
				self.weapon_morph3origin = QCWEAPONANIMATION_ORIGIN(self.weaponentity);

				self.weapon_morph4angles = '0 0 0';
				self.weapon_morph4time = time + t;
				makevectors(self.weapon_morph4angles_x * '-1 0 0' + self.weapon_morph4angles_y * '0 1 0' + self.weapon_morph4angles_z * '0 0 1');
				self.weapon_morph4origin = QCWEAPONANIMATION_ORIGIN(self.weaponentity);

				if (fr == WFRAME_FIRE1)
				{
					self.weapon_morph1angles = '5 0 0';
					self.weapon_morph1time = time + t * 0.1;
					makevectors(self.weapon_morph1angles_x * '-1 0 0' + self.weapon_morph1angles_y * '0 1 0' + self.weapon_morph1angles_z * '0 0 1');
					self.weapon_morph1origin = QCWEAPONANIMATION_ORIGIN(self.weaponentity);
					self.weapon_morph4time = time + t + 1; // delay idle effect
				}
				else if (fr == WFRAME_FIRE2)
				{
					self.weapon_morph1angles = '10 0 0';
					self.weapon_morph1time = time + t * 0.1;
					makevectors(self.weapon_morph1angles_x * '-1 0 0' + self.weapon_morph1angles_y * '0 1 0' + self.weapon_morph1angles_z * '0 0 1');
					self.weapon_morph1origin = QCWEAPONANIMATION_ORIGIN(self.weaponentity);
					self.weapon_morph4time = time + t + 1; // delay idle effect
				}
				else if (fr == WFRAME_RELOAD)
				{
					self.weapon_morph1time = time + t * 0.05;
					self.weapon_morph1angles = '-10 40 0';
					makevectors(self.weapon_morph1angles_x * '-1 0 0' + self.weapon_morph1angles_y * '0 1 0' + self.weapon_morph1angles_z * '0 0 1');
					self.weapon_morph1origin = QCWEAPONANIMATION_ORIGIN(self.weaponentity);

					self.weapon_morph2time = time + t * 0.15;
					self.weapon_morph2angles = '-10 40 5';
					makevectors(self.weapon_morph2angles_x * '-1 0 0' + self.weapon_morph2angles_y * '0 1 0' + self.weapon_morph2angles_z * '0 0 1');
					self.weapon_morph2origin = QCWEAPONANIMATION_ORIGIN(self.weaponentity);

					self.weapon_morph3time = time + t * 0.25;
					self.weapon_morph3angles = '-10 40 0';
					makevectors(self.weapon_morph3angles_x * '-1 0 0' + self.weapon_morph3angles_y * '0 1 0' + self.weapon_morph3angles_z * '0 0 1');
					self.weapon_morph3origin = QCWEAPONANIMATION_ORIGIN(self.weaponentity);
				}
			}
		}
		else
		{
			if (fr == WFRAME_IDLE)
				a = self.weaponentity.anim_idle;
			else if (fr == WFRAME_FIRE1)
				a = self.weaponentity.anim_fire1;
			else if (fr == WFRAME_FIRE2)
				a = self.weaponentity.anim_fire2;
			else if (fr == WFRAME_RELOAD)
				a = self.weaponentity.anim_reload;
			a_z *= g_weaponratefactor;
			setanim(self.weaponentity, a, restartanim == FALSE, restartanim, restartanim);
		}
	}

	v_forward = of;
	v_right = or;
	v_up = ou;

	if(self.weapon_think == w_ready && func != w_ready && self.weaponentity.state == WS_RAISE)
	{
		backtrace("Tried to override initial weapon think function - should this really happen?");
	}

	t *= W_WeaponRateFactor();

	// VorteX: haste can be added here
	if (self.weapon_think == w_ready)
	{
		self.weapon_nextthink = time;
		//dprint("started firing at ", ftos(time), "\n");
	}
	if (self.weapon_nextthink < time - self.weapon_frametime * 1.5 || self.weapon_nextthink > time + self.weapon_frametime * 1.5)
	{
		self.weapon_nextthink = time;
		//dprint("reset weapon animation timer at ", ftos(time), "\n");
	}
	self.weapon_nextthink = self.weapon_nextthink + t;
	self.weapon_think = func;
	//dprint("next ", ftos(self.weapon_nextthink), "\n");

	if (restartanim)
	if (t)
	if (!self.crouch) // shoot anim stands up, this looks bad
	{
		local vector anim;
		anim = self.anim_shoot;
		anim_z = anim_y / (t + sys_frametime);
		setanim(self, anim, FALSE, TRUE, TRUE);
	}
};

void weapon_boblayer1(float spd, vector org)
{
	// VorteX: haste can be added here
};

vector W_CalculateProjectileVelocity(vector pvelocity, vector mvelocity)
{
	vector mdirection;
	float mspeed;
	float outspeed;
	float nstyle;
	vector outvelocity;

	mvelocity = mvelocity * g_weaponspeedfactor;

	mdirection = normalize(mvelocity);
	mspeed = vlen(mvelocity);

	nstyle = cvar("g_projectiles_newton_style");
	if(nstyle == 0)
	{
		// absolute velocity
		outvelocity = mvelocity;
	}
	else if(nstyle == 1)
	{
		// true Newtonian projectiles
		outvelocity = pvelocity + mvelocity;
	}
	else if(nstyle == 2)
	{
		// true Newtonian projectiles with automatic aim adjustment
		//
		// solve: |outspeed * mdirection - pvelocity| = mspeed
		// outspeed^2 - 2 * outspeed * (mdirection * pvelocity) + pvelocity^2 - mspeed^2 = 0
		// outspeed = (mdirection * pvelocity) +- sqrt((mdirection * pvelocity)^2 - pvelocity^2 + mspeed^2)
		// PLUS SIGN!
		// not defined?
		// then...
		// pvelocity^2 - (mdirection * pvelocity)^2 > mspeed^2
		// velocity without mdirection component > mspeed
		// fire at smallest possible mspeed that works?
		// |(mdirection * pvelocity) * pvelocity - pvelocity| = mspeed

		vector solution;
		solution = solve_quadratic(1, -2 * (mdirection * pvelocity), pvelocity * pvelocity - mspeed * mspeed);
		if(solution_z)
			outspeed = solution_y; // the larger one
		else
		{
			//outspeed = 0; // slowest possible shot
			outspeed = solution_x; // the real part (that is, the average!)
			//dprint("impossible shot, adjusting\n");
		}

		outspeed = bound(mspeed * cvar("g_projectiles_newton_style_2_minfactor"), outspeed, mspeed * cvar("g_projectiles_newton_style_2_maxfactor"));
		outvelocity = mdirection * outspeed;
	}
	else if(nstyle == 3)
	{
		// pseudo-Newtonian:
		outspeed = mspeed + mdirection * pvelocity;
		outspeed = bound(mspeed * 0.7, outspeed, mspeed * 5.0);
		outvelocity = mdirection * outspeed;
	}
	else if(nstyle == 4)
	{
		// tZorkian:
		outspeed = mspeed + vlen(pvelocity);
		outvelocity = mdirection * outspeed;
	}
	else
		error("g_projectiles_newton_style must be 0 (absolute), 1 (Newtonian), 2 (Newtonian + aimfix), 3 (pseudo Newtonian) or 4 (tZorkian)!");

	return outvelocity;
}

void W_AttachToShotorg(entity flash, vector offset)
{
	entity xflash;
	flash.owner = self;
	flash.angles_z = random() * 360;
	if(qcweaponanimation)
	{
		setorigin(flash, w_shotorg + w_shotdir * 50);
		flash.angles = vectoangles(w_shotdir);
		flash.angles_z = random() * 360;
	}
	else
	{
		setattachment(flash, self.weaponentity, "shot");
		setorigin(flash, offset);

		xflash = spawn();
		copyentity(flash, xflash);

		flash.viewmodelforclient = self;

		if(self.weaponentity.oldorigin_x > 0)
		{
			setattachment(xflash, self.exteriorweaponentity, "");
			setorigin(xflash, self.weaponentity.oldorigin + offset);
		}
		else
		{
			setattachment(xflash, self.exteriorweaponentity, "shot");
		}
	}
}

vector cliptoplane(vector v, vector p)
{
	return v - (v * p) * p;
}

vector solve_cubic_pq(float p, float q)
{
	float D, u, v, a;
	D = q*q/4.0 + p*p*p/27.0;
	if(D < 0)
	{
		// irreducibilis
		a = 1.0/3.0 * acos(-q/2.0 * sqrt(-27.0/(p*p*p)));
		u = sqrt(-4.0/3.0 * p);
		// a in range 0..pi/3
		// cos(a)
		// cos(a + 2pi/3)
		// cos(a + 4pi/3)
		return
			u *
			(
				'1 0 0' * cos(a + 2.0/3.0*M_PI)
				+
				'0 1 0' * cos(a + 4.0/3.0*M_PI)
				+
				'0 0 1' * cos(a)
			);
	}
	else if(D == 0)
	{
		// simple
		if(p == 0)
			return '0 0 0';
		u = 3*q/p;
		v = -u/2;
		if(u >= v)
			return '1 1 0' * v + '0 0 1' * u;
		else
			return '0 1 1' * v + '1 0 0' * u;
	}
	else
	{
		// cardano
		u = cbrt(-q/2.0 + sqrt(D));
		v = cbrt(-q/2.0 - sqrt(D));
		return '1 1 1' * (u + v);
	}
}
vector solve_cubic_abcd(float a, float b, float c, float d)
{
	// y = 3*a*x + b
	// x = (y - b) / 3a
	float p, q;
	vector v;
	p = (9*a*c - 3*b*b);
	q = (27*a*a*d - 9*a*b*c + 2*b*b*b);
	v = solve_cubic_pq(p, q);
	v = (v -  b * '1 1 1') * (1.0 / (3.0 * a));
	if(a < 0)
		v += '1 0 -1' * (v_z - v_x); // swap x, z
	return v;
}

vector findperpendicular(vector v)
{
	vector p;
	p_x = v_z;
	p_y = -v_x;
	p_z = v_y;
	return normalize(cliptoplane(p, v));
}

vector W_CalculateProjectileSpread(vector forward, float spread)
{
	float sigma;
	vector v1, v2;
	float dx, dy, r;
	float sstyle;
	spread *= g_weaponspreadfactor;
	if(spread <= 0)
		return forward;
	sstyle = cvar("g_projectiles_spread_style");
	
	if(sstyle == 0)
	{
		// this is the baseline for the spread value!
		// standard deviation: sqrt(2/5)
		// density function: sqrt(1-r^2)
		return forward + randomvec() * spread;
	}
	else if(sstyle == 1)
	{
		// same thing, basically
		return normalize(forward + cliptoplane(randomvec() * spread, forward));
	}
	else if(sstyle == 2)
	{
		// circle spread... has at sigma=1 a standard deviation of sqrt(1/2)
		sigma = spread * 0.89442719099991587855; // match baseline stddev
		v1 = findperpendicular(forward);
		v2 = cross(forward, v1);
		// random point on unit circle
		dx = random() * 2 * M_PI;
		dy = sin(dx);
		dx = cos(dx);
		// radius in our dist function
		r = random();
		r = sqrt(r);
		return normalize(forward + (v1 * dx + v2 * dy) * r * sigma);
	}
	else if(sstyle == 3) // gauss 3d
	{
		sigma = spread * 0.44721359549996; // match baseline stddev
		// note: 2D gaussian has sqrt(2) times the stddev of 1D, so this factor is right
		v1 = forward;
		v1_x += gsl_ran_gaussian(sigma);
		v1_y += gsl_ran_gaussian(sigma);
		v1_z += gsl_ran_gaussian(sigma);
		return v1;
	}
	else if(sstyle == 4) // gauss 2d
	{
		sigma = spread * 0.44721359549996; // match baseline stddev
		// note: 2D gaussian has sqrt(2) times the stddev of 1D, so this factor is right
		v1_x = gsl_ran_gaussian(sigma);
		v1_y = gsl_ran_gaussian(sigma);
		v1_z = gsl_ran_gaussian(sigma);
		return normalize(forward + cliptoplane(v1, forward));
	}
	else if(sstyle == 5) // 1-r
	{
		sigma = spread * 1.154700538379252; // match baseline stddev
		v1 = findperpendicular(forward);
		v2 = cross(forward, v1);
		// random point on unit circle
		dx = random() * 2 * M_PI;
		dy = sin(dx);
		dx = cos(dx);
		// radius in our dist function
		r = random();
		r = solve_cubic_abcd(-2, 3, 0, -r) * '0 1 0';
		return normalize(forward + (v1 * dx + v2 * dy) * r * sigma);
	}
	else if(sstyle == 6) // 1-r^2
	{
		sigma = spread * 1.095445115010332; // match baseline stddev
		v1 = findperpendicular(forward);
		v2 = cross(forward, v1);
		// random point on unit circle
		dx = random() * 2 * M_PI;
		dy = sin(dx);
		dx = cos(dx);
		// radius in our dist function
		r = random();
		r = sqrt(1 - r);
		r = sqrt(1 - r);
		return normalize(forward + (v1 * dx + v2 * dy) * r * sigma);
	}
	else if(sstyle == 7) // (1-r) (2-r)
	{
		sigma = spread * 1.224744871391589; // match baseline stddev
		v1 = findperpendicular(forward);
		v2 = cross(forward, v1);
		// random point on unit circle
		dx = random() * 2 * M_PI;
		dy = sin(dx);
		dx = cos(dx);
		// radius in our dist function
		r = random();
		r = 1 - sqrt(r);
		r = 1 - sqrt(r);
		return normalize(forward + (v1 * dx + v2 * dy) * r * sigma);
	}
	else
		error("g_projectiles_spread_style must be 0 (sphere), 1 (flattened sphere), 2 (circle), 3 (gauss 3D), 4 (gauss plane), 5 (linear falloff), 6 (quadratic falloff), 7 (stronger falloff)!");
	return '0 0 0';
	/*
	 * how to derive falloff functions:
	 * rho(r) := (2-r) * (1-r);
	 * a : 0;
	 * b : 1;
	 * rhor(r) := r * rho(r);
	 * cr(t) := integrate(rhor(r), r, a, t);
	 * scr(t) := integrate(rhor(r) * r^2, r, a, t);
	 * variance : scr(b) / cr(b);
	 * solve(cr(r) = rand * cr(b), r), programmmode:false;
	 * sqrt(0.4 / variance), numer;
	 */
}

#if 0
float mspercallsum;
float mspercallsstyle;
float mspercallcount;
#endif
void W_SetupProjectileVelocityEx(entity missile, vector dir, vector upDir, float pSpeed, float pUpSpeed, float pZSpeed, float spread)
{
	if(missile.owner == world)
		error("Unowned missile");

	dir = dir + upDir * (pUpSpeed / pSpeed);
	dir_z += pZSpeed / pSpeed;
	pSpeed *= vlen(dir);
	dir = normalize(dir);

#if 0
	if(cvar("g_projectiles_spread_style") != mspercallsstyle)
	{
		mspercallsum = mspercallcount = 0;
		mspercallsstyle = cvar("g_projectiles_spread_style");
	}
	mspercallsum -= gettime(GETTIME_HIRES);
#endif
	dir = W_CalculateProjectileSpread(dir, spread);
#if 0
	mspercallsum += gettime(GETTIME_HIRES);
	mspercallcount += 1;
	print("avg: ", ftos(mspercallcount / mspercallsum), " per sec\n");
#endif

	missile.velocity = W_CalculateProjectileVelocity(missile.owner.velocity, pSpeed * dir);
}

void W_SetupProjectileVelocity(entity missile, float pSpeed, float spread)
{
	W_SetupProjectileVelocityEx(missile, w_shotdir, v_up, pSpeed, 0, 0, spread);
}

#define W_SETUPPROJECTILEVELOCITY_UP(m,s) W_SetupProjectileVelocityEx(m, w_shotdir, v_up, cvar(#s "_speed"), cvar(#s "_speed_up"), cvar(#s "_speed_z"), cvar(#s "_spread"))
#define W_SETUPPROJECTILEVELOCITY(m,s) W_SetupProjectileVelocityEx(m, w_shotdir, v_up, cvar(#s "_speed"), 0, 0, cvar(#s "_spread"))
