// DP/Nex menu
// system/history.qc


/*
===================
Menu_History_Push
===================
*/
void( entity pEntity, Menu_History_PopFunction pPopFunction ) Menu_History_Push =
{
	local entity lHistory;

	Menu_KeyHook = Util_NullFunction;

	lHistory = spawn();

	lHistory.type = "MMANAGER_HISTORY";
	lHistory._prev = Menu_History;
	lHistory._child = Menu_ActiveItem;
	lHistory._parent = Menu_ActiveWindow;
	lHistory._next = pEntity; // "used for"
	lHistory._destroy = pPopFunction;

	Menu_History = lHistory;
};

/*
===================
Menu_History_Pop
===================
*/
void() Menu_History_Pop =
{
	local entity lTemp;

	if( Menu_History == null_entity )
		return;

	Menu_KeyHook = Util_NullFunction;

	Menu_ActiveItem = Menu_History._child;
	Menu_ActiveWindow = Menu_History._parent;

	lTemp = Menu_History;
	// FIXME: use Menu_DestroyItem
	Raise_Destroy( lTemp );
	Menu_History = Menu_History._prev;
	remove( lTemp );
};

/*
===================
Menu_History_Verify
===================
*/
bool( entity pEntity ) Menu_History_Verify =
{
	if( Menu_History == null_entity )
		return false;

	if( Menu_History._next == pEntity )
		return true;
	return false;
};

/*
===================
Menu_History_Clear
===================
*/
void() Menu_History_Clear =
{
	local entity lEntity;

	lEntity = null_entity;
	while( ( lEntity = findstring( lEntity, type, "MMANAGER_HISTORY" ) ) != null_entity)
		remove( lEntity );

	Menu_History = null_entity;
};
