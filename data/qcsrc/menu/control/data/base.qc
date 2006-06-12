// DP/Nex Menu
// control/data/base.qc

/*
===================
Raise_DataEvent
===================
*/
void( entity pItem, float pEvent ) Raise_DataEvent =
{
	local entity lOld;

	if( !pItem._dataEvent )
		return;

	lOld = self;
	self = pItem;
	self._dataEvent( pEvent );
	self = lOld;
};

/*
===================
Data_ExecString_BeginUse
===================
*/
void() Data_ExecString_BeginUse =
{
	Data_ExecString = String_Create();
};

/*
===================
Data_ExecString_EndUse
===================
*/
void() Data_ExecString_EndUse =
{
	String_Free( Data_ExecString);
};

/////////////////////
// [Item_Data]
///

/*
===================
Item_Data_Destroy
===================
*/
void() Item_Data_Destroy =
{
	String_EntityFree( self, value );
	String_EntityFree( self, defValue );
	String_EntityFree( self, _syncValue );
};

/*
===================
Item_Data_Init
===================
*/
void() Item_Data_Init =
{
	String_EntityZone( self, value );
	String_EntityZone( self, defValue );
	String_EntityCreate( self, _syncValue );

	self.flag = self.flag | FLAG_HIDDEN;

	self._destroy = Item_Data_Destroy;
};

////////////////////
// [Item_DataLink]
///

/*
===================
Item_DataLink_Update
===================
*/
void() Item_DataLink_Update =
{
	if( self.link == "" )
		self._link = null_entity;
	else if( self.link != self._link.name )
		self._link = Menu_GetItem( self.link );
};

/*
===================
Item_DataLink_Destroy
===================
*/
void() Item_DataLink_Destroy =
{
	String_EntityFree( self, link );
	String_EntityFree( self, value );
};

/*
===================
Item_DataLink_Init
===================
*/
void() Item_DataLink_Init =
{
	self.flag = self.flag | FLAG_HIDDEN;

	String_EntityZone( self, link );
	String_EntityZone( self, value );
	Item_DataLink_Update();

	self._destroy = Item_DataLink_Destroy;
};

////////////////////
// [Item_DataLink_Switch]
///

/*
===================
Item_DataLink_Switch_Destroy
===================
*/
void() Item_DataLink_Switch_Destroy =
{
	Item_DataLink_Destroy();
	String_EntityFree( self, descList );
};

/*
===================
Item_DataLink_Switch_Init
===================
*/
void() Item_DataLink_Switch_Init =
{
	Item_DataLink_Value_Spawn();
	String_EntityZone( self, descList );

	self._destroy = Item_DataLink_Switch_Destroy;
};

/*
===================
Item_GetOrdinal
===================
*/
float( entity pDataLink, float pValue ) DataLink_Switch_GetOrdinal =
{
	if( pDataLink.stepValue == 0.0 )
		return 0.0;
	return (pValue - pDataLink.minValue) / pDataLink.stepValue;
};

////////////////////
// [Item_DataUser]
///

/*
===================
Item_DataUser_Update
===================
*/
void() Item_DataUser_Update =
{
	if( self.target == "" )
		self._target = null_entity;
	else if( self.target != self._target.name )
		self._target = Menu_GetItem( self.target );
};

/*
===================
Item_DataUser_Destroy
===================
*/
void() Item_DataUser_Destroy =
{
	String_EntityFree( self, target );
};

/*
===================
Item_DataUser_Init
===================
*/
void() Item_DataUser_Init =
{
	String_EntityZone( self, target );

	Item_DataUser_Update();

	self._destroy = Item_DataUser_Destroy;
};

/*
===================
Item_DataContainer_DataEvent
===================
*/
void( float pEvent ) Item_DataContainer_DataEvent =
{
	// no support for embedded stuff yet (isnt needed imho anyway)
	local entity lItem;

	for( lItem = self._child ; lItem != null_entity ; lItem = lItem._next ) {
		Raise_DataEvent( lItem, pEvent );
	}
};

/*
===================
Item_DataContainer_Spawn
===================
*/
void() Item_DataContainer_Spawn =
{
	Item_Container_Spawn();

	self._dataEvent = Item_DataContainer_DataEvent;
};
