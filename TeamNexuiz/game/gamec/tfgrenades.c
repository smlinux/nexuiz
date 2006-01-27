entity msg_entity;
void () TeamFortress_GrenadePrimed;
.float grenade_timer;
.float FlashTime;
void () CP_Timer;

/*=======================
 General grenade explode
 ======================*/
void () GrenadeExplode =
{
/*	if (self.voided)
	{
		return;
	}
	self.voided = 1;
	if ((self.classname == "pipebomb"))
	{
		num_world_pipebombs = (num_world_pipebombs - 1);
		decrement_team_pipebombs (self.team_no);
		if (!(self.flags & 512))
		{
			self.weapon = 40;
		}
	}*/
	if ((self.owner.has_disconnected != 1))
	{
		deathmsg = self.weapon;
		T_RadiusDamage (self, self.owner, 120, world);
	}
/*	local entity te;
	if ((self.no_active_nail_grens != 0))
	{
		self.no_active_nail_grens = 0;
		self.owner.no_active_nail_grens = (self.owner.no_active_nail_grens - 1);
		te = find (world, classname, "grenade");
		while (te)
		{
			if (((te.owner == self.owner) && (te.no_active_nail_grens != 0)))
			{
				te.no_active_nail_grens = (te.no_active_nail_grens - 1);
			}
			te = find (te, classname, "grenade");
		}
	}*/
	WriteByte (0, 23);
	WriteByte (0, 3);
	WriteCoord (0, self.origin_x);
	WriteCoord (0, self.origin_y);
	WriteCoord (0, self.origin_z);
	BecomeExplosion ();
};

// TF Recoil? Anyhoo, this entity causes oddities :/
void(float psize, entity p) KickPlayer = 
{
	return;			// temp
	msg_entity = p;
	if (psize > -3)
	{
		WriteByte(1, 34);
	}
	else
	{
		WriteByte(1, 35);
	}
};

/* ================
 Flash grenade
  ===============*/
void () FlashGrenadeTouch =
{
	sound (self, 1, "weapons/bounce.wav", 1, 1);
	if ((self.velocity == '0 0 0'))
	{
		self.avelocity = '0 0 0';
	}
};

void () FlashTimer =
{
	local entity te;
	local string st;

	te = self.owner;
	te.FlashTime = (te.FlashTime - 0.100000);
	if ((te.FlashTime <= 0.000000))
	{
		te.FlashTime = 0.000000;
		stuffcmd (te, "v_cshift 0\n");
		if (te.uses_bloom)
		{
			stuffcmd (te, "r_bloom_power 2\n");
			stuffcmd (te, "r_bloom_intensity 1.5\n");
		}
		remove (self);
		return;
	}
	if ((te.FlashTime < 1.700000))
	{
		st = ftos ((te.FlashTime * 150.000000));	
		stuffcmd (te, "v_cshift ");
		stuffcmd (te, st);
		stuffcmd (te, " ");
		stuffcmd (te, st);
		stuffcmd (te, " ");
		stuffcmd (te, st);
		stuffcmd (te, " ");
		stuffcmd (te, st);
		stuffcmd (te, "\n");

		// BLOOM!!! :D
		if (te.uses_bloom)
		{
			stuffcmd (te, "r_bloom_power 1\n");
			st = ftos(2 + (te.FlashTime * 10));
			stuffcmd (te, "r_bloom_intensity ");
			stuffcmd (te, st);
			stuffcmd (te, "\n");
		}
		
	}
	if ((te.FlashTime >= 1.700000))
	{
		stuffcmd (te, "v_cshift 255 255 255 255\n");
	}
	if ((te.FlashTime <= 0.000000))
	{
		te.FlashTime = 0.000000;
		stuffcmd (te, "v_cshift 0\n");
		stuffcmd (te, "r_bloom_power 2\n");
		stuffcmd (te, "r_bloom_intensity 1.5\n");
		remove (self);
		return;
	}
	self.nextthink = (time + 0.100000);
};

