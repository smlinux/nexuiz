// Property of Alientrap/AK
// custom/visible.qc

void( entity pItem ) Nex_MakeOnlyVisible =
{
	local entity lChild;

	for( lChild = pItem._parent._child ; lChild ; lChild = lChild._next )
		lChild.flag = lChild.flag | FLAG_HIDDEN;

	pItem.flag = pItem.flag - FLAG_HIDDEN;

	Menu_UpdateRunFlags();
};
