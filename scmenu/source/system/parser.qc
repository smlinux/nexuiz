// DP/Nex Menu
// system/parser.qc

void() Parser_Define_Spawn = {};

void() Parser_TokenizeLine =
{
	Parser_NumTokens = tokenize( Parser_Line );
	Parser_TokenNum = 0;
};

bool() Parser_GetToken =
{
	local string lLine;

	if( Parser_TokenNum >= Parser_NumTokens ) { // get a new line
		lLine = fgets( Parser_File );
		++Parser_LineNumber;
		if( !lLine )
			if( !validstring( lLine ) )
				return false;
			else
				return Parser_GetToken();

		Parser_Line = String_Set( Parser_Line, lLine );
		Parser_TokenizeLine();
		return Parser_GetToken();
	} else {
		Parser_Token = String_Set( Parser_Token, argv( Parser_TokenNum ) );
		Parser_TokenNum++;
	}

	Parser_Print( PARSER_LOW, strcat( "Read token '", Parser_Token, "'" ) );

	Parser_TokenType = Parser_GetTokenType();
	if( Parser_TokenType == PARSER_TT_BRACKETOPEN ) {
		Parser_ProcessDefine();
		return Parser_GetToken();
	}

	return true;
};

float() Parser_GetTokenType =
{
	if( Parser_Token == "Item" )
		return PARSER_TT_ITEM;
	else if( Parser_Token == "Template" )
		return PARSER_TT_TEMPLATE;
	else if( Parser_Token == "Derive" )
		return PARSER_TT_DERIVE;
	else if( Parser_Token == "DeriveTemplate" )
		return PARSER_TT_DERIVETEMPLATE;
	else if( Parser_Token == "#define" )
		return PARSER_TT_DEFINE;
	else if( Parser_Token == "Ignore" )
		return PARSER_TT_IGNORE;
	else if( Parser_Token == "#undef" )
		return PARSER_TT_UNDEF;
	else if( Parser_Token == "Namespace" )
		return PARSER_TT_NAMESPACE;
	else if( Parser_Token == "#include" )
		return PARSER_TT_INCLUDE;
	else if( Parser_Token == "}" )
		return PARSER_TT_BRACECLOSE;
	else if( Parser_Token == "{" )
		return PARSER_TT_BRACEOPEN;
	else if( Parser_Token == "[" )
		return PARSER_TT_BRACKETOPEN;
	else if( Parser_Token == "]" )
		return PARSER_TT_BRACKETCLOSE;

	return PARSER_TT_TOKEN;
};

void( float pLevel, string pText ) _Parser_Print =
{
	if( pLevel == 0 || sys_debug_parser & pLevel )
		print( "Parser: ", pText, "\n" );
};

void( float pLevel, string pInfo ) Parser_Print =
{
	if( pLevel == 0 || sys_debug_parser & pLevel )
		print( "Parser: ", Parser_Filename, ":", ftos( Parser_LineNumber ), ": ", pInfo, "\n" );
};

void( string pInfo ) Parser_Error =
{
	print( "Parser: ", Parser_Filename, ":", ftos( Parser_LineNumber ), ": Error: '");
	print( Parser_Token, "' not expected (", pInfo, ")!\n" );
	fclose( Parser_File );
	error( "Error in the menu parser!" );
};

void( float pType ) Parser_Expect =
{
	if( !Parser_GetToken() || ( Parser_TokenType != pType && Parser_TokenType != PARSER_TT_BRACKETOPEN ) )
		Parser_Error( strcat( "expected ", PARSER_TT_TEXT[ pType - PARSER_TT_ITEM ] ) );
};

