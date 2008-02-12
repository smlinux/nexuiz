// --------------------------------------------------------------------------
// BEGIN REQUIRED CSQC FUNCTIONS

// CSQC_Init : Called every time the CSQC code is initialized (essentially at map load)
// Useful for precaching things
void CSQC_Init(void)
{
}
// CSQC_Shutdown : Called every time the CSQC code is shutdown (changing maps, quitting, etc)
void CSQC_Shutdown(void)
{
}
// CSQC_ConsoleCommand : Used to parse commands in the console that have been registered with the "registercmd" function
// Return value should be 1 if CSQC handled the command, otherwise return 0 to have the engine handle it.
float CSQC_ConsoleCommand(string strMessage)
{
	local float nReturn;
	local string s;
	local vector v;
		nReturn = FALSE;
		
	// Tokenize String
	tokenize(strMessage);
	
	// Acquire Command
	local string strCmd;
		strCmd = argv(0);

	/*
	if (strCmd == "+forward")
	{
		// blah
		nReturn = TRUE;
	}
	*/
	return nReturn;
}
// CSQC_InputEvent : Used to perform actions based on any key pressed, key released and mouse on the client.
// Return value should be 1 if CSQC handled the input, otherwise return 0 to have the input passed to the engine.
// All keys are in ascii.
// bInputType = 0 is key pressed, 1 is key released, 2 is mouse input.
// In the case of keyboard input, nPrimary is the ascii code, and nSecondary is 0.
// In the case of mouse input, nPrimary is xdelta, nSecondary is ydelta.
float CSQC_InputEvent(float bInputType, float nPrimary, float nSecondary)
{
	local float bSkipKey;
		bSkipKey = false;
	return bSkipKey;
}

// END REQUIRED CSQC FUNCTIONS
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// BEGIN OPTIONAL CSQC FUNCTIONS

// CSQC_Ent_Update : Called every frame that the server has indicated an update to the SSQC / CSQC entity has occured.
// The only parameter reflects if the entity is "new" to the client, meaning it just came into the client's PVS.
void(float bIsNewEntity) CSQC_Ent_Update =
{
	self.enttype = ReadByte();
	/*
	if (self.enttype == ENT_CLIENT)
	{
		setmodelindex(self, ReadShort());
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		self.angles_x = ReadCoord();
		self.angles_y = ReadCoord();
		self.angles_z = ReadCoord();
		self.sv_entnum = ReadShort();
		setorigin(self, self.origin); // relink
		if (bIsNewEntity)
		{
			setsize(self, '0 0 0', '0 0 0');
			self.drawmask = MASK_NORMAL;
			self.think = Client_Think;
			self.nextthink = time;
		}
	}
	else
		error("unknown entity type in CSQC_Ent_Update\n");
	*/
};
// CSQC_Ent_Remove : Called when the server requests a SSQC / CSQC entity to be removed.  Essentially call remove(self) as well.
void CSQC_Ent_Remove()
{
	remove(self);
}
// CSQC_Parse_StuffCmd : Provides the stuffcmd string in the first parameter that the server provided.  To execute standard behavior, simply execute localcmd with the string.
void CSQC_Parse_StuffCmd(string strMessage)
{	
	localcmd(strMessage);
}
// CSQC_Parse_Print : Provides the print string in the first parameter that the server provided.  To execute standard behavior, simply execute print with the string.
void CSQC_Parse_Print(string strMessage)
{
	print(strMessage);
}
// CSQC_Parse_CenterPrint : Provides the centerprint string in the first parameter that the server provided.  To execute standard behavior, simply execute cprint with the string.
void CSQC_Parse_CenterPrint(string strMessage)
{
	cprint(strMessage);
}
// CSQC_Parse_TempEntity : Handles all temporary entity network data in the CSQC layer.
// You must ALWAYS first acquire the temporary ID, which is sent as a byte.
// Return value should be 1 if CSQC handled the temporary entity, otherwise return 0 to have the engine process the event.
float CSQC_Parse_TempEntity()
{
	local float bHandled;
		bHandled  = true;
	// Acquire TE ID
	local float nTEID;
		nTEID = ReadByte();
		
	switch(nTEID)
	{
		//case TE_GUNSHOT:
		//	Do something cool with TE_GUNSHOT!
		//	break;
		default:
			// No special logic for this temporary entity; return 0 so the engine can handle it
			bHandled = false;
			break;
	}
		
	return bHandled;
}