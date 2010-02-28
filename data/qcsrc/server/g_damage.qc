.float dmg;
.float dmg_edge;
.float dmg_force;
.float dmg_radius;

float Damage_DamageInfo_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_DAMAGEINFO);
	WriteShort(MSG_ENTITY, self.projectiledeathtype);
	WriteCoord(MSG_ENTITY, floor(self.origin_x));
	WriteCoord(MSG_ENTITY, floor(self.origin_y));
	WriteCoord(MSG_ENTITY, floor(self.origin_z));
	WriteByte(MSG_ENTITY, bound(1, self.dmg, 255));
	WriteByte(MSG_ENTITY, bound(0, self.dmg_radius, 255));
	WriteByte(MSG_ENTITY, bound(1, self.dmg_edge, 255));
	WriteShort(MSG_ENTITY, self.oldorigin_x);
	return TRUE;
}

void Damage_DamageInfo(vector org, float coredamage, float edgedamage, float rad, vector force, float deathtype, entity dmgowner)
{
	// TODO maybe call this from non-edgedamage too?
	// TODO maybe make the client do the particle effects for the weapons and the impact sounds using this info?

	entity e;

	if(!sound_allowed(MSG_BROADCAST, dmgowner))
		deathtype |= 0x8000;

	e = spawn();
	setorigin(e, org);
	e.projectiledeathtype = deathtype;
	e.dmg = coredamage;
	e.dmg_edge = edgedamage;
	e.dmg_radius = rad;
	e.dmg_force = vlen(force);
	e.velocity = force;

	e.oldorigin_x = compressShortVector(e.velocity);

	Net_LinkEntity(e, FALSE, 0.2, Damage_DamageInfo_SendEntity);
}

#define DAMAGE_CENTERPRINT_SPACER NEWLINES

float checkrules_firstblood;

float yoda;
float damage_goodhits;
float damage_gooddamage;
float headshot;
float damage_headshotbonus; // bonus multiplier for head shots, set to 0 after use

.float dmg_team;
.float teamkill_complain;
.float teamkill_soundtime;
.entity teamkill_soundsource;
.entity pusher;
.float taunt_soundtime;


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
	if(a.waterlevel >= WATERLEVEL_SWIMMING)
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

