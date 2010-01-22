// WEAPON PLUGIN SYSTEM
entity weapon_info[24];
entity dummy_weapon_info;

void register_weapon(float id, float(float) func, float ammotype, float i, float weapontype, float pickupbasevalue, string modelname, string shortname, string wname)
{
	entity e;
	weapon_info[id - 1] = e = spawn();
	e.classname = "weapon_info";
	e.weapon = id;
	e.weapons = power2of(id - WEP_FIRST);
	e.netname = shortname;
	e.message = wname;
	e.items = ammotype;
	e.weapon_func = func;
	e.mdl = modelname;
	e.model = strzone(strcat("models/weapons/g_", modelname, ".md3"));
	e.spawnflags = weapontype;
	e.model2 = strzone(strcat("wpn-", e.mdl));
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
	dummy_weapon_info.weapon = 0; // you can recognize dummies by this
	dummy_weapon_info.weapons = 0; // you can recognize dummies by this too
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
string W_NameWeaponOrder_MapFunc(string s)
{
	entity wi;
	if(s == "0" || stof(s))
	{
		wi = get_weaponinfo(stof(s));
		if(wi != dummy_weapon_info)
			return wi.netname;
	}
	return s;
}
string W_NameWeaponOrder(string order)
{
	return mapPriorityList(order, W_NameWeaponOrder_MapFunc);
}
string W_NumberWeaponOrder_MapFunc(string s)
{
	float i;
	if(s == "0" || stof(s))
		return s;
	for(i = WEP_FIRST; i <= WEP_LAST; ++i)
		if(s == get_weaponinfo(i).netname)
			return ftos(i);
	return s;
}
string W_NumberWeaponOrder(string order)
{
	return mapPriorityList(order, W_NumberWeaponOrder_MapFunc);
}
