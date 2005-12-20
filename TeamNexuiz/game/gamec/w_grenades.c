void W_Grenade_DefaultTouch (void)
{
	if (!self.state & 1 && (other.classname == "player" || other.classname == "corpse"))
		self.think();	// assume my think was an explosion function
	else
		sound (self, CHAN_IMPACT, "weapons/grenade_bounce.wav", 1, ATTN_NORM);
}

void W_Grenade_DefaultDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		self.think();	// assume my think was an explosion function
}

float W_ThrowGrenade(void() GrenadeSpecial)
{
	local entity gren, oself;
	local vector org;

	if(self.ammo_shells < 10)
	{
		sprint(self, "Not enough grenade ammo\n");
		self.grenade_time = time + 0.3;
		return FALSE;
	}
	self.ammo_shells = self.ammo_shells - 10;

//	sound (self, CHAN_WEAPON, "weapons/grenade_fire.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;
	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -12;

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	setorigin(gren, org);

	gren.takedamage = DAMAGE_YES;
	gren.health = 10;
	//gren.damageforcescale = 4;
	gren.event_damage = W_Grenade_DefaultDamage;

	oself = self;
	self = gren;

	GrenadeSpecial();

	self = oself;

	return TRUE;
}

//--------------------------------------------

void InflictStunStatus(entity targ, float stuntime)
{
	if(targ.classname != "player")
		return; // only players can be stunned (fixme: turrets?  vehicles?)

	// stun target by increasing attack_finished so he can't attack
	if(targ.attack_finished < time + stuntime)
		targ.attack_finished = time + stuntime;

	// also prevent use of grenades
	// disabled, since the point of the grenades is being
	// able to attack when weapon is busy or disabled
	//if(targ.grenade_time < time + stuntime)
	//	targ.grenade_time = time + stuntime;
}

//--------------------------------------------

void ExtinguishFirebomb(entity e)
{
	entity f, b;
	if(e.enemy == world)
	{
		//bprint("ExtinguishFirebomb failed, no enemy!\n");
		return;
	}
	//bprint(strcat("ExtinguishFirebomb(", e.classname, ") ", e.enemy.classname, "\n"));

	f = e.enemy;
	b = e.enemy.enemy;

	e.enemy = world;
	f.enemy = world;

	f.think = SUB_Null;
	f.nextthink = -1;
	setmodel(f, "models/sprites/null.spr");
	setattachment(f, world, "");
	if(b)
	{
		b.think = SUB_Null;
		b.nextthink = -1;
		setmodel(b, "models/sprites/null.spr");
		setattachment(b, world, "");
		remove(b);
		//b.think = SUB_Remove;
		//b.nextthink = time + 2;
	}
	setmodel(e, "");
	//f.think = SUB_Remove;
	//f.nextthink = time + 2;
	//eprint(f);
	remove(f);
	//eprint(f);
}

void Firebomb_Flame_Check()
{
	if(self.owner == world || self.owner.model == "")
	{
		if(self.owner != world && self.owner.enemy == self)
		{
			//bprint("Firebomb flame calls ExtinguishFirebomb on owner\n");

			ExtinguishFirebomb(self.owner);
			self.owner.enemy = world;
			return;
		}
		//bprint("Firebomb flame resorts to deleting itself!\n");
		setattachment(self, world, "");
		setattachment(self.enemy, world, "");
		setmodel(self, "");
		setmodel(self.enemy, "");
		self.think = self.enemy.think = SUB_Remove;
		self.nextthink = self.enemy.nextthink = time + 1;
	}

	self.nextthink = time + 0.5;
}

