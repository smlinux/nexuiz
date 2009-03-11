// WEAPON PLUGIN SYSTEM
entity weapon_info[24];
entity dummy_weapon_info;

void register_weapon_real(float id, float(float) func, float ammotype, float i, float normalweapon, float canclimb, float pickupbasevalue, string modelname, string shortname, string wname)
{
	entity e;
	weapon_info[id - 1] = e = spawn();
	e.classname = "weapon_info";
	e.weapon = id;
	e.weapons = power2of(id - 1);
	e.netname = shortname;
	e.message = wname;
	e.items = ammotype;
	e.weapon_func = func;
	e.mdl = modelname;
	e.model = strzone(strcat("models/weapons/g_", modelname, ".md3"));
	e.spawnflags = 0;
	e.model2 = strzone(strcat("wpn-", e.mdl));
	if(normalweapon)
		e.spawnflags |= WEPSPAWNFLAG_NORMAL;
	if(canclimb)
		e.spawnflags |= WEPSPAWNFLAG_CANCLIMB;
	e.impulse = i;
	e.bot_pickupbasevalue = pickupbasevalue;
}
float w_null(float dummy)
{
	return 0;
}
void register_weapons_done()
{
	entity wi;

	dummy_weapon_info = spawn();
	dummy_weapon_info.classname = "weapon_info";
	dummy_weapon_info.weapon = 0;
	dummy_weapon_info.weapons = 0;
	dummy_weapon_info.netname = "@!#%'n Tuba";
	dummy_weapon_info.items = 0;
	dummy_weapon_info.weapon_func = w_null;
	dummy_weapon_info.mdl = "";
	dummy_weapon_info.model = "";
	dummy_weapon_info.spawnflags = 0;
	dummy_weapon_info.impulse = -1;
	dummy_weapon_info.bot_pickupbasevalue = 0;
	dummy_weapon_info.model2 = "";

	float i;
	weaponpriority_hudselector_0 = "";
	for(i = 24; i >= 1; --i)
		if(weapon_info[i-1])
			weaponpriority_hudselector_0 = strcat(weaponpriority_hudselector_0, " ", ftos(i));

	float imp;
	weaponpriority_hudselector_1 = "";
	for(i = 1; i <= 24; ++i)
	{
		wi = weapon_info[i-1];
		if(wi && wi.impulse == 0)
			weaponpriority_hudselector_1 = strcat(weaponpriority_hudselector_1, " ", ftos(i));
	}
	for(imp = 9; imp > 0; --imp)
		for(i = 1; i <= 24; ++i)
		{
			wi = weapon_info[i-1];
			if(wi && wi.impulse == imp)
				weaponpriority_hudselector_1 = strcat(weaponpriority_hudselector_1, " ", ftos(i));
		}

	weaponpriority_hudselector_0 = strzone(substring(weaponpriority_hudselector_0, 1, strlen(weaponpriority_hudselector_0) - 1));
	weaponpriority_hudselector_1 = strzone(substring(weaponpriority_hudselector_1, 1, strlen(weaponpriority_hudselector_1) - 1));
}
entity get_weaponinfo(float id)
{
	entity w;
	if(id < WEP_FIRST || id > WEP_LAST)
		return dummy_weapon_info;
	w = weapon_info[id - 1];
	if(w)
		return w;
	return dummy_weapon_info;
}
string W_FixWeaponOrder(string order, float complete)
{
	return fixPriorityList(order, WEP_FIRST, WEP_LAST, 230 - WEP_FIRST, complete);
}

#ifdef SVQC
#define register_weapon(id,func,ammotype,i,normalweapon,canclimb,pickupbasevalue,modelname,shortname,wname) \
	register_weapon_real(id,func,ammotype,i,normalweapon,canclimb,pickupbasevalue,modelname,shortname,wname)
#else
// no weapon funcs here!
#define register_weapon(id,func,ammotype,i,normalweapon,canclimb,pickupbasevalue,modelname,shortname,wname) \
	register_weapon_real(id,w_null,ammotype,i,normalweapon,canclimb,pickupbasevalue,modelname,shortname,wname)
#endif

void RegisterWeapons()
{
	// %weaponaddpoint
	register_weapon(WEP_LASER,            w_laser,        0,          1, 1, 1, 0,                      "laser",        "laser",           "Laser");
	register_weapon(WEP_SHOTGUN,          w_shotgun,      IT_SHELLS,  2, 1, 0, BOT_PICKUP_RATING_LOW,  "shotgun",      "shotgun",         "Shotgun");
	register_weapon(WEP_UZI,              w_uzi,          IT_NAILS,   3, 1, 0, BOT_PICKUP_RATING_MID,  "uzi",          "uzi",             "Machine Gun");
	register_weapon(WEP_GRENADE_LAUNCHER, w_glauncher,    IT_ROCKETS, 4, 1, 1, BOT_PICKUP_RATING_MID,  "gl",           "grenadelauncher", "Mortar");
	register_weapon(WEP_ELECTRO,          w_electro,      IT_CELLS,   5, 1, 0, BOT_PICKUP_RATING_MID,  "electro",      "electro",         "Electro");
	register_weapon(WEP_CRYLINK,          w_crylink,      IT_CELLS,   6, 1, 0, BOT_PICKUP_RATING_MID,  "crylink",      "crylink",         "Crylink");
	register_weapon(WEP_NEX,              w_nex,          IT_CELLS,   7, 1, 0, BOT_PICKUP_RATING_HIGH, "nex",          "nex",             "Nex");
	register_weapon(WEP_HAGAR,            w_hagar,        IT_ROCKETS, 8, 1, 1, BOT_PICKUP_RATING_MID,  "hagar",        "hagar",           "Hagar");
	register_weapon(WEP_ROCKET_LAUNCHER,  w_rlauncher,    IT_ROCKETS, 9, 1, 1, BOT_PICKUP_RATING_HIGH, "rl",           "rocketlauncher",  "Rocket Launcher");
	register_weapon(WEP_PORTO,            w_porto,        0,          0, 0, 0, 0,                      "porto" ,       "porto",           "Port-O-Launch");
	register_weapon(WEP_MINSTANEX,        w_minstanex,    IT_CELLS,   7, 0, 1, BOT_PICKUP_RATING_HIGH, "minstanex",    "minstanex",       "MinstaNex");
	register_weapon(WEP_HOOK,             w_hook,         IT_CELLS,   0, 0, 1, 0,                      "hookgun",      "hook",            "Grappling Hook");
	register_weapon(WEP_SEEKER,           w_seeker,       IT_ROCKETS, 8, 0, 0, BOT_PICKUP_RATING_HIGH, "seeker",       "seeker",          "T.A.G. Seeker");
	register_weapon(WEP_HLAC,             w_hlac,         IT_CELLS,   6, 1, 0, BOT_PICKUP_RATING_MID,  "hlac",         "hlac",            "Heavy Laser Assault Cannon");
	register_weapon(WEP_CAMPINGRIFLE,     w_campingrifle, IT_NAILS,   3, 1, 0, BOT_PICKUP_RATING_MID,  "campingrifle", "campingrifle",    "Rifle");

	register_weapons_done();
}
