
float	RUNE_FIRST	= 1;
float	RUNE_STRENGTH	= 1;
float	RUNE_DEFENSE	= 2;
float	RUNE_REGEN	= 4;
float	RUNE_SPEED	= 8;
float	RUNE_VAMPIRE	= 16;
float	RUNE_LAST	= 16;

float	CURSE_FIRST	= 8192;
float	CURSE_WEAK	= 8192;
float	CURSE_VULNER	= 16384;
float	CURSE_VENOM	= 32768;
float	CURSE_SLOW	= 65536;
float	CURSE_EMPATHY	= 131072;
float	CURSE_LAST	= 131072;

/* rune ideas:

	Doom/Death
	Rune: When you damage enemies, you have a slight chance of instant-killing them (porportional to damage dealt / their health)
	Curse: When you are damaged, you have a chance of being instant-killed

	Vengence/Slothful
	Rune: The lower your health below 100, the more damage you deal (does not decrease your damage if you're above 100)
	Curse: The higher your health (up to 100), the less damage you deal (at 100 hp deal 1/5th damage)

*/

/*QUAKED spawnfunc_runematch_spawn_point (1 0 0) (-16 -16 -24) (16 16 24)
spawn point for runes in runematch
*/

void spawnfunc_runematch_spawn_point()
{
	if(!g_runematch)
	{
		remove(self);
		return;
	}

	setsize(self, '0 0 -35', '0 0 0');
	droptofloor();
}

string RuneName(float r)
{
	if(r == RUNE_STRENGTH)
		return "^1Strength^7";
	if(r == RUNE_DEFENSE)
		return "^4Defense^7";
	if(r == RUNE_REGEN)
		return "^2Vitality^7";
	if(r == RUNE_SPEED)
		return "^3Speed^7";
	if(r == RUNE_VAMPIRE)
		return "^6Vampire^7";

	if(r == CURSE_WEAK)
		return "^1Weakness^7";
	if(r == CURSE_VULNER)
		return "^4Vulnerability^7";
	if(r == CURSE_VENOM)
		return "^2Venom^7";
	if(r == CURSE_SLOW)
		return "^3Slow^7";
	if(r == CURSE_EMPATHY)
		return "^6Empathy^7";
	return strcat("^8[unnamed", ftos(r), "]^7");
}

vector RuneColormod(float r)
{
	vector _color;
	if(r == RUNE_STRENGTH)
		_color = '255 0 0';
	if(r == RUNE_DEFENSE)
		_color = '0 0 255';//'0 102 255';//
	if(r == RUNE_REGEN)
		_color = '0 204 0';//'0 255 0';
	if(r == RUNE_SPEED)
		_color = 0.35*'185 185 0';//255 230 0';//'255 255 0';
	if(r == RUNE_VAMPIRE)
		_color = '64 0 128';//'108 0 217';//'128 0 255';//'179 0 204';//

	if(r == CURSE_WEAK)
		_color = '255 0 0';
	if(r == CURSE_VULNER)
		_color = '0 0 255';//'0 102 255';//
	if(r == CURSE_VENOM)
		_color = '0 204 0';//'0 255 0';
	if(r == CURSE_SLOW)
		_color = 0.5*'185 185 0';//'255 255 0';
	if(r == CURSE_EMPATHY)
		_color = '179 0 204';//'128 0 255';

	return _color * (1 / 255) * cvar("g_runematch_rune_color_strength");
}

float count_rune_spawnpoints()
{
	float num;
	entity e;
	num = 0;
	e = findchain(classname, "runematch_spawn_point");
	while(e)
	{
		num = num + 1;
		e = e.chain;

	}
	return num;
}

entity rune_find_spawnpoint(float num, float r)
{
	entity e;
	e = world;
	do
	{
		e = find(e, classname, "runematch_spawn_point");
		if(!e)
			e = find(e, classname, "runematch_spawn_point");
		if(!e)
			break;

		if(r < 0)
		{
			return e; // emergency: prevent crash
		}

		if(e.owner != world)//e.wait > time) // already taken
			continue;

		if(r <= 1)
		{
			return e;
		}

		r = r - 1;

	}while(e);
	return world;
}

