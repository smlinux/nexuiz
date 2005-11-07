// DP/Nex Menu
// control/effect/float.qc

//////////////////////
// Item_Effect_Float
///

void() Item_Effect_Float_Update =
{
	if( self._state == ITEM_STATE_FORWARD ) {
		if( self._presstime + self.time_x < Timer_Time ) {
			self._parent.self.targetFloat = self.endFloat;
			self._presstime = Timer_Time;
			self._state = ITEM_STATE_BACKWARD;
		} else
			self._parent.self.targetFloat = self.interpolForward( self.startFloat,
				self.endFloat, self.time_x, Timer_Time - self._presstime,
				self._parent.self.targetFloat );
	} else {
		if( self._presstime + self.time_y < Timer_Time ) {
			self._parent.self.targetFloat = self.startFloat;
			self._presstime = Timer_Time;
			self._state = ITEM_STATE_FORWARD;
		} else
			self._parent.self.targetFloat = self.interpolForward( self.endFloat,
				self.startFloat, self.time_y, Timer_Time - self._presstime,
				self._parent.self.targetFloat );
	}

	// Check the task state
	if( ( self.time_y == -1 && self._state == ITEM_STATE_BACKWARD ) ||
		( self.time_z >= 0 && self.time_z >= Timer_Time ) )
			if( self.time_z == -2 )
				self._runFlag = self._runFlag | RUNFLAG_CHILDDRAWONLY | FLAG_DRAWONLY;
			else
				Menu_DeleteAfterFrame( self );
};

void() Item_Effect_Float_Reinit =
{
	self._parent.self.targetFloat = self.startFloat;
	self._presstime = Timer_Time;
	self._state = ITEM_STATE_FORWARD;
	if( self.flag & FLAG_DRAWONLY )
		self.flag = self.flag - FLAG_DRAWONLY;
};

void() Item_Effect_Float_Spawn =
{
	self.flag = self.flag | FLAG_HIDDEN;

	self._update = Item_Effect_Float_Update;
	self._reinit = Item_Effect_Float_Reinit;
};