// NOTE: f=0 means still count as a (positive) kill, but count no frags for it
void W_SwitchWeapon_Force(entity e, float w);
void GiveFrags (entity attacker, entity targ, float f)
{
	float w;

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

	if(g_arena || g_ca)
		if(cvar("g_arena_roundbased"))
			return;

	if(targ != attacker) // not for suicides
	if(g_weaponarena_random)
	{
		// after a frag, choose another random weapon set
		if(inWarmupStage)
			w = warmup_start_weapons;
		else
			w = start_weapons;

		attacker.weapons = randombits(w - (w & W_WeaponBit(attacker.weapon)), g_weaponarena_random, TRUE);
		if(attacker.weapons < 0)
		{
			// error from randombits: no weapon available
			// this means we can just give ALL weapons
			attacker.weapons = w;
		}
		if not(attacker.weapons & W_WeaponBit(attacker.weapon))
			W_SwitchWeapon_Force(attacker, w_getbestweapon(attacker));
	}

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
	else if(g_ctf)
	{
		if(g_ctf_ignore_frags)
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
	s = strcat(s, ftos(w));
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
	GameLogEcho(s);
}

void Obituary (entity attacker, entity inflictor, entity targ, float deathtype)
{
	string	s, a;
	float p, w;

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
				centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "You are now on: ", ColoredTeamName(targ.team)));
			} else if (deathtype == DEATH_AUTOTEAMCHANGE) {
				centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "You have been moved into a different team to improve team balance\nYou are now on: ", ColoredTeamName(targ.team)));
				return;
			} else if (deathtype == DEATH_CAMP) {
				if(sv_gentle)
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1Reconsider your tactics, camper!"));
				else
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1Die camper!"));
			} else if (deathtype == DEATH_NOAMMO) {
				if(sv_gentle)
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1You are reinserted into the game for running out of ammo..."));
				else
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1You were killed for running out of ammo..."));
			} else if (deathtype == DEATH_ROT) {
				if(sv_gentle)
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1You need to preserve your health"));
				else
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1You grew too old without taking your medicine"));
			} else if (deathtype == DEATH_MIRRORDAMAGE) {
				if(sv_gentle)
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1Don't go against team mates!"));
				else
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1Don't shoot your team mates!"));
			} else if (deathtype == DEATH_QUIET) {
				// do nothing
			} else {
				if(sv_gentle)
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1You need to be more careful!"));
				else
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1You killed your own dumb self!"));
			}
			if(sv_gentle) {
				if (deathtype == DEATH_CAMP)
					bprint ("^1",s, "^1 thought they found a nice camping ground\n");
				else if (deathtype == DEATH_MIRRORDAMAGE)
					bprint ("^1",s, "^1 didn't become friends with the Lord of Teamplay\n");
				else
					bprint ("^1",s, "^1 will be reinserted into the game due to their own actions\n");

				if(deathtype != DEATH_TEAMCHANGE && deathtype != DEATH_QUIET)
				{
					LogDeath("suicide", deathtype, targ, targ);
					GiveFrags(attacker, targ, -1);
				}
				if (targ.killcount > 2)
					bprint ("^1",s,"^1 faded after a ",ftos(targ.killcount)," point spree\n");
			} else {
				w = DEATH_WEAPONOF(deathtype);
				if(WEP_VALID(w))
				{
					w_deathtypestring = "couldn't resist the urge to self-destruct";
					w_deathtype = deathtype;
					weapon_action(w, WR_SUICIDEMESSAGE);
 					bprint("^1", s, "^1 ", w_deathtypestring, "\n");
				}
				else if (deathtype == DEATH_KILL)
					bprint ("^1",s, "^1 couldn't take it anymore\n");
				else if (deathtype == DEATH_ROT)
					bprint ("^1",s, "^1 died\n");
				else if (deathtype == DEATH_NOAMMO)
					bprint ("^7",s, "^7 committed suicide. What's the point of living without ammo?\n");
				else if (deathtype == DEATH_CAMP)
					bprint ("^1",s, "^1 thought they found a nice camping ground\n");
				else if (deathtype == DEATH_MIRRORDAMAGE)
					bprint ("^1",s, "^1 didn't become friends with the Lord of Teamplay\n");
				else if (deathtype == DEATH_CHEAT)
					bprint ("^1",s, "^1 unfairly eliminated themself\n");
				else if (deathtype == DEATH_FIRE)
					bprint ("^1",s, "^1 burned to death\n");
				else if (deathtype != DEATH_TEAMCHANGE && deathtype != DEATH_QUIET)
					bprint ("^1",s, "^1 couldn't resist the urge to self-destruct\n");

				if(deathtype != DEATH_TEAMCHANGE && deathtype != DEATH_QUIET)
				{
					LogDeath("suicide", deathtype, targ, targ);
					GiveFrags(attacker, targ, -1);
				}
				if (targ.killcount > 2)
					bprint ("^1",s,"^1 ended it all after a ",ftos(targ.killcount)," kill spree\n");
			}
		}
		else if (attacker.classname == "player" || attacker.classname == "gib")
		{
			if(teams_matter && attacker.team == targ.team)
			{
				if(sv_gentle) {
					centerprint(attacker, strcat(DAMAGE_CENTERPRINT_SPACER, "^1Moron! You went against a team mate!"));
					bprint ("^1", a, "^1 took action against a team mate\n");
				} else {
					centerprint(attacker, strcat(DAMAGE_CENTERPRINT_SPACER, "^1Moron! You fragged ", s, ", a team mate!"));
					bprint ("^1", a, "^1 mows down a team mate\n");
				}
				GiveFrags(attacker, targ, -1);
				if (targ.killcount > 2) {
					if(sv_gentle)
						bprint ("^1",s,"'s ^1",ftos(targ.killcount)," scoring spree was ended by a team mate!\n");
					else
						bprint ("^1",s,"'s ^1",ftos(targ.killcount)," kill spree was ended by a team mate!\n");
				}
				if (attacker.killcount > 2) {
					if(sv_gentle)
						bprint ("^1",a,"^1 ended a ",ftos(attacker.killcount)," scoring spree by going against a team mate\n");
					else
						bprint ("^1",a,"^1 ended a ",ftos(attacker.killcount)," kill spree by killing a team mate\n");
				}
				attacker.killcount = 0;

				LogDeath("tk", deathtype, attacker, targ);
			}
			else
			{
				string blood_message, victim_message;
				if (!checkrules_firstblood)
				{
					checkrules_firstblood = TRUE;
					if(sv_gentle)
					{
						bprint("^1",a, "^1 was the first to score", "\n");
						blood_message = "^1First point\n";
						//victim_message = "^1First victim\n";  // or First casualty
					}
					else
					{
						bprint("^1",a, "^1 drew first blood", "\n");
						blood_message = "^1First blood\n";
						victim_message = "^1First victim\n";  // or First casualty
					}
				}
				if(sv_gentle > 0) {
					centerprint(attacker, strcat(DAMAGE_CENTERPRINT_SPACER, blood_message, "^4You scored against ^7", s, GetAdvancedDeathReports(targ)));
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, a,"^1 scored against you ^7", GetAdvancedDeathReports(attacker)));
				} else {
					if((cvar("sv_fragmessage_information_typefrag")) && (targ.BUTTON_CHAT)) {
						centerprint(attacker, strcat(DAMAGE_CENTERPRINT_SPACER, blood_message, "^1You typefragged ^7", s, GetAdvancedDeathReports(targ)));
						centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, victim_message, "^1You were typefragged by ^7", a, GetAdvancedDeathReports(attacker)));
					} else {
						centerprint(attacker, strcat(DAMAGE_CENTERPRINT_SPACER, blood_message, "^4You fragged ^7", s, GetAdvancedDeathReports(targ)));
						centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, victim_message, "^1You were fragged by ^7", a, GetAdvancedDeathReports(attacker)));
					}
					attacker.taunt_soundtime = time + 1;
				}

				if(sv_gentle) {
					bprint ("^1",s, "^1 needs a restart thanks to ", a, "\n");
				} else {
					w = DEATH_WEAPONOF(deathtype);
					if(WEP_VALID(w))
					{
						w_deathtypestring = "was blasted by";
						w_deathtype = deathtype;
						weapon_action(w, WR_KILLMESSAGE);
						p = strstrofs(w_deathtypestring, "#", 0);
						if(p < 0)
							bprint("^1", s, "^1 ", w_deathtypestring, " ", a, "\n");
						else
							bprint("^1", s, "^1 ", substring(w_deathtypestring, 0, p), a, "^1", substring(w_deathtypestring, p+1, strlen(w_deathtypestring) - (p+1)), "\n");
					}
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
					else if (deathtype == DEATH_HURTTRIGGER && inflictor.message2 != "")
					{
						p = strstrofs(inflictor.message2, "#", 0);
						if(p < 0)
							bprint("^1", s, "^1 ", inflictor.message2, " ", a, "\n");
						else
							bprint("^1", s, "^1 ", substring(inflictor.message2, 0, p), a, "^1", substring(inflictor.message2, p+1, strlen(inflictor.message2) - (p+1)), "\n");
					}
					else if(deathtype == DEATH_SBCRUSH)
                        bprint ("^1",s, "^1 was crushed by ^1", a, "\n");
					else if(deathtype == DEATH_SBMINIGUN)
                        bprint ("^1",s, "^1 got shredded by ^1", a, "\n");
					else if(deathtype == DEATH_SBROCKET)
                        bprint ("^1",s, "^1 was blased to bits by ^1", a, "\n");
					else if(deathtype == DEATH_SBBLOWUP)
                        bprint ("^1",s, "^1 got cought in the destruction of ^1", a, "'s vehicle\n");

					else if(deathtype == DEATH_WAKIGUN)
                        bprint ("^1",s, "^1 was bolted down by ^1", a, "\n");
					else if(deathtype == DEATH_WAKIROCKET)
                        bprint ("^1",s, "^1 could find no shelter from ^1", a, "'s rockets\n");
					else if(deathtype == DEATH_WAKIBLOWUP)
                        bprint ("^1",s, "^1 dies when ^1", a, "'s wakizashi dies.\n");

					else if(deathtype == DEATH_TURRET)
						bprint ("^1",s, "^1 was pushed into the line of fire by ^1", a, "\n");
					else if(deathtype == DEATH_TOUCHEXPLODE)
						bprint ("^1",s, "^1 was pushed into an accident by ^1", a, "\n");
					else if(deathtype == DEATH_CHEAT)
						bprint ("^1",s, "^1 was unfairly eliminated by ^1", a, "\n");
					else if (deathtype == DEATH_FIRE)
					bprint ("^1",s, "^1 was burnt to death by ^1", a, "\n");
					else if (deathtype == DEATH_CUSTOM)
						bprint ("^1",s, "^1 ", deathmessage, " by ^1", a, "\n");
					else
						bprint ("^1",s, "^1 was fragged by ", a, "\n");
				}

				if(g_ctf && targ.flagcarried)
				{
					UpdateFrags(attacker, ctf_score_value("score_kill"));
					PlayerScore_Add(attacker, SP_CTF_FCKILLS, 1);
					GiveFrags(attacker, targ, 0); // for logging
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
						AnnounceTo(attacker, "03kills");
					}
				}
				else if (attacker.killcount == 5)
				{
					if(sv_gentle) {
						bprint (a,"^7 unleashes ^1SCORING RAGE\n");
					} else {
						bprint (a,"^7 unleashes ^1RAGE\n");
						AnnounceTo(attacker, "05kills");
					}
				}
				else if (attacker.killcount == 10)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1TEN SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 starts the ^1MASSACRE!\n");
						AnnounceTo(attacker, "10kills");
					}
				}
				else if (attacker.killcount == 15)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1FIFTEEN SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 executes ^1MAYHEM!\n");
						AnnounceTo(attacker, "15kills");
					}
				}
				else if (attacker.killcount == 20)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1TWENTY SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 is a ^1BERSERKER!\n");
						AnnounceTo(attacker, "20kills");
					}
				}
				else if (attacker.killcount == 25)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1TWENTY FIFE SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 inflicts ^1CARNAGE!\n");
						AnnounceTo(attacker, "25kills");
					}
				}
				else if (attacker.killcount == 30)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1THIRTY SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 unleashes ^1ARMAGEDDON!\n");
						AnnounceTo(attacker, "30kills");
					}
				}
			}
		}
		else
		{
			centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1Watch your step!"));
			if (deathtype == DEATH_HURTTRIGGER && inflictor.message != "")
				bprint ("^1",s, "^1 ", inflictor.message, "\n");
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
            else if (deathtype == DEATH_CUSTOM)
                bprint ("^1",s, "^1 ", deathmessage, "\n");
			else if(deathtype == DEATH_TOUCHEXPLODE)
				bprint ("^1",s, "^1 died in an accident\n");
			else if(deathtype == DEATH_CHEAT)
				bprint ("^1",s, "^1 was unfairly eliminated\n");
			else if(deathtype == DEATH_FIRE)
				if(sv_gentle)
					bprint ("^1",s, "^1 felt a little hot\n");
				else
					bprint ("^1",s, "^1 burnt to death\n");
			else
				if(sv_gentle)
					bprint ("^1",s, "^1 needs a restart\n");
				else
					bprint ("^1",s, "^1 died\n");
			GiveFrags(targ, targ, -1);
			if(PlayerScore_Add(targ, SP_SCORE, 0) == -5) {
				AnnounceTo(targ, "botlike");
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
	float teamdamage0;
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

	if(targ.classname == "player")
		if(targ.hook)
			if(targ.hook.aiment)
				if(targ.hook.aiment == attacker)
					RemoveGrapplingHook(targ); // STOP THAT, you parasite!

	// special rule: gravity bomb does not hit team mates (other than for disconnecting the hook)
	if(DEATH_ISWEAPON(deathtype, WEP_HOOK) || DEATH_ISWEAPON(deathtype, WEP_TUBA))
	{
		if(targ.classname == "player")
			if not(IsDifferentTeam(targ, attacker))
			{
				self = oldself;
				return;
			}
	}

	if(deathtype == DEATH_KILL || deathtype == DEATH_TEAMCHANGE || deathtype == DEATH_AUTOTEAMCHANGE || deathtype == DEATH_QUIET)
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
	else if(deathtype == DEATH_MIRRORDAMAGE || deathtype == DEATH_NOAMMO)
	{
		// no processing
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
		if(attacker.classname == "player")
		{
			if(targ.classname == "player" && targ != attacker && (IS_INDEPENDENT_PLAYER(attacker) || IS_INDEPENDENT_PLAYER(targ)))
			{
				damage = 0;
				force = '0 0 0';
			}
			else if(attacker.team == targ.team)
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
							teamdamage0 = max(attacker.dmg_team, cvar("g_teamdamage_threshold"));
							attacker.dmg_team = attacker.dmg_team + damage;
							if(attacker.dmg_team > teamdamage0 && !g_ca)
								mirrordamage = cvar("g_mirrordamage") * (attacker.dmg_team - teamdamage0);
							mirrorforce = cvar("g_mirrordamage") * vlen(force);
							if(g_minstagib)
							{
								if(cvar("g_friendlyfire") == 0)
									damage = 0;
							}
							else if(g_ca)
								damage = 0;
							else
								damage = cvar("g_friendlyfire") * damage;
							// mirrordamage will be used LATER
						}
						else
							damage = 0;
					}
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

		if(targ.classname == "player")
		if (g_minstagib)
		{
			if ((deathtype == DEATH_FALL)  ||
				(deathtype == DEATH_DROWN) ||
				(deathtype == DEATH_SLIME) ||
				(deathtype == DEATH_LAVA)  ||
				(!DEATH_ISWEAPON(deathtype, WEP_LASER) && damage > 0 && damage < 100))
			{
				self = oldself;
				return;
			}
			if(damage > 0)
			    damage = 10000;
			if (targ.armorvalue && (deathtype == WEP_MINSTANEX) && damage)
			{
				targ.armorvalue -= 1;
				centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^3Remaining extra lives: ",ftos(targ.armorvalue)));
				damage = 0;
				targ.hitsound += 1;
				attacker.hitsound += 1; // TODO change this to a future specific hitsound for armor hit
			}
			if (DEATH_ISWEAPON(deathtype, WEP_LASER))
			{
				damage = 0;
				if (targ != attacker)
				{
					if ((targ.health >= 1) && (targ.classname == "player"))
						centerprint(attacker, strcat(DAMAGE_CENTERPRINT_SPACER, "Secondary fire inflicts no damage!"));
					damage = 0;
					mirrordamage = 0;
					force = '0 0 0';
					// keep mirrorforce
					attacker = targ;
				}
			}
		}

		if not(DEATH_ISSPECIAL(deathtype))
		{
			damage *= g_weapondamagefactor;
			mirrordamage *= g_weapondamagefactor;
			force = force * g_weaponforcefactor;
			mirrorforce *= g_weaponforcefactor;
		}

		// apply strength multiplier
		if ((attacker.items & IT_STRENGTH) && !g_minstagib)
		{
			if(targ == attacker)
			{
				damage = damage * cvar("g_balance_powerup_strength_selfdamage");
				force = force * cvar("g_balance_powerup_strength_selfforce");
			}
			else
			{
				damage = damage * cvar("g_balance_powerup_strength_damage");
				force = force * cvar("g_balance_powerup_strength_force");
			}
		}

		// apply invincibility multiplier
		if (targ.items & IT_INVINCIBLE && !g_minstagib)
			damage = damage * cvar("g_balance_powerup_invincible_takedamage");

		if (targ == attacker)
		{
			if(g_ca || (g_cts && !cvar("g_cts_selfdamage")))
				damage = 0;
			else
				damage = damage * cvar("g_balance_selfdamagepercent");	// Partial damage if the attacker hits himself
		}

		// CTF: reduce damage/force
		if(g_ctf)
		if(targ == attacker)
		if(targ.flagcarried)
		{
			damage = damage * cvar("g_ctf_flagcarrier_selfdamage");
			force = force * cvar("g_ctf_flagcarrier_selfforce");
		}

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

		// count the damage
		if(attacker)
		if(!targ.deadflag)
		if(targ.takedamage == DAMAGE_AIM)
		if(targ != attacker)
		{
			if(targ.classname == "player")
			{
				// HEAD SHOT:
				// find height of hit on player axis
				// if above view_ofs and below maxs, and also in the middle half of the bbox, it is head shot
				vector headmins, headmaxs, org;
				org = antilag_takebackorigin(targ, time - ANTILAG_LATENCY(attacker));
				headmins = org + '0.6 0 0' * targ.mins_x + '0 0.6 0' * targ.mins_y + '0 0 1' * (1.3 * targ.view_ofs_z - 0.3 * targ.maxs_z);
				headmaxs = org + '0.6 0 0' * targ.maxs_x + '0 0.6 0' * targ.maxs_y + '0 0 1' * targ.maxs_z;
				if(trace_hits_box(railgun_start, railgun_end, headmins, headmaxs))
				{
					deathtype |= HITTYPE_HEADSHOT;
				}
			}
			else if(targ.classname == "turret_head")
			{
				deathtype |= HITTYPE_HEADSHOT;
			}
			if(deathtype & HITTYPE_HEADSHOT)
				damage *= 1 + damage_headshotbonus;

			if(targ.classname == "player")
			{
				if(IsDifferentTeam(targ, attacker))
				{
					if(damage > 0)
					{
						if(targ.BUTTON_CHAT)
							attacker.typehitsound += 1;
						else
							attacker.hitsound += 1;

						damage_goodhits += 1;
						damage_gooddamage += damage;

						if not(DEATH_ISSPECIAL(deathtype))
						{
							if(!g_minstagib)
							if(IsFlying(targ))
								yoda = 1;

							if(g_minstagib)
							if(targ.items & IT_STRENGTH)
								yoda = 1;

							if(deathtype & HITTYPE_HEADSHOT)
								headshot = 1;
						}
					}
				}
				else
				{
					if(deathtype != DEATH_FIRE)
						attacker.typehitsound += 1;
					if(mirrordamage > 0)
						if(time > attacker.teamkill_complain)
						{
							attacker.teamkill_complain = time + 5;
							attacker.teamkill_soundtime = time + 0.4;
							attacker.teamkill_soundsource = targ;
						}
				}
			}
		}
	}

	// apply push
	if (self.damageforcescale)
	if (vlen(force))
	if (self.classname != "player" || time >= self.spawnshieldtime || g_midair)
	{
		self.velocity = self.velocity + self.damageforcescale * force;
		self.flags &~= FL_ONGROUND;
		UpdateCSQCProjectile(self);
	}
	// apply damage
	if (damage != 0 || (self.damageforcescale && vlen(force)))
	if (self.event_damage)
		self.event_damage (inflictor, attacker, damage, deathtype, hitloc, force);
	self = oldself;

	if(targ.classname == "player" && attacker.classname == "player" && attacker != targ && attacker.health > 2)
	{
		// Savage: vampire mode
		if (g_vampire)
		if (!g_minstagib)
		if (time >= self.spawnshieldtime)
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
					centerprint(attacker, strcat(DAMAGE_CENTERPRINT_SPACER, "^3Remaining extra lives: ",ftos(attacker.armorvalue)));
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

void Damage_RecordDamage(entity attacker, float deathtype, float damage)
{
	float weaponid;
	weaponid = DEATH_WEAPONOF(deathtype);

	if not(inWarmupStage)
	if (weaponid)
	if ((clienttype(attacker) == CLIENTTYPE_REAL) | (clienttype(attacker) == CLIENTTYPE_BOT)) {
		attacker.stats_hit[weaponid - 1] += damage;
		attacker.stat_hit = weaponid + 64 * floor(attacker.stats_hit[weaponid - 1]);
	}
}

float RadiusDamage_running;
float RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype, entity directhitentity)
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
	entity  next;
	float   tfloordmg;
	float   tfloorforce;

	float stat_damagedone;
	float stat_maxdamage;

	if(RadiusDamage_running)
	{
		string save;
		print("RadiusDamage called recursively!\n");
		print("Expect stuff to go HORRIBLY wrong.\n");
		print("Causing a stack trace...\n");
		save = cvar_string("prvm_backtraceforwarnings");
		cvar_set("prvm_backtraceforwarnings", "1");
		fclose(-1); // calls VM_Warning
		cvar_set("prvm_backtraceforwarnings", save);
		return 0;
	}

	RadiusDamage_running = 1;

	tfloordmg = cvar("g_throughfloor_damage");
	tfloorforce = cvar("g_throughfloor_force");

	blastorigin = (inflictor.origin + (inflictor.mins + inflictor.maxs) * 0.5);
	total_damage_to_creatures = 0;

	if(deathtype != (WEP_HOOK | HITTYPE_SECONDARY | HITTYPE_BOUNCE)) // only send gravity bomb damage once
	if(DEATH_WEAPONOF(deathtype) != WEP_TUBA) // do not send tuba damage (bandwidth hog)
	{
		force = inflictor.velocity;
		if(vlen(force) == 0)
			force = '0 0 -1';
		else
			force = normalize(force);
		if(forceintensity >= 0)
			Damage_DamageInfo(blastorigin, coredamage, edgedamage, rad, forceintensity * force, deathtype, attacker);
		else
			Damage_DamageInfo(blastorigin, coredamage, edgedamage, -rad, (-forceintensity) * force, deathtype, attacker);
	}

	stat_damagedone = 0;
	stat_maxdamage = 0;

	targ = WarpZone_FindRadius (blastorigin, rad, FALSE);
	while (targ)
	{
		next = targ.chain;
		if (targ != inflictor)
			if (ignore != targ) if(targ.takedamage)
			{
				// LordHavoc: measure distance to nearest point on target (not origin)
				// (this guarentees 100% damage on a touch impact)
				nearest = targ.WarpZone_findradius_nearest;
				diff = targ.WarpZone_findradius_dist;
				// round up a little on the damage to ensure full damage on impacts
				// and turn the distance into a fraction of the radius
				power = 1 - ((vlen (diff) - 2) / rad);
				//bprint(" ");
				//bprint(ftos(power));
				//if (targ == attacker)
				//	print(ftos(power), "\n");
				if (power > 0)
				{
					if (power > 1)
						power = 1;
					finaldmg = coredamage * power + edgedamage * (1 - power);
					if (finaldmg > 0)
					{
						local float a;
						local float c;
						local float hits;
						local float total;
						local float hitratio;
						local vector hitloc;
						local vector myblastorigin;
						myblastorigin = WarpZone_TransformOrigin(targ, blastorigin);
						center = targ.origin + (targ.mins + targ.maxs) * 0.5;
						// if it's a player, use the view origin as reference
						if (targ.classname == "player")
							center = targ.origin + targ.view_ofs;
						force = normalize(center - myblastorigin);
						force = force * (finaldmg / coredamage) * forceintensity;
						// test line of sight to multiple positions on box,
						// and do damage if any of them hit
						hits = 0;
						if (targ.classname == "player")
							total = ceil(bound(1, finaldmg, 50));
						else
							total = ceil(bound(1, finaldmg/10, 5));
						hitloc = nearest;
						c = 0;
						while (c < total)
						{
							//traceline(targ.WarpZone_findradius_findorigin, nearest, MOVE_NOMONSTERS, inflictor);
							WarpZone_TraceLine(blastorigin, WarpZone_UnTransformOrigin(targ, nearest), MOVE_NOMONSTERS, inflictor);
							if (trace_fraction == 1 || trace_ent == targ)
							{
								hits = hits + 1;
								if (hits > 1)
									hitloc = hitloc + nearest;
								else
									hitloc = nearest;
							}
							nearest_x = targ.origin_x + targ.mins_x + random() * targ.size_x;
							nearest_y = targ.origin_y + targ.mins_y + random() * targ.size_y;
							nearest_z = targ.origin_z + targ.mins_z + random() * targ.size_z;
							c = c + 1;
						}
						nearest = hitloc * (1 / max(1, hits));
						hitratio = (hits / total);
						a = bound(0, tfloordmg + (1-tfloordmg) * hitratio, 1);
						finaldmg = finaldmg * a;
						a = bound(0, tfloorforce + (1-tfloorforce) * hitratio, 1);
						force = force * a;
						//if (targ == attacker)
						//{
						//	print("hits ", ftos(hits), " / ", ftos(total));
						//	print(" finaldmg ", ftos(finaldmg), " force ", vtos(force));
						//	print(" (", ftos(a), ")\n");
						//}
						if(hits || tfloordmg || tfloorforce)
						{
							if(targ.iscreature)
							{
								total_damage_to_creatures += finaldmg;

								if(targ.flags & FL_CLIENT)
								if(targ.deadflag == DEAD_NO)
								if(targ != attacker)
								if(!teamplay || targ.team != attacker.team)
								{
									stat_damagedone += finaldmg;
									stat_maxdamage += coredamage;
								}
							}

							if(targ == directhitentity || DEATH_ISSPECIAL(deathtype))
								Damage (targ, inflictor, attacker, finaldmg, deathtype, nearest, force);
							else
								Damage (targ, inflictor, attacker, finaldmg, deathtype | HITTYPE_SPLASH, nearest, force);
						}
					}
				}
			}
		targ = next;
	}

	RadiusDamage_running = 0;

	Damage_RecordDamage(attacker, deathtype, min(stat_maxdamage, stat_damagedone));

	return total_damage_to_creatures;
}

