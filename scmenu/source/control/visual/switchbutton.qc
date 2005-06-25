// DP/Nex Menu
// control/visual/switchbutton.qc

bool( float pKey, float pAscii ) Item_SwitchButton_Key =
{
	if( !self._target )
		return false;

	if( pKey == K_SPACE || pKey == K_ENTER || pKey == K_MOUSE1 || pKey == K_RIGHTARROW ) {
		Sound_Play( self.soundPressed );
		self._presstime = Timer_Time;

		self._target._realValue = self._target._realValue + self._target.stepValue;
		if( self._target._realValue > self._target.maxValue )
			self._target._realValue = self._target.minValue;

		Raise_DataEvent( self._target, ITEM_DATALINK_SET );

		CtCall_Action();
		return true;
	} else if( pKey == K_BACKSPACE || pKey == K_MOUSE2 || pKey == K_LEFTARROW ) {
		Sound_Play( self.soundPressed );
		self._presstime = Timer_Time;

		self._target._realValue = self._target._realValue - self._target.stepValue;
		if( self._target._realValue < self._target.minValue )
			self._target._realValue = self._target.maxValue;

		Raise_DataEvent( self._target, ITEM_DATALINK_SET );

		CtCall_Action();
		return true;
	}

	return false;
};

void() Item_SwitchButton_Spawn =
{
	Item_ValueButton_Spawn();

	self._key = Item_SwitchButton_Key;
};
