void() hurt_on =
{
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

void() hurt_touch =
{
	if (other.takedamage)
	{
		self.solid = SOLID_NOT;
		Damage (other, self, self, self.dmg, 1, '0 0 0', '0 0 0');
		self.think = hurt_on;
		self.nextthink = time + 1;
	}

	return;
};


void() trigger_hurt =
{
	InitTrigger ();
	self.touch = hurt_touch;
	if (!self.dmg)
		self.dmg = 500;
};