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

void Damage_DamageInfo(vector org, float coredamage, float edgedamage, float rad, vector force, float deathtype)
{
	// TODO maybe call this from non-edgedamage too?
	// TODO maybe make the client do the particle effects for the weapons and the impact sounds using this info?

	entity e;

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
			} else {
				if(sv_gentle)
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1You need to be more careful!"));
				else
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, "^1You killed your own dumb self!"));
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
					bprint ("^1",s, "^1 thought he found a nice camping ground\n");
				else if (deathtype == DEATH_MIRRORDAMAGE)
					bprint ("^1",s, "^1 didn't become friends with the Lord of Teamplay\n");
				else if (deathtype == DEATH_CHEAT)
					bprint ("^1",s, "^1 unfairly eliminated himself\n");
				else if (deathtype != DEATH_TEAMCHANGE)
					bprint ("^1",s, "^1 couldn't resist the urge to self-destruct\n");

				if(deathtype != DEATH_TEAMCHANGE)
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
					centerprint(attacker, strcat(DAMAGE_CENTERPRINT_SPACER, "^4You scored against ^7", s));
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, a,"^1 scored against you ^7"));
				} else {
					centerprint(attacker, strcat(DAMAGE_CENTERPRINT_SPACER, blood_message, "^4You fragged ^7", s));
					centerprint(targ, strcat(DAMAGE_CENTERPRINT_SPACER, victim_message, "^1You were fragged by ^7", a));
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
					else if(deathtype == DEATH_TURRET)
						bprint ("^1",s, "^1 was pushed into the line of fire by ^1", a, "\n");
					else if(deathtype == DEATH_TOUCHEXPLODE)
						bprint ("^1",s, "^1 was pushed into an accident by ^1", a, "\n");
					else if(deathtype == DEATH_CHEAT)
						bprint ("^1",s, "^1 was unfairly eliminated by ^1", a, "\n");
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
						announce(attacker, "announcer/male/03kills.wav");
					}
				}
				else if (attacker.killcount == 5)
				{
					if(sv_gentle) {
						bprint (a,"^7 unleashes ^1SCORING RAGE\n");
					} else {
						bprint (a,"^7 unleashes ^1RAGE\n");
						announce(attacker, "announcer/male/05kills.wav");
					}
				}
				else if (attacker.killcount == 10)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1TEN SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 starts the ^1MASSACRE!\n");
						announce(attacker, "announcer/male/10kills.wav");
					}
				}
				else if (attacker.killcount == 15)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1FIFTEEN SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 executes ^1MAYHEM!\n");
						announce(attacker, "announcer/male/15kills.wav");
					}
				}
				else if (attacker.killcount == 20)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1TWENTY SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 is a ^1BERSERKER!\n");
						announce(attacker, "announcer/male/20kills.wav");
					}
				}
				else if (attacker.killcount == 25)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1TWENTY FIFE SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 inflicts ^1CARNAGE!\n");
						announce(attacker, "announcer/male/25kills.wav");
					}
				}
				else if (attacker.killcount == 30)
				{
					if(sv_gentle) {
						bprint (a,"^7 made ^1THIRTY SCORES IN A ROW!\n");
					} else {
						bprint (a,"^7 unleashes ^1ARMAGEDDON!\n");
						announce(attacker, "announcer/male/30kills.wav");
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
			else if(deathtype == DEATH_TOUCHEXPLODE)
				bprint ("^1",s, "^1 died in an accident\n");
			else if(deathtype == DEATH_CHEAT)
				bprint ("^1",s, "^1 was unfairly eliminated\n");
			else
				if(sv_gentle)
					bprint ("^1",s, "^1 needs a restart\n");
				else
					bprint ("^1",s, "^1 died\n");
			GiveFrags(targ, targ, -1);
			if(PlayerScore_Add(targ, SP_SCORE, 0) == -5) {
				announce(targ, "announcer/male/botlike.wav");
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
	if(DEATH_ISWEAPON(deathtype, WEP_HOOK))
	{
		if(targ.classname == "player")
			if not(IsDifferentTeam(targ, attacker))
			{
				self = oldself;
				return;
			}
	}

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
							if(attacker.dmg_team > teamdamage0)
								mirrordamage = cvar("g_mirrordamage") * (attacker.dmg_team - teamdamage0);
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
				(deathtype == DEATH_LAVA))
			{
				self = oldself;
				return;
			}
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
					if (targ.classname == "player")
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
			damage *= g_weapondamagefactor;

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
			damage = damage * cvar("g_balance_selfdamagepercent");	// Partial damage if the attacker hits himself

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

						// HEAD SHOT:
						// find height of hit on player axis
						// if above view_ofs and below maxs, and also in the middle half of the bbox, it is head shot
						vector headmins, headmaxs, org;
						org = antilag_takebackorigin(targ, time - ANTILAG_LATENCY(attacker));
						headmins = org + '0.7 0 0' * targ.mins_x + '0 0.7 0' * targ.mins_y + '0 0 1' * targ.view_ofs_z;
						headmaxs = org + '0.7 0 0' * targ.maxs_x + '0 0.7 0' * targ.maxs_y + '0 0 1' * targ.maxs_z;
						if(trace_hits_box(railgun_start, railgun_end, headmins, headmaxs))
						{
							damage *= 1 + damage_headshotbonus;
							headshot = 1;
							deathtype |= HITTYPE_HEADSHOT;
						}
					}
				}
			}
			else
			{
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

	// apply push
	if (self.damageforcescale)
	if (vlen(force))
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

	blastorigin = (inflictor.origin + (inflictor.mins + inflictor.maxs) * 0.5);
	total_damage_to_creatures = 0;

	if(deathtype != (WEP_HOOK | HITTYPE_SECONDARY | HITTYPE_BOUNCE)) // only send gravity bomb damage once
	{
		force = inflictor.velocity;
		if(vlen(force) == 0)
			force = '0 0 -1';
		else
			force = normalize(force);
		if(forceintensity >= 0)
			Damage_DamageInfo(blastorigin, coredamage, edgedamage, rad, forceintensity * force, deathtype);
		else
			Damage_DamageInfo(blastorigin, coredamage, edgedamage, -rad, (-forceintensity) * force, deathtype);
	}

	targ = findradius (blastorigin, rad);
	while (targ)
	{
		next = targ.chain;
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
								if(targ == directhitentity || DEATH_ISSPECIAL(deathtype))
									Damage (targ, inflictor, attacker, finaldmg, deathtype, nearest, force);
								else
									Damage (targ, inflictor, attacker, finaldmg, deathtype | HITTYPE_SPLASH, nearest, force);
								break;
							}
							nearest_x = targ.mins_x + random() * targ.size_x;
							nearest_y = targ.mins_y + random() * targ.size_y;
							nearest_z = targ.mins_z + random() * targ.size_z;
						}
					}
				}
			}
		targ = next;
	}

	RadiusDamage_running = 0;

	return total_damage_to_creatures;
}
