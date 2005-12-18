void MedicSpecial()
{
	sprint(self, "Not done yet\n");
}

void MedicGrenade(float req)
{
	float atk_delay;
	atk_delay = cvar("g_balance_class_medic_grenade_delayattack");
	if(req == WR_GRENADE1)
	{
		if(W_ThrowGrenade(W_PoisonGrenade))
		{
			self.grenade_time = time + cvar("g_balance_grenade_poison_refire");
			// special: medic can't shoot for a while
			if(self.attack_finished < time + atk_delay)
				self.attack_finished = time + atk_delay;
		}
	}
	else if(req == WR_GRENADE2)
	{
		if(W_ThrowGrenade(W_ArmorGrenade))
		{
			self.grenade_time = time + cvar("g_balance_grenade_armor_refire");
			// special: medic can't shoot for a while
			if(self.attack_finished < time + atk_delay)
				self.attack_finished = time + atk_delay;
		}
	}
}

void player_clearpoison(entity targ);

void MedicPreThink()
{
	entity head;
	float maxhpratio, healamt, armoramt, reducestatus, didheal;

	if(self.special_time > time)
		return;
	self.special_time = time + cvar("g_balance_medic_heal_pingrate");

	maxhpratio = cvar("g_balance_medic_heal_max");
	healamt = cvar("g_balance_medic_heal_pingheal");
	armoramt = cvar("g_balance_medic_heal_pingarmor");
	reducestatus = cvar("g_balance_medic_heal_reducestatus");

	head = findradius(self.origin, cvar("g_balance_medic_heal_radius"));
	while(head)
	{
		if(head.team == self.team && head.class != CLASS_MEDIC)// && head != self)
		{
			if(head.classname == "player")
			{
				didheal = 0;
				if(head.health < head.max_health * maxhpratio)
				{
					//bprint(strcat("heal hp ", ftos(head.health)));
					//bprint(strcat(" ", ftos(head.health + healamt)));
					//bprint(strcat(" ", ftos(head.max_health * maxhpratio), "\n"));
					head.health = bound(head.health,
						head.health + healamt,
						head.max_health * maxhpratio);
					//head.health = head.health + healamt;
					//if(head.health > head.max_health * maxhpratio)
					//	head.health = head.max_health * maxhpratio;
					DelayHealthRot(head);
					didheal = 1;
				}
				if(head.armorvalue < head.max_armor * maxhpratio)
				{
					//bprint("heal ar\n");
					head.armorvalue = bound(head.armorvalue,
						head.armorvalue + armoramt,
						head.max_armor * maxhpratio);
					DelayArmorRot(head);
					didheal = 1;
				}
				if(head.poison_damage)
				{
					//bprint("heal poison\n");
					player_clearpoison(head);
					didheal = 1;
				}
				if(head.onfire)
				{
					//bprint("heal fire\n");
					head.onfire.wait = time + (head.onfire.wait - time)*reducestatus;
					didheal = 1;
				}
				if(didheal)
				{
					// visual effect
					te_teleport(head.origin);
				}
			}
		}
		head = head.chain;
	}
}

void MedicPostThink()
{
}

void BecomeMedic(float portion)
{
	self.max_health = cvar("g_balance_class_medic_health") * portion;

	self.max_armor = cvar("g_balance_class_medic_armor") * portion;

	self.mass = cvar("g_balance_class_medic_mass");

	SetPlayerSpeed(self);

	self.items = IT_WEP1 | IT_WEP2 | IT_WEP3 | IT_WEP4;
	self.switchweapon = WEP2;
	self.ammo_shells = floor(20 * portion);
	self.ammo_nails = floor(50 * portion);
	self.ammo_rockets = floor(0 * portion);
	self.ammo_cells = floor(0 * portion);
	self.playerclass = 5;		// TF P.C.
	SetMaxAmmoFor (16);
}
