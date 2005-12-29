void() ai_face = 
{
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.ideal_yaw = anglemod(self.ideal_yaw);
	ChangeYaw();
};

void(float normal) SUB_AttackFinished = 
{
	self.cnt = TF_FLARE_LIT;
//	if (skill < 3)
//	{
		self.attack_finished = time + normal;
//	}
};

float(entity targ) range = 
{
	local vector spot1;
	local vector spot2;
	local float r;
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	r = vlen(spot1 - spot2);
	if (r < 120)
	{
		return TF_FLARE_LIT;
	}
	if (r < 500)
	{
		return TF_FLARE_OFF;
	}
	if (r < 1000)
	{
		return 2;
	}
	return 3;
};

float(entity targ) infront = 
{
	local vector vec;
	local float dot;
	makevectors(self.angles);
	vec = normalize(targ.origin - self.origin);
	dot = vec * v_forward;
	if (dot > 0.3)
	{
		return TF_FLARE_OFF;
	}
	return TF_FLARE_LIT;
};

void() t_movetarget = 
{
	local entity temp;
	if (other.movetarget != self)
	{
		return;
	}
	if (other.enemy)
	{
		return;
	}
	temp = self;
	self = other;
	other = temp;
	if (self.classname == "monster_ogre")
	{
		sound(self, 2, "ogre/ogdrag.wav", TF_FLARE_OFF, 2);
	}
	self.goalentity = self.movetarget = find(world, targetname, other.target);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	if (!(self.movetarget))
	{
		self.pausetime = time + 999999;
		self.th_stand();
		return;
	}
};

void() movetarget_f = 
{
	if (!(self.targetname))
	{
		objerror("monster_movetarget: no targetname");
	}
	self.solid = TF_FLARE_OFF;
	self.touch = t_movetarget;
	setsize(self, '-8 -8 -8', '8 8 8');
};

void() path_corner = 
{
	if (CheckExistence() == TF_FLARE_LIT)
	{
		dremove(self);
		return;
	}
	movetarget_f();
};