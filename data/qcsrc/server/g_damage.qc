
float checkrules_firstblood;

float yoda;

float IsDifferentTeam(entity a, entity b)
{
	if(teams_matter)
	{
		if(a.team == b.team)
			return 0;
	}
	else
	{
		if(a == b)
			return 0;
	}
	return 1;
}

float IsFlying(entity a)
{
	if(a.flags & FL_ONGROUND)
		return 0;
	if(a.waterlevel >= 2)
		return 0;
	traceline(a.origin, a.origin - '0 0 48', MOVE_NORMAL, a);
	if(trace_fraction < 1)
		return 0;
	return 1;
}

void UpdateFrags(entity player, float f)
{
	PlayerTeamScore_AddScore(player, f);
}

void GiveFrags (entity attacker, entity targ, float f)
{
	// TODO route through PlayerScores instead
	if(gameover) return;

	if(f < 0)
	{
		if(targ == attacker)
		{
			// suicide
			PlayerScore_Add(attacker, SP_SUICIDES, 1);
		}
		else
		{
			// teamkill
			PlayerScore_Add(attacker, SP_KILLS, -1); // or maybe add a teamkills field?
		}
	}
	else
	{
		// regular frag
		PlayerScore_Add(attacker, SP_KILLS, 1);
	}

	PlayerScore_Add(targ, SP_DEATHS, 1);

	if(g_arena)
		if(cvar("g_arena_roundbased"))
			return;

	// FIXME fix the mess this is (we have REAL points now!)
	if(g_runematch)
	{
		f = RunematchHandleFrags(attacker, targ, f);
	}
	else if(g_keyhunt)
	{
		f = kh_HandleFrags(attacker, targ, f);
	}
	else if(g_lms)
	{
		// remove a life
		float tl;
		tl = PlayerScore_Add(targ, SP_LMS_LIVES, -1);
		if(tl < lms_lowest_lives)
			lms_lowest_lives = tl;
		if(tl <= 0)
		{
			if(!lms_next_place)
				lms_next_place = player_count;
			PlayerScore_Add(targ, SP_LMS_RANK, lms_next_place); // won't ever spawn again
			--lms_next_place;
		}
		f = 0;
	}

	attacker.totalfrags += f;

	if(f)
		UpdateFrags(attacker, f);
}

string AppendItemcodes(string s, entity player)
{
	float w;
	w = player.weapon;
	//if(w == 0)
	//	w = player.switchweapon;
	if(w == 0)
		w = player.cnt; // previous weapon!
	s = strcat(s, ftos(W_ItemCode(w)));
	if(time < player.strength_finished)
		s = strcat(s, "S");
	if(time < player.invincible_finished)
		s = strcat(s, "I");
	if(player.flagcarried != world)
		s = strcat(s, "F");
	if(player.BUTTON_CHAT)
		s = strcat(s, "T");
	if(player.kh_next)
		s = strcat(s, "K");
	if(player.runes)
		s = strcat(s, "|", ftos(player.runes));
	return s;
}

void LogDeath(string mode, float deathtype, entity killer, entity killed)
{
	string s;
	if(!cvar("sv_eventlog"))
		return;
	s = strcat(":kill:", mode);
	s = strcat(s, ":", ftos(killer.playerid));
	s = strcat(s, ":", ftos(killed.playerid));
	s = strcat(s, ":type=", ftos(deathtype));
	s = strcat(s, ":items=");
	s = AppendItemcodes(s, killer);
	if(killed != killer)
	{
		s = strcat(s, ":victimitems=");
		s = AppendItemcodes(s, killed);
	}
	GameLogEcho(s, FALSE);
}

