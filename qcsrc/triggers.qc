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
		self.nextthink = time + 0.1;
	}

	return;
};


void() trigger_hurt =       // this doesn't work
{
	InitTrigger ();
	self.touch = hurt_touch;
	self.dmg = 300;
};

void() target_speaker_use = {sound(self, CHAN_VOICE, self.noise, 1, 1);}
void() target_speaker = {self.use = target_speaker_use;}