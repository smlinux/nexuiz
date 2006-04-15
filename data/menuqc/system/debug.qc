// SCMenu
// system/debug.qc


/*
===================
Sys_Debug_Init
===================
*/
void() Sys_Debug_Init =
{
	registercvar( SYSTEM_CVAR_VERSION_BUILDDATE, "", CVAR_READONLY );
	cvar_set( SYSTEM_CVAR_VERSION_BUILDDATE, SYSTEM_CVAR_VERSION_BUILDDATE_VALUE );
	registercvar( SYSTEM_CVAR_VERSION_BUILDTIME, "", CVAR_READONLY );
	cvar_set( SYSTEM_CVAR_VERSION_BUILDTIME, SYSTEM_CVAR_VERSION_BUILDTIME_VALUE );
	registercvar( SYSTEM_CVAR_VERSION, "", CVAR_READONLY );
	cvar_set( SYSTEM_CVAR_VERSION, SYSTEM_CVAR_VERSION_VALUE );

	registercvar( SYSTEM_CVAR_DEBUG, ftos( SYSTEM_CVAR_DEBUG_DEFAULT ), 0 );
	registercvar( SYSTEM_CVAR_DEBUG_REF, ftos( SYSTEM_CVAR_DEBUG_REF_DEFAULT ), 0 );
	registercvar( SYSTEM_CVAR_DEBUG_RUNFLAG, ftos( SYSTEM_CVAR_DEBUG_RUNFLAG_DEFAULT ), 0 );
	registercvar( SYSTEM_CVAR_DEBUG_PROCESS, ftos( SYSTEM_CVAR_DEBUG_PROCESS_DEFAULT ), 0 );
	registercvar( SYSTEM_CVAR_DEBUG_MGFX, ftos( SYSTEM_CVAR_DEBUG_MGFX_DEFAULT ), 0 );
	registercvar( SYSTEM_CVAR_DEBUG_STRUCTURE, ftos( SYSTEM_CVAR_DEBUG_STRUCTURE_DEFAULT ), 0 );
	registercvar( SYSTEM_CVAR_DEBUG_PARSER, SYSTEM_CVAR_DEBUG_PARSER_DEFAULT, 0 );
	registercvar( SYSTEM_CVAR_DEBUG_PROCESS_FILTER, SYSTEM_CVAR_DEBUG_PROCESS_FILTER_DEFAULT, 0 );
	registercvar( SYSTEM_CVAR_DEBUG_SOUND, ftos( SYSTEM_CVAR_DEBUG_SOUND_DEFAULT ), 0 );
	registercvar( SYSTEM_CVAR_DEBUG_DUMP_NAMES, "0", 0 );
	registercvar( SYSTEM_CVAR_DEBUG_AREA, ftos( SYSTEM_CVAR_DEBUG_AREA_DEFAULT ), 0 );
	registercvar( SYSTEM_CVAR_DEBUG_STEP, ftos( SYSTEM_CVAR_DEBUG_STEP_DEFAULT ), 0 );
	registercvar( SYSTEM_CVAR_DEBUG_MOUSE, ftos( SYSTEM_CVAR_DEBUG_MOUSE_DEFAULT ), 0 );
};