void Obituary (entity attacker, entity targ, float deathtype)
{
	string	s, a;

	if (targ.classname == "player" || targ.classname == "corpse")
	{
		if (targ.classname == "corpse")
			s = "A corpse";
		else
			s = targ.netname;
		a = attacker.netname;

		if (targ == attacker)
		{
			if (deathtype == DEATH_TEAMCHANGE) {
				centerprint(targ, strcat("You are now on: ", ColoredTeamName(targ.team)));
			} else if (deathtype == DEATH_AUTOTEAMCHANGE) {
				centerprint(targ, strcat("You have been moved into a different team to improve team balance\nYou are now on: ", ColoredTeamName(targ.team)));
				return;
			} else if (deathtype == DEATH_CAMP) {
				if(sv_gentle)
					centerprint(targ, "^1Reconsider your tactics, camper!\n\n\n");
				else
					centerprint(targ, "^1Die camper!\n\n\n");
			} else if (deathtype == DEATH_NOAMMO) {
				if(sv_gentle)
					centerprint(targ, "^1You are reinserted into the game for running out of ammo...\n\n\n");
				else
					centerprint(targ, "^1You were killed for running out of ammo...\n\n\n");
			} else if (deathtype == DEATH_ROT) {
				if(sv_gentle)
					centerprint(targ, "^1You need to preserve your health\n\n\n");
				else
					centerprint(targ, "^1You grew too old without taking your medicine\n\n\n");
			} else if (deathtype == DEATH_MIRRORDAMAGE) {
				if(sv_gentle)
					centerprint(targ, "^1Don't go against team mates!\n\n\n");
				else
					centerprint(targ, "^1Don't shoot your team mates!\n\n\n");
			} else {
				if(sv_gentle)
					centerprint(targ, "^1You need to be more careful!\n\n\n");
				else
					centerprint(targ, "^1You killed your own dumb self!\n\n\n");
			}

			if(sv_gentle) {
				if (deathtype == DEATH_CAMP)
					bprint ("^1",s, "^1 thought he found a nice camping ground\n");
				else if (deathtype == DEATH_MIRRORDAMAGE)
					bprint ("^1",s, "^1 didn't become friends with the Lord of Teamplay\n");
				else
					bprint ("^1",s, "^1 will be reinserted into the game due to his own actions\n");

				if(deathtype != DEATH_TEAMCHANGE)
				{
					LogDeath("suicide", deathtype, targ, targ);
					GiveFrags(attacker, targ, -1);
				}
				if (targ.killcount > 2)
					bprint ("^1",s,"^1 ended it all with a ",ftos(targ.killcount)," scoring spree\n");
			} else {

				if (deathtype == IT_GRENADE_LAUNCHER)
					bprint ("^1",s, "^1 detonated\n");
				else if (deathtype == IT_ELECTRO)
					bprint ("^1",s, "^1 played with plasma\n");
				else if (deathtype == IT_ROCKET_LAUNCHER)
					bprint ("^1",s, "^1 exploded\n");
				else if (deathtype == DEATH_KILL)
					bprint ("^1",s, "^1 couldn't take it anymore\n");
				else if (deathtype == DEATH_ROT)
					bprint ("^1",s, "^1 died\n");
				else if (deathtype == DEATH_NOAMMO)
				{
					bprint ("^7",s, " ^7committed suicide. What's the point of living without ammo?\n");
				}
				else if (deathtype == DEATH_CAMP)
					bprint ("^1",s, "^1 thought he found a nice camping ground\n");
				else if (deathtype == DEATH_MIRRORDAMAGE)
					bprint ("^1",s, "^1 didn't become friends with the Lord of Teamplay\n");
				else if (deathtype != DEATH_TEAMCHANGE)
					bprint ("^1",s, "^1 couldn't resist the urge to self-destruct\n");

				if(deathtype != DEATH_TEAMCHANGE)
				{
					LogDeath("suicide", deathtype, targ, targ);
					GiveFrags(attacker, targ, -1);
				}
				if (targ.killcount > 2)
					bprint ("^1",s,"^1 ended it all with a ",ftos(targ.killcount)," kill spree\n");
			}
		}
		else if (attacker.classname == "player" || attacker.classname == "gib")
		{
			if(teamplay && attacker.team == targ.team)
			{
				if(sv_gentle) {
					centerprint(attacker, "^1Moron! You went against a teammate!\n\n\n");
					bprint ("^1", a, "^1 took action against a teammate\n");
				} else {
					centerprint(attacker, "^1Moron! You fragged a teammate!\n\n\n");
					bprint ("^1", a, "^1 mows down a teammate\n");
				}
				GiveFrags(attacker, targ, -1);
				if (targ.killcount > 2) {
					if(sv_gentle)
						bprint ("^1",s,"'s ^1",ftos(targ.killcount)," scoring spree was ended by a teammate!\n");
					else
						bprint ("^1",s,"'s ^1",ftos(targ.killcount)," kill spree was ended by a teammate!\n");
				}
				if (attacker.killcount > 2) {
					if(sv_gentle)
						bprint ("^1",a,"^1 ended a ",ftos(attacker.killcount)," scoring spree by going against a teammate\n");
					else
						bprint ("^1",a,"^1 ended a ",ftos(attacker.killcount)," kill spree by killing a teammate\n");
				}
				attacker.killcount = 0;

				LogDeath("tk", deathtype, attacker, targ);
			}
			else
			{
				if (!checkrules_firstblood)
				{
					checkrules_firstblood = TRUE;
					if(sv_gentle)
						bprint("^1",a, "^1 was the first to score", "\n");
					else
						bprint("^1",a, "^1 drew first blood", "\n");
				}

				if(sv_gentle > 0) {
					centerprint(attacker, strcat("^4You scored against ^7", s, "\n\n\n"));
					centerprint(targ, strcat(a,"^1 scored against you ^7\n\n\n"));
				} else {
					centerprint(attacker, strcat("^4You fragged ^7", s, "\n\n\n"));
					centerprint(targ, strcat("^1You were fragged by ^7", a, "\n\n\n"));
				}

				if(sv_gentle) {
					bprint ("^1",s, "^1 needs a restart thanks to ", a, "\n");
				} else {
					if (deathtype == IT_LASER)
						bprint ("^1",s, "^1 was blasted by ", a, "\n");
					else if (deathtype == IT_UZI)
						bprint ("^1",s, "^1 was riddled full of holes by ", a, "\n");
					else if (deathtype == IT_SHOTGUN)
						bprint ("^1",s, "^1 was gunned by ", a, "\n");
					else if (deathtype == IT_GRENADE_LAUNCHER)
						bprint ("^1", s, "^1 was blasted by ", a, "\n");
					else if (deathtype == IT_ELECTRO)
						bprint ("^1",s, "^1 was blasted by ", a, "\n");
					else if (deathtype == IT_CRYLINK)
						bprint ("^1",s, "^1 was blasted by ", a, "\n");
					else if (deathtype == IT_NEX)
						bprint ("^1",s, "^1 has been vaporized by ", a, "\n");
					else if (deathtype == IT_HAGAR)
						bprint ("^1",s, "^1 was pummeled by ", a, "\n");
					else if (deathtype == IT_ROCKET_LAUNCHER)
						bprint ("^1",s, "^1 was blasted by ", a, "\n");
					else if (deathtype == DEATH_TELEFRAG)
						bprint ("^1",s, "^1 was telefragged by ", a, "\n");
					else if (deathtype == DEATH_DROWN)
						bprint ("^1",s, "^1 was drowned by ", a, "\n");
					else if (deathtype == DEATH_SLIME)
						bprint ("^1",s, "^1 was slimed by ", a, "\n");
					else if (deathtype == DEATH_LAVA)
						bprint ("^1",s, "^1 was cooked by ", a, "\n");
					else if (deathtype == DEATH_FALL)
						bprint ("^1",s, "^1 was grounded by ", a, "\n");
					else if (deathtype == DEATH_SHOOTING_STAR)
						bprint ("^1",s, "^1 was shot into space by ", a, "\n");
					else if (deathtype == DEATH_SWAMP)
						bprint ("^1",s, "^1 was conserved by ", a, "\n");
					else if (deathtype == DEATH_HURTTRIGGER)
						bprint ("^1",s, "^1 was thrown into a world of hurt by ", a, "\n");
                    else if(deathtype == DEATH_TURRET)
                        bprint ("^1",s, "^1 was pushed into the line of fire by ^1", a, "\n");
					else
						bprint ("^1",s, "^1 was fragged by ", a, "\n");
				}
				if(g_ctf && targ.flagcarried)
				{
					GiveFrags(attacker, targ, cvar("g_ctf_flagscore_kill"));
					PlayerScore_Add(attacker, SP_CTF_FCKILLS, 1);
				}
				else
					GiveFrags(attacker, targ, 1);
				if (targ.killcount > 2) {
					if(sv_gentle)
						bprint ("^1",s,"'s ^1", ftos(targ.killcount), " scoring spree was ended by ", a, "\n");
					else
						bprint ("^1",s,"'s ^1", ftos(targ.killcount), " kill spree was ended by ", a, "\n");
				}
				attacker.killcount = attacker.killcount + 1;
				if (attacker.killcount > 2) {
					if(sv_gentle)
						bprint ("^1",a,"^1 made ",ftos(attacker.killcount)," scores in a row\n");
					else
						bprint ("^1",a,"^1 has ",ftos(attacker.killcount)," frags in a row\n");
				}

				LogDeath("frag", deathtype, attacker, targ);

				if (attacker.killcount == 3)
				{
					if(sv_gentle) {
						bprint (a,"^7 made a ^1TRIPLE SCORE\n");
					} else {
						bprint (a,"^7 made a ^1TRIPLE FRAG\n");
						announce(attacker, "announcer/male/03kills.ogg");
					}
				}
				else if (attacker.killcount == 5)
				{
					if(sv_gentle) {
						bprint (a,"^7 unleashes ^1SCORING RAGE\n");
					} else {
						bprint (a,"^7 unleashes ^1RAGE\n");
						announce(attacker, "announcer/male/05kills.ogg");
					}
				}
				else if (attacker.killcount == 10)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1TEN SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 starts the ^1MASSACRE!\n");
						announce(attacker, "announcer/male/10kills.ogg");
					}
				}
				else if (attacker.killcount == 15)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1FIFTEEN SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 executes ^1MAYHEM!\n");
						announce(attacker, "announcer/male/15kills.ogg");
					}
				}
				else if (attacker.killcount == 20)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1TWENTY SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 is a ^1BERSERKER!\n");
						announce(attacker, "announcer/male/20kills.ogg");
					}
				}
				else if (attacker.killcount == 25)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1TWENTY FIFE SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 inflicts ^1CARNAGE!\n");
						announce(attacker, "announcer/male/25kills.ogg");
					}
				}
				else if (attacker.killcount == 30)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1THIRTY SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 unleashes ^1ARMAGEDDON!\n");
						announce(attacker, "announcer/male/30kills.ogg");
					}
				}
			}
		}
		else
		{
			centerprint(targ, "^1Watch your step!\n\n\n");
			if (deathtype == DEATH_HURTTRIGGER && attacker.message != "")
				bprint ("^1",s, "^1 ", attacker.message, "\n");
			else if (deathtype == DEATH_DROWN)
				if(sv_gentle)
					bprint ("^1",s, "^1 was in the water for too long\n");
				else
					bprint ("^1",s, "^1 drowned\n");
			else if (deathtype == DEATH_SLIME)
				bprint ("^1",s, "^1 was slimed\n");
			else if (deathtype == DEATH_LAVA)
				if(sv_gentle)
					bprint ("^1",s, "^1 found a hot place\n");
				else
					bprint ("^1",s, "^1 turned into hot slag\n");
			else if (deathtype == DEATH_FALL)
				if(sv_gentle)
					bprint ("^1",s, "^1 tested gravity (and it worked)\n");
				else
					bprint ("^1",s, "^1 hit the ground with a crunch\n");
			else if (deathtype == DEATH_SHOOTING_STAR)
				bprint ("^1",s, "^1 became a shooting star\n");
			else if (deathtype == DEATH_SWAMP)
				if(sv_gentle)
					bprint ("^1",s, "^1 discovered a swamp\n");
				else
					bprint ("^1",s, "^1 is now conserved for centuries to come\n");
            else if(deathtype == DEATH_TURRET)
                    bprint ("^1",s, "^1 was mowed down by a turret \n");
			else
				if(sv_gentle)
					bprint ("^1",s, "^1 needs a restart\n");
				else
					bprint ("^1",s, "^1 died\n");
			GiveFrags(targ, targ, -1);
			if(PlayerScore_Add(targ, SP_SCORE, 0) == -5) {
				announce(targ, "announcer/male/botlike.ogg");
			}

			if (targ.killcount > 2)
				if(sv_gentle)
					bprint ("^1",s,"^1 needs a restart after a ",ftos(targ.killcount)," scoring spree\n");
				else
					bprint ("^1",s,"^1 died with a ",ftos(targ.killcount)," kill spree\n");

			LogDeath("accident", deathtype, targ, targ);
		}
		targ.death_origin = targ.origin;
		if(targ != attacker)
			targ.killer_origin = attacker.origin;
		// FIXME: this should go in PutClientInServer
		if (targ.killcount)
			targ.killcount = 0;
	}
}

