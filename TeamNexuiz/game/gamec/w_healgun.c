void() healgun_ready_01;
void() healgun_fire1_01;
void() healgun_deselect_01;
void() healgun_select_01;


float is_ally (entity targ, entity attacker);


float() healgun_check =
{
	return TRUE;
};

void(float req) w_healgun =
{
	if (req == WR_IDLE)
		healgun_ready_01();
	else if (req == WR_FIRE1 || req == WR_FIRE2)
		weapon_prepareattack(healgun_check, healgun_check, healgun_fire1_01, cvar("g_balance_healgun_refire"));
	else if (req == WR_RAISE)
		healgun_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_nails;
	else if (req == WR_DROP)
		healgun_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_HEALGUN, "w_uzi.zym", IT_NAILS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = healgun_check();
};

.float healgun_bulletcounter;
void W_Healgun_Attack (void)
{
	local vector org;
	float selfdrain, targheal, newhp;
	sound (self, CHAN_WEAPON, "weapons/healgun_fire.wav", 1, ATTN_NORM);
	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 8) + (v_forward * 15);

	// this attack_finished just enforces a cooldown at the end of a burst
	self.attack_finished = time + cvar("g_balance_healgun_refire2");

	traceline(org, org + v_forward * cvar("g_balance_healgun_range"), FALSE, self);
	// fixme: need a better visual effect
	// instead, every .5 or 1 seconds send a transluscent glob toward ally or away from enemy (depending on heal/drain)
	// It can use the biorifle glob model I made for now, until someone makes a better one.
	te_beam(self, org, trace_endpos);


	if(trace_ent.classname != "player" && trace_ent.classname != "body")
		return;
	if(is_ally(trace_ent, self)) {
		// heal, drain self
		if(floor(self.health) <= cvar("g_balance_healgun_selfhp_min"))
			return; // can't drain anymore
		if(ceil(trace_ent.health) >= self.max_health*cvar("g_balance_healgun_targhp_maxratio"))
			return; // already fully healed

		targheal = cvar("g_balance_healgun_targheal"); // how much to heal
		selfdrain = cvar("g_balance_healgun_selfdrain"); // how much it costs to heal them
	}
	else {
		// drain, heal self
		// can drain enemy's health even if your health won't increase
		//if(self.health >= self.health * cvar("g_balance_healgun_selfhp_maxratio"))
		//	return; // already fully healed

		targheal = 0 - cvar("g_balance_healgun_targdrain"); // how much to drain from targ
		selfdrain = 0 - cvar("g_balance_healgun_selfheal"); // how much to heal self
	}

	// take health from user, or heal if stealing
	newhp = bound(cvar("g_balance_healgun_selfhp_min"),
					self.health - selfdrain,
					self.max_health * cvar("g_balance_healgun_selfhp_maxratio"));

	self.health = newhp;


	// heal or damage the target
	newhp = bound(5,
					trace_ent.health + targheal,
					cvar("g_balance_healgun_targhp_maxratio"));

	if(newhp < trace_ent.health)
		Damage (trace_ent, self, self, trace_ent.health - newhp, WEP_HEALGUN, trace_endpos, '0 0 0');
	else
		trace_ent.health = newhp;

}
// weapon frames

void()	healgun_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, healgun_ready_01); self.weaponentity.state = WS_READY;};
void()	healgun_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	healgun_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	healgun_fire1_02 =
{
	if (self.button0)
	{
		weapon_doattack(healgun_check, healgun_check, W_Healgun_Attack);
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_healgun_refire"), healgun_fire1_02);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_healgun_refire"), healgun_ready_01);
};
void()	healgun_fire1_01 =
{
	weapon_doattack(healgun_check, healgun_check, W_Healgun_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_healgun_refire"), healgun_fire1_02);
};

