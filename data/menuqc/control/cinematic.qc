// DP/Nex Menu
// control/cinematic.qc

/////////////////////
// [Item_Cinematic]
///

/*
===================
Item_Cinematic_Destroy
===================
*/
void() Item_Cinematic_Destroy =
{
	// close the video stream
	cin_close( self.normal );

	String_EntityFree( self, link );
	String_EntityFree( self, normal );
}

/*
===================
Item_Cinematic_Init
===================
*/
void() Item_Cinematic_Init =
{
	self.flag = self.flag | FLAG_HIDDEN;

	String_EntityZone( self, link );
	String_EntityZone( self, normal );

	cin_open( self.link, self.normal );

	self._destroy = Item_Cinematic_Destroy;
};

/////////////////////////
// Item_Cinematic_Loop
///

void() Item_Cinematic_Loop_Spawn =
{
	Item_Cinematic_Init();

	cin_setstate( self.normal, CINE_LOOP );
};