// these are updated by each Damage call for use in button triggering and such
entity damage_targ;
entity damage_inflictor;
entity damage_attacker;

void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	float mirrordamage;
	float mirrorforce;
	entity attacker_save;
	mirrordamage = 0;
	mirrorforce = 0;

	if (gameover || targ.killcount == -666)
		return;

	local entity oldself;
	oldself = self;
	self = targ;
        damage_targ = targ;
        damage_inflictor = inflictor;
        damage_attacker = attacker;
		attacker_save = attacker;

	if(deathtype == DEATH_KILL || deathtype == DEATH_TEAMCHANGE || deathtype == DEATH_AUTOTEAMCHANGE)
	{
		// These are ALWAYS lethal
		// No damage modification here
		// Instead, prepare the victim for his death...
		targ.armorvalue = 0;
		targ.spawnshieldtime = 0;
		targ.health = 0.9; // this is < 1
		targ.flags -= targ.flags & FL_GODMODE;
		damage = 100000;
	}
	else
	{
		if (targ.classname == "player")
		if (attacker.classname == "player")
		if (!targ.isbot)
		if (attacker.isbot)
			damage = damage * bound(0.1, (skill + 5) * 0.1, 1);

		// nullify damage if teamplay is on
		if(deathtype != DEATH_TELEFRAG)
		if(attacker.team == targ.team)
		if(attacker.classname == "player")
		{
			if(teamplay == 1)
				damage = 0;
			else if(attacker != targ)
			{
				if(teamplay == 3)
					damage = 0;
				else if(teamplay == 4)
				{
					if(targ.classname == "player" && targ.deadflag == DEAD_NO)
					{
						mirrordamage = cvar("g_mirrordamage") * damage;
						mirrorforce = cvar("g_mirrordamage") * vlen(force);
						if(g_minstagib)
						{
							if(cvar("g_friendlyfire") == 0)
								damage = 0;
						}
						else
							damage = cvar("g_friendlyfire") * damage;
						// mirrordamage will be used LATER
					}
					else
						damage = 0;
				}
			}
		}

		if(targ.classname == "player")
		if(attacker.classname == "player")
		if(attacker != targ)
		{
			targ.lms_traveled_distance = cvar("g_lms_campcheck_distance");
			attacker.lms_traveled_distance = cvar("g_lms_campcheck_distance");
		}

		if(targ != attacker)
		if(!targ.deadflag)
		if(damage > 0)
		if(targ.classname == "player")
		if(attacker)
			attacker.hitsound += 1;

		if (g_minstagib)
		{
			if ((deathtype == DEATH_FALL)  ||
				(deathtype == DEATH_DROWN) ||
				(deathtype == DEATH_SLIME) ||
				(deathtype == DEATH_LAVA))
				return;
			if (targ.armorvalue && (deathtype == IT_NEX) && damage)
			{
				targ.armorvalue -= 1;
				centerprint(targ, strcat("^3Remaining extra lives: ",ftos(targ.armorvalue),"\n"));
				damage = 0;
				targ.hitsound += 1;
			}
			else if (deathtype == IT_NEX && targ.items & IT_STRENGTH)
			{
				if(clienttype(attacker) == CLIENTTYPE_REAL)
					if(IsDifferentTeam(targ, attacker))
						yoda = 1;
			}
			if (deathtype == IT_LASER)
			{
				damage = 0;
				if (targ != attacker)
				{
					if (targ.classname == "player")
						centerprint(attacker, "Secondary fire inflicts no damage!\n");
					damage = 0;
					mirrordamage = 0;
					force = '0 0 0';
					// keep mirrorforce
					attacker = targ;
				}
			}
		} else {
			if (!targ.deadflag)
				if(targ.takedamage == DAMAGE_AIM)
					if(IsFlying(targ))
						if(IsDifferentTeam(targ, attacker))
							yoda = 1;
		}

		// apply strength multiplier
		if (attacker.items & IT_STRENGTH && !g_minstagib)
		{
			damage = damage * cvar("g_balance_powerup_strength_damage");
			force = force * cvar("g_balance_powerup_strength_force");
		}
		// apply invincibility multiplier
		if (targ.items & IT_INVINCIBLE && !g_minstagib)
			damage = damage * cvar("g_balance_powerup_invincible_takedamage");


		if(g_runematch)
		{
			// apply strength rune
			if (attacker.runes & RUNE_STRENGTH)
			{
				if(attacker.runes & CURSE_WEAK) // have both curse & rune
				{
					damage = damage * cvar("g_balance_rune_strength_combo_damage");
					force = force * cvar("g_balance_rune_strength_combo_force");
				}
				else
				{
					damage = damage * cvar("g_balance_rune_strength_damage");
					force = force * cvar("g_balance_rune_strength_force");
				}
			}
			else if (attacker.runes & CURSE_WEAK)
			{
				damage = damage * cvar("g_balance_curse_weak_damage");
				force = force * cvar("g_balance_curse_weak_force");
			}

			// apply defense rune
			if (targ.runes & RUNE_DEFENSE)
			{
				if (targ.runes & CURSE_VULNER) // have both curse & rune
					damage = damage * cvar("g_balance_rune_defense_combo_takedamage");
				else
					damage = damage * cvar("g_balance_rune_defense_takedamage");
			}
			else if (targ.runes & CURSE_VULNER)
				damage = damage * cvar("g_balance_curse_vulner_takedamage");
		}
	}

	// apply push
	if (self.damageforcescale)
	if (vlen(force))
	{
		self.velocity = self.velocity + self.damageforcescale * force;
		self.flags = self.flags - (self.flags & FL_ONGROUND);
	}
	// apply damage
	if (self.event_damage)
		self.event_damage (inflictor, attacker, damage, deathtype, hitloc, force);
	self = oldself;

	if(targ.classname == "player" && attacker.classname == "player" && attacker != targ && attacker.health > 2)
	{
		// Savage: vampire mode
		if (g_vampire)
		if (!g_minstagib)
		if (!g_instagib)
		if (time > self.spawnshieldtime)
		{
			attacker.health += damage;
		}
		if(g_runematch)
		{
			if (attacker.runes & RUNE_VAMPIRE)
			{
			// apply vampire rune
				if (attacker.runes & CURSE_EMPATHY) // have the curse too
				{
					//attacker.health = attacker.health + damage * cvar("g_balance_rune_vampire_combo_absorb");
					attacker.health = bound(
						cvar("g_balance_curse_empathy_minhealth"), // LA: was 3, now 40
						attacker.health + damage * cvar("g_balance_rune_vampire_combo_absorb"),
						cvar("g_balance_rune_vampire_maxhealth"));	// LA: was 1000, now 500
				}
				else
				{
					//attacker.health = attacker.health + damage * cvar("g_balance_rune_vampire_absorb");
					attacker.health = bound(
						attacker.health,	// LA: was 3, but changed so that you can't lose health
											// empathy won't let you gain health in the same way...
						attacker.health + damage * cvar("g_balance_rune_vampire_absorb"),
						cvar("g_balance_rune_vampire_maxhealth"));	// LA: was 1000, now 500
					}
			}
			// apply empathy curse
			else if (attacker.runes & CURSE_EMPATHY)
			{
				attacker.health = bound(
					cvar("g_balance_curse_empathy_minhealth"), // LA: was 3, now 20
					attacker.health + damage * cvar("g_balance_curse_empathy_takedamage"),
					attacker.health);
			}
		}
	}

	// apply mirror damage if any
	if(mirrordamage > 0 || mirrorforce > 0)
	{
		attacker = attacker_save;
		if(g_minstagib)
			if(mirrordamage > 0)
			{
				// just lose extra LIVES, don't kill the player for mirror damage
				if(attacker.armorvalue > 0)
				{
					attacker.armorvalue = attacker.armorvalue - 1;
					centerprint(attacker, strcat("^3Remaining extra lives: ",ftos(attacker.armorvalue),"\n"));
					attacker.hitsound += 1;
				}
				mirrordamage = 0;
			}
		force = normalize(attacker.origin + attacker.view_ofs - hitloc) * mirrorforce;
		Damage(attacker, inflictor, attacker, mirrordamage, DEATH_MIRRORDAMAGE, attacker.origin, force);
	}
}

