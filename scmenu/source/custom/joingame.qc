// Property of Alientrap/AK
// custom/joingame/joingame.qc

////////////////////////////////////
// Item_Nex_HostCache_Entry
//////

void() Item_Nex_HostCache_Entry_Update =
{
	if( HostCache_ViewCount <= self.stepValue ) {
		self.flag = self.flag | FLAG_HIDDEN;
		return;
	} else if( self.flag & FLAG_HIDDEN )
		self.flag = self.flag - FLAG_HIDDEN;

	if( Menu_HasRunFlag( self, RUNFLAG_CLIPPED ) )
		return;

	Item_Button_Update();
};

void() Item_Nex_HostCache_Entry_Draw =
{
	Item_Window_Draw();
	Item_Button_Draw();
};

void() Item_Nex_HostCache_Entry_Spawn =
{
	Item_Window_Spawn();
	Item_Button_Spawn();

	self.flag = self.flag | FLAG_HIDDEN; // we dont want to get this bloody hostcachestring warning
	if( self.flag & FLAG_NOSELECT )
		self.flag = self.flag - FLAG_NOSELECT;
	self._draw = Item_Nex_HostCache_Entry_Draw;
	self._update = Item_Nex_HostCache_Entry_Update;
};

////////////////////////////////////
// Item_Nex_HostCache_StringField
////////

void() Item_Nex_HostCache_StringField_Update =
{
	local float lMaxLen;

	if( HostCache_ViewCount <= self._parent.stepValue )
		return;
	lMaxLen = floor( self.size_x / self.fontSize_x );
	String_EntitySet( self, text, gethostcachestring( self._realValue, self._parent.stepValue ) );
	if( lMaxLen < strlen( self.text ) )
		String_EntitySet( self, text, strcat( substring( self.text, 0, lMaxLen - 3 ), "..." ) );

	Item_Label_Update();
};

void() Item_Nex_HostCache_StringField_Spawn =
{
	Item_Label_Spawn();

	self._realValue = gethostcacheindexforkey( self.target );
	self._update = Item_Nex_HostCache_StringField_Update;
};

////////////////////////////////////
// Item_Nex_HostCache_ValueField
////////

void() Item_Nex_HostCache_ValueField_Update =
{
	if( HostCache_ViewCount <= self._parent.stepValue )
		return;
	String_EntitySet( self, text, ftos( gethostcachenumber( self._realValue, self._parent.stepValue ) ) );

	Item_Label_Update();
};

void() Item_Nex_HostCache_ValueField_Spawn =
{
	Item_Label_Spawn();

	self._realValue = gethostcacheindexforkey( self.target );
	self._update = Item_Nex_HostCache_ValueField_Update;
};

//////////////////////////////////
// Item_Nex_HostCache_Players
///////

void() Item_Nex_HostCache_Players_Update =
{
	local string lNum, lMax;

	if( HostCache_ViewCount <= self._parent.stepValue )
		return;
	lNum = ftos( gethostcachenumber( SLIST_FIELD_NUMPLAYERS, self._parent.stepValue ) );
	lMax = ftos( gethostcachenumber( SLIST_FIELD_MAXPLAYERS, self._parent.stepValue ) );

	String_EntitySet( self, text, strcat( lNum, "/", lMax ) );

	Item_Label_Update();
};

void() Item_Nex_HostCache_Players_Spawn =
{
	Item_Label_Spawn();

	self._update = Item_Nex_HostCache_Players_Update;
};