/*
===================
Sys_Debug_Frame
===================
*/
void() Sys_Debug_Frame =
{
	local float lTemp1, lTemp2, lStep;
	sys_debug = cvar( SYSTEM_CVAR_DEBUG );
	if( sys_debug ) {
		sys_debug_ref = cvar( SYSTEM_CVAR_DEBUG_REF );

		sys_debug_area = cvar( SYSTEM_CVAR_DEBUG_AREA );

		sys_debug_sound = cvar( SYSTEM_CVAR_DEBUG_SOUND );

		sys_debug_structure = cvar( SYSTEM_CVAR_DEBUG_STRUCTURE );

		sys_debug_mouse = cvar( SYSTEM_CVAR_DEBUG_MOUSE );

		lStep = cvar( SYSTEM_CVAR_DEBUG_STEP );
		if( lStep == 1 ) {
			sys_debug_halt = true;
		} else if( lStep == 2 ) {
			sys_debug_halt = false;
			cvar_set( SYSTEM_CVAR_DEBUG_STEP, "1" );

			print( "Menu: -- Step: Time:", ftos( gettime() ), "\n" );
		} else {
			sys_debug_halt = false;
		}

		sys_debug_runflag = cvar( SYSTEM_CVAR_DEBUG_RUNFLAG );
		// FIXME: evil bug in fteqcc!! dont pass function calls to switches
		switch( sys_debug_runflag ) {
		case 0:
			sys_debug_runflag = false;
			break;
		case 1:
			cvar_set( SYSTEM_CVAR_DEBUG_RUNFLAG, "0" );
		case 2:
			sys_debug_runflag = true;
			break;
		}

		sys_debug_process = cvar( SYSTEM_CVAR_DEBUG_PROCESS );
		switch( sys_debug_process ) {
		case 0:
			sys_debug_process = false;
			break;
		case 1:
			cvar_set( SYSTEM_CVAR_DEBUG_PROCESS, "0" );
		case 2:
			sys_debug_process = true;
			break;
		}

		sys_debug_mgfx = cvar( SYSTEM_CVAR_DEBUG_MGFX );
		switch( sys_debug_mgfx ) {
		case 0:
			sys_debug_mgfx = false;
			break;
		case 1:
			cvar_set( SYSTEM_CVAR_DEBUG_MGFX, "0" );
		case 2:
			sys_debug_mgfx = true;
			break;
		}

		lTemp1 = tokenize( cvar_string( SYSTEM_CVAR_DEBUG_PROCESS_FILTER ) );
		sys_debug_process_filter = 0;
		for( lTemp2 = 0 ; lTemp2 < lTemp1 ; ++lTemp2 )
			if( argv( lTemp2 ) == "runflag" )
				sys_debug_process_filter = sys_debug_process_filter | MENU_PROCESS_RUNFLAG;
			else if( argv( lTemp2 ) == "draw" )
				sys_debug_process_filter = sys_debug_process_filter | MENU_PROCESS_DRAW;
			else if( argv( lTemp2 ) == "update" )
				sys_debug_process_filter = sys_debug_process_filter | MENU_PROCESS_UPDATE;
			else if( argv( lTemp2 ) == "mouse" )
				sys_debug_process_filter = sys_debug_process_filter | MENU_PROCESS_MOUSE;
			else if( argv( lTemp2 ) == "key" )
				sys_debug_process_filter = sys_debug_process_filter | MENU_PROCESS_KEY;

		lTemp1 = tokenize( cvar_string( SYSTEM_CVAR_DEBUG_PARSER ) );
		sys_debug_parser = 0;
		for( lTemp2 = 0 ; lTemp2 < lTemp1 ; ++lTemp2 )
			if( argv( lTemp2 ) == "info" )
				sys_debug_parser = sys_debug_parser | PARSER_INFO;
			else if( argv( lTemp2 ) == "high" )
				sys_debug_parser = sys_debug_parser | PARSER_HIGH;
			else if( argv( lTemp2 ) == "low" )
				sys_debug_parser = sys_debug_parser | PARSER_LOW;


	} else {
		sys_debug_halt = false;
		sys_debug_ref = false;
		sys_debug_area = false;
		sys_debug_sound = false;
		sys_debug_runflag = 0;
		sys_debug_process = 0;
		sys_debug_mgfx = false;
		sys_debug_structure = 0;
		sys_debug_parser = 0;
		sys_debug_process_filter = 0;
		sys_debug_mouse = 0;
	}
	if( cvar( SYSTEM_CVAR_DEBUG_DUMP_NAMES ) ) {
		Sys_Debug_DumpNames();
		cvar_set( SYSTEM_CVAR_DEBUG_DUMP_NAMES, "0" );
	}
	sys_debug_cursor_localpos = '-1 -1 -1';
};

/*
===================
Sys_Debug_Draw
===================
*/
void() Sys_Debug_Draw =
{
	if( sys_debug_mouse == 1 )
		Cursor_PrintInfo( '1 0 0', strcat( ftos( floor( sys_debug_cursor_localpos_x ) ),
			" ", ftos( floor( sys_debug_cursor_localpos_y ) ) ), '9 9 0', '0.8 0.8 0.8',
			1, DRAWFLAG_ADDITIVE );
	else if( sys_debug_mouse == 2 )
		Cursor_PrintInfo( '1 0 0', strcat( ftos( floor( Cursor_Position_x ) ), " ",
			ftos( floor( Cursor_Position_y ) ) ), '9 9 0', '0.8 0.8 0.8', 1, DRAWFLAG_ADDITIVE );
};

/*
===================
Sys_Debug_DumpNames
===================
*/
void() Sys_Debug_DumpNames =
{
	local entity lNode;

	print( "Menu: Dumping names..\n" );

	lNode = null_entity;
	while( (lNode = nextent( lNode )) != null_entity )
		print( "Menu: ", etos( lNode ), " <-> ", lNode.name, "\n" );
	print( "\n" );
};