void rune_respawn();

void RuneCarriedThink()
{
	float rcount, rnum;
	vector ang;
	entity rune;

	if(self.owner.classname != "player" || time < game_starttime)
	{
		rune_respawn();
		return;
	}

	self.nextthink = time + 0.1;

	// count runes my owner holds
	rcount = 0;
	rune = find(world, classname, "rune");
	while(rune)
	{
		if(rune.owner == self.owner)
			rcount = rcount + 1;
		if(rune == self)
			rnum = rcount;
		rune = find(rune, classname, "rune");
	}

	ang_y = rnum*(360 / rcount) + mod(time, 360)*45;//180;

	makevectors(ang);

	//setorigin(self, v_forward*32);
	self.view_ofs = v_forward*32;
}

void rune_touch()
{
	if(other.classname != "player" || other.health < 1)
		return;
	if(self.wait > time)
		return; // "notouch" time isn't finished

	// detach from the spawn point you're on
	if(self.owner.classname == "runematch_spawn_point")
	{
		self.owner.owner = world;
		self.owner = world;
	}

	self.owner = other;
	self.enemy.owner = other;
	//setattachment(self, other, "");
	setattachment(self, world, "");

	self.movetype = MOVETYPE_FOLLOW;
	self.aiment = other;
	self.view_ofs = other.origin;

	setorigin(self, '0 0 0');
	other.runes = other.runes | self.runes | self.enemy.runes;

	//self.think = SUB_Null;
	//self.nextthink = 0;
	self.think = RuneCarriedThink;
	self.nextthink = time;
	self.touch = SUB_Null;

	self.solid = SOLID_NOT;
	setorigin(self, self.origin);

	//sprint(other, strcat("^3You have picked up ",
	//	RuneName(self.runes & (RUNE_LAST*2-1)), " and "));
	//sprint(other, strcat(RuneName(self.enemy.runes & (CURSE_WEAK | CURSE_VULNER | CURSE_VENOM | CURSE_SLOW | CURSE_EMPATHY)), "\n"));

	bprint("^3", other.netname, "^7 has picked up ",
		RuneName(self.runes & (RUNE_LAST*2-1)), "^7 and ");
	bprint(RuneName(self.enemy.runes & (CURSE_WEAK | CURSE_VULNER | CURSE_VENOM | CURSE_SLOW | CURSE_EMPATHY)), "\n");
}

void rune_respawn()
{
	float num, r;
	entity spot;
	num = count_rune_spawnpoints();
	r = floor(random()*num) + 1;

	if(self.owner.classname == "runematch_spawn_point")
	{
		self.owner.owner = world;
		self.owner = world;
	}


	spot = rune_find_spawnpoint(num, r);
	if(!spot)
	{
		bprint("Warning: couldn't find spawn spot for rune respawn\n");
		return;
	}

	self.solid = SOLID_TRIGGER;

	setorigin(self, spot.origin);
	self.owner = spot;
	spot.owner = self;

	self.touch = rune_touch;

	self.think = rune_respawn;
	self.nextthink = time + cvar("g_runematch_shuffletime");//30 + random()*5; // fixme: cvar
}

entity FindRune(entity own, string clname, float r)
{
	entity rune;
	float _count, c;

	c = _count = 0;
	rune = world;

	do
	{
		rune = find(rune, classname, clname);
		if(!rune)
			rune = find(rune, classname, clname);
		if(!rune)
			break;
		if(rune.owner == own)
		{
			_count = _count + 1;
			if(_count >= r)
				return rune;
			if(r <= 1)
				return rune;
		}
		c = c + 1;
	}while(c < 30);
	return world;
}