void W_Firebomb_Think ()
{
	entity head;
	float flametime, flamedmg, flamerate, flameedge, flameradius, distratio;

	self.nextthink = time + cvar("g_balance_grenade_firebomb_burnrate");

	if(self.wait < time || self.enemy == world)
	{
		//bprint("Firebomb deletes its flame\n");
		ExtinguishFirebomb(self);

		setmodel(self, "");
		self.think = SUB_Remove;
		self.nextthink = time + 2.2;
		return;
	}

	flameradius =	cvar("g_balance_grenade_firebomb_burnradius");
	flamedmg =		cvar("g_balance_grenade_firebomb_flamedmg");
	flamerate =		cvar("g_balance_grenade_firebomb_flamerate");
	flametime =		cvar("g_balance_grenade_firebomb_flametime");
	flameedge =		cvar("g_balance_grenade_firebomb_edgeratio");

	RadiusDamage (self, self.owner,
		cvar("g_balance_grenade_firebomb_burndmg"),
		cvar("g_balance_grenade_firebomb_burndmg")*flameedge,
		cvar("g_balance_grenade_firebomb_burnradius"), world,
		0, DEATH_BURNING);

	head = findradius(self.origin, flameradius);
	while(head)
	{
		if(head.takedamage == DAMAGE_AIM)//head.classname == "player" || head.classname == "turret")
		{
			traceline(self.origin, head.origin, TRUE, self);
			if(trace_fraction >= 1)
			{
				distratio = 1 - (vlen(head.origin - self.origin) / flameradius);
				IgniteTarget(head, self.owner,
					(flametime*flameedge) + (flametime - flameedge)*distratio,
					flamedmg,
					flamerate,
					TRUE);
			}
		}
		head = head.chain;
	}


/*	radius = cvar("g_balance_grenade_firebomb_burnradius");
	head = findradius(self.origin, radius);
	while(head)
	{
		//bprint("firebomb see target\n");
		if((head.takedamage || head.classname == "grenade") && head != self.enemy && head != self)
		{
			//bprint("firebomb try to burn target\n");
			// don't harm or spread to allies or pyros
			if(!(head.classname == "player" && (head.team == self.team || head.class == CLASS_PYRO)) )
			{
				//bprint("firebomb burn target\n");
				edgeratio = cvar("g_balance_heat_edgeratio");
				distratio = ( 1 - (vlen(self.enemy.origin - head.origin) / radius) );
				flameratio = edgeratio + distratio*(1 - edgeratio);

				// deal direct damage from the heat radiated by the fire
				damage = flameratio * cvar("g_balance_grenade_firebomb_burndmg");
				Damage (head, self, self.owner, damage, DEATH_BURNING, self.enemy.origin, '0 0 0');

				if(head.takedamage == DAMAGE_AIM)
				{
					IgniteTarget(head, self.owner,
						cvar("g_balance_grenade_firebomb_flametime"),
						cvar("g_balance_grenade_firebomb_flamedmg"),
						cvar("g_balance_grenade_firebomb_flamerate"), TRUE);
				}
			}
		}
		head = head.chain;
	}
	*/
}

void W_Firebomb_Activate (void)
{
	// set bomb on fire visually
/*	CreateFlame(self, self.owner);
	self.onfire.think = SUB_Null;
	self.onfire.nextthink = -1;
	self.onfire.colormod = self.onfire.onfire.colormod = '128 255 128'*(1/255)*1;//'255 128 64'*(1/255)*1;//3;
*/

	entity f;
	f = self.enemy = spawn();
	f.enemy = spawn();
	f.classname = f.enemy.classname = "firebomb_flame";
	f.owner = self;
	f.dmg = 0;
	f.ltime = 0;
	f.wait = 0;
	f.think = Firebomb_Flame_Check;
	f.nextthink = time;

	f.colormod = f.enemy.colormod = 
		stov(cvar_string("g_balance_grenade_firebomb_flamecolor"))*(1/255)
		*cvar("g_balance_grenade_firebomb_flamec_strength");//0.3;//'128 128 255'*(1/255)*3;//'255 128 64'*(1/255)*1;//3;
	//f.alpha = f.enemy.alpha = 0.6;
	f.effects = f.enemy.effects = EF_ADDITIVE;
	f.scale = f.enemy.scale = 2;

	setmodel(f, "models/sprites/fire_top.spr32");
	setmodel(f.enemy, "models/sprites/fire_base.spr32");

	setorigin(f.enemy, '0 0 -5' * f.scale);
	setorigin(f, '0 0 2' * f.scale + '0 0 20');

	setattachment(f, f.owner, "");
	setattachment(f.enemy, f, "");

	// burn targets each frame
	self.wait = time + cvar("g_balance_grenade_firebomb_burntime");
	self.event_damage = SUB_Null;
	self.takedamage = 0;
	self.movetype = MOVETYPE_TOSS;
	self.angles = '0 0 0';
	self.touch = SUB_Null;
	self.think = W_Firebomb_Think;
	self.nextthink = time;
}

