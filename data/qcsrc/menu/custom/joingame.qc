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
	local string lString;

	if( HostCache_ViewCount <= self._parent.stepValue )
		return;
	lMaxLen = floor( self.size_x / self.fontSize_x );
	lString = gethostcachestring( self._realValue, self._parent.stepValue );
	if( lMaxLen < strlen( lString ) ) {
		lString = strcat( substring( lString, 0, lMaxLen - 3 ), "..." );
	}
	String_EntitySet( self, text, lString );

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
	local string lHum, lNum, lMax;
	local float lHumans, lBots;

	if( HostCache_ViewCount <= self._parent.stepValue )
		return;
	lHumans = gethostcachenumber( SLIST_FIELD_NUMHUMANS, self._parent.stepValue );
	lBots = gethostcachenumber( SLIST_FIELD_NUMBOTS, self._parent.stepValue );
	if (lBots >= 0) lHum = ftos( lHumans ); else lHum = "?";
	lNum = ftos( gethostcachenumber( SLIST_FIELD_NUMPLAYERS, self._parent.stepValue ) );
	lMax = ftos( gethostcachenumber( SLIST_FIELD_MAXPLAYERS, self._parent.stepValue ) );

	String_EntitySet( self, text, strcat( lHum, "/", lNum, "/", lMax ) );

	Item_Label_Update();
};

void() Item_Nex_HostCache_Players_Spawn =
{
	Item_Label_Spawn();

	self._update = Item_Nex_HostCache_Players_Update;
};

//////////////////////////////////
// Item_Nex_HostCache_Ping
///////

const vector HOSTCACHE_FAST_PING_COLOR = '0.0 1.0 0.0';
const vector HOSTCACHE_MEDIUM_PING_COLOR = '1.0 1.0 0.0';
const vector HOSTCACHE_SLOW_PING_COLOR = '1.0 0.0 0.0';

const float HOSTCACHE_FAST_PING = 90;
const float HOSTCACHE_SLOW_PING = 150;

void() Item_Nex_HostCache_Ping_Update =
{
	local float ping;

	Item_Nex_HostCache_ValueField_Update();

	// AK 06 yes I know its not fast.. but its shorter..
	ping = stof( self.text );
	if( ping < HOSTCACHE_FAST_PING ) {
		self.color = HOSTCACHE_FAST_PING_COLOR;
	} else if( ping > HOSTCACHE_SLOW_PING ) {
		self.color = HOSTCACHE_SLOW_PING_COLOR;
	} else {
		self.color = HOSTCACHE_MEDIUM_PING_COLOR;
	}
}

void() Item_Nex_HostCache_Ping_Spawn =
{
	Item_Nex_HostCache_ValueField_Spawn();

	self._update = Item_Nex_HostCache_Ping_Update;
};

