void () T_MissileTouch;
void () info_player_start;
void (entity targ, entity attacker) ClientObituary;
void (entity Goal, entity AP, float addb) DoResults;
float (entity Goal, entity AP) Activated;
float (entity targ, entity attacker, float damage) TeamEqualiseDamage;

// Death MSG Caller
float deathmsg;	// Gonna have to make this work with NexTF's

//compiler-satisfying vars (Add these to defs)
.void() th_die;									// Note to self: figure out wtf these 2 do
.void(entity attacker, float damage) th_pain;	////
float skill;	// Skill level. Moot in NexTF (no SP, and bots use some other var)
.float super_damage_finished; //quad damage over <- convert this to work with nex!
entity damage_attacker;
.float immune_to_check;		// as it says
float rj;	// not sure, really..


// COMBAT
void () monster_death_use =
{
	local entity ent;
	local entity otemp;
	local entity stemp;

	if ((self.flags & 1))
	{
		self.flags = (self.flags - 1);
	}
	if ((self.flags & 2))
	{
		self.flags = (self.flags - 2);
	}
	if (!self.target)
	{
		return;
	}
	activator = self.enemy;
	SUB_UseTargets ();
};

float (entity targ, entity inflictor) CanDamage =
{
	if ((targ.movetype == 7))
	{
		traceline (inflictor.origin, (0.5 * (targ.absmin + targ.absmax)), 1, self);
		if ((trace_fraction == 1))
		{
			return (1);
		}
		if ((trace_ent == targ))
		{
			return (1);
		}
		return (0);
	}
	traceline (inflictor.origin, targ.origin, 1, self);
	if ((trace_fraction == 1))
	{
		return (1);
	}
	traceline (inflictor.origin, (targ.origin + '15 15 0'), 1, self);
	if ((trace_fraction == 1))
	{
		return (1);
	}
	traceline (inflictor.origin, (targ.origin + '-15 -15 0'), 1, self);
	if ((trace_fraction == 1))
	{
		return (1);
	}
	traceline (inflictor.origin, (targ.origin + '-15 15 0'), 1, self);
	if ((trace_fraction == 1))
	{
		return (1);
	}
	traceline (inflictor.origin, (targ.origin + '15 -15 0'), 1, self);
	if ((trace_fraction == 1))
	{
		return (1);
	}
	return (0);
};

void (entity targ, entity attacker) Killed =
{
	local entity oself;
	local string db;

	oself = self;
	self = targ;
	if ((self.health < -99))
	{
		self.health = -99;
	}
	if (((self.movetype == 7) || (self.movetype == 0)))
	{
		self.th_die ();
		self = oself;
		return;
	}
	self.enemy = attacker;
	if ((self.flags & 32))
	{
		killed_monsters = (killed_monsters + 1);
		WriteByte (2, 27);
	}
//	ClientObituary (self, attacker);		// causing crash :/
//	Obituary (attacker, targ, deathmsg);
	self.takedamage = 0;
	self.touch = SUB_Null;
	monster_death_use ();
//	self.th_die ();
// (float unnatural_death, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force
	PlayerKilled (0, targ, attacker, 0, deathmsg);
	self = oself;
};