vector NearestPointOnBox(entity box, vector org)
{
	vector m1, m2, nearest;

	m1 = box.mins + box.origin;
	m2 = box.maxs + box.origin;

	nearest_x = bound(m1_x, org_x, m2_x);
	nearest_y = bound(m1_y, org_y, m2_y);
	nearest_z = bound(m1_z, org_z, m2_z);

	return nearest;
}

float RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype)
// Returns total damage applies to creatures
{
	entity	targ;
	float	finaldmg;
	float	power;
	vector	blastorigin;
	vector	force;
	vector  diff;
	vector  center;
	vector  nearest;
	float   total_damage_to_creatures;

	blastorigin = (inflictor.origin + (inflictor.mins + inflictor.maxs) * 0.5);
	total_damage_to_creatures = 0;

	targ = findradius (blastorigin, rad);
	while (targ)
	{
		if (targ != inflictor)
			if (ignore != targ)
			{
				// LordHavoc: measure distance to nearest point on target (not origin)
				// (this guarentees 100% damage on a touch impact)
				nearest = NearestPointOnBox(targ, blastorigin);
				diff = nearest - blastorigin;
				// round up a little on the damage to ensure full damage on impacts
				// and turn the distance into a fraction of the radius
				power = 1 - ((vlen (diff) - 2) / rad);
				//bprint(" ");
				//bprint(ftos(power));
				if (power > 0)
				{
					if (power > 1)
						power = 1;
					finaldmg = coredamage * power + edgedamage * (1 - power);
					if (finaldmg > 0)
					{
						center = targ.origin + (targ.mins + targ.maxs) * 0.5;
						// if it's a player, use the view origin as reference
						if (targ.classname == "player")
							center = targ.origin + targ.view_ofs;
						force = normalize(center - blastorigin) * (finaldmg / coredamage) * forceintensity;
						if (targ == attacker)
							finaldmg = finaldmg * cvar("g_balance_selfdamagepercent");	// Partial damage if the attacker hits himself
						// test line of sight to multiple positions on box,
						// and do damage if any of them hit
						local float c;
						c = ceil(finaldmg / 10);
						if (c > 20)
							c = 20;
						while (c > 0)
						{
							c = c - 1;
							traceline(blastorigin, nearest, TRUE, inflictor);
							if (trace_fraction == 1 || trace_ent == targ
							    || cvar("g_throughfloor"))
							{
								if(targ.iscreature)
									total_damage_to_creatures += finaldmg;
								Damage (targ, inflictor, attacker, finaldmg, deathtype, nearest, force);
								break;
							}
							nearest_x = targ.mins_x + random() * targ.size_x;
							nearest_y = targ.mins_y + random() * targ.size_y;
							nearest_z = targ.mins_z + random() * targ.size_z;
						}
					}
				}
			}
		targ = targ.chain;
	}

	return total_damage_to_creatures;
}