.float fire_damagepersec;
.float fire_endtime;
.float fire_deathtype;
.entity fire_owner;
.float fire_hitsound;
.entity fire_burner;

void fireburner_think();

float Fire_IsBurning(entity e)
{
	return (time < e.fire_endtime);
}

float Fire_AddDamage(entity e, entity o, float d, float t, float dt)
{
	float dps;
	float maxtime, mintime, maxdamage, mindamage, maxdps, mindps, totaldamage, totaltime;

	if(e.classname == "player")
	{
		if(e.deadflag)
			return -1;
	}
	else
	{
		if(!e.fire_burner)
		{
			// print("adding a fire burner to ", e.classname, "\n");
			e.fire_burner = spawn();
			e.fire_burner.classname = "fireburner";
			e.fire_burner.think = fireburner_think;
			e.fire_burner.nextthink = time;
			e.fire_burner.owner = e;
		}
	}

	t = max(t, 0.1);
	dps = d / t;
	if(Fire_IsBurning(e))
	{
		mintime = e.fire_endtime - time;
		maxtime = max(mintime, t);

		mindps = e.fire_damagepersec;
		maxdps = max(mindps, dps);

		if(maxtime > mintime || maxdps > mindps)
		{
			mindamage = mindps * mintime;
			maxdamage = mindamage + d;

			// interval [mintime, maxtime] * [mindps, maxdps]
			// intersected with
			// [mindamage, maxdamage]
			// maximum of this!

			if(maxdamage >= maxtime * maxdps)
			{
				totaltime = maxtime;
				totaldamage = maxtime * maxdps;

				// this branch increases totaldamage if either t > mintime, or dps > mindps
			}
			else
			{
				// maxdamage is inside the interval!
				// first, try to use mindps; only if this fails, increase dps as needed
				totaltime = min(maxdamage / mindps, maxtime); // maxdamage / mindps >= mindamage / mindps = mintime
				totaldamage = maxdamage;
				// can totaldamage / totaltime be >= maxdps?
				// max(mindps, maxdamage / maxtime) >= maxdps?
				// we know maxdamage < maxtime * maxdps
				// so it cannot be

				// this branch ALWAYS increases totaldamage, but requires maxdamage < maxtime * maxdps
			}

			// total conditions for increasing:
			//     maxtime > mintime OR maxdps > mindps OR maxtime * maxdps > maxdamage
			// however:
			//     if maxtime = mintime, maxdps = mindps
			// then:
			//     maxdamage = mindamage + d
			//     mindamage = mindps * mintime = maxdps * maxtime < maxdamage!
			// so the last condition is not needed

			e.fire_damagepersec = totaldamage / totaltime;
			e.fire_endtime = time + totaltime;
			if(totaldamage > 1.2 * mindamage)
			{
				e.fire_deathtype = dt;
				if(e.fire_owner != o)
				{
					e.fire_owner = o;
					e.fire_hitsound = FALSE;
				}
			}
			return max(0, totaldamage - mindamage); // can never be negative, but to make sure
		}
		else
			return 0;
	}
	else
	{
		e.fire_damagepersec = dps;
		e.fire_endtime = time + t;
		e.fire_deathtype = dt;
		e.fire_owner = o;
		e.fire_hitsound = FALSE;
		return d;
	}
}