void (entity targ, entity inflictor, entity attacker, float damage) T_Damage =
{
	local vector dir;
	local entity oldself;
	local entity te;
	local float save;
	local float take;

	local float damagearmor;

	if (targ.team_no < 1 && targ.classname != "func_button" && targ.classname != "door")			// TEMP
	{								////
		return;						////
	}								////

	if (!targ.takedamage)
	{
		return;
	}
	if ((attacker.classname == "player"))
	{
		damage = (damage * 0.9);
	}
	if ((attacker.classname == "player"))
	{
		if ((attacker.super_damage_finished > time))
		{
			damage = (damage * 4);
		}
		if (((targ.classname != "player") && (targ.classname != "bot")))
		{
			if (!Activated (targ, attacker))
			{
				if ((targ.else_goal != 0))
				{
					te = Findgoal (targ.else_goal);
					if (te)
					{
						AttemptToActivate (te, attacker, targ);
					}
				}
				return;
			}
		}
	}
	damage_attacker = attacker;
	if ((teamplay & (64 | 32)))
	{
		damage = TeamEqualiseDamage (targ, attacker, damage);
	}
	save = ceil ((targ.armortype * damage));
	if ((save >= targ.armorvalue))
	{
		save = targ.armorvalue;
		targ.armortype = 0;
		targ.armorclass = 0;
		targ.items = (targ.items - (targ.items & ((8192 | 16384) | 32768)));
	}

	targ.armorvalue = (targ.armorvalue - save);
	take = ceil ((damage - save));
	if ((targ.flags & 8))
	{
		targ.dmg_take = (targ.dmg_take + take);
		targ.dmg_save = (targ.dmg_save + save);
		targ.dmg_inflictor = inflictor;
	}
	if (((inflictor != world) && (targ.movetype == 3)))
	{
		targ.immune_to_check = (time + (damage / 20));
		dir = (targ.origin - ((inflictor.absmin + inflictor.absmax) * 0.5));
		dir = normalize (dir);
		if ((((damage < 60) & ((attacker.classname == "player") & (targ.classname == "player"))) & (attacker.netname != targ.netname)))
		{
			targ.velocity = (targ.velocity + ((dir * damage) * 11));
		}
		else
		{
			targ.velocity = (targ.velocity + ((dir * damage) * 8));
		}
		if ((((rj > 1) & ((attacker.classname == "player") & (targ.classname == "player"))) & (attacker.netname == targ.netname)))
		{
			targ.velocity = (targ.velocity + ((dir * damage) * rj));
		}
	}
	if ((targ.flags & 64))
	{
		return;
	}
	if ((targ.invincible_finished >= time))
	{
		if ((self.invincible_sound < time))
		{
			sound (targ, 3, "items/protect3.wav", 1, 1);
			self.invincible_sound = (time + 2);
		}
		return;
	}
	if (((attacker.classname == "player") && ((targ.classname == "player") || (targ.classname == "building_sentrygun"))))
	{
		if ((((targ.team_no > 0) && (targ.team_no == attacker.team_no)) && (targ != attacker)))
		{
			if ((teamplay & 16))
			{
				return;
			}
			else
			{
				if ((teamplay & 8))
				{
					take = (take / 2);
				}
			}
		}
	}

	//			MOVED HERE FROM PlayerDamage -- need to port the rest
	// how much damage to deal to armor
	damagearmor = bound(0, damage * 0.2 * (targ.armorvalue / 50) * cvar("g_balance_armor_takedamage"), targ.armorvalue);
	// how much damage armor blocks
	save = bound(0, damage * (targ.armorvalue / 100) * cvar("g_balance_armor_effectiveness"), damage);
	// how much damage to deal to player
	take = bound(0, damage - save, damage);
	targ.armorvalue = targ.armorvalue - damagearmor;
	DelayArmorRegen(targ);

	if (((take < 1) && (take != 0)))
	{
		take = 1;
	}
	targ.health = (targ.health - take);
	if ((targ.armorvalue < 1))
	{
		targ.armorclass = 0;
		targ.armorvalue = 0;
	}
	if ((targ.health <= 0))
	{
		Killed (targ, attacker);
		return;
	}
	oldself = self;
	self = targ;
	if (self.th_pain)
	{
		self.th_pain (attacker, take);
		if ((skill >= 3))
		{
			self.pain_finished = (time + 5);
		}
	}
	self = oldself;
};