void DropRune(entity pl, entity e)
{
	//entity pl;

	//pl = e.owner;
	// detach from player
	setattachment(e, world, "");
	e.owner = world;
	e.enemy.owner = world;
	// don't instantly touch player again
	e.wait = time + 1; // "notouch" time
	e.movetype = MOVETYPE_TOSS;
	e.solid = SOLID_TRIGGER;
	// reposition itself if not picked up soon
	e.think = rune_respawn;
	e.nextthink = time + cvar("g_runematch_respawntime");//15 + random()*5; // fixme: cvar
	e.touch = rune_touch;

	pl.runes = pl.runes - (pl.runes & (e.runes | e.enemy.runes));

	// toss from player
	setorigin(e, pl.origin + '0 0 10');
	e.velocity = '0 0 200' + '0 100 0'*crandom() + '100 0 0'*crandom();


	bprint("^3", pl.netname, "^7 has lost ",
		RuneName(e.runes & (RUNE_LAST*2-1)), "^7 and ");
	bprint(RuneName(e.enemy.runes & (CURSE_WEAK | CURSE_VULNER | CURSE_VENOM | CURSE_SLOW | CURSE_EMPATHY)), "\n");
}

float RuneMatchesCurse(float r, float c)
{
	float cr;
	if(r & RUNE_STRENGTH)
		cr = CURSE_WEAK;
	else if(r & RUNE_DEFENSE)
		cr = CURSE_VULNER;
	else if(r & RUNE_REGEN)
		cr = CURSE_VENOM;
	else if(r & RUNE_SPEED)
		cr = CURSE_SLOW;
	else if(r & RUNE_VAMPIRE)
		cr = CURSE_EMPATHY;
	else return FALSE; // fixme: error?

	if(c & cr)
		return TRUE;
	return FALSE;
}

// player died, drop runes
// each rune should pair up with a random curse and then be tossed from the player
void DropAllRunes(entity pl)
{
	entity rune, curse;
	float rcount, ccount, r, c, rand, prevent_same, numtodrop, tries;

	entity curse1, rune1, curse2, rune2;

	rune = curse = world;
	rcount = ccount = r = c = 0;
	rune = find(rune, classname, "rune");
	while(rune)
	{
		if(rune.owner == pl)
			rcount = rcount + 1;
		rune = find(rune, classname, "rune");
	}
	curse = find(curse, classname, "curse");
	while(curse)
	{
		if(curse.owner == pl)
			ccount = ccount + 1;
		curse = find(curse, classname, "curse");
	}

	numtodrop = cvar("g_runematch_drop_runes_max");
	prevent_same = !cvar("g_runematch_allow_same");

	rune = curse = world;
	do
	{
		rune = find(rune, classname, "rune");
		if(!rune)
			break;
		if(rune.owner != pl)
			continue;


		// find a random curse
		tries = 15;
		if(ccount > 1 && prevent_same)
		{
			// avoid pairing runes and curses that match each other
			do{
				rand = floor(random()*ccount) + 1;
				curse = FindRune(pl, "curse", rand);
				tries = tries - 1;
			}while(RuneMatchesCurse(rune.runes, curse.runes) && tries > 0);
			if(tries <= 0)
			{
				bprint("warning: couldn't prevent same rune\n");
			}
		}
		else
		{
				rand = floor(random()*ccount) + 1;
				curse = FindRune(pl, "curse", rand);
		}

		if(!curse)
			error("Couldn't fine curse to bind rune to\n");

		// pair rune and curse

		rune1 = rune;
		curse1 = curse;
		rune2 = curse1.enemy;
		curse2 = rune1.enemy;

		if(rune1 != rune2) // not already attached to each other
		{
			rune1.enemy = curse1;
			curse1.enemy = rune1;
			setattachment(curse1, rune1, "");
			rune2.enemy = curse2;
			curse2.enemy = rune2;
			setattachment(curse2, rune2, "");
			//DropRune(pl, rune2);
			//ccount = ccount - 1;
			//rcount = rcount - 1;
		}
		DropRune(pl, rune1);

		if(numtodrop <=0)
		{
			rune1.think = rune_respawn;
			rune1.nextthink = time;
		}

		numtodrop = numtodrop - 1;

		ccount = ccount - 1;
		rcount = rcount - 1;

	}while(rune);
}