void () FlashGrenadeExplode =
{
	local entity te;

	self.effects = (self.effects | 4);
	WriteByte (0, 23);
	WriteByte (0, 4);
	WriteCoord (0, self.origin_x);
	WriteCoord (0, self.origin_y);
	WriteCoord (0, self.origin_z);
	te = findradius (self.origin, 300);
	while (te)
	{
		if ((te.classname == "player" && te.team_no != self.owner.team_no || te == self.owner))
		{
			traceline (self.origin, te.origin, 1, self);
			if ((trace_fraction == 1))
			{
				if ((vlen ((self.origin - te.origin)) <= 200))
				{
					deathmsg = 35;
					TF_T_Damage (te, self, self.owner, 60, 2, (16 | 4));
				}
				if (te.health > TF_FLARE_LIT)
				{
					if (te.FlashTime == TF_FLARE_LIT)
					{
						newmis = spawn ();
						newmis.classname = "timer";
						newmis.netname = "flashtimer";
						newmis.team_no = self.owner.team_no;
						newmis.owner = te;
						newmis.think = FlashTimer;
						newmis.nextthink = (time + 0.100000);
						stuffcmd(te, "cmd check_val r_bloom $r_bloom\n");		// checks if the client has bloom enabled
					}
					te.FlashTime = 4.500000;
					stuffcmd (te, "v_cshift 255 255 255 255\n");
				}
			}
		}
		te = te.chain;
	}
	BecomeExplosion ();
};

/*=============
 Nail Grenade
 ============*/
void() NailGrenadeTouch;
void() NailGrenadeExplode;
void() NailGrenadeNailEm;
void() NailGrenadeLaunchNail;
void() GrenadeExplode;

void() NailGrenadeTouch = 
{
	if (other == self.owner)
	{
		return;
	}
	sound(self, TF_FLARE_OFF, "weapons/bounce.wav", TF_FLARE_OFF, TF_FLARE_OFF);
	if (self.velocity == '0 0 0')
	{
		self.avelocity = '0 0 0';
	}
};

void() NailGrenadeExplode = 
{
	self.movetype = 5;
	setorigin(self, self.origin + '0 0 32');
	self.avelocity = '0 500 0';
	self.nextthink = time + 0.7;
	self.think = NailGrenadeNailEm;
};

void() NailGrenadeNailEm = 
{
	self.velocity = '0 0 0';
	self.nextthink = time + 0.1;
	self.think = NailGrenadeLaunchNail;
	self.playerclass = TF_FLARE_LIT;
};

void() NailGrenadeLaunchNail = 
{
	local float i;
	local float j;
	i = TF_FLARE_LIT;
	while (i < TF_FLARE_OFF)
	{
		j = (random() + 2) * 5;
		current_yaw = anglemod(self.angles_y + j);
		self.angles_y = current_yaw;
		self.angles_x = TF_FLARE_LIT;
		self.angles_z = TF_FLARE_LIT;
		makevectors(self.angles);
		deathmsg = 99;			//temp
		launch_spike(self.origin, v_forward);
		newmis.touch = superspike_touch;
		newmis.weapon = 9;
		i = i + TF_FLARE_OFF;
	}
	self.playerclass = self.playerclass + TF_FLARE_OFF;
	self.nextthink = time + 0.1;
	if (self.playerclass > 40)
	{
		self.weapon = 9;
		self.think = GrenadeExplode;
	}
};

/*=====================
  TF Gren Prime Code
  ===================*/

void() TeamFortress_ExplodePerson = 
{
//	local entity te;
	self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & 1);
	KickPlayer(-2, self.owner);		// Doesnt wanna work right
	newmis = spawn();
	newmis.movetype = 10;
	newmis.solid = 2;
	newmis.classname = "grenade";
	newmis.team_no = self.owner.team_no;
	newmis.owner = self.owner;
	newmis.velocity = '0 0 0';
	newmis.angles = vectoangles(newmis.velocity);
	newmis.think = SUB_Null;
//	newmis.think = NormalGrenadeExplode;
	newmis.nextthink = time + 0.1;
	if (self.weapon == 1)
	{
		newmis.touch = NormalGrenadeTouch;
		newmis.think = NormalGrenadeExplode;
		newmis.skin = 0;
		newmis.avelocity = '300 300 300';
		self.owner.velocity = (((v_forward * 900) + '0 0 250') + (v_up * 100));	// Shoot the player hehe
//		setmodel(newmis, "progs/hgren2.mdl");
		setmodel(newmis, "models/grenades/fragnade.md3");
		
	}
	else
