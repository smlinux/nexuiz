/*~
========================================
	Custom TF/BeyondTF Tesla Coil
========================================
	Originally made for Custom TF
	Borrowed from Catch22's BeyondTF
	Modified by XavioR (aka avirox) for MegaTF United and Team:Nexuiz
																		~*/

float () Tesla_Fire;
float () Tesla_FindTarget;
void () Tesla_FoundTarget;

.float frame_loop;
void () Tesla_Animate =
{
	if (self.owner.health <= 0 || (!self.owner))
		dremove(self);

	if (self.owner.effects == (self.owner.effects | 8))
	{
		if (self.owner.frame > 3)
			self.owner.frame = 0;
		else if (self.owner.frame == 0)
			self.owner.frame = 1;
		else if (self.owner.frame == 1)
			self.owner.frame = 2;
		else if (self.owner.frame == 2)
			self.owner.frame = 3;
	}
	else 
	{
		if (self.frame_loop == 0)
			self.frame = 5;
		else if (self.frame_loop == 1)
			self.owner.frame = 6;
		else if (self.frame_loop == 2)
			self.owner.frame = 7;
		else if (self.frame_loop == 3)
			self.owner.frame = 8;
		else if (self.frame_loop == 4)
			self.owner.frame = 9;
		else if (self.frame_loop == 5)
			self.owner.frame = 8;
		else if (self.frame_loop == 6)
			self.owner.frame = 7;
		else if (self.frame_loop == 7)
			self.owner.frame = 6;
		else if (self.frame_loop == 8)
			self.owner.frame = 5;
		else if (self.frame_loop == 9) {
			self.owner.frame = 4;
			self.frame_loop = -1;
		}
		self.frame_loop = self.frame_loop + 1;
	}

	self.nextthink = time + .05;
};


void () Tesla_Idle =
{
	if (self.waitmax)
	{
		self.waitmax = Tesla_Fire ();
	}
	if ((self.waitmax == 0))
	{
		if (Tesla_FindTarget ())
		{
			self.waitmax = 1;
		}
		else
		{
			self.effects = (self.effects - (self.effects & 8));
			self.nextthink = (time + 0.250000);
		}
	}
	self.think = Tesla_Idle;
};

float () Tesla_FindTarget =
{
	local entity client;
	local entity te;
	local float r;
	local float gotone;
	local float loopc;

	if ((self.tf_items & 2))
	{
		self.origin_z = (self.origin_z - 40);
	}
	else
	{
		self.origin_z = (self.origin_z + 24);
	}
	r = 0;
	loopc = 0;
	gotone = 0;
	while (((loopc < 8) && (gotone == 0)))
	{
		client = checkclient ();
		te = find (world, classname, "bot");
		if (te)
		{
			if (te.health)
			{
				if (visible (te))
				{
					client = te;
				}
			}
		}
		gotone = 1;
		if (!client)
		{
			gotone = 0;
		}
		if ((client.playerclass == 0))
		{
			gotone = 0;
		}
		if ((client.health <= 0))
		{
			gotone = 0;
		}
		if (client.has_disconnected)
		{
			gotone = 0;
		}
		if (teamplay)
		{
			if (((client.team_no == self.team_no) && (self.team_no != 0)))
			{
				gotone = 0;
			}
			if (((client.undercover_team == self.team_no) && (self.team_no != 0)))
			{
				if (!(self.tf_items & 1024))
				{
					gotone = 0;
				}
			}
		}
		if ((client == self.real_owner))
		{
			gotone = 0;
		}
/*		if (client.is_feigning)				// no feigning in NTF (yet?)
		{
			if (!(self.tf_items & 1024))
			{
				gotone = 0;
			}
		}*/
		if ((client.flags & 128))
		{
			gotone = 0;
		}
		if ((client.items & 524288))
		{
			gotone = 0;
		}
		if (!visible (client))
		{
			gotone = 0;
		}
		r = vlen ((client.origin - self.origin));
		if (((self.ammo_shells == 0) && (r > 400)))
		{
			gotone = 0;
		}
		if (((self.ammo_shells == 1) && (r > 800)))
		{
			gotone = 0;
		}
		if (((self.ammo_shells == 2) && (r > 1200)))
		{
			gotone = 0;
		}
		loopc = loopc + 1;
		if (gotone)
		{
			loopc = 1000;
		}
	}
	if ((self.tf_items & 2))
	{
		self.origin_z = (self.origin_z + 40);
	}
	else
	{
		self.origin_z = (self.origin_z - 24);
	}
	if (!gotone)
	{
		return (0);
	}
	if ((self.enemy == client))
	{
		return (Tesla_Fire ());
	}
	self.enemy = client;
	if (((self.enemy.classname != "player") && (self.enemy.classname != "bot")))
	{
		self.enemy = self.enemy.enemy;
		if (((self.enemy.classname != "player") && (self.enemy.classname != "bot")))
		{
			self.enemy = world;
			return (0);
		}
	}
	Tesla_FoundTarget ();
	return (1);
};