void (entity targ, entity inflictor, entity attacker, float damage, float T_flags, float T_AttackType) TF_T_Damage =
{
	local vector dir;
	local entity oldself;
	local entity te;
	local float save;
	local float take;
	local float olddmsg;
	local float no_damage;
	local float moment;

	if (targ.team_no < 1 && targ.classname != "func_button" && targ.classname != "door")			// TEMP
	{								////
		return;						////
	}								////
	if ((targ.takedamage == 0))
	{
		return;
	}
	if ((T_AttackType & 256))
	{
		targ.health = damage;
		return;
	}
	/*if (cease_fire) // this aint needed
	{
		return;
	}*/
	no_damage = 0;
	if ((attacker.classname == "player"))
	{
		damage = (damage * 0.9);
		if ((attacker.super_damage_finished > time))
		{
			damage = (damage * 4);
		}
		if (((((((targ.classname != "player") && (targ.classname != "bot")) && (targ.classname != "building_sentrygun")) && (targ.classname != "building_dispenser")) && (targ.classname != "building_teleporter_entrance")) && (targ.classname != "building_teleporter_exit")))
		{
			if (!Activated (targ, attacker))
			{
				if ((targ.else_goal != 0))
				{
					te = Findgoal (targ.else_goal);
					if (te)
					{
						AttemptToActivate (te, attacker, targ);
					}
				}
				return;
			}
		}
	}
	damage_attacker = attacker;
	if ((teamplay & (64 | 32)))
	{
		damage = TeamEqualiseDamage (targ, attacker, damage);
	}
	if (((targ.armorclass != 0) && (T_AttackType != 0)))
	{
		if (((targ.armorclass & 1) && (T_AttackType & 1)))
		{
			damage = floor ((damage * 0.5));
		}
		if (((targ.armorclass & 2) && (T_AttackType & 2)))
		{
			damage = floor ((damage * 0.5));
		}
		if (((targ.armorclass & 4) && (T_AttackType & 4)))
		{
			damage = floor ((damage * 0.5));
		}
		if (((targ.armorclass & 8) && (T_AttackType & 8)))
		{
			damage = floor ((damage * 0.5));
		}
		if (((targ.armorclass & 16) && (T_AttackType & 16)))
		{
			damage = floor ((damage * 0.5));
		}
	}
	if ((T_flags & 1))
	{
		take = damage;
		save = 0;
	}
	else
	{
		save = ceil ((targ.armortype * damage));
		if ((((((attacker.classname == "player") && (targ.team_no > 0)) && (targ.team_no == attacker.team_no)) && (targ != attacker)) && (T_flags & 2)))
		{
			if ((T_AttackType & 4))
			{
				if ((teamplay & 1024))
				{
					save = 0;
				}
				else
				{
					if ((teamplay & 512))
					{
						save = (save / 2);
					}
				}
			}
			else
			{
				if ((teamplay & 256))
				{
					save = 0;
				}
				else
				{
					if ((teamplay & 128))
					{
						save = (save / 2);
					}
				}
			}
		}
		if ((save >= targ.armorvalue))
		{
			save = targ.armorvalue;
			targ.armortype = 0;
			targ.armorclass = 0;
			targ.items = (targ.items - (targ.items & ((8192 | 16384) | 32768)));
		}
		targ.armorvalue = (targ.armorvalue - save);
		take = ceil ((damage - save));
	}
	if ((targ.flags & 8))
	{
		targ.dmg_take = (targ.dmg_take + take);
		targ.dmg_save = (targ.dmg_save + save);
		targ.dmg_inflictor = inflictor;
	}
	if ((((inflictor != world) && (targ.movetype == 3)) && !(targ.tfstate & 65536)))
	{
		if ((deathmsg != 9))
		{
			targ.immune_to_check = (time + (damage / 20));
			dir = (targ.origin - ((inflictor.absmin + inflictor.absmax) * 0.5));
			dir = normalize (dir);
			/*if ((targ.class == 6)) // moot function -- NexTF doesnt have an HWGuy
			{
				moment = (damage / 4);
				if ((damage <= 50))
				{
					moment = 0;
				}
			}
			else*/
			{
				moment = damage;
			}
			if ((((moment < 60) && ((attacker.classname == "player") && (targ.classname == "player"))) && (attacker.netname != targ.netname)))
			{
				targ.velocity = (targ.velocity + ((dir * moment) * 11));
			}
			else
			{
				targ.velocity = (targ.velocity + ((dir * moment) * 8));
			}
			if ((((rj > 1) && ((attacker.classname == "player") && (targ.classname == "player"))) && (attacker.netname == targ.netname)))
			{
				targ.velocity = (targ.velocity + ((dir * moment) * rj));
			}
		}
	}
	if ((targ.flags & 64))
	{
		return;
	}
	if ((targ.invincible_finished >= time))
	{
		if ((self.invincible_sound < time))
		{
			sound (targ, 3, "items/protect3.wav", 1, 1);
			self.invincible_sound = (time + 2);
		}
		return;
	}
	if (((attacker.classname == "player") && (((((targ.classname == "player") || (targ.classname == "building_sentrygun")) || (targ.classname == "building_dispenser")) || (targ.classname == "building_teleporter_entrance")) || (targ.classname == "building_teleporter_exit"))))
	{
		if (((((targ.team_no > 0) && (targ.team_no == attacker.team_no)) && (targ != attacker)) && (T_flags & 2)))
		{
			if ((T_AttackType & 4))
			{
				if ((teamplay & 16))
				{
					no_damage = 1;
				}
				else
				{
					if ((teamplay & 8))
					{
						take = (take / 2);
					}
				}
			}
			else
			{
				if ((teamplay & 4))
				{
					no_damage = 1;
				}
				else
				{
					if ((teamplay & 2))
					{
						take = (take / 2);
					}
				}
			}
		}
	}
	if ((T_flags & 4))
	{
		if ((targ == attacker))
		{
			return;
		}
	}

	local float damagearmor;
	//			MOVED HERE FROM PlayerDamage -- need to port the rest
	// how much damage to deal to armor
	damagearmor = bound(0, damage * 0.2 * (targ.armorvalue / 50) * cvar("g_balance_armor_takedamage"), targ.armorvalue);
	// how much damage armor blocks
	save = bound(0, damage * (targ.armorvalue / 100) * cvar("g_balance_armor_effectiveness"), damage);
	// how much damage to deal to player
	take = bound(0, damage - save, damage);
	targ.armorvalue = targ.armorvalue - damagearmor;
	DelayArmorRegen(targ);

	if ((take < 1))
	{
		take = 1;
	}
	take = rint (take);
	if ((no_damage == 0))
	{
		targ.health = (targ.health - take);
	}
	if (((attacker.classname == "player") && (((((targ.classname == "player") || (targ.classname == "building_sentrygun")) || (targ.classname == "building_dispenser")) || (targ.classname == "building_teleporter_entrance")) || (targ.classname == "building_teleporter_exit"))))
	{
		if (((((targ.team_no > 0) && (targ.team_no == attacker.team_no)) && (targ != attacker)) && (T_flags & 2)))
		{
			olddmsg = deathmsg;
			if ((T_AttackType & 4))
			{
				deathmsg = 37;
				if ((teamplay & 16384))
				{
					TF_T_Damage (attacker, world, world, take, 1, 0);
				}
				else
				{
					if ((teamplay & 8192))
					{
						TF_T_Damage (attacker, world, world, (take / 2), 1, 0);
					}
				}
			}
			else
			{
				deathmsg = 37;
				if ((teamplay & 4096))
				{
					TF_T_Damage (attacker, world, world, take, 1, 0);
				}
				else
				{
					if ((teamplay & 2048))
					{
						TF_T_Damage (attacker, world, world, (take / 2), 1, 0);
					}
				}
			}
			deathmsg = olddmsg;
		}
	}
	if ((no_damage == 1))
	{
		return;
	}
	if ((targ.armorvalue < 1))
	{
		targ.armorclass = 0;
		targ.armorvalue = 0;
	}
	if ((targ.health <= 0))
	{
		if ((((inflictor.classname == "detpack") && (inflictor.weaponmode == 1)) && (inflictor.enemy == targ)))
		{
			deathmsg = 16;
		}
		Killed (targ, attacker);
		return;
	}
	oldself = self;
	self = targ;
	if (self.th_pain)
	{
		self.th_pain (attacker, take);
		if ((skill >= 3))
		{
			self.pain_finished = (time + 5);
		}
	}
	self = oldself;
};

void (entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local float points;
	local entity head;
	local entity te;
	local vector org;							////

	head = findradius (inflictor.origin, (damage + 40));
	while (head)
	{
		if ((head != ignore))
		{
			if (head.takedamage)
			{
				org = (head.origin + ((head.mins + head.maxs) * 0.5));
				points = (0.5 * vlen ((inflictor.origin - org)));
				if ((points < 0))
				{
					points = 0;
				}
				points = (damage - points);
				if ((head == attacker))
				{
					points = (points * 0.75);
				}
				if ((points > 0))
				{
					if (CanDamage (head, inflictor))
					{
						if ((head.classname == "monster_shambler"))
						{
							T_Damage (head, inflictor, attacker, (points * 0.5));
						}
						else
						{
							TF_T_Damage (head, inflictor, attacker, points, 2, 4);
						}
					}
				}
			}
		}
		head = head.chain;
	}
};
