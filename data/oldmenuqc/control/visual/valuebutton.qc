// DP/Nex Menu
// control/visual/valuebutton.qc

/////////////////////
// Item_ValueButton
///

void() Item_ValueButton_Update =
{
	Item_DataUser_Update();

	Raise_DataEvent( self._target, ITEM_DATALINK_GET );
	String_EntitySet( self, normal, self._target.value );
	self.size = '0 0 0'; // FIXME: Do we really want this/need this?
	Item_Button_Update();
};

void() Item_ValueButton_Destroy =
{
	Item_DataUser_Destroy();
	Item_Button_Destroy();
};

void() Item_ValueButton_Spawn =
{
	Item_DataUser_Init();
	Item_Button_Spawn();

	self._destroy = Item_ValueButton_Destroy;
	self._update = Item_ValueButton_Update;
};
