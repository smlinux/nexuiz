// DP/Nex Menu
// control/fx/base.qc

/////////////////////
// [Item_Fx_Mutator]
///

bool() Item_Fx_Mutator_IsActive =
{
	if( self._parent.time_z >= 0 ) // < 0 stopped
		self.time_z = (self._parent.time_z - self.time_y) / self.time_x;
	else
		self.time_z = -1;
	if( self.time_z > 0 )
		return true;
	return false;
};

void() Item_Fx_Mutator_UpdateTarget =
{
	if( !self.target )
		self._target = self._parent._target;
	else if( self.target != self._target.name )
		self._target = Menu_GetItemEx( self._parent._target.parent, self.target, true );
};

void() Item_Fx_Mutator_Destroy =
{
	String_EntityFree( self, target );
};

void() Item_Fx_Mutator_Init =
{
	String_EntityZone( self, target );

	self._destroy = Item_Fx_Destroy;
};


//////////////////
// Item_Effect
////

void() Item_Fx_Effect_Update =
{
	if( !self.target ) {
		self._target = null_entity;
		self.time_z = -1;
		return;
	}

	if( self.target != self._target.name )
		self._target = Menu_GetItem( self._target );
	if( self.time_y <= Timer_Time && self.time_y + self.time_x <= Timer_Time )
		self.time_z = (Timer_Time - self.time_y) / self.time_x;
	else
		self.time_z = -1;
};

void() Item_Fx_Effect_Spawn =
{
	Item_Fx_Init();

	self.time_y = -1;

	self.flag = self.flag | FLAG_HIDDEN;

	self._update = Item_Fx_Effect_Update;
};