void spawn_default_runespawnpoints()
{
	entity spot, e;
	spot = find(world, classname, "info_player_deathmatch");
	while(spot)
	{
		e = spawn();
		e.classname = "runematch_spawn_point";
		e.origin = spot.origin;
		spot = find(spot, classname, "info_player_deathmatch");
	}
}

void rune_reset()
{
	if(self.owner)
		if(self.owner.classname != "runematch_spawn_point")
			DropAllRunes(self.owner);
	rune_respawn();
}

void spawn_runes()
{
	float r, num, max_num, rn, cs, numrunes, runes_left, curses_left, tries, prevent_same;
	entity e, spot;

	if(self)
		remove(self);

	// fixme: instead of placing them all now, why not
	// simply create them all and let them call rune_respawn() as their think?

	runes_left  = RUNE_STRENGTH | RUNE_DEFENSE | RUNE_REGEN | RUNE_SPEED | RUNE_VAMPIRE;
	curses_left = CURSE_WEAK | CURSE_VULNER | CURSE_VENOM | CURSE_SLOW | CURSE_EMPATHY;
	numrunes = 5;
	max_num = num = count_rune_spawnpoints();

	if(num < numrunes)
	{
		spawn_default_runespawnpoints();
	}

	prevent_same = !cvar("g_runematch_allow_same");

	max_num = num = count_rune_spawnpoints();

	if(num < numrunes)
		error(strcat("not enough spawn points for runematch, need ", ftos(numrunes), " but found ", ftos(num), "\n"));

	while(numrunes > 0)
	{
		r = floor(random()*numrunes) + 1;
		if(r == 1)
			rn = RUNE_STRENGTH;
		else if(r == 2)
			rn = RUNE_DEFENSE;
		else if(r == 3)
			rn = RUNE_REGEN;
		else if(r == 4)
			rn = RUNE_SPEED;
		else
			rn = RUNE_VAMPIRE;

		if(curses_left > 1 && prevent_same)
		{
			tries = 15;
			// avoid pairing runes and curses that match each other
			do{
				r = floor(random()*numrunes) + 1;
				if(r == 1)
					cs = CURSE_WEAK;
				else if(r == 2)
					cs = CURSE_VULNER;
				else if(r == 3)
					cs = CURSE_VENOM;
				else if(r == 4)
					cs = CURSE_SLOW;
				else
					cs = CURSE_EMPATHY;
				tries = tries - 1;
			}while(RuneMatchesCurse(rn, cs) && tries > 0);
			if(tries <= 0)
			{
				bprint("warning: couldn't prevent same rune\n");
			}
		}
		else
		{
			r = floor(random()*numrunes) + 1;
			if(r == 1)
				cs = CURSE_WEAK;
			else if(r == 2)
				cs = CURSE_VULNER;
			else if(r == 3)
				cs = CURSE_VENOM;
			else if(r == 4)
				cs = CURSE_SLOW;
			else
				cs = CURSE_EMPATHY;
		}



		if(num <= 1)
			r = 1;
		else
			r = floor(random()*num*1.25) + 1;

		spot = rune_find_spawnpoint(num, r);

		if(spot == world)
		{
			error("failed to find runematch spawnpoint!\n");
		}

		// choose and spawn rune

/*		//rn = RUNE_FIRST;
		while(!runes_left & rn && rn <= RUNE_LAST)
			rn = rn * 2;
		if(rn > RUNE_LAST)
			error("couldn't select rune\n");
		runes_left = runes_left - rn;

		//cs = CURSE_FIRST;
		while(!curses_left & cs && cs <= CURSE_LAST)
			cs = cs * 2;
		if(cs > CURSE_LAST)
			error("couldn't select rune\n");
		curses_left = curses_left - cs;
*/
		while(!runes_left & rn)
		{
			rn = rn * 2;
			if(rn > RUNE_LAST)
				rn = RUNE_FIRST;
		}
		runes_left = runes_left - rn;

		while(!curses_left & cs)
		{
			cs = cs * 2;
			if(cs > CURSE_LAST)
				cs = CURSE_FIRST;
		}
		curses_left = curses_left - cs;

		e = spawn();
		e.runes = rn;
		e.classname = "rune";
		e.touch = rune_touch;
		e.think = rune_respawn;
		e.nextthink = time + random();
		e.movetype = MOVETYPE_TOSS;
		e.solid = SOLID_TRIGGER;
		e.flags = FL_ITEM;
		e.reset = rune_reset;
		setmodel(e, "models/runematch/rune.mdl"); // precision set below
		setorigin(e, spot.origin);
		setsize(e, '0 0 -35', '0 0 0');

		e.enemy = spawn();
		e.enemy.enemy = e;
		e.enemy.classname = "curse";
		e.enemy.runes = cs;
		//e.enemy.avelocity = '300 500 200';
		setmodel(e.enemy, "models/runematch/curse.mdl"); // precision set below
		setorigin(e, '0 0 0');
		setattachment(e.enemy, e, "");


		e.colormod = RuneColormod(rn);
		e.enemy.colormod = RuneColormod(cs);

		e.alpha = e.enemy.alpha = cvar("g_runematch_rune_alpha");//0.78;
		e.effects = e.enemy.effects = cvar("g_runematch_rune_effects") | EF_LOWPRECISION;//EF_ADDITIVE;// | EF_FULLBRIGHT;

		//e.glow_size = e.enemy.glow_size = cvar("g_runematch_rune_glow_size");
		//e.glow_color = e.enemy.glow_color = cvar("g_runematch_rune_glow_color");

		// this spot is taken
		spot.owner = e;
		e.owner = spot;


		//rn = RUNE_FIRST;
		//cs = CURSE_FIRST;

		numrunes = numrunes - 1;
		num = num - 1;
	}
}