void( string pNamespace ) Parser_IncludeFile =
{
	local string 	lFilename, lLine;
	local float 	lFile, lLineNumber, lNumTokens, lTokenNum;

	// #include file
	Parser_Expect( PARSER_TT_TOKEN );

	Parser_Print( PARSER_INFO, strcat( "#include: Including file '", Parser_Token, "'" ) );

	Parser_FileList = String_Append( Parser_FileList, strcat( " {'", String_Normal( Util_AltStringPrepare( Parser_Token ) ), "'" ) );

	lFilename = Parser_Filename;
	lLine = Parser_Line;

	lFile = Parser_File;
	lLineNumber = Parser_LineNumber;
	lNumTokens = Parser_NumTokens;
	lTokenNum = Parser_TokenNum;

	--Parser_IncludeDepth;
	if( Parser_IncludeDepth > Parser_MaxIncludeDepth )
		Parser_Print( PARSER_NORMAL, "#include: Maximum depth reached!" );
	else
		Parser_ParseFile( Parser_Token, pNamespace );
	--Parser_IncludeDepth;

	Parser_Filename = lFilename;
	Parser_Line = lLine;

	Parser_File = lFile;
	Parser_LineNumber = lLineNumber;

	// tokenize the line again, but jump to the old position
	Parser_TokenizeLine();
	Parser_NumTokens = lNumTokens;
	Parser_TokenNum = lTokenNum;

	Parser_FileList = String_Append( Parser_FileList, "}" );
};

void() Parser_ParseDefine =
{
	local entity lDefine;
	local float lOldLine;

	Parser_Print( 2, "Parsing #define..." );

	// #define NAME CONSTANT
	//Parser_Expect( PARSER_TT_BRACKETOPEN );
	Parser_Expect( PARSER_TT_TOKEN );

	// check for double definitions (dont error just print a warning)
	for( lDefine = Parser_DefineChain ; lDefine ; lDefine = lDefine.chain )
		if( Parser_Token == lDefine.name ) {
			Parser_Print( PARSER_INFO, strcat( "#define: [", Parser_Token, "] already defined!" ) );
			Parser_Expect( PARSER_TT_TOKEN );
			return;
		}

	lDefine = spawn();
	lDefine.type = "Parser_Define";
	lDefine.name = String_Zone( Parser_Token );

	//Parser_Expect( PARSER_TT_BRACKETCLOSE );
	// read the rest of the line
	String_EntityZone( lDefine, value );
	lOldLine = Parser_LineNumber;
	while( 1 )
		if( !Parser_GetToken() )
			break;
		else if( lOldLine != Parser_LineNumber ) {
			--Parser_TokenNum;
			break;
		} else if( Parser_Token == "\\" )
			++lOldLine;
		else
			String_EntitySet( lDefine, value, strcat( lDefine.value, "\"", Parser_Token, "\" " ) );

	Parser_Print( PARSER_HIGH, strcat( " Name = '", lDefine.name, "' Replacement = '", lDefine.value, "'" ) );

	lDefine.chain = Parser_DefineChain;
	Parser_DefineChain = lDefine;

	Parser_Print( PARSER_HIGH, "Done parsing #define" );
};

void() Parser_ParseUndef =
{
	local entity lEntity, lPrevious;

	// #undef Name
	Parser_Print( PARSER_HIGH, "Parsing #undef..." );
	Parser_Expect( PARSER_TT_TOKEN );

	lPrevious = null_entity;
	for( lEntity = Parser_DefineChain ; lEntity ; lPrevious = lEntity, lEntity = lEntity.chain )
		if( lEntity.name == Parser_Token ) {
			if( lPrevious )
				lPrevious.chain = lEntity.chain;
			else
				Parser_DefineChain = lEntity.chain;

			Parser_Print( PARSER_INFO, strcat( "#undef: Removed [", Parser_Token, "]" ) );

			String_Free( lEntity.name );
			String_Free( lEntity.value );

			remove( lEntity );

			return;
		}

	Parser_Print( PARSER_INFO, strcat( "#undef: [", Parser_Token, "] not found!" ) );
};