void W_Firebomb()
{
	setmodel(self, "models/grenademodel.md3");
	setsize(self, '-6 -6 -3', '6 6 3');

	self.classname = "firebomb"; // don't get bounced around like other grenades

	self.nextthink = time + 3;
	self.think = W_Firebomb_Activate;
	self.touch = W_Firebomb_Activate;
	self.state = 1; // don't explode on contact with player
	self.velocity = v_forward * cvar("g_balance_grenade_firebomb_speed")
		+ v_up * cvar("g_balance_grenade_frag_firebomb_up");
	self.avelocity = '-500 0 0';
	//self.event_damage = SUB_Null;

	self.colormod = '255 128 0'*(1/255)*2;
	self.scale = 1.5;

	self.angles = vectoangles (self.velocity);
}

//--------------------------------------------

void W_ConcussionGrenade_Explode (void)
{
	vector	org2;
	float radius, spd, spd_up, stuntime, sim_jump_pad;
	entity head;

	org2 = findbetterlocation (self.origin);
	te_explosionrgb (org2, (1/255)*'255 128 0');
	// fixme: need different sound
	sound (self, CHAN_VOICE, "weapons/grenade_impact.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;

	radius = cvar("g_balance_grenade_concussion_radius");
	spd = cvar("g_balance_grenade_concussion_force");
	spd_up = cvar("g_balance_grenade_concussion_force_up");
	stuntime = cvar("g_balance_grenade_concussion_stuntime");
	sim_jump_pad = !cvar("g_balance_grenade_concussion_restrictflight");

	// extinguish flames in radius (even those not burning a player)
	head = world;
	do
	{
		head = find(head, classname, "burning");
		if(head != world && vlen(head.enemy.origin - self.origin) <= radius)
		{
			traceline(self.origin, head.enemy.origin, TRUE, self);
			if(trace_fraction >= 1)
			{
				ExtinguishFlame(head.enemy);
			}
		}
	}while(head);



	// extinguish firebombs
	head = world;
	do
	{
		head = find(head, classname, "firebomb");
		if(head != world && vlen(head.origin - self.origin) <= radius)
		{
			traceline(self.origin, head.origin, TRUE, self);
			if(trace_fraction >= 1)
			{
				ExtinguishFirebomb(head);
			}
		}
	}while(head);



	// also extinguish napalm
	head = world;
	do
	{
		head = find(head, classname, "napalm");
		if(head != world && vlen(head.origin - self.origin) <= radius)
		{
			traceline(self.origin, head.origin, TRUE, self);
			if(trace_fraction >= 1)
			{
				head.think = SUB_Remove;
				head.nextthink = time;
				//remove(head);
				//return;
			}
		}
	}while(head);




	// throw hapless players
	head = world;
	do
	{
		head = findfloat(head, movetype, MOVETYPE_WALK);
		if(head != world && vlen(head.origin - self.origin) <= radius)
		{
			traceline(self.origin, head.origin, TRUE, self);
			if(trace_fraction >= 1)
			{
				if(sim_jump_pad && head.classname == "player" && !head.jump_pad)
					head.jump_pad = 1;
				head.velocity = head.velocity + normalize(head.origin - self.origin) * spd + '0 0 1'*spd_up;

				// stun status
				InflictStunStatus(head, stuntime);
			}
		}
	}while(head);

	remove (self);
}

void W_ConcussionGrenade()
{
	setmodel(self, "models/grenademodel.md3");
	setsize(self, '-6 -6 -3', '6 6 3');

	self.nextthink = time + 1.5 + random()*0.5;
	self.think = W_ConcussionGrenade_Explode;
	self.touch = W_Grenade_DefaultTouch;
	self.state = 1; // don't explode on contact with player
	self.velocity = v_forward * cvar("g_balance_grenade_concussion_speed")
		+ v_up * cvar("g_balance_grenade_concussion_speed_up");
	self.avelocity = '100 150 100';

	self.angles = vectoangles (self.velocity);
}

//--------------------------------------------

// touch the player and go *poke*
void W_NailGrenade_Spike_Poke (void)
{
	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	if(other.takedamage)
		Damage (other, self, self.enemy, self.dmg, WEP_NAMEK, self.origin, normalize(self.velocity) * cvar("g_balance_grenade_nail_spikeforce"));
	else
	{
		te_spark(self.origin, normalize(self.velocity) * -70 - '0 0 100', 30);
		te_gunshot(self.origin);
	}

	remove (self);
}

void W_NailGrenade_Spike(vector org, vector vel, float damage)
{
	entity spike;
	spike = spawn ();
	spike.enemy = self.owner;
	spike.owner = self;
	spike.classname = "spike";

	// some downward curving
	spike.movetype = MOVETYPE_BOUNCE;
	spike.gravity = cvar("g_balance_grenade_nail_spikegrav");
	spike.solid = SOLID_BBOX;
	setmodel(spike, "models/plasmatrail.mdl");
	setsize(spike, '0 0 0', '0 0 0');
	setorigin(spike, org);

	spike.dmg = damage;

	spike.nextthink = time + 3 + random()*0.5;
	spike.think = SUB_Remove;
	spike.touch = W_NailGrenade_Spike_Poke;
	spike.velocity = vel;
	spike.angles = vectoangles (spike.velocity);
	spike.scale = 0.75;
}

void W_NailGrenade_Attack (void)
{
	float r, num, maxnum, is_odd, spread, starty, incy;
	vector ang;

	r = ceil(random()*3);
	if(r == 1)
		sound (self, CHAN_IMPACT, "weapons/ric1.wav", 1, ATTN_NORM);
	else if(r == 2)
		sound (self, CHAN_IMPACT, "weapons/ric2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_IMPACT, "weapons/ric3.wav", 1, ATTN_NORM);

	num = 0;
	maxnum = cvar("g_balance_grenade_nail_numspikes");
	spread = cvar("g_balance_grenade_nail_spread");

	is_odd = (floor(maxnum / 2) != maxnum / 2); //true if maxnum is an odd number

	if(is_odd)
	{
		incy = (1 / maxnum) * spread;
		starty = self.mangle_y - (incy * maxnum/2) + incy*0.5;
	}
	else
	{
		incy = (1 / maxnum) * spread;
		starty = self.mangle_y - (incy * maxnum/2) + incy*0.5;
	}

	ang_z = self.mangle_z;
	ang_x = self.mangle_x;
	ang_y = starty;

	while(num < maxnum)
	{
		makevectors(ang);
		W_NailGrenade_Spike(self.origin, v_forward*cvar("g_balance_grenade_nail_spikespeed")     , cvar("g_balance_grenade_nail_spikedamage"));
		W_NailGrenade_Spike(self.origin, v_forward*cvar("g_balance_grenade_nail_spikespeed") * -1, cvar("g_balance_grenade_nail_spikedamage"));
		num = num + 1;
		ang_y = ang_y + incy;
	}

	self.count = self.count - 1;

	if(self.count > 0)
	{
		// change shooting angle and fire again
		self.mangle_y = self.mangle_y + cvar("g_balance_grenade_nail_anglechange");
		self.think = W_NailGrenade_Attack;
		self.nextthink = time + cvar("g_balance_grenade_nail_cluster_rate");
	}
	else
	{
		// fall to ground & disappear
		self.alpha = 0.5;
		self.gravity = 0;
		self.touch = SUB_Remove;
		self.think = self.touch;
		self.nextthink = time + 3;
		self.movetype = MOVETYPE_TOSS;
		self.solid = SOLID_BBOX;
		self.velocity = '0 0 20';
		self.avelocity = '300 200 100';
		setorigin(self, self.origin);
	}
}

void W_NailGrenade_Activate (void)
{
	self.velocity = '0 0 0';
	self.think = W_NailGrenade_Attack;
	self.nextthink = time + 0.3;
//	self.origin = self.dest1;

	self.count = cvar("g_balance_grenade_nail_numclusters");
}

// lift into air
void W_NailGrenade_Deploy (void)
{
	float thtime, dheight, spd;
	entity oldself;

	self.touch = SUB_Null;

	dheight = cvar("g_balance_grenade_nail_deployheight");
	thtime = cvar("g_balance_grenade_nail_deploytime");
	spd = dheight / thtime;

	// GRRR!  Quake's floor fetish is driving me crazy.
	// The ONLY way I've found to get the grenade off the floor once it's on
	// is to delete it and spawn a new entity in its place.

	oldself = self;
	self = spawn();
	self.owner = oldself.owner;
	self.angles_y = oldself.angles_y;
	self.angles_x = self.angles_z = 0; // point upright
	self.mangle = oldself.mangle;

	setmodel(self, oldself.model);
	setsize(self, '0 0 0', '0 0 0');
	setorigin(self, oldself.origin);
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.oldorigin = self.origin;

	//self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_FLY;
	self.solid = SOLID_NOT;
	self.velocity = '0 0 1' * spd;
	self.nextthink = time + thtime;
	self.think = W_NailGrenade_Activate;

	self.dest1 = self.origin + '0 0 1'*dheight;
	traceline(self.origin, self.dest1, TRUE, self);
	self.dest1 = trace_endpos;

	remove(oldself);
}

void W_NailGrenade_Touch (void)
{
	sound (self, CHAN_IMPACT, "weapons/grenade_bounce.wav", 1, ATTN_NORM);
	traceline(self.origin, self.origin - '0 0 10', TRUE, self);
	if(self.flags & FL_ONGROUND || trace_fraction < 1)
		W_NailGrenade_Deploy();
}

void W_NailGrenade()
{
	setmodel(self, "models/grenademodel.md3");
	setsize(self, '-6 -6 -3', '6 6 3');

	self.takedamage = DAMAGE_NO;
	self.event_damage = SUB_Null;

	self.nextthink = time + 2.5;
	self.think = W_NailGrenade_Activate;
	self.touch = W_NailGrenade_Touch;
	self.state = 1; // don't explode on contact with player
	self.velocity = v_forward * cvar("g_balance_grenade_nail_speed")
		+ v_up * cvar("g_balance_grenade_nail_speed_up");
	self.avelocity = '100 150 100';

	self.angles = vectoangles (self.velocity);

	// decide on a direction to fire in
	self.mangle_y = self.angles_y;// + 45;
	self.mangle_z = 0;
	self.mangle_x = 0;
}

//--------------------------------------------

void W_MirvGrenade_Explode (void)
{
	vector	org2;
	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/grenadeexplosion.spr32", 0, 20, 30);
	sound (self, CHAN_BODY, "weapons/grenade_impact.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_grenade_mirv_damage"), cvar("g_balance_grenade_mirv_edgedamage"), cvar("g_balance_grenade_mirv_radius"), world, cvar("g_balance_grenade_mirv_force"), WEP_GRENADE_MIRV);

	remove (self);
}

void W_MirvBomb(vector org, vector vel)
{
	entity gren;
	gren = spawn ();
	gren.owner = self.owner;
	gren.classname = "grenade";
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	setmodel(gren, "models/grenademodel.md3");
	//setsize(self, '-6 -6 -3', '6 6 3');
	setsize(gren, '0 0 0', '0 0 0');
	setorigin(gren, org);

	gren.nextthink = time + 2 + crandom()*0.15;
	gren.think = W_MirvGrenade_Explode;
	gren.touch = W_Grenade_DefaultTouch;
	gren.state = 1; // don't explode on contact
	gren.takedamage = DAMAGE_YES;
	gren.health = 20;
	gren.damageforcescale = 4;
	gren.event_damage = W_Grenade_DefaultDamage;
	gren.velocity = vel;
	gren.avelocity = '100 150 100' * (1 + crandom()*0.5);
	gren.angles = vectoangles (gren.velocity);
	gren.scale = 0.75;
}

void W_MirvGrenade_Split (void)
{
	float num, maxnum, spread;
	vector dir, vel;
	sound (self, CHAN_IMPACT, "weapons/grenade_bounce.wav", 1, ATTN_NORM);

	if(self.flags & FL_ONGROUND)
	{
		//traceline(self.origin, self.origin - '0 0 5', TRUE, self);
		//dir = normalize(self.velocity) + trace_plane_normal + '0 0 1';
		//dir = normalize(dir * (1/3));
		dir = normalize(self.velocity)*0.2 + normalize('0 0 1');
		dir = normalize(dir);
	}
	else
	{
		dir = normalize(self.velocity);
	}

	spread = cvar("g_balance_grenade_mirv_spread");

	maxnum = cvar("g_balance_grenade_mirv_count");
	for (num = 0; num < maxnum; num = num + 1)
	{
		vel_x = dir_x + crandom()*spread;
		vel_y = dir_y + crandom()*spread;
		vel_z = dir_z + crandom()*spread;
		vel = normalize(vel) * cvar("g_balance_grenade_mirv_speed2");
		W_MirvBomb(self.origin, vel);
	}
	remove(self);
}

void W_MirvGrenade()
{
	setmodel(self, "models/grenademodel.md3");
	setsize(self, '-6 -6 -3', '6 6 3');

	self.nextthink = time + 2.5;
	self.think = W_MirvGrenade_Split;
	self.touch = W_MirvGrenade_Split;
	self.velocity = v_forward * cvar("g_balance_grenade_mirv_speed")
		+ v_up * cvar("g_balance_grenade_mirv_speed_up");
	self.avelocity = '100 150 100';

	self.angles = vectoangles (self.velocity);
	self.scale = 2.5;
}

//--------------------------------------------

void W_FragGrenade_Explode (void)
{
	vector	org2;
	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/grenadeexplosion.spr32", 0, 20, 30);
	sound (self, CHAN_BODY, "weapons/rocket_impact.wav", 1, ATTN_NORM);
	sound (self, CHAN_VOICE, "weapons/grenade_impact.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_grenade_frag_damage"), cvar("g_balance_grenade_frag_edgedamage"), cvar("g_balance_grenade_frag_radius"), world, cvar("g_balance_grenade_frag_force"), WEP_GRENADE_FRAG);

	remove (self);
}