/*	{
		if (self.weapon == 2)
		{
			newmis.touch = ConcussionGrenadeTouch;
			newmis.think = ConcussionGrenadeExplode;
			newmis.skin = 1;
			newmis.avelocity = '300 300 300';
			setmodel(newmis, "progs/hgren2.mdl");
		}
		else
		{*/
			if (self.weapon == 3)
			{
				newmis.touch = NailGrenadeTouch;
				newmis.think = NailGrenadeExplode;
				newmis.skin = 1;
				newmis.avelocity = '0 300 0';
				setmodel(newmis, "progs/biggren.mdl");
			}/*
			else
			{
				if (self.weapon == 4)
				{
					newmis.touch = MirvGrenadeTouch;
					newmis.think = MirvGrenadeExplode;
					newmis.skin = 0;
					newmis.avelocity = '0 300 0';
					setmodel(newmis, "progs/biggren.mdl");
				}
				else
				{
					if (self.weapon == 5)
					{
						newmis.touch = NapalmGrenadeTouch;
						newmis.think = NapalmGrenadeExplode;
						newmis.skin = 2;
						newmis.avelocity = '0 300 0';
						setmodel(newmis, "progs/biggren.mdl");
					}
					else
					{
						if (self.weapon == 6)
						{
							sprint(self.owner, "Flare lit.\n");
							te = spawn();
							te.touch = SUB_Null;
							te.think = RemoveFlare;
							te.nextthink = time + 25;
							te.owner = self.owner;
							te.solid = 0;
							self.owner.effects = self.owner.effects | 4;
							dremove(self);
							dremove(newmis);
							return;
						}
						else
						{
							if (self.weapon == 7)
							{
								newmis.touch = GasGrenadeTouch;
								newmis.think = GasGrenadeExplode;
								newmis.skin = 2;
								newmis.avelocity = '300 300 300';
								setmodel(newmis, "progs/grenade2.mdl");
							}
							else
							{
								if (self.weapon == 8)
								{
									newmis.touch = EMPGrenadeTouch;
									newmis.think = EMPGrenadeExplode;
									newmis.skin = 4;
									newmis.avelocity = '300 300 300';
									setmodel(newmis, "progs/grenade2.mdl");
								}
								else
								{*/
									if (self.weapon == 9)
									{
										newmis.touch = FlashGrenadeTouch;
										newmis.think = FlashGrenadeExplode;
										newmis.skin = 1;
										newmis.avelocity = '300 300 300';
										setmodel(newmis, "progs/grenade2.mdl");
									}/*
								}
							}
						}
					}
				}
			}
		}
	}*/
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, self.owner.origin);
	bprint("No ");
	bprint(self.owner.netname);
	bprint(", throw the grenade, not the pin!\n");
	dremove(self);
};

void() NormalGrenadeTouch = 
{
	if (other == self.owner)
	{
		return;
	}
	sound(self, 1, "weapons/bounce.wav", 1, 1);
	if (self.velocity == '0 0 0')
	{
		self.avelocity = '0 0 0';
	}
};

void () NormalGrenadeExplode =
{
	deathmsg = 88;
	T_RadiusDamage (self, self.owner, 180, world);
	WriteByte (0, 23);
	WriteByte (0, 3);
	WriteCoord (0, self.origin_x);
	WriteCoord (0, self.origin_y);
	WriteCoord (0, self.origin_z);
	BecomeExplosion ();
};