void() Parser_ProcessDefine =
{
	local string lConstant;
	local entity lDefine;

	// [Name]
	Parser_Expect( PARSER_TT_TOKEN );
	lConstant = String_Zone( Parser_Token );

	Parser_Expect( PARSER_TT_BRACKETCLOSE );

	Parser_Print( PARSER_HIGH, strcat( "Processing [", lConstant, "]..." ) );

	for( lDefine = Parser_DefineChain ; lDefine ; lDefine = lDefine.chain )
		if( lDefine.name == lConstant ) {
			// if you want to have a single token use \" or '
			Parser_Line = String_Set( Parser_Line, strcat( " ", lDefine.value ) );
			Parser_Print( PARSER_HIGH, strcat( "Replacing with '", Parser_Line, "'" ) );
			for( ; Parser_TokenNum < Parser_NumTokens ; Parser_TokenNum++ )
				Parser_Line = String_Set( Parser_Line, strcat( Parser_Line, " \"", argv( Parser_TokenNum ), "\"" ) );
			Parser_TokenizeLine();
			String_Free( lConstant );
			return;
		}

	Parser_Token = String_Set( Parser_Token, String_Normal( lConstant ) );
	Parser_Print( PARSER_NORMAL, strcat( "#define: Couldn't find constant '", Parser_Token, "'!" ) );
	Parser_Error( "constant not found" );
};

// Item [Template]
// Template
void( string pNamespace ) Parser_ParseDefinition =
{
	local entity lEntity;

	if( Parser_TokenType == PARSER_TT_ITEM )
		Parser_ParseItem( pNamespace );
	else if( Parser_TokenType == PARSER_TT_TEMPLATE ) {
		lEntity = Parser_ParseItem( pNamespace );
		lEntity.flag = lEntity.flag | FLAG_TEMPLATE;
	} else if( Parser_TokenType == PARSER_TT_DEFINE )
		Parser_ParseDefine();
	else if( Parser_TokenType == PARSER_TT_DERIVE )
		Parser_DeriveItem( pNamespace );
	else if( Parser_TokenType == PARSER_TT_DERIVETEMPLATE ) {
		lEntity = Parser_DeriveItem( pNamespace );
		lEntity.flag = lEntity.flag | FLAG_TEMPLATE;
	} else if( Parser_TokenType == PARSER_TT_UNDEF )
		Parser_ParseUndef();
	else if( Parser_TokenType == PARSER_TT_NAMESPACE )
		Parser_ParseNamespace( pNamespace );
	else if( Parser_TokenType == PARSER_TT_INCLUDE )
		Parser_IncludeFile( pNamespace );
	else if( Parser_TokenType == PARSER_TT_IGNORE )
		Parser_ParseIgnore();
	else
		Parser_Error( "couldn't find type in Parser_ParseDef" );
};

void() Parser_ParseIgnore =
{
	local float lBraceCount;

	Parser_Expect( PARSER_TT_BRACEOPEN );
	for( lBraceCount = 1 ; lBraceCount > 0 ; )
		if( !Parser_GetToken() )
			break;
		else if( Parser_TokenType == PARSER_TT_BRACEOPEN )
			++lBraceCount;
		else if( Parser_TokenType == PARSER_TT_BRACECLOSE )
			--lBraceCount;
};

entity( string pNamespace ) Parser_ParseItem =
{
	local string lNamespace;
	local string lEntityText;
	local entity lEntity;

	Parser_Print( PARSER_HIGH, "Parsing item.." );

	// get the item type
	Parser_Expect( PARSER_TT_TOKEN );
	lEntityText = String_Zone( strcat( "{ \"type\" \"Item_", Parser_Token,"\" " ) );

	Parser_Print( PARSER_HIGH, strcat( " Type = '", Parser_Token, "'" ) );

	// get the item name
	Parser_Expect( PARSER_TT_TOKEN );
	if( pNamespace != "" )
		lNamespace = String_Zone( strcat( pNamespace, "::", Parser_Token ) );
	else
		lNamespace = String_Zone( Parser_Token );

	lEntityText = String_Set( lEntityText, strcat( lEntityText, "\"name\" \"", lNamespace, "\" " ) );
	lEntityText = String_Set( lEntityText, strcat( lEntityText, "\"parent\" \"", pNamespace, "\" " ) );

	Parser_Print( PARSER_HIGH, strcat( " Name = '", Parser_Token, "' Parent = '", pNamespace,
				"' Namespace = '", lNamespace, "'" ) );

	Parser_Expect( PARSER_TT_BRACEOPEN );
	lEntityText = Parser_ParseEntity( lNamespace, lEntityText );

	// parse the entity (builtin)
	lEntity = spawn();
	parseentitydata( lEntity, lEntityText );

	String_Free( lEntityText );
	String_Free( lNamespace );

	Parser_Print( PARSER_HIGH, strcat( "Parsing '", lEntity.name, "' finished" ) );

	return lEntity;
};

