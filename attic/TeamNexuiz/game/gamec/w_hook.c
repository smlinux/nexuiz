void() grapple_ready_01;
void() grapple_fire1_01;
void() grapple_deselect_01;
void() grapple_select_01;

float() grapple_check =
{
	return TRUE;
}

void(float req) w_grapple =
{
	if (req == WR_IDLE)
		grapple_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(grapple_check, grapple_check, grapple_fire1_01, cvar("g_balance_grapple_refire"));
	else if (req == WR_RAISE)
		grapple_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = 1;
	else if (req == WR_DROP)
		grapple_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_GRAPPLE, "w_grapple.zym", 0);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = grapple_check();
}

void RemoveGrapplingHook(entity pl)
{
	if(pl.hook == world)
		return;
	remove(pl.hook);
	pl.hook = world;
	if(pl.movetype == MOVETYPE_FLY)
		pl.movetype = MOVETYPE_WALK;
}

void GrapplingHookThink()
{
	float spd, dist, minlength, pullspeed, pullspeed2, totalmass, m1, m2, dropspd1, dropspd2;
	vector dir, org, end;

	makevectors(self.owner.v_angle);
	org = self.owner.origin + self.owner.view_ofs + v_forward * 15 - v_right * 5 + v_up * -12;

	traceline(self.origin, org, TRUE, self);
	if(self.owner.health <= 2		// owner died
		|| self.owner.hook != self	// owner fired a different hook
		|| !self.owner.button0		// owner let go of button
		|| trace_fraction < 1)		// owner not visible
	{
		remove(self);
		return;
	}

	self.nextthink = time + 0.1;
	dropspd1 = cvar("sv_gravity") * 0.1; // thinks this often
	dropspd2 = dropspd1;
	if(self.owner.gravity)
		dropspd1 = dropspd1 * self.owner.gravity;
	if(self.enemy.gravity)
		dropspd2 = dropspd2 * self.enemy.gravity;
	self.owner.attack_finished = max(self.owner.attack_finished, time + cvar("g_balance_grapple_refire"));


	// testing
	self.owner.jump_pad = 1;


	if(self.state == 1)
	{
		pullspeed = cvar("g_balance_grapple_pullspeed");
		if(self.enemy != world) // pull both players toward each other at different speeds based on mass
		{
			m1 = self.owner.mass;
			m2 = self.enemy.mass;
			if(m1 <= 0)
				m1 = 1;
			if(m2 <= 0)
				m2 = 1;
			totalmass = m1 + m2;
			pullspeed2 = (m1 / totalmass) * pullspeed;
			pullspeed = (m2 / totalmass) * pullspeed;
		}
		minlength = 50;
		dir = self.origin - org;
		dist = vlen(dir);
		dir = normalize(dir);

		end = self.origin - dir*minlength;
		
		dist = vlen(end - org);

		if(dist < 200 && self.enemy == world)
			spd = dist * (pullspeed / 200);
		else
			spd = pullspeed;
		if(spd < 50)
			spd = 0;

		if(!(dist < 200 && !self.owner.flags & FL_ONGROUND && self.enemy != world))
			self.owner.velocity = dir*spd;
		self.owner.movetype = MOVETYPE_FLY;
		self.owner.flags = self.owner.flags - (self.owner.flags & FL_ONGROUND);

		org = org + dir*50; // get the beam out of the player's eyes

		if(self.enemy != world)
		{
			self.origin = 0.5*(self.enemy.absmin+self.enemy.absmax) + '0 0 10'; // follow enemy's body

			if(dist < 200)
				spd = dist * (pullspeed2 / 200 + 150);
			else
				spd = pullspeed2;
			if(spd < 50)
				spd = 0;


			if(dist < 200 && !self.owner.flags & FL_ONGROUND)
			{
				//self.enemy.velocity = self.enemy.velocity + '0 0 -1'*dropspd1;
				self.owner.velocity = self.owner.velocity + '0 0 -1'*dropspd2; // fake effects of gravity, and don't pull enemy toward me
			}
			else
				self.enemy.velocity = dir * spd * -1;

			if(self.attack_finished < time)
			{
				self.attack_finished = time + cvar("g_balance_grapple_hurtrate");
				Damage (self.enemy, self, self.owner, cvar("g_balance_grapple_damage2"), WEP_GRAPPLE, self.origin, '0 0 0');
			}
			if(self.enemy.health <= 0) // gib the dead player
			{
				Damage (self.enemy, self, self.owner, 100, WEP_GRAPPLE, self.origin, '0 0 0');
				self.enemy = world;
				self.owner.hook = world;
				remove(self);
				return;
			}
		}
	}

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_BEAM);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	//WriteCoord (MSG_BROADCAST, 0);
	//WriteCoord (MSG_BROADCAST, 0);
	//WriteCoord (MSG_BROADCAST, 0);
}

void GrapplingHookTouch (void)
{
	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		RemoveGrapplingHook(self.owner);
		return;
	}

	self.event_damage = SUB_Null; // fixme: ability to dislodge a player by damaging hook?
	sound (self, CHAN_BODY, "weapons/laserimpact.wav", 1, ATTN_NORM);

	self.state = 1;
	self.think = GrapplingHookThink;
	self.nextthink = time + 0.1;
	self.touch = SUB_Null;
	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_NONE;

	if((other.classname == "player" || other.classname == "body") && other.health > 0)
	{
		self.enemy = other;
	}

	Damage (other, self, self.owner, cvar("g_balance_grapple_damage"), WEP_GRAPPLE, self.origin, normalize(self.velocity)*cvar("g_balance_grapple_force"));
}

void FireGrapplingHook (void)
{

	// fixme: drop the CTF flag


	local entity missile;
	local vector org;

	makevectors(self.v_angle);

	sound (self, CHAN_WEAPON, "weapons/lasergun_fire.wav", 1, ATTN_NORM);
	org = self.origin + self.view_ofs + v_forward * 15 - v_right * 5 + v_up * -12;
	te_customflash(org, 160, 0.2, '1 0 0');

	missile = spawn ();
	missile.owner = self;
	self.hook = missile;
	missile.classname = "laserbolt";

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;

	setmodel (missile, "models/ebomb.mdl");//laser.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, org);

	missile.state = 0; // not latched onto anything

	missile.velocity = v_forward * cvar("g_balance_grapple_speed");
	missile.angles = vectoangles (missile.velocity);
	//missile.glow_color = 250; // 244, 250
	//missile.glow_size = 120;
	missile.touch = GrapplingHookTouch;
	missile.think = GrapplingHookThink;
	missile.nextthink = time + 0.1;

	missile.effects = EF_FULLBRIGHT | EF_ADDITIVE | EF_LOWPRECISION;
}

void GrapplingHookFrame()
{
	// if I have no hook or it's not pulling yet, make sure I'm not flying!
	if((self.hook == world || !self.hook.state) && self.movetype == MOVETYPE_FLY && self.health > 2)
	{
		self.movetype = MOVETYPE_WALK;
	}
	if(!self.button0)
	{
		// remove hook, reset movement type
		RemoveGrapplingHook(self);
		return;
	}
	// note: The hook entity does the actual pulling
}

void()	grapple_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, grapple_ready_01); self.weaponentity.state = WS_READY;};
void()	grapple_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	grapple_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	grapple_fire1_01 =
{
	weapon_doattack(grapple_check, grapple_check, FireGrapplingHook);
	weapon_thinkf(WFRAME_FIRE1, 0.3, grapple_ready_01);
}
