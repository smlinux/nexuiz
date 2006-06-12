// DP/Nex Menu
// control/automation/foreach.qc

void() Item_Automation_ForEach_Spawn =
{
	local entity lLink;

	Item_Automation_Init();

	if( self.link == "" )
		lLink = self._parent;
	else
		lLink = Menu_GetItem( self.link );
	if( !self.target || !isfunction( strcat( self.target, "_Spawn" ) ) ) {
		objerror( "Bad target type!" );
		return;
	}

	for( self._current = lLink._child ; self._current ; self._current = self._current._next )
		if( self._current.type == self.target )
			CtCall_Action();
};

