// DP/Nex Menu
// system/gc.qc

void() Menu_InitGarbageStats =
{
	Menu_GarbageFrameCount = 0;
	Menu_GarbageToggleCount = 0;
};

void() Menu_ResetGarbageStats =
{
	if( Menu_GarbageFrameCount )
		print( "Menu: GC: ", ftos( Menu_GarbageFrameCount ), " items marked for frame deletion but couldnt be reached!\n" );
	if( Menu_GarbageToggleCount )
		print( "Menu: GC: ", ftos( Menu_GarbageToggleCount ), " items marked for toggle delition but couldnt be reached!\n" );

	Menu_GarbageFrameCount = 0;
	Menu_GarbageToggleCount = 0;
};

bool( entity pItem ) Menu_CheckForGarbage =
{
	if( Menu_HasRunFlag( pItem, RUNFLAG_DELETEFRAME ) ) {
		Menu_RemoveItem( pItem );
		--Menu_GarbageFrameCount;
		return true;
	}
	return false;
};

void( bool pToggle ) Menu_CollectGarbage =
{
	local entity lNode;

	lNode = null_entity;
	if( pToggle ) {
		while( (Menu_GarbageFrameCount || Menu_GarbageToggleCount) && (lNode = nextent( lNode )) != null_entity )
			if( Menu_HasRunFlag( lNode, RUNFLAG_DELETEFRAME ) ) {
				Menu_RemoveItem( lNode );
				--Menu_GarbageFrameCount;
			} else if( Menu_HasRunFlag( lNode, RUNFLAG_DELETETOGGLE ) ) {
				Menu_RemoveItem( lNode );
				--Menu_GarbageToggleCount;
			}
	} else while( Menu_GarbageFrameCount && (lNode = nextent( lNode )) != null_entity )
		if( Menu_HasRunFlag( lNode, RUNFLAG_DELETEFRAME ) ) {
			Menu_RemoveItem( lNode );
			--Menu_GarbageFrameCount;
		}
};

void( entity pItem ) Menu_DeleteAfterFrame =
{
	if( !Menu_HasRunFlag( pItem, RUNFLAG_DELETEFRAME ) ) {
		if( Menu_HasRunFlag( pItem, RUNFLAG_DELETETOGGLE ) ) {
			pItem._runFlag = pItem._runFlag + RUNFLAG_DELETEFRAME - RUNFLAG_DELETETOGGLE;
			--Menu_GarbageToggleCount;
		} else
			pItem._runFlag = pItem._runFlag + RUNFLAG_DELETEFRAME;
		++Menu_GarbageFrameCount;
	}
};

void( entity pItem ) Menu_DeleteAfterToggle =
{
	if( Menu_HasRunFlag( pItem, RUNFLAG_DELETEFRAME )
		|| Menu_HasRunFlag( pItem, RUNFLAG_DELETETOGGLE ) )
		return;
	pItem._runFlag = self._runFlag + RUNFLAG_DELETETOGGLE;
	++Menu_GarbageToggleCount;
};

