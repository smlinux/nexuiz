float (entity e, float healamount, float ignore) T_Heal =
{
	if ((e.health <= 0))
	{
		return (0);
	}
	if ((!ignore && (e.health >= e.max_health)))
	{
		return (0);
	}
	healamount = ceil (healamount);
	e.health = (e.health + healamount);
	if ((!ignore && (e.health >= e.max_health)))
	{
		e.health = e.max_health;
	}
	if ((e.health > 250))
	{

		e.health = 250;
	}
	/*					// There are no snipers in NexTF
	if (e.leg_damage)
	{
		if ((e.health > 95))
		{
			e.leg_damage = 0;
		}
		else
		{
			e.leg_damage = (e.leg_damage - ceil ((e.health / 20)));
		}
		if ((e.leg_damage < 1))
		{
			e.leg_damage = 0;
		}
		TeamFortress_SetSpeed (e);
	}*/
	return (1);
};

// Pre-Packed TeamNexuiz items/entities :)
//backpack
.string cells;
.string shells;
.string rockets;
.string nails;
.string grenade1;
.string grenade2;
.string armor;

// TF Map rules
.string team1limit;
.string team2limit;
.string team3limit;
.string team4limit;

//	Moved the below to tfdefs. These are the "Map_Rules" entity's class restricts.
/*.float team1_scout, team1_soldier, team1_medic, team1_pyro, team1_spy, team1_engineer;
.float team2_scout, team2_soldier, team2_medic, team2_pyro, team2_spy, team2_engineer;
.float team3_scout, team3_soldier, team3_medic, team3_pyro, team3_spy, team3_engineer;
.float team4_scout, team4_soldier, team4_medic, team4_pyro, team4_spy, team4_engineer;*/

void () Map_Rules =
{
	local entity infoent;		// our class restricts info entity is spaned here
	infoent = spawn();
	infoent.classname = "class_restrictions";
	copyentity (self, infoent);

	// Amount of teams available on a map are determined by spawn points
	if (self.team1limit)
		self.ammo_medikit = stof(self.team1limit);
	if (self.team2limit)
		self.ammo_detpack = stof(self.team2limit);
	if (self.team3limit)
		self.maxammo_medikit = stof(self.team3limit);
	if (self.team4limit)
		self.maxammo_detpack = stof(self.team4limit);

	info_tfdetect();
};

// Team:Nexuiz backpack
void () item_backpack =
{
	if ((!self.mdl) && (!self.model))
	{
		self.model = "models/objects/backpack/backpack.md3";
	}
	if (self.cells)
		self.ammo_cells = stof(self.cells);
	if (self.shells)
		self.ammo_shells = stof(self.shells);
	if (self.rockets)
		self.ammo_rockets = stof(self.rockets);
	if (self.nails)
		self.ammo_nails = stof(self.nails);
	if (self.grenade1)
		self.no_grenades_1 = stof(self.grenade1);
	if (self.grenade2)
		self.no_grenades_2 = stof(self.grenade2);
	if (self.armor)
		self.armorvalue = stof(self.armor);
	if ((!self.delay) && (!self.wait))
		self.wait = 10;			// next time item can be used

	ConvertToBackPack();		// finish conversion using q3f conversion func
};