// TF Prime Grenade Function
void () TeamFortress_PrimeGrenade =
{
	local float gtype;
	local string gs;
	local string ptime;
	local entity tGrenade;

	if (((self.tfstate & 1) || (self.tfstate & 1024) || self.is_feigning == 1))
	{
		return;
	}
	if ((self.impulse == 150))
	{
		gtype = self.tp_grenades_1;
		
		if ((self.tp_grenades_1 == 2))
		{
			gs = "Concussion grenade";
		}
		else
		{
			if ((self.tp_grenades_1 == 3))
			{
				gs = "Nail grenade";
			}
			else
			{
				if ((self.tp_grenades_1 == 4))
				{
					gs = "Mirv grenade";
				}
				else
				{
					if ((self.tp_grenades_1 == 5))
					{
						gs = "Napalm grenade";
					}
					else
					{
						if ((self.tp_grenades_1 == 6))
						{
							gs = "Flare";
						}
						else
						{
							if ((self.tp_grenades_1 == 7))
							{
								gs = "Gas grenade";
							}
							else
							{
								if ((self.tp_grenades_1 == 8))
								{
									gs = "EMP grenade";
								}
								else
								{
									if ((self.tp_grenades_1 == 10))
									{
										gs = "Caltrop canister";
									}
									else
									{
										if ((self.tp_grenades_1 == 9))
										{
											gs = "Flash grenade";
										}
										else
										{
											gs = "Grenade";
										}
									}
								}
							}
						}
					}
				}
			}
		}
//		gs = "Grenade";

		if ((self.no_grenades_1 > 0))
		{
			self.no_grenades_1 = (self.no_grenades_1 - 1);
			/*if ((gtype == 6))
			{
				newmis = spawn ();
				newmis.owner = self;
				newmis.movetype = 6;
				newmis.solid = 2;
				newmis.classname = "grenade";
				makevectors (self.v_angle);
				newmis.velocity = ((v_forward * 600) + (v_up * 25));
				newmis.velocity = (newmis.velocity * 700);
				newmis.angles = vectoangles (newmis.velocity);
				newmis.weapon = self.team_no;
				newmis.think = FlareGrenadeExplode;
				newmis.nextthink = (time + 0.8);
				newmis.touch = FlareGrenadeTouch;
				newmis.skin = 1;
				newmis.mdl = "flare";
				setmodel (newmis, "progs/flare.mdl");
				setsize (newmis, '0 0 0', '0 0 0');
				setorigin (newmis, self.origin);
				return;
			}*/
			if ((gtype == 10))
			{
				ptime = ftos (0.5);
				sprint (self, "Opening ");
				sprint (self, gs);
				sprint (self, "...\n");
			}
			else
			{
				sound (self, CHAN_WEAPON, "weapons/prime.wav", 1, ATTN_STATIC);
				sound (self, CHAN_AUTO, "weapons/gren.wav", 1, ATTN_STATIC);
				ptime = ftos (3);
				sprint (self, gs);
				sprint (self, " primed, ");
				sprint (self, ptime);
				sprint (self, " seconds...\n");
			}
		}
		else
		{
			sprint (self, "No ");
			sprint (self, gs);
			sprint (self, "s left.\n");
			return;
		}
	}
	if ((self.impulse == 151))
	{
		if (self.tp_grenades_2 == 0)
			return;
		gtype = self.tp_grenades_2;
/*		if ((self.tp_grenades_2 == 2))
		{
			gs = "Concussion grenade";
		}
		else
		{*/
			if ((self.tp_grenades_2 == 3))
			{
				gs = "Nail grenade";
			}/*
			else
			{
				if ((self.tp_grenades_2 == 4))
				{
					gs = "Mirv grenade";
				}
				else
				{
					if ((self.tp_grenades_2 == 5))
					{
						gs = "Napalm grenade";
					}
					else
					{
						if ((self.tp_grenades_2 == 6))
						{
							gs = "Flare";
						}
						else
						{
							if ((self.tp_grenades_2 == 7))
							{
								gs = "Gas grenade";
							}
							else
							{
								if ((self.tp_grenades_2 == 8))
								{
									gs = "EMP grenade";
								}
								else
								{
									if ((self.tp_grenades_2 == 9))
									{
										gs = "Flash grenade";
									}*/
									else
									{
										gs = "Grenade";
									}/*
								}
							}
						}
					}
				}
			}
		}*/
		if ((self.no_grenades_2 > 0))
		{
			self.no_grenades_2 = (self.no_grenades_2 - 1);
/*			if ((gtype == 6))
			{
				newmis = spawn ();
				newmis.owner = self;
				newmis.movetype = 6;
				newmis.solid = 2;
				newmis.classname = "grenade";
				makevectors (self.v_angle);
				if (self.v_angle_x)
				{
					newmis.velocity = ((v_forward * 1200) + (v_up * 200));
				}
				else
				{
					newmis.velocity = aim (self, 10000);
					newmis.velocity = (newmis.velocity * 1200);
					newmis.velocity_z = 75;
				}
				newmis.angles = vectoangles (newmis.velocity);
				newmis.weapon = self.team_no;
				newmis.think = FlareGrenadeExplode;
				newmis.nextthink = (time + 0.8);
				newmis.touch = FlareGrenadeTouch;
				newmis.skin = 1;
				newmis.mdl = "flare";
				setmodel (newmis, "progs/flare.mdl");
				setsize (newmis, '0 0 0', '0 0 0');
				setorigin (newmis, self.origin);
				return;
			}*/
			if ((gtype == 10))
			{
				ptime = ftos (0.5);
				sprint (self, "Opening ");
				sprint (self, gs);
				sprint (self, "...\n");
			}
			else
			{
				ptime = ftos (3);
				sprint (self, gs);
				sprint (self, " primed, ");
				sprint (self, ptime);
				sprint (self, " seconds...\n");
			}
		}
		else
		{
			sprint (self, "No ");
			sprint (self, gs);
			sprint (self, "s left.\n");
			return;
		}
	}
	self.tfstate = (self.tfstate | 1);
	tGrenade = spawn ();
	tGrenade.owner = self;
	tGrenade.weapon = gtype;
	tGrenade.classname = "primer";
	tGrenade.impulse = self.impulse;
	tGrenade.nextthink = (time + 0.8);
	tGrenade.heat = time + 4;

/*	// Make Centerprint timer			// Taken out due to the fact that the function sucked
	newmis = spawn ();
	newmis.owner = self;
	newmis.classname = "primedtimer";
	newmis.think = CP_Timer;
	newmis.nextthink = (time);
	self.grenade_timer = time;		*/
	/*if ((gtype == 10))
	{
		tGrenade.heat = ((time + 0.5) + 0.5);
	}
	else
	{
		tGrenade.heat = ((time + 3) + 0.8);
	}*/
	tGrenade.think = TeamFortress_GrenadePrimed;
};