void( entity pSource, entity pTarget ) Parser_CloneChildren =
{
	// we search for all items that are direct children of pSource and copy them
	// and adapt their parent and names
	local entity lNode;

	lNode = null_entity;
	while ( (lNode = findstring( lNode, parent, pSource.name )) != null_entity ) {
		local entity lClone;
		local string lModifierString;

		lClone = spawn();
		copyentity( lNode, lClone );

		if( lClone.flag & FLAG_TEMPLATE )
			lClone.flag = lClone.flag - FLAG_TEMPLATE;

		lModifierString = strcat( "{ name \"", pTarget.name,
			substring( lNode.name, strlen( pSource.name ), 100000 ), "\" parent \"", pTarget.name, "\" }" );

		parseentitydata( lClone, lModifierString );

		Parser_CloneChildren( lNode, lClone );
	}
};

entity( string pNamespace ) Parser_DeriveItem =
{
	local string lNamespace;
	local string lEntityText;
	local entity lBase;
	local string lBaseName;
	local entity lEntity;

	Parser_Print( PARSER_HIGH, "Parsing derived item.." );

	// get the base item
	Parser_Expect( PARSER_TT_TOKEN );

	if( substring( Parser_Token, 0, 2 ) == "::" )
		lBaseName = String_Zone( substring( Parser_Token, 2, strlen( Parser_Token ) - 2 ) );
	else if( pNamespace == "" )
		lBaseName = String_Zone( Parser_Token );
	else {
		lBaseName = String_Zone( strcat( pNamespace, "::", Parser_Token ) );

		// try the local namespace first, then try to find it in the global
		if( findstring( null_entity,  name, lBaseName ) == null_entity )
			lBaseName = String_Set( lBaseName, Parser_Token );
	}

	Parser_Print( PARSER_HIGH, strcat( " Base = '", lBaseName, "'" ) );

	lBase = findstring( null_entity, name, lBaseName );
	if( lBase == null_entity )
		Parser_Error( "couldnt find item" );

	// get the item name
	Parser_Expect( PARSER_TT_TOKEN );
	if( pNamespace != "" )
		lNamespace = String_Zone( strcat( pNamespace, "::", Parser_Token ) );
	else
		lNamespace = String_Zone( Parser_Token );

	lEntityText = String_Zone( strcat( "{ \"name\" \"", lNamespace, "\" " ) );
	lEntityText = String_Set( lEntityText, strcat( lEntityText, "\"parent\" \"", pNamespace, "\" " ) );

	Parser_Print( PARSER_HIGH, strcat( " Name = '", Parser_Token, "' Parent = '", pNamespace,
				"' Namespace = '", lNamespace, "'" ) );

	Parser_Expect( PARSER_TT_BRACEOPEN );
	lEntityText = Parser_ParseEntity( lNamespace, lEntityText );

	// parse the entity (builtin)
	lEntity = spawn();
	copyentity( lBase, lEntity );
	if( lEntity.flag & FLAG_TEMPLATE )
		lEntity.flag = lEntity.flag - FLAG_TEMPLATE;
	parseentitydata( lEntity, lEntityText );

	String_Free( lEntityText );
	String_Free( lNamespace );
	String_Free( lBaseName );

	// now copy over all children
	Parser_CloneChildren( lBase, lEntity );

	Parser_Print( PARSER_HIGH, strcat( "Parsing '", lEntity.name, "' finished" ) );

	return lEntity;
};

string( string pNamespace, string pEntityText ) Parser_ParseEntity =
{
	while( Parser_GetToken() ) {
		if( Parser_TokenType == PARSER_TT_TOKEN ) {
			// must be a property...
			// store the key value
			pEntityText = String_Set( pEntityText, strcat( pEntityText, "\"", Parser_Token, "\" " ) );
			Parser_Expect( PARSER_TT_TOKEN );
			pEntityText = String_Set( pEntityText, strcat( pEntityText, "\"", Parser_Token, "\" " ) );
		} else if( Parser_TokenType == PARSER_TT_BRACECLOSE )
			break;
		else
			Parser_ParseDefinition( pNamespace );
	}

	return String_Append( pEntityText, " }" );
};