void W_FragGrenade()
{
	setmodel(self, "models/grenademodel.md3");
	setsize(self, '-6 -6 -3', '6 6 3');

	self.nextthink = time + 2;//1.5 + random()*0.5;
	self.think = W_FragGrenade_Explode;
	self.touch = W_Grenade_DefaultTouch;
	self.state = 1; // don't explode on contact with player
	self.velocity = v_forward * cvar("g_balance_grenade_frag_speed")
		+ v_up * cvar("g_balance_grenade_frag_speed_up");
	self.avelocity = '100 150 100';

	self.angles = vectoangles (self.velocity);
}

//--------------------------------------------

void PoisonGrenadeGib(entity gib, string mdlname, vector org, vector v, float destroyontouch)
{
	entity e;
	e = TossGib(gib, mdlname, org, v, destroyontouch);
	e.colormod = 5 * '0 1 0'; // bright green
	e.scale = 0.2;
	e.gravity = 0.8;
	e.velocity = e.velocity * e.gravity;// * 0.8;
}

void W_PoisonGrenade_Explode (void)
{
	vector	org2, org1;
	entity head;

	org2 = findbetterlocation (self.origin);
	org1 = org2 + '0 0 5';
	te_explosionrgb (org2, (1/255)*'0 255 0');
	sound (trace_ent, CHAN_VOICE, "misc/gib.wav", 1, ATTN_NORM);
	PoisonGrenadeGib (world, "models/gibs/gib5.md3", org1, '-500 0 450',1);
	PoisonGrenadeGib (world, "models/gibs/gib6.md3", org1, '0 500 450',1);
	PoisonGrenadeGib (world, "models/gibs/gib6.md3", org1, '0 -500 450',1);
	PoisonGrenadeGib (world, "models/gibs/gib6.md3", org1, '500 0 450',1);
	PoisonGrenadeGib (world, "models/gibs/chunk.mdl", org1, '0 0 450',1);


	head = findradius(self.origin, cvar("g_balance_grenade_poison_radius"));
	while(head)
	{
		if(head.classname == "player") // only players can be poisoned
		{
			traceline(self.origin, head.origin, TRUE, self);
			if(trace_fraction >= 1)
			{
				PoisonTarget(head, cvar("g_balance_grenade_poison_damage"), cvar("g_balance_grenade_poison_duration"), TRUE);
				//bprint(strcat(head.netname, " is poisoned for ", ftos(head.poison_damage), " damage\n"));
			}
		}
		head = head.chain;
	}

	remove (self);
}

