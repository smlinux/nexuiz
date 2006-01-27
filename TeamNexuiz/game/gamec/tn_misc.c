/*-----===================================-------
		Team:Nexuiz Misc. Items/Functions
				-=[ by avirox ]=-
-------===================================-----*/

// Ice/Slippery ground
.vector area_min;
.vector area_max;
.float slip_time;
.float slip_amount;

void () slippery_touch =
{
	other.slip_time = time + .2;				// amount of time the player is slipping (this gets constantly updated)
	other.slip_amount = self.slip_amount;		// handled in cl_physics.c
};

void () func_slippery =
{
	if (self.area_min != '0 0 0')
	{
		setsize(self, self.area_min, self.area_max);
	}
	else
	{
		setsize(self, '-16 -16 -24', '16 16 32');
	}
	self.solid = SOLID_TRIGGER;
	self.touch = slippery_touch;
};

void () func_ice =
{
	self.classname = "func_slippery";
	func_slippery();
};