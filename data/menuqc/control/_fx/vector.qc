// DP/Nex Menu
// control/fx/vector.qc

//////////////////////
// Item_Effect_Vector
///

void( InterpolFunction pFunction, bool pForward ) _IEV_Interpolate =
{
	local vector lCopy;
	local float lT;

	lT = Timer_Time - self._presstime;
	lCopy = self._parent.self.targetVector;
	if( pForward ) {
		lCopy_x = pFunction( self.startVector_x, self.endVector_x, self.time_x, lT, lCopy_x );
		lCopy_y = pFunction( self.startVector_y, self.endVector_y, self.time_x, lT, lCopy_y );
		lCopy_z = pFunction( self.startVector_z, self.endVector_z, self.time_x, lT, lCopy_z );
	} else {
		lCopy_x = pFunction( self.endVector_x, self.startVector_x, self.time_y, lT, lCopy_x );
		lCopy_y = pFunction( self.endVector_y, self.startVector_y, self.time_y, lT, lCopy_y );
		lCopy_z = pFunction( self.endVector_z, self.startVector_z, self.time_y, lT, lCopy_z );
	}
	self._parent.self.targetVector = lCopy;
};

void() Item_Effect_Vector_Update =
{
	if( self._state == ITEM_STATE_FORWARD ) {
		if( self._presstime + self.time_x < Timer_Time ) {
			self._parent.self.targetVector = self.endVector;
			self._presstime = Timer_Time;
			self._state = ITEM_STATE_BACKWARD;
		} else
			_IEV_Interpolate( self.interpolForward, true );
	} else {
		if( self._presstime + self.time_y < Timer_Time ) {
			self._parent.self.targetVector = self.startVector;
			self._presstime = Timer_Time;
			self._state = ITEM_STATE_FORWARD;
		} else
			_IEV_Interpolate( self.interpolBackward, false );
	}

	// Check the task state
	if( ( self.time_y == -1 && self._state == ITEM_STATE_BACKWARD ) ||
		( self.time_z >= 0 && self.time_z >= Timer_Time ) )
			if( self.time_z == -2 )
				self._runFlag = self._runFlag | RUNFLAG_CHILDDRAWONLY | FLAG_DRAWONLY;
			else
				Menu_DeleteAfterFrame( self );

};

void() Item_Effect_Vector_Reinit =
{
	self._parent.self.targetVector = self.startVector;
	self._presstime = Timer_Time;
	self._state = ITEM_STATE_FORWARD;
	if( self.flag & FLAG_DRAWONLY )
		self.flag = self.flag - FLAG_DRAWONLY;
};

void() Item_Effect_Vector_Spawn =
{
	self.flag = self.flag | FLAG_HIDDEN;

	self._update = Item_Effect_Vector_Update;
	self._reinit = Item_Effect_Vector_Reinit;
};