void () TeamFortress_GrenadePrimed =
{
	local entity user;
	local entity oldself;

	user = self.owner;
	if ((!(user.tfstate & 1024) && !user.deadflag))
	{
		self.nextthink = (time + 0.1);
		if (!self.think)
		{
			dremove (self);
		}
		if ((time > self.heat))
		{
			TeamFortress_ExplodePerson ();
		}
		return;
	}
	if (!(user.tfstate & 1))
	{
		dprint ("GrenadePrimed logic error\n");
	}
	user.tfstate = (user.tfstate - (user.tfstate & 1));
	user.tfstate = (user.tfstate - (user.tfstate & 1024));
//	sound (user, 1, "weapons/grenade.wav", 1, 1);
	KickPlayer (-1, user);
	newmis = spawn ();
	newmis.owner = user;
	newmis.movetype = 10;
	newmis.solid = 2;
	newmis.classname = "grenade";
	makevectors (user.v_angle);
	if (user.deadflag)
	{
		newmis.velocity = '0 0 200';
	}
	else
	{
		if (user.v_angle_x)
		{
			newmis.velocity = ((((v_forward * 600) + (v_up * 200)) + ((crandom () * v_right) * 10)) + ((crandom () * v_up) * 10));
		}
		else
		{
			newmis.velocity = aim (user, 10000);
			newmis.velocity = (newmis.velocity * 600);
			newmis.velocity_z = 200;
		}
	}
	newmis.angles = vectoangles (newmis.velocity);
	newmis.think = SUB_Null;
	newmis.nextthink = self.heat;
	if ((self.weapon == 1))
	{
		newmis.touch = NormalGrenadeTouch;
		newmis.think = NormalGrenadeExplode;
		newmis.skin = 0;
		newmis.avelocity = '300 300 300';
//		setmodel (newmis, "progs/hgren2.mdl");
		setmodel(newmis, "models/grenades/fragnade.md3");
	}
	else if ((self.weapon == 9))
	{
		newmis.touch = FlashGrenadeTouch;
		newmis.think = FlashGrenadeExplode;
		newmis.skin = 2;
		newmis.avelocity = '300 300 300';
		setmodel (newmis, "progs/hgren2.mdl");
	}
/*	else
	{
		if ((self.weapon == 2))
		{
			newmis.touch = ConcussionGrenadeTouch;
			newmis.think = ConcussionGrenadeExplode;
			newmis.skin = 1;
			newmis.avelocity = '300 300 300';
			setmodel (newmis, "progs/hgren2.mdl");
		}
		else
		{*/
			if ((self.weapon == 3))
			{
				newmis.touch = NailGrenadeTouch;
				newmis.think = NailGrenadeExplode;
				newmis.skin = 1;
				newmis.avelocity = '0 300 0';
				setmodel (newmis, "progs/biggren.mdl");
			}/*
			else
			{
				if ((self.weapon == 4))
				{
					newmis.touch = MirvGrenadeTouch;
					newmis.think = MirvGrenadeExplode;
					newmis.skin = 0;
					newmis.avelocity = '0 300 0';
					setmodel (newmis, "progs/biggren.mdl");
				}
				else
				{
					if ((self.weapon == 5))
					{
						newmis.touch = NapalmGrenadeTouch;
						newmis.think = NapalmGrenadeExplode;
						newmis.skin = 2;
						newmis.avelocity = '0 300 0';
						setmodel (newmis, "progs/biggren.mdl");
					}
					else
					{
						if ((self.weapon == 6))
						{
							newmis.touch = FlareGrenadeTouch;
							newmis.weapon = self.team_no;
							newmis.think = FlareGrenadeExplode;
							newmis.skin = 1;
							newmis.avelocity = '300 300 300';
							newmis.mdl = "flare";
							setmodel (newmis, "progs/flare.mdl");
						}
						else
						{
							if ((self.weapon == 7))
							{
								newmis.touch = GasGrenadeTouch;
								newmis.think = GasGrenadeExplode;
								newmis.skin = 3;
								newmis.avelocity = '300 300 300';
								setmodel (newmis, "progs/grenade2.mdl");
							}
							else
							{
								if ((self.weapon == 8))
								{
									newmis.touch = EMPGrenadeTouch;
									newmis.think = EMPGrenadeExplode;
									newmis.skin = 4;
									newmis.avelocity = '300 300 300';
									setmodel (newmis, "progs/grenade2.mdl");
								}
								else
								{
									if ((self.weapon == 10))
									{
										newmis.touch = CanisterTouch;
										newmis.think = ScatterCaltrops;
										newmis.skin = 0;
										newmis.avelocity = '0 0 0';
									}
									else
									{
										if ((self.weapon == 9))
										{
											newmis.touch = FlashGrenadeTouch;
											newmis.think = FlashGrenadeExplode;
											newmis.skin = 2;
											newmis.avelocity = '300 300 300';
											setmodel (newmis, "progs/hgren2.mdl");
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}*/
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, user.origin);
	oldself = self;
	self = self.owner;
	self = oldself;
	dremove (self);
};

void () TeamFortress_ThrowGrenade =
{
	if (!(self.tfstate & 1))
	{
		return;
	}
	sound(self, 3, "weapons/throw.wav", 1, 1);
	self.tfstate = (self.tfstate | 1024);
};

// TF Grenade CenterPrint Timer - it sucks so I took it out:x
void () CP_Timer =
{
	local float countdown;

	countdown = (time - self.owner.grenade_timer);

	if (countdown > 0)
	{
		CenterPrint (self.owner, "^7€‚^1\n");
	}
	if (countdown > .25)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > .5)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > .75)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > 1)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > 1.25)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > 1.5)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > 1.75)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > 2)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > 2.25)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > 2.5)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > 2.75)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > 3)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > 3.25)
	{
		CenterPrint (self.owner, "^1€^7‚\n");
	}
	if (countdown > 3.5)
	{
		CenterPrint (self.owner, "^1€‚^7\n");
	}
	if (countdown > 3.75)
	{
		CenterPrint (self.owner, "^3€‚^7\n");
	}
	if (countdown > 4)
	{
		CenterPrint (self.owner, "\n");
		dremove(self);
	}
	else
	{
		self.nextthink = (time + .25);
	}
};