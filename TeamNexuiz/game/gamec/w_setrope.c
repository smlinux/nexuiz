void() setrope_ready_01;
void() setrope_fire1_01;
void() setrope_deselect_01;
void() setrope_select_01;

float() setrope_check =
{
	return TRUE;
}

void(float req) w_setrope =
{
	if (req == WR_IDLE)
		setrope_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(setrope_check, setrope_check, setrope_fire1_01, cvar("g_balance_setrope_refire"));
	else if (req == WR_RAISE)
		setrope_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = 1;
	else if (req == WR_DROP)
		setrope_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_SETROPE, "w_setrope.zym", 0);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = setrope_check();
}

void RemoveRope()
{
}

void RopeThink()
{
}

void RopeTouch (void)
{
	if (other.classname != "player" || other.health < 1)
		return;
	other.ladder_time = time + 0.1;
	other.ladder_entity = self;
}

void W_SetRope (void)
{
	local entity ropestand, oself;
	local vector org;

	makevectors(self.v_angle);
	org = self.origin + self.view_ofs + v_forward * 15 - v_right * 5 + v_up * -12;

	ropestand = spawn ();
	ropestand.owner = self;
	ropestand.classname = "ropestand";

	ropestand.movetype = MOVETYPE_NONE;
	ropestand.solid = SOLID_BBOX;

	setmodel (ropestand, "models/ropebase.mdl");
	setsize (ropestand, '0 0 0', '0 0 0');
	setorigin (ropestand, org);

	oself = self;
	self = ropestand;
	droptofloor();
	self = oself;

	ropestand.angles = self.angles;
	ropestand.angles_x = ropestand.angles_z = 0;

	//ropestand.touch = RopeStandTouch;
	ropestand.think = RopeExtend;
	ropestand.nextthink = time + 0.1;
}

void()	setrope_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, setrope_ready_01); self.weaponentity.state = WS_READY;};
void()	setrope_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	setrope_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	setrope_fire1_01 =
{
	weapon_doattack(setrope_check, setrope_check, W_SetRope);
	weapon_thinkf(WFRAME_FIRE1, 0.3, setrope_ready_01);
}
