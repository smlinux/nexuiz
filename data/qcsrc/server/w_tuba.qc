float Tuba_GetNote(entity pl, float hittype)
{
	float note;
	float movestate;
	print(etos(pl), "\n");
	movestate = 5;
	if(pl.movement_x < 0) movestate -= 3;
	if(pl.movement_x > 0) movestate += 3;
	if(pl.movement_y < 0) movestate -= 1;
	if(pl.movement_y > 0) movestate += 1;
	switch(movestate)
	{
		case 1: note = -6; break; // Gb
		case 2: note = -5; break; // G
		case 3: note = -4; break; // G#
		case 4: note = -1; break; // B
		case 5: note =  0; break; // c
		case 6: note = +2; break; // d
		case 7: note = +3; break; // eb
		case 8: note = +4; break; // e
		case 9: note = +5; break; // e#
	}
	print(ftos(movestate), "\n");
	if(pl.BUTTON_CROUCH)
		note -= 12;
	if(hittype & HITTYPE_SECONDARY)
		note += 7;
	
	// total range of notes:
	//                       0
	//                 ***  ** ****
	//                        ***  ** ****
	//     ***  ** ****
	//            ***  ** ****
	//     -18.........................+12
	return note;
}

void W_Tuba_Attack(float hittype)
{
	W_SetupShot(self, FALSE, 2, "");
	sound(self, CHAN_WEAPON, strcat("weapons/tuba_note", ftos(Tuba_GetNote(self, hittype)), ".wav"), VOL_BASE, cvar("g_balance_tuba_attenuation"));
	RadiusDamage(self, self, cvar("g_balance_tuba_damage"), cvar("g_balance_tuba_edgedamage"), cvar("g_balance_tuba_radius"), world, cvar("g_balance_tuba_force"), hittype | WEP_TUBA, world);
}

void spawnfunc_weapon_tuba (void)
{
	error("The tuba does not work yet. Forget it.");
	weapon_defaultspawnfunc(WEP_TUBA);
}

float w_tuba(float req)
{
	if (req == WR_AIM)
	{
		// bots cannot play the Tuba yet
		// I think they should start with the recorder first
	}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_tuba_refire")))
		{
			W_Tuba_Attack(0);
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_tuba_animtime"), w_ready);
		}
		if (self.BUTTON_ATCK2)
		if (weapon_prepareattack(1, cvar("g_balance_tuba_refire")))
		{
			W_Tuba_Attack(HITTYPE_SECONDARY);
			weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_tuba_animtime"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_tuba.md3");
		precache_model ("models/weapons/v_tuba.md3");
		precache_model ("models/weapons/h_tuba.dpm");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_TUBA);
	else if (req == WR_CHECKAMMO1)
		return TRUE; // TODO use fuel?
	else if (req == WR_CHECKAMMO2)
		return TRUE; // TODO use fuel?
	else if (req == WR_SUICIDEMESSAGE)
	{
		w_deathtypestring = "hurt his own ears";
	}
	else if (req == WR_KILLMESSAGE)
	{
		w_deathtypestring = "died of #'s great playing";
	}
	return TRUE;
};