void Fire_ApplyDamage(entity e)
{
	float t, d, hi, ty;
	entity o;

	if not(Fire_IsBurning(e))
		return;

	o = e.owner;
	while(o.owner)
		o = o.owner;
	if(clienttype(o) == CLIENTTYPE_NOTACLIENT)
		o = e.fire_owner;

	// water and slime stop fire
	if(e.waterlevel)
	if(e.watertype != CONTENT_LAVA)
		e.fire_endtime = 0;

	t = min(frametime, e.fire_endtime - time);
	d = e.fire_damagepersec * t;

	hi = e.fire_owner.hitsound;
	ty = e.fire_owner.typehitsound;
	Damage(e, e, e.fire_owner, d, e.fire_deathtype, e.origin, '0 0 0');
	if(e.fire_hitsound && e.fire_owner)
	{
		e.fire_owner.hitsound = hi;
		e.fire_owner.typehitsound = ty;
	}
	e.fire_hitsound = TRUE;

	Damage_RecordDamage(e.fire_owner, e.fire_deathtype, d);

	if not(IS_INDEPENDENT_PLAYER(e))
	FOR_EACH_PLAYER(other) if(e != other)
	{
		if(other.classname == "player")
		if(other.deadflag == DEAD_NO)
		if not(IS_INDEPENDENT_PLAYER(other))
		if(boxesoverlap(e.absmin, e.absmax, other.absmin, other.absmax))
		{
			t = cvar("g_balance_firetransfer_time") * (e.fire_endtime - time);
			d = cvar("g_balance_firetransfer_damage") * e.fire_damagepersec * t;
			Fire_AddDamage(other, o, d, t, DEATH_FIRE);
		}
	}
}

void Fire_ApplyEffect(entity e)
{
	if(Fire_IsBurning(e))
		e.effects |= EF_FLAME;
	else
		e.effects &~= EF_FLAME;
}

void fireburner_think()
{
	// for players, this is done in the regular loop
	if(wasfreed(self.owner))
	{
		remove(self);
		return;
	}
	Fire_ApplyEffect(self.owner);
	if(!Fire_IsBurning(self.owner))
	{
		self.owner.fire_burner = world;
		remove(self);
		return;
	}
	Fire_ApplyDamage(self.owner);
	self.nextthink = time;
}