void( string pNamespace ) Parser_ParseNamespace =
{
	local string lNamespace;

	Parser_Print( PARSER_HIGH, "Parsing Namespace..." );
	// namespace Name {
	Parser_Expect( PARSER_TT_TOKEN );
	if( pNamespace != "" )
		lNamespace = String_Zone( strcat( pNamespace, "::", Parser_Token ) );
	else
		lNamespace = String_Zone( Parser_Token );
	Parser_Print( PARSER_HIGH, strcat( " Subnamespace = '", Parser_Token, "' New namespace = '", lNamespace, "'" ) );

	Parser_Expect( PARSER_TT_BRACEOPEN );

	while( Parser_GetToken() ) {
		if( Parser_TokenType == PARSER_TT_BRACECLOSE )
			break;

		Parser_ParseDefinition( lNamespace );
	}

	Parser_Print( PARSER_HIGH, strcat( "Finished parsing Namespace. Namespace = '", pNamespace, "'" ) );

	String_Free( lNamespace );
};

void( string pFilename, string pNamespace ) Parser_ParseFile =
{
	Parser_Filename = String_Zone( pFilename );
	Parser_File = fopen( Parser_Filename, FILE_READ );
	if( Parser_File == -1 ) {
		print( "Parser: Couldn't open ", Parser_Filename, "\n" );
		return;
	}

	Parser_Line = String_Create();
	Parser_LineNumber = 0;
	Parser_NumTokens = Parser_TokenNum = 0;

	while( Parser_GetToken() )
		Parser_ParseDefinition( pNamespace );

	fclose( Parser_File );
	String_Free( Parser_Filename );
	String_Free( Parser_Line );
};

void() Parser_Init =
{
	Parser_Token = String_Create();
	Parser_DefineChain = null_entity;
	Parser_IncludeDepth = 0;

	Parser_FileList = String_Create();
};

void() Parser_Quit =
{
	local entity lNext;

	_Parser_Print( PARSER_HIGH, "Deleting #defines:" );
	while( Parser_DefineChain ) {
		lNext = Parser_DefineChain.chain;
		_Parser_Print( PARSER_HIGH, strcat( "  [", Parser_DefineChain.name, "]" ) );

		String_Free( Parser_DefineChain.name );
		String_Free( Parser_DefineChain.value );

		remove( Parser_DefineChain );
		Parser_DefineChain = lNext;
	}


	String_Free( Parser_Token );
	String_Free( Parser_FileList );
};

void( string pPluginDir ) Parser_ParsePlugins =
{
	local float lSearchHandle;
	local float lCounter, lCount;

	lSearchHandle = search_begin( strcat( pPluginDir, "/*.plugin" ), true, true );
	if( lSearchHandle < 0 ) {
		return;
	}

	lCount = search_getsize( lSearchHandle );

	for( lCounter = 0 ; lCounter < lCount ; lCounter++ ) {
		local string pPlugin;

		Parser_FileList = String_Set( Parser_FileList, "" );

		pPlugin = String_Zone( search_getfilename( lSearchHandle, lCounter ) );
		Parser_FileList = Util_AltStringPush( Parser_FileList, pPlugin );

		Parser_ParseFile( pPlugin, "" );

		_Parser_Print( PARSER_INFO, strcat( "Plugin '", pPlugin, "': files parsed: ", Parser_FileList ) );
		String_Free( pPlugin );
	}

	search_end( lSearchHandle );
};

void( string pMain, string pPluginDir ) Parser_ParseMenu =
{
	Parser_Init();

	pMain = String_Zone( pMain );
	Parser_FileList = Util_AltStringPush( Parser_FileList, pMain );

	Parser_ParseFile( pMain, "" );

	_Parser_Print( PARSER_INFO, strcat( "Files parsed: ", Parser_FileList ) );
	String_Free( pMain );

	// plugins
	if( pPluginDir != "" ) {
		Parser_ParsePlugins( pPluginDir );
	}

	Parser_Quit();
};
