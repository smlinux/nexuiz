void() flamer_ready_01;
void() flamer_fire1_01;
void() flamer_deselect_01;
void() flamer_select_01;

float() flamer_check =
{
	if (self.ammo_nails >= 4)
		return TRUE;
	return FALSE;
};

void(float req) w_flamer =
{
	if (req == WR_IDLE)
		flamer_ready_01();
	else if (req == WR_FIRE1 || req == WR_FIRE2)
		weapon_prepareattack(flamer_check, flamer_check, flamer_fire1_01, .09);
	else if (req == WR_RAISE)
		flamer_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = floor(self.ammo_nails/4);
	else if (req == WR_DROP)
		flamer_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_FLAMER, "w_flamethrower.zym", IT_ROCKETS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = flamer_check();
};

void W_Flamer_Touch (void)
{
	float wasliving, burntime, minburntime, maxburntime;
	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

//	dillute = 1 - 0.65*(1 - self.alpha);
//	dillute = 1 - cvar("g_balance_flamer_dillute")*(self.frame / 20);

	wasliving = other.health;
	if(!self.cnt) // direct damage only if haven't touched once before
	{
		RadiusDamage (self, self.owner, cvar("g_balance_flamer_damage"), cvar("g_balance_flamer_edgedamage"), cvar("g_balance_flamer_radius"), world, cvar("g_balance_flamer_force"), WEP_FLAMER);

		if(other.takedamage == DAMAGE_AIM)//health > 2)
		{ // ignite target or renew fire damage
			burntime = other.onfire.wait - time;
			minburntime = cvar("g_balance_flamer_burntime");
			maxburntime = cvar("g_balance_flamer_burntime_max");
			if(burntime < minburntime)
				burntime = minburntime;
			else
				burntime = burntime + cvar("g_balance_flamer_burntime_inc");

			if(burntime > maxburntime)
				burntime = maxburntime;


			IgniteTarget(other, self.owner,
				burntime,
				cvar("g_balance_flamer_burndamage"),
				cvar("g_balance_flamer_burnrate"),
				TRUE);
		}
	}

	if(wasliving > 2)
		self.cnt = 1; // once it's touched something it can damage, it can't directly damage anymore, or set on fire or renew the flame damage (just for looks)
	self.velocity_x = self.velocity_x * 0.5;
	self.velocity_y = self.velocity_y * 0.5;
}

// fade the flame off, the only way the fire can be destroyed
void W_Flamer_Dissipate ()
{
	if (self.alpha < 0.01 || pointcontents (self.origin) == CONTENT_WATER)// || self.frame >= 20)
	{
		remove(self);
		return;
	}
	self.scale = self.scale + 0.35;//0.2;
	self.alpha = self.alpha - 0.08;//0.04;
	self.frame = self.frame + 1;
	if(self.frame > 20)
		self.frame = 20;
	self.think = W_Flamer_Dissipate;
	self.nextthink = time + 0.1;
	//if(self.colormod_y > 0)
		self.colormod = self.colormod - '0 0.004 0.01' * 25;//'0 0.2 0.12'; // fade to red!
};

void W_Flamer_Attack (void)
{
	local entity missile;
	local vector org;
	local vector end;

	local vector trueaim;
	org = self.origin + self.view_ofs;
	end = self.origin + self.view_ofs + v_forward * 4096;
	traceline(org,end,TRUE,self);
	trueaim = trace_endpos;

	sound (self, CHAN_WEAPON, "weapons/flamer.wav", 1, ATTN_NORM);
	self.ammo_nails = self.ammo_nails - 4;
	org = self.origin + self.view_ofs + v_forward * 1 + v_right * 14 + v_up * -5;

	missile = spawn ();
	missile.owner = self;
	missile.classname = "flame";
	missile.think = W_Flamer_Dissipate;
	missile.nextthink = time + 0.01;
	missile.touch = W_Flamer_Touch;
	missile.solid = SOLID_BBOX;
	setorigin (missile, org);
	setmodel (missile, "models/sprites/hagarexplosion.spr32");
	setsize (missile, '0 0 0', '0 0 0');
	missile.effects = EF_LOWPRECISION | EF_ADDITIVE;
	missile.alpha = 0.7;//0.3;
	missile.scale = 0.005;//0.015;//0.15;
	missile.colormod = '1 1 1'; // set full colors, then reduce later
	missile.frame = random() * 4 + 2;

	missile.movetype = MOVETYPE_BOUNCE;
	missile.gravity = -0.07; // fall lightly up
//	missile.velocity = (v_forward + v_right * crandom() * 0.035 + v_up * crandom() * 0.015) * cvar("g_balance_flamer_speed");
	missile.velocity = normalize(trueaim - org) * cvar("g_balance_flamer_speed");

	missile.angles = vectoangles (missile.velocity);
}

// weapon frames
void()	flamer_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, flamer_ready_01); self.weaponentity.state = WS_READY;};
void()	flamer_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	flamer_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};

void()	flamer_fire1_02 =
{
	if (self.button0 || self.button3)
	{
		weapon_doattack(flamer_check, flamer_check, W_Flamer_Attack);
		weapon_thinkf(WFRAME_FIRE1, 0.09, flamer_fire1_02);
		weapon_prepareattack(flamer_check, flamer_check, SUB_Null, .09);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, 0.09, flamer_ready_01);
};
void()	flamer_fire1_01 =
{
	weapon_doattack(flamer_check, flamer_check, W_Flamer_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.09, flamer_fire1_02);
};
/*
void()	flamer_fire1_01 =
{
	weapon_doattack(flamer_check, flamer_check, W_Flamer_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.003, flamer_ready_01);
	//flamer_ready_01();
};*/