void () Tesla_FoundTarget =
{
	if ((self.ammo_cells > self.waitmin))
	{
		sound (self, 2, "weapons/guerilla_set.wav", 1, 1);
	}
	self.effects = (self.effects | 8);
	self.goalentity = self.enemy;
	if ((self.ammo_nails <= 1))
	{
		self.nextthink = (time + 1);
	}
	else
	{
		if ((self.ammo_nails == 2))
		{
			self.nextthink = (time + 0.500000);
		}
		else
		{
			self.nextthink = (time + 1.500000);
		}
	}
	if ((self.enemy.modelindex == modelindex_null))
	{
		self.nextthink = (self.nextthink + 2);
	}
	else
	{
		if ((self.enemy.modelindex == modelindex_eyes))
		{
			self.nextthink = (self.nextthink + 1.500000);
		}
	}
	if ((self.tf_items & 1))
	{
		self.nextthink = (time + 0.500000);
	}
};

void () Tesla_Pain =
{
	self.real_owner.StatusRefreshTime = (time + 0.200000);
};

void () Tesla_Die =
{
	sprint (self.real_owner, "Your tesla coil was destroyed.\n");
	self.real_owner.has_tesla = 0;
	self.real_owner.has_turretized_tesla = 0;
/*	ThrowGib ("progs/tgib1.mdl", -70);			// use other explosion method?
	ThrowGib ("progs/tgib2.mdl", -70);
	ThrowGib ("progs/tgib3.mdl", -70);*/
	WriteByte (4, 23);
	WriteByte (4, 3);
	WriteCoord (4, self.origin_x);
	WriteCoord (4, self.origin_y);
	WriteCoord (4, self.origin_z);
//	multicast (self.origin, 1);			// where are my scriptable particles? :(
	BecomeExplosion ();
};