void runematch_init()
{
	if(!g_runematch)
		return;

	entity e;
	e = spawn();
	e.think = spawn_runes;
	e.nextthink = time + 0.1;
}


float runematch_point_time;

// give points to players who are holding runes
void RuneMatchGivePoints()
{
	entity rune;

	if(!g_runematch || !cvar("g_runematch_pointamt"))
		return;

	if(gameover)
		return;

	if(runematch_point_time > time)
		return;

	runematch_point_time = time + cvar("g_runematch_pointrate");

	rune = world;
	do
	{
		rune = find(rune, classname, "rune");
		if(!rune)
			return;

		if(rune.owner.classname == "player")
		{
			UpdateFrags(rune.owner, cvar("g_runematch_pointamt"));
		}
	}while(rune);
}

float RunematchHandleFrags(entity attacker, entity targ, float f)
{
	entity head;
	float arunes, trunes, newfrags;

	if(f <= 0)
		return f;
	if(attacker == targ)
		return f;

	arunes = trunes = 0;

	head = find(world, classname, "rune");
	while(head)
	{
		if(head.owner == attacker)
		{
			arunes = arunes + 1;
		}
		else if(head.owner == targ)
		{
			trunes = trunes + 1;
		}

		head = find(head, classname, "rune");
	}

	if(!arunes && !trunes)
		return f - 1 + cvar("g_runematch_frags_norune"); // don't give points to players when no runes are involved.

	if(arunes)
	{	// got a kill while holding runes
		newfrags = newfrags + cvar("g_runematch_frags_killedby_runeholder");//5;
	}
	if(trunes)
	{	// killed an enemy holding runes
		newfrags = newfrags + cvar("g_runematch_frags_killed_runeholder");//5;
	}
	if(newfrags)
		f = f - 1 + newfrags;

	return f;
}