void W_PoisonGrenade()
{
	setmodel(self, "models/grenademodel.md3");
	setsize(self, '-6 -6 -3', '6 6 3');

	self.nextthink = time + 1.5 + random()*0.5;
	self.think = W_PoisonGrenade_Explode;
	self.touch = W_Grenade_DefaultTouch;
	self.state = 1; // don't explode on contact with player
	self.velocity = v_forward * cvar("g_balance_grenade_poison_speed")
		+ v_up * cvar("g_balance_grenade_poison_speed_up");
	self.avelocity = '100 150 100';

	self.angles = vectoangles (self.velocity);
}

//--------------------------------------------

void W_ArmorGrenade_Explode (void)
{
	entity head;
	vector	org2;

	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/grenadeexplosion.spr32", 0, 20, 30);
	sound (self, CHAN_BODY, "weapons/grenade_impact.wav", 1, ATTN_NORM);

	head = findradius(self.origin, cvar("g_balance_grenade_armor_radius"));
	while(head)
	{
		if(head.classname == "player") // only players are affected
		{
			traceline(self.origin, head.origin, TRUE, self);
			if(trace_fraction >= 1)
			{
				head.armorvalue = 0; // wipe out target's armor
			}
		}
		head = head.chain;
	}

	remove (self);
}

void W_ArmorGrenade()
{
	setmodel(self, "models/grenademodel.md3");
	setsize(self, '-6 -6 -3', '6 6 3');

	self.nextthink = time + 1.5 + random()*0.5;
	self.think = W_ArmorGrenade_Explode;
	self.touch = W_Grenade_DefaultTouch;
	self.state = 1; // don't explode on contact with player
	self.velocity = v_forward * cvar("g_balance_grenade_armor_speed")
		+ v_up * cvar("g_balance_grenade_armor_speed_up");
	self.avelocity = '100 150 100';

	self.angles = vectoangles (self.velocity);
}

//--------------------------------------------