float () Tesla_Fire =
{
	local vector dir;
	local float damage;

	dir = self.enemy.origin - self.origin;
	if ((self.enemy.classname == "bot"))
	{
		dir = (self.enemy.origin + '0 0 -35') - self.origin;
	}
	if (!self.enemy)
	{
		return (0);
	}
	if ((self.enemy == world))
	{
		return (0);
	}
	if (self.enemy.has_disconnected)
	{
		self.enemy = world;
		return (0);
	}
/*	if (self.enemy.is_feigning)			// no feigning yet
	{
		if (!(self.tf_items & 1024))
		{
			return (0);
		}
	}*/
	if ((self.tf_items & 2))
	{
		self.origin_z = (self.origin_z - 40);
	}
	else
	{
		self.origin_z = (self.origin_z + 24);
	}
	if (!visible (self.enemy))
	{
		if ((self.tf_items & 2))
		{
			self.origin_z = (self.origin_z + 40);
		}
		else
		{
			self.origin_z = (self.origin_z - 24);
		}
		return (0);
	}
	self.ammo_cells = (self.ammo_cells - self.waitmin);
	if ((self.ammo_cells < 0))
	{
		self.ammo_cells = 0;
		if ((self.tf_items & 2))
		{
			self.origin_z = (self.origin_z + 40);
		}
		else
		{
			self.origin_z = (self.origin_z - 24);
		}
		self.enemy = world;
		return (0);
	}
	self.effects = (self.effects | 8);
	deathmsg = 51;
	WriteByte (4, 23);
	WriteByte (4, 6);
	WriteEntity (4, self);
	WriteCoord (4, self.origin_x);
	WriteCoord (4, self.origin_y);
	WriteCoord (4, (self.origin_z + 24));
	WriteCoord (4, self.enemy.origin_x);
	WriteCoord (4, self.enemy.origin_y);
	WriteCoord (4, self.enemy.origin_z);
//	void(entity own, vector start, vector end) te_lightning2 = #429;
//	te_lightning2(self, self.origin, self.enemy.origin);
//	multicast (self.origin, 1);	
	sound (self, 1, "weapons/tesla.wav", 1, 1);
	if ((self.ammo_nails == 0))
	{
		damage = 40;
	}
	if ((self.ammo_nails == 1))
	{
		damage = 100;
	}
	if ((self.ammo_nails == 2))
	{
		damage = 200;
	}
	if ((self.ammo_nails == 3))
	{
		damage = 400;
	}

	TF_T_Damage (self.enemy, self, self.real_owner, damage, 2, 8);
	if ((self.ammo_nails <= 1))
	{
		self.nextthink = (time + 1.500000);
	}
	else
	{
		if ((self.ammo_nails == 2))
		{
			self.nextthink = (time + 1);
		}
		else
		{
			self.nextthink = (time + 2);
		}
	}
	if (((self.ammo_cells == 0) && (random () < 0.100000)))
	{
		sprint (self.real_owner, "Tesla is out of cells.\n");
	}
	else
	{
		if ((self.ammo_cells <= self.waitmin))
		{
			sprint (self.real_owner, "Tesla is low on cells.\n");
		}
	}
	if ((self.tf_items & 2))
	{
		self.origin_z = (self.origin_z + 40);
	}
	else
	{
		self.origin_z = (self.origin_z - 24);
	}
	if ((self.enemy.health <= 0))
	{
		self.enemy = world;
		return (0);
	}
	return (1);
};

void () Tesla_Touch =
{
	if ((pointcontents (self.origin) == -6))
	{
		sprint (self.real_owner, "Your sentry gun flew away.\n");
		Tesla_Die ();
		return;
	}
	if ((other.takedamage && !(self.tf_items & 2)))
	{
		deathmsg = 52;
		if ((((other.team_no > 0) && (other.team_no != self.real_owner.team_no)) && (other.is_undercover != 1)))
		{
			TF_T_Damage (other, self, self.real_owner, 400, 2, 8);
		}
		return;
	}
	if (((self.tf_items & 2) && (self.movetype == 5)))
	{
		if (((((((((pointcontents (self.origin) == -6) || (pointcontents ((self.origin - '0 0 10')) == -6)) || (pointcontents ((self.origin + '0 0 5')) == -6)) || (pointcontents ((self.origin + '0 0 10')) == -6)) || (pointcontents ((self.origin + '0 0 15')) == -6)) || (pointcontents ((self.origin + '0 0 20')) == -6)) || (pointcontents ((self.origin + '0 0 30')) == -6)) || (pointcontents ((self.origin + '0 0 40')) == -6)))
		{
			sprint (self.real_owner, "Your sentry gun flew away.\n");
			Tesla_Die ();
			return;
		}
		if ((other == world))
		{
			self.flags = (self.flags | 512);
			self.movetype = 4;
			self.origin_z = (self.origin_z + 40);
			return;
		}
		else
		{
			if ((other.classname == "player"))
			{
				deathmsg = 52;
				TF_T_Damage (other, self, self.real_owner, 400, 2, 8);
			}
		}
		Tesla_Die ();
	}
};
