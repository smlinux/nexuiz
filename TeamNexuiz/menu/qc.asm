entity self;
void end_sys_globals;
void end_sys_fields;
void () m_init;
void (float, float) m_keydown;
void () m_draw;
void () m_display;
void () m_toggle;
void () m_hide;
void () m_shutdown;
float K_TAB;
float K_ENTER;
float K_ESCAPE;
float K_SPACE;
float K_BACKSPACE;
float K_UPARROW;
float K_DOWNARROW;
float K_LEFTARROW;
float K_RIGHTARROW;
float K_ALT;
float K_CTRL;
float K_SHIFT;
float K_F1;
float K_F2;
float K_F3;
float K_F4;
float K_F5;
float K_F6;
float K_F7;
float K_F8;
float K_F9;
float K_F10;
float K_F11;
float K_F12;
float K_INS;
float K_DEL;
float K_PGDN;
float K_PGUP;
float K_HOME;
float K_END;
float K_KP_HOME;
float K_KP_UPARROW;
float K_KP_PGUP;
float K_KP_LEFTARROW;
float K_KP_5;
float K_KP_RIGHTARROW;
float K_KP_END;
float K_KP_DOWNARROW;
float K_KP_PGDN;
float K_KP_ENTER;
float K_KP_INS;
float K_KP_DEL;
float K_KP_SLASH;
float K_KP_MINUS;
float K_KP_PLUS;
float K_PAUSE;
float K_JOY1;
float K_JOY2;
float K_JOY3;
float K_JOY4;
float K_AUX1;
float K_AUX2;
float K_AUX3;
float K_AUX4;
float K_AUX5;
float K_AUX6;
float K_AUX7;
float K_AUX8;
float K_AUX9;
float K_AUX10;
float K_AUX11;
float K_AUX12;
float K_AUX13;
float K_AUX14;
float K_AUX15;
float K_AUX16;
float K_AUX17;
float K_AUX18;
float K_AUX19;
float K_AUX20;
float K_AUX21;
float K_AUX22;
float K_AUX23;
float K_AUX24;
float K_AUX25;
float K_AUX26;
float K_AUX27;
float K_AUX28;
float K_AUX29;
float K_AUX30;
float K_AUX31;
float K_AUX32;
float K_MOUSE1;
float K_MOUSE2;
float K_MOUSE3;
float K_MOUSE4;
float K_MOUSE5;
float K_MOUSE6;
float K_MOUSE7;
float K_MOUSE8;
float K_MOUSE9;
float K_MOUSE10;
float K_MWHEELDOWN;
float K_MWHEELUP;
float KEY_GAME;
float KEY_MENU;
float KEY_UNKNOWN;
float FILE_READ;
float FILE_APPEND;
float FILE_WRITE;
float TRUE;
float FALSE;
float true;
float false;
float MSG_BROADCAST;
float MSG_ONE;
float MSG_ALL;
float MSG_INIT;
float MT_MENU;
float MT_CLIENT;
float CS_DEDICATED;
float CS_DISCONNECTED;
float CS_CONNECTED;
float DRAWFLAG_NORMAL;
float DRAWFLAG_ADDITIVE;
float DRAWFLAG_MODULATE;
float DRAWFLAG_2XMODULATE;
float CVAR_SAVE;
float CVAR_NOTIFY;
float CVAR_READONLY;
float SLIST_HOSTCACHEVIEWCOUNT;
float SLIST_HOSTCACHETOTALCOUNT;
float SLIST_MASTERQUERYCOUNT;
float SLIST_MASTERREPLYCOUNT;
float SLIST_SERVERQUERYCOUNT;
float SLIST_SERVERREPLYCOUNT;
float SLIST_SORTFIELD;
float SLIST_SORTDESCENDING;
float SLIST_LEGACY_LINE1;
float SLIST_LEGACY_LINE2;
float SLIST_TEST_CONTAINS;
float SLIST_TEST_NOTCONTAIN;
float SLIST_TEST_LESSEQUAL;
float SLIST_TEST_LESS;
float SLIST_TEST_EQUAL;
float SLIST_TEST_GREATER;
float SLIST_TEST_GREATEREQUAL;
float SLIST_TEST_NOTEQUAL;
float SLIST_MASK_AND;
float SLIST_MASK_OR;
float NET_CURRENTPROTOCOL;
float CINE_PLAY;
float CINE_LOOP;
float CINE_PAUSE;
float CINE_FIRSTFRAME;
float CINE_RESETONWAKEUP;
entity null_entity;
float ERR_CANNOTOPEN;
float ERR_NOTENOUGHFILEHANDLES;
float ERR_INVALIDMODE;
float ERR_BADFILENAME;
float ERR_NULLSTRING;
float ERR_BADDRAWFLAG;
float ERR_BADSCALE;
float ERR_BADSIZE;
float ERR_NOTCACHED;
void (string) checkextension;
void (string) error;
void (string) objerror;
void (string) print;
void (string) bprint;
void (float, string) sprint;
void (string) centerprint;
vector (vector) normalize;
float (vector) vlen;
float (vector) vectoyaw;
vector (vector) vectoangles;
float () random;
void (string) cmd;
float (string) cvar;
string (string) str_cvar;
void (string, string) cvar_set;
void (string) dprint;
string (float) ftos;
float (float) fabs;
string (vector) vtos;
string (entity) etos;
float (string) stof;
entity () spawn;
void (entity) remove;
entity (entity, FIELD TYPE, string) findstring;
entity (entity, FIELD TYPE, float) findfloat;
entity (entity, FIELD TYPE, entity) findentity;
entity (FIELD TYPE, string) findchainstring;
entity (FIELD TYPE, float) findchainfloat;
entity (FIELD TYPE, entity) findchainentity;
string (string) precache_file;
string (string) precache_sound;
void () crash;
void () coredump;
void () stackdump;
void () traceon;
void () traceoff;
void (entity) eprint;
float (float) rint;
float (float) floor;
float (float) ceil;
entity (entity) nextent;
float (float) sin;
float (float) cos;
float (float) sqrt;
vector () randomvec;
float (string, string, float) registercvar;
float (float) min;
float (float) max;
float (float, float, float) bound;
float (float, float) pow;
void (entity, entity) copyentity;
float (string, float) _fopen;
void (float) fclose;
string (float) fgets;
void (float, string) fputs;
float (string) strlen;
string (string) strcat;
string (string, float, float) substring;
vector (string) stov;
string (string) strzone;
void (string) strunzone;
float (string) tokenize;
string (float) argv;
float () isserver;
float () clientcount;
float () clientstate;
void (float, string) clientcommand;
void (string) changelevel;
void (string) localsound;
vector () getmousepos;
float () gettime;
void (string) loadfromdata;
void (string) loadfromfile;
float (float, float) mod;
float (string, float, float) search_begin;
void (float) search_end;
float (float) search_getsize;
string (float, float) search_getfilename;
string (float) chr;
float (entity) etof;
entity (float) ftoe;
float (string) validstring;
float (string) altstr_count;
string (string) altstr_prepare;
string (string, float) altstr_get;
string (string, float, string) altstr_set;
string (string, float, string) altstr_ins;
void (float, float, float) WriteByte;
void (float, float, float) WriteChar;
void (float, float, float) WriteShort;
void (float, float, float) WriteLong;
void (float, float, float) WriteAngle;
void (float, float, float) WriteCoord;
void (string, float, float) WriteString;
void (entity, float, float) WriteEntity;
float (string) iscachedpic;
string (string) precache_pic;
void (string) freepic;
float (vector, float, vector, vector, float, float) drawcharacter;
float (vector, string, vector, vector, float, float) drawstring;
float (vector, string, vector, vector, float, float) drawpic;
float (vector, vector, vector, float, float) drawfill;
void (float, float, float, float) drawsetcliparea;
void () drawresetcliparea;
vector (string) drawgetimagesize;
float (string, string) cin_open;
void (string) cin_close;
void (string, float) cin_setstate;
float (string) cin_getstate;
void (float) setkeydest;
float () getkeydest;
void (float) setmousetarget;
float () getmousetarget;
float (string) isfunction;
void () callfunction;
void (float, entity) writetofile;
vector (float) getresolution;
string (float) keynumtostring;
string (string) findkeysforcommand;
float (float) gethostcachevalue;
string (float, float) gethostcachestring;
void (entity, string) parseentitydata;
float (string) stringtokeynum;
void () resethostcachemasks;
void (float, float, string, float) sethostcachemaskstring;
void (float, float, float, float) sethostcachemasknumber;
void () resorthostcache;
void (float, float) sethostcachesort;
void () refreshhostcache;
float (float, float) gethostcachenumber;
float (string) gethostcacheindexforkey;
void (string) addwantedhostcachekey;
float (string, float) fopen;
float(string filename, float mode) fopen = asm
{
local float handle;
local float temp_0;
	EQ_F		mode,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	filename,	parm0_x;
	STORE_F	mode,	parm1_x;
	CALL2		_fopen;
	RETURN	return_x;
	STORE_F	filename,	parm0_x;
	CALL1		strzone;
	STORE_S	return_x,	filename;
	STORE_F	filename,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	SLIST_SERVERREPLYCOUNT,	parm2_x;
	CALL3		substring;
	NE_S		return_x,	"data/",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	"menu: fopen: all output must go into data/!
",	parm0_x;
	CALL1		print;
	RETURN	ERR_CANNOTOPEN;
	STORE_F	filename,	parm0_x;
	STORE_F	SLIST_SERVERREPLYCOUNT,	parm1_x;
	STORE_F	10000.000000,	parm2_x;
	CALL3		substring;
	STORE_F	return_x,	parm0_x;
	STORE_F	mode,	parm1_x;
	CALL2		_fopen;
	STORE_F	return_x,	handle;
	STORE_F	filename,	parm0_x;
	CALL1		strunzone;
	RETURN	handle;
	DONE;
}

float GAME_ISSERVER;
float GAME_CONNECTED;
float GAME_DEVELOPER;
float INFINITY;
bool Menu_Active;
float gamestatus;
void () Util_NullFunction;
float () Util_TrueFunction;
float () Util_FalseFunction;
string () Util_StringFuntion;
vector () Util_VectorFunction;
entity () Util_EntityFunction;
float (string) Util_GetAltStringCount;
string (string, float) Util_GetAltStringItem;
string (string, float, string) Util_SetAltStringItem;
string (string, float) Util_DelAltStringItem;
string (string, float, string) Util_InsAltStringItem;
string (string) Util_AltStringPrepare;
string (string, string) Util_AltStringPush;
string (string, string) Util_AltStringPushBack;
string (string) Util_GetAltStringTop;
string (string) Util_AltStringPop;
bool (vector, vector, vector) Util_InRect;
vector (vector, vector, vector) Util_GetClipDelta;
vector (vector, vector, vector, vector) Util_ClipRect;
bool (vector, vector, vector, vector) Util_RectInRect;
string (string) Util_ClipStack_Reset;
string (string, vector, vector) Util_ClipStack_Push;
string (string) Util_ClipStack_Pop;
vector (string) Util_ClipStack_GetPosition;
vector (string) Util_ClipStack_GetSize;
string (string) Util_OriginStack_Reset;
string (string, vector) Util_OriginStack_Push;
string (string) Util_OriginStack_Pop;
vector (string) Util_OriginStack_Get;
string () String_Create;
string (string) String_Zone;
string (string) String_Normal;
string (string, string) String_Set;
string (string) String_Free;
string (string, string) String_Append;
string (string, float, float) String_Substring;
void (entity, FIELD TYPE) String_EntityCreate;
void (entity, FIELD TYPE) String_EntityZone;
void (entity, FIELD TYPE, string) String_EntitySet;
void (entity, FIELD TYPE) String_EntityFree;
vector (string, vector) Util_GetEndOfLine;
vector (string, vector, float) Util_GetEndOfWrappedLine;
string () Util_CreateUID;
string (float) Util_GetUIDName;
float (string) Util_GetUIDNum;
string () Property_Create;
string (string) Property_Zone;
string (string) Propery_Free;
float (string) Property_Validate;
float (string, string) Property_Exists;
string (string, string, string) Property_Register;
string (string, string, string) Property_Set;
string (string, string, string) Property_Rename;
string (string, string) Property_Delete;
string (string, string) Property_Get;
string (string, string) Property_GetString;
float (string, string) Property_GetFloat;
vector (string, string) Property_GetVector;
entity (string, string) Property_GetEntity;
float Timer_Time;
float Timer_Delta;
void () Timer_Init;
void () Timer_Update;
void () Timer_Quit;
float GFX_MENU_DEFAULT_WIDTH;
float GFX_MENU_DEFAULT_HEIGHT;
string CVAR_SCMENU_MENU_WIDTH;
string CVAR_SCMENU_MENU_HEIGHT;
float GFX_SHOWFPS_DURATION;
float GFX_SHOWFPS_DEFAULT;
string CVAR_SCMENU_SHOWFPS;
float Gfx_Menu_Width;
float Gfx_Menu_Height;
float Gfx_Real_Width;
float Gfx_Real_Height;
void () Gfx_Init;
void () Gfx_Quit;
void () Gfx_Display;
void () Gfx_Hide;
void () Gfx_Update;
void () Gfx_Draw;
float (string) Gfx_IsCached;
float (string) Gfx_Precache;
void (string) Gfx_Free;
vector (string) Gfx_GetImageSize;
vector (vector) Gfx_ConToMen;
vector (vector) Gfx_MenToCon;
void () Gfx_ResetClipArea;
float (vector, float, vector, vector, float, float) Gfx_DrawCharacter;
float (vector, string, vector, vector, float, float) Gfx_DrawString;
float (vector, string, vector, vector, float, float) Gfx_DrawPic;
float (vector, vector, vector, float, float) Gfx_Fill;
void (float, float, float, float) Gfx_SetClipArea;
float (string) Sound_Precache;
void (string) Sound_Free;
void (string) Sound_Play;
string CURSOR_PATH;
string Cursor_Current;
void () Cursor_Animation;
float Cursor_Relative_x;
float Cursor_Relative_y;
float Cursor_Relative_z;
vector Cursor_Relative;
float Cursor_Position_x;
float Cursor_Position_y;
float Cursor_Position_z;
vector Cursor_Position;
float Cursor_Speed_x;
float Cursor_Speed_y;
float Cursor_Speed_z;
vector Cursor_Speed;
float Cursor_Transparency;
float Cursor_Color_x;
float Cursor_Color_y;
float Cursor_Color_z;
vector Cursor_Color;
float Cursor_Scale;
float Cursor_Flag;
float Cursor_Offset_x;
float Cursor_Offset_y;
float Cursor_Offset_z;
vector Cursor_Offset;
void () Cursor_Init;
void () Cursor_Quit;
void () Cursor_Display;
void () Cursor_Hide;
void () Cursor_Draw;
void () Cursor_Update;
void () Cursor_DefaultAnimation;
void (vector, string, vector, vector, float, float) Cursor_PrintInfo;
void () Key_Init;
void () Key_Quit;
void () Key_Update;
void () Key_Display;
void () Key_Hide;
void (string) Key_Unbind;
string (float) Key_GetName;
float (string) Key_GetNum;
string (string) Key_GetBindList;
void (float, string) Key_LimitBinds;
void (string, string) Key_Bind;
float SLIST_FIELD_CNAME;
float SLIST_FIELD_PING;
float SLIST_FIELD_GAME;
float SLIST_FIELD_MOD;
float SLIST_FIELD_MAP;
float SLIST_FIELD_NAME;
float SLIST_FIELD_MAXPLAYERS;
float SLIST_FIELD_NUMPLAYERS;
float SLIST_FIELD_PROTOCOL;
float HostCache_ViewCount;
float HostCache_TotalCount;
float HostCache_MasterQueryCount;
float HostCache_MasterReplyCount;
float HostCache_ServerQueryCount;
float HostCache_ServerReplyCount;
float HostCache_SortField;
float HostCache_SortDescending;
void () HostCache_Init;
void () HostCache_Update;
void () HostCache_ResortViewSet;
void () HostCache_RefreshHostCache;
float PARSER_TT_ITEM;
float PARSER_TT_TEMPLATE;
float PARSER_TT_DERIVE;
float PARSER_TT_DERIVETEMPLATE;
float PARSER_TT_DEFINE;
float PARSER_TT_UNDEF;
float PARSER_TT_IGNORE;
float PARSER_TT_NAMESPACE;
float PARSER_TT_INCLUDE;
float PARSER_TT_BRACEOPEN;
float PARSER_TT_BRACECLOSE;
float PARSER_TT_BRACKETOPEN;
float PARSER_TT_BRACKETCLOSE;
float PARSER_TT_TOKEN;
float PARSER_TT_SIZE;
string PARSER_TT_TEXT;
float PARSER_NORMAL;
float PARSER_INFO;
float PARSER_HIGH;
float PARSER_LOW;
float Parser_MaxIncludeDepth;
string Parser_FileList;
float Parser_IncludeDepth;
entity Parser_DefineChain;
string Parser_Filename;
float Parser_LineNumber;
float Parser_File;
string Parser_Line;
float Parser_NumTokens;
float Parser_TokenNum;
string Parser_Token;
float Parser_TokenType;
float () Parser_GetToken;
float () Parser_GetTokenType;
void () Parser_ParseDefine;
void () Parser_ProcessDefine;
void () Parser_ParseUndef;
void (float) Parser_Expect;
void (string) Parser_Error;
void (float, string) Parser_Print;
entity (string) Parser_ParseItem;
entity (string) Parser_DeriveItem;
string (string, string) Parser_ParseEntity;
void (string) Parser_ParseDefinition;
void (string) Parser_ParseNamespace;
void () Parser_ParseIgnore;
void (entity, entity) Parser_CloneChildren;
void (string) Parser_IncludeFile;
void (string, string) Parser_ParseFile;
void (string) Parser_ParseMenu;
void () Parser_Init;
void () Parser_Quit;
string SYSTEM_CVAR_VERSION_BUILDDATE;
string SYSTEM_CVAR_VERSION_BUILDTIME;
string SYSTEM_CVAR_VERSION;
string SYSTEM_CVAR_VERSION_BUILDDATE_VALUE;
string SYSTEM_CVAR_VERSION_BUILDTIME_VALUE;
string SYSTEM_CVAR_VERSION_VALUE;
string SYSTEM_CVAR_DEBUG;
string SYSTEM_CVAR_DEBUG_REF;
string SYSTEM_CVAR_DEBUG_SOUND;
string SYSTEM_CVAR_DEBUG_AREA;
string SYSTEM_CVAR_DEBUG_STEP;
string SYSTEM_CVAR_DEBUG_MOUSE;
string SYSTEM_CVAR_DEBUG_STRUCTURE;
string SYSTEM_CVAR_DEBUG_RUNFLAG;
string SYSTEM_CVAR_DEBUG_PROCESS;
string SYSTEM_CVAR_DEBUG_MGFX;
string SYSTEM_CVAR_DEBUG_PARSER;
string SYSTEM_CVAR_DEBUG_PROCESS_FILTER;
string SYSTEM_CVAR_DEBUG_DUMP_NAMES;
float SYSTEM_CVAR_DEBUG_DEFAULT;
float SYSTEM_CVAR_DEBUG_REF_DEFAULT;
float SYSTEM_CVAR_DEBUG_RUNFLAG_DEFAULT;
float SYSTEM_CVAR_DEBUG_PROCESS_DEFAULT;
float SYSTEM_CVAR_DEBUG_MGFX_DEFAULT;
float SYSTEM_CVAR_DEBUG_STRUCTURE_DEFAULT;
string SYSTEM_CVAR_DEBUG_PARSER_DEFAULT;
string SYSTEM_CVAR_DEBUG_PROCESS_FILTER_DEFAULT;
float SYSTEM_CVAR_DEBUG_SOUND_DEFAULT;
float SYSTEM_CVAR_DEBUG_AREA_DEFAULT;
float SYSTEM_CVAR_DEBUG_STEP_DEFAULT;
float SYSTEM_CVAR_DEBUG_MOUSE_DEFAULT;
bool sys_debug;
bool sys_debug_sound;
bool sys_debug_ref;
bool sys_debug_area;
bool sys_debug_runflag;
bool sys_debug_process;
bool sys_debug_mgfx;
float sys_debug_mouse;
float sys_debug_structure;
float sys_debug_parser;
bool sys_debug_halt;
float sys_debug_process_filter;
float sys_debug_cursor_localpos_x;
float sys_debug_cursor_localpos_y;
float sys_debug_cursor_localpos_z;
vector sys_debug_cursor_localpos;
void () Sys_Debug_Init;
void () Sys_Debug_Frame;
void () Sys_Debug_Draw;
void () Sys_Debug_DumpNames;
string MENU_NORMAL_NAME;
string MENU_INGAME_NAME;
string MENU_NORMAL_DEFAULT;
string MENU_INGAME_DEFAULT;
string MENU_MAINFILE;
bool MENU_ALLOWINGAME;
void () Menu_Init;
void () Menu_Load;
void () Menu_PerformReinit;
void () Menu_Hide;
void () Menu_Shutdown;
void (entity) Menu_LinkItem;
void (entity) Menu_LinkWindow;
entity (string, string, string) Menu_CreateItem;
entity (entity, string, string, bool) Menu_DeriveItem;
void (entity, string) Menu_AddEntityData;
void (entity) Menu_LinkChildren;
void () Menu_LinkWindows;
float Menu_Clip_Position_x;
float Menu_Clip_Position_y;
float Menu_Clip_Position_z;
vector Menu_Clip_Position;
float Menu_Clip_Size_x;
float Menu_Clip_Size_y;
float Menu_Clip_Size_z;
vector Menu_Clip_Size;
float Menu_Origin_x;
float Menu_Origin_y;
float Menu_Origin_z;
vector Menu_Origin;
vector (vector) Menu_OrgToMen;
vector (vector) Menu_MenToOrg;
vector (vector) Menu_ConToOrg;
vector (vector) Menu_OrgToCon;
float (vector, float, vector, vector, float, float) Menu_DrawCharacter;
float (vector, string, vector, vector, float, float) Menu_DrawString;
float (vector, string, vector, vector, float, float) Menu_DrawPicture;
float (vector, vector, vector, float, float) Menu_Fill;
void (float, float, float, float) Menu_SetClipArea;
void () Menu_ResetClipArea;
bool _menu_process_filtered;
float RUNFLAG_TEMPLATE;
float RUNFLAG_HADMOUSE;
float RUNFLAG_MOUSEINAREA;
float RUNFLAG_CHILDDRAWONLY;
float RUNFLAG_CHILDDRAWUPDATEONLY;
float RUNFLAG_HIDDEN;
float RUNFLAG_CLIPPED;
float RUNFLAG_NOSELECT;
float RUNFLAG_USERSELECT;
float RUNFLAG_DELETEFRAME;
float RUNFLAG_DELETETOGGLE;
float RUNFLAG_SPAWNED;
.entity chain;
.string type;
.entity _parent;
.string parent;
.string name;
.entity _next;
.entity _prev;
.entity _child;
.float orderPos;
.float flag;
.float _runFlag;
.float pos_x;
.float pos_y;
.float pos_z;
.vector pos;
.float size_x;
.float size_y;
.float size_z;
.vector size;
.float origin_x;
.float origin_y;
.float origin_z;
.vector origin;
.float _cache_origin_x;
.float _cache_origin_y;
.float _cache_origin_z;
.vector _cache_origin;
.float _cache_clip_pos_x;
.float _cache_clip_pos_y;
.float _cache_clip_pos_z;
.vector _cache_clip_pos;
.float _cache_clip_size_x;
.float _cache_clip_size_y;
.float _cache_clip_size_z;
.vector _cache_clip_size;
.void () init;
.void () reinit;
.void () destroy;
.void () mouseEnter;
.void () mouseLeave;
.void () update;
.void (bool, bool) select;
.void () action;
.void () draw;
.bool (float, float) key;
.void () _reinit;
.void () _destroy;
.void () _mouseEnter;
.void () _mouseLeave;
.void () _update;
.void (bool, bool) _select;
.void () _draw;
.bool (float, float) _key;
void () DefCt_Reinit;
void () DefCt_Destroy;
float (float, float) DefCt_Key;
void () DefCt_Draw;
void () DefCt_MouseEnter;
void () DefCt_MouseLeave;
void () DefCt_Update;
void (float, float) DefCt_Select;
void (entity) Raise_Reinit;
void (entity) Raise_Destroy;
bool (entity, float, float) Raise_Key;
void (entity) Raise_Draw;
void (entity) Raise_MouseEnter;
void (entity) Raise_MouseLeave;
void (entity) Raise_Update;
void (entity, float, float) Raise_Select;
void () CtCall_Init;
void () CtCall_Reinit;
void () CtCall_Destroy;
float (float, float) CtCall_Key;
void () CtCall_Draw;
void () CtCall_MouseEnter;
void () CtCall_MouseLeave;
void () CtCall_Action;
void () CtCall_Update;
void (float, float) CtCall_Select;
entity Menu_ActiveWindow;
entity Menu_ActiveItem;
entity (entity) _Menu_GetParent;
entity (entity) _Menu_GetFirst;
entity (entity) _Menu_GetLast;
entity (entity) _Menu_GetNext;
entity (entity) _Menu_GetPrev;
bool (entity, entity) _Menu_IsEmbeddedParentOf;
void () _Menu_SelectNext;
void () _Menu_SelectPrev;
float () _Menu_SelectUp;
float () _Menu_SelectDown;
void () _Menu_Reselect;
void (float) Menu_SelectNext;
void (float) Menu_SelectPrev;
float (float) Menu_SelectUp;
float (float) Menu_SelectDown;
void (float) Menu_Reselect;
void (entity, bool) Menu_CorrectSelection;
void (entity, bool) Menu_Select;
void (entity, float, float) Menu_JumpToWindow;
float (entity) Menu_HasEvents;
void (entity) Menu_SetRunFlag;
void (entity, entity) Menu_InheritRunFlag;
void () Menu_UpdateRunFlags;
void (entity) Menu_EmptyWindow;
void (entity) Menu_RemoveItem;
entity (entity, string, bool) Menu_GetItemEx;
entity (entity, string, bool) Menu_GetChildEx;
entity (string) Menu_GetItem;
entity (string) Menu_GetChild;
float MENU_SELECT_SELECTABLE;
float MENU_SELECT_ALWAYS;
float MENU_SELECT_NEVER;
float MENU_EVENT_NORMAL;
float MENU_EVENT_CONTINUE;
float MENU_EVENT_RAISEPARENT;
float MENU_EVENT_PROCESSED;
float MENU_PROCESS_RUNFLAG;
float MENU_PROCESS_UPDATE;
float MENU_PROCESS_DRAW;
float MENU_PROCESS_MOUSE;
float MENU_PROCESS_KEY;
float Menu_Cursor_Position_x;
float Menu_Cursor_Position_y;
float Menu_Cursor_Position_z;
vector Menu_Cursor_Position;
entity Menu_KeyHook_Target;
void (float, float) Menu_KeyHook;
void () Menu_Frame;
void () Menu_Draw;
void (float, float) Menu_Key;
float () Menu_Toggle;
void () Menu_Process_Setup;
float (entity, float, float, float, float) Menu_Process;
entity Menu_History;
void (entity, Menu_History_PopFunction) Menu_History_Push;
void () Menu_History_Pop;
float (entity) Menu_History_Verify;
void () Menu_History_Clear;
float Menu_GarbageFrameCount;
float Menu_GarbageToggleCount;
void () Menu_InitGarbageStats;
void () Menu_ResetGarbageStats;
float (entity) Menu_CheckForGarbage;
void (float) Menu_CollectGarbage;
void (entity) Menu_DeleteAfterFrame;
void (entity) Menu_DeleteAfterToggle;
float ITEM_ALIGN_LEFT;
float ITEM_ALIGN_CENTER;
float ITEM_ALIGN_RIGHT;
float ITEM_ALIGN_FIX_RIGHT;
float ITEM_ALIGN_FIX_CENTER;
float ITEM_ALIGN_FIX_LEFT;
float ITEM_ALIGN_FIRST;
float FLAG_TEMPLATE;
float FLAG_EMBEDDED;
float FLAG_HIDDEN;
float FLAG_NOSELECT;
float FLAG_CONNECTEDONLY;
float FLAG_SERVERONLY;
float FLAG_DEVELOPERONLY;
float FLAG_DRAWONLY;
float FLAG_CHILDDRAWONLY;
float FLAG_DRAWUPDATEONLY;
float FLAG_CHILDDRAWUPDATEONLY;
float FLAG_SEALOFFMOUSE;
.entity _link;
void () Item_Link_Init;
void () Item_Link_Destroy;
void () Item_Link_Update;
float (float, float) Item_Link_Key;
void () Item_Link_MouseEnter;
float () Item_Link_IsSelected;
.string link;
.string normal;
void () Item_Cinematic_Destroy;
void () Item_Cinematic_Init;
void () Item_Cinematic_Loop_Spawn;
void () Item_Container_Spawn;
.string value;
string ITEM_SOUND_NOSELECT;
float ITEM_BUTTON_ACTIONTIME;
float ITEM_EDITBOX_CURSOR_FREQ;
float ITEM_EDITBOX_FLASHTIME;
float ITEM_EDITBOX_SCROLLDISTANCE;
float ITEM_DATA_SYNC;
float ITEM_DATA_SEND;
float ITEM_DATA_RESET;
float ITEM_DATA_TEST_START;
float ITEM_DATA_TEST_END;
float ITEM_DATA_SAVE_EXECSTRING;
float ITEM_DATALINK_SET;
float ITEM_DATALINK_GET;
void (entity, bool) Raise_DataEvent;
string Data_ExecString;
void () Data_ExecString_BeginUse;
void () Data_ExecString_EndUse;
.string defValue;
.string _syncValue;
.void (float) _dataEvent;
void () Item_Data_Init;
void () Item_Data_Destroy;
.string target;
.entity _target;
void () Item_DataUser_Update;
void () Item_DataUser_Init;
void () Item_DataUser_Destroy;
void () Item_DataLink_Init;
void () Item_DataLink_Destroy;
void () Item_DataLink_Update;
void (float) Item_DataContainer_DataEvent;
void () Item_DataContainer_Spawn;
void () Item_Data_Container_Reinit;
void (float) Item_Data_Container_DataEvent;
void () Item_Data_Container_Spawn;
.string cvarName;
void (float) Item_Data_Cvar_DataEvent;
void () Item_Data_Cvar_Spawn;
void () Item_Data_CvarCreateSave_Spawn;
.float maxValue;
.float minValue;
.float stepValue;
.float _realValue;
void () Item_DataLink_Value_Clamp;
void () Item_DataLink_Value_Spawn;
.string descList;
void () Item_DataLink_Switch_Init;
void () Item_DataLink_Switch_Destroy;
float (entity, float) DataLink_Switch_GetOrdinal;
void () Item_DataLink_ValueSwitch_Spawn;
.string valueList;
void (float) Item_DataLink_TextSwitch_DataEvent;
void () Item_DataLink_TextSwitch_Destroy;
void () Item_DataLink_TextSwitch_Spawn;
.float _presstime;
void () Item_DataLink_FastResync_Spawn;
void () Item_DataLink_TextValue_Spawn;
void () Item_DataLink_TextTime_Spawn;
void () Item_DataLink_AltString_Spawn;
void () Item_DataLink_Router_Spawn;
float (float, float) Item_Window_Key;
void () Item_Window_Draw;
void () Item_Window_Spawn;
void () Item_Frame_Spawn;
void () Item_EventWindow_Spawn;
void () Item_Reference_Update;
void () Item_Reference_Draw;
void () Item_Reference_Destroy;
void () Item_Reference_Spawn;
.float direction_x;
.float direction_y;
.float direction_z;
.vector direction;
.float alignment;
void () Item_Layout_Spawn;
void () Item_Layout_Update;
void () Item_Arrangement_CalculateSize;
void () Item_Arrangement_Update;
void () Item_Arrangement_Spawn;
void () Item_ScrollWindow_Update;
void () Item_ScrollWindow_Spawn;
float ITEM_STATE_NORMAL;
float ITEM_STATE_SELECTED;
float ITEM_STATE_PRESSED;
.string picture;
.float color_x;
.float color_y;
.float color_z;
.vector color;
.float alpha;
.float drawFlag;
void () Item_Picture_Draw;
void () Item_Picture_Destroy;
void () Item_Picture_Spawn;
void () Item_Rect_Draw;
void () Item_Rect_Spawn;
.string text;
.float fontSize_x;
.float fontSize_y;
.float fontSize_z;
.vector fontSize;
void () Item_Label_Draw;
void () Item_Label_Update;
void () Item_Label_Destroy;
void () Item_Label_Spawn;
.float wrap;
void () Item_MultiLabel_Update;
void () Item_MultiLabel_Draw;
void () Item_MultiLabel_Destroy;
void () Item_MultiLabel_Spawn;
.string selected;
.string pressed;
.float colorSelected_x;
.float colorSelected_y;
.float colorSelected_z;
.vector colorSelected;
.float colorPressed_x;
.float colorPressed_y;
.float colorPressed_z;
.vector colorPressed;
.float drawFlags_x;
.float drawFlags_y;
.float drawFlags_z;
.vector drawFlags;
.float alphas_x;
.float alphas_y;
.float alphas_z;
.vector alphas;
.string soundSelected;
.string soundPressed;
.float _state;
void () Item_Button_Draw;
void () Item_Button_Update;
void (float, float) Item_Button_Select;
float (float, float) Item_Button_Key;
void () Item_Button_Destroy;
void () Item_Button_Spawn;
.float proportions_x;
.float proportions_y;
.float proportions_z;
.vector proportions;
.string pictureSlider;
.string soundIncrease;
.string soundDecrease;
.float sizeSlider_x;
.float sizeSlider_y;
.float sizeSlider_z;
.vector sizeSlider;
void (float, float) Item_Slider_Select;
void () Item_Slider_Draw;
float (float, float) Item_Slider_Key;
void () Item_Slider_Destroy;
void () Item_Slider_Spawn;
.float colorCursor_x;
.float colorCursor_y;
.float colorCursor_z;
.vector colorCursor;
.float colorCursorFlash_x;
.float colorCursorFlash_y;
.float colorCursorFlash_z;
.vector colorCursorFlash;
.float sizeCursor_x;
.float sizeCursor_y;
.float sizeCursor_z;
.vector sizeCursor;
.float sizeCursorFlash_x;
.float sizeCursorFlash_y;
.float sizeCursorFlash_z;
.vector sizeCursorFlash;
.float alphasCursor_x;
.float alphasCursor_y;
.float alphasCursor_z;
.vector alphasCursor;
.float drawFlagsCursor_x;
.float drawFlagsCursor_y;
.float drawFlagsCursor_z;
.vector drawFlagsCursor;
.string soundKey;
.string soundMove;
.float _cursorPos;
void () Item_EditBox_Draw;
void () Item_EditBox_Update;
float (float, float) Item_EditBox_Key;
void (float, float) Item_EditBox_Select;
void () Item_EditBox_Destroy;
void () Item_EditBox_Reinit;
void () Item_EditBox_Spawn;
void () Item_ValueButton_Update;
void () Item_ValueButton_Destroy;
void () Item_ValueButton_Spawn;
float (float, float) Item_SwitchButton_Key;
void () Item_SwitchButton_Spawn;
.float colorInactive_x;
.float colorInactive_y;
.float colorInactive_z;
.vector colorInactive;
.float drawFlagInactive;
.float alphaInactive;
void () Item_List_Draw;
void () Item_List_Update;
void (float, float) Item_List_Select;
float (float, float) Item_List_Key;
void () Item_List_Destroy;
void () Item_List_Spawn;
float (float, float) Item_FloatingArea_Key;
void () Item_FloatingArea_Update;
void () Item_FloatingArea_Spawn;
void () Item_VScrollBar_Draw;
float (float, float) Item_VScrollBar_Key;
void () Item_VScrollBar_Update;
void () Item_VScrollBar_Spawn;
void () Item_Automation_Init;
.entity _current;
void () Item_Automation_ForEach_Spawn;
void () Item_Task_Init;
void () Item_Automation_Job_Spawn;
void () Item_Task_Job_Spawn;
void (entity) Nex_MakeOnlyVisible;
void () Item_Nex_Avatar_Info_Destroy;
void () Item_Nex_Avatar_Info_Spawn;
void (float) Item_Data_Nex_Avatar_DataEvent;
void () Item_Data_Nex_Avatar_Spawn;
void (float) Item_Data_Nex_Name_DataEvent;
void () Item_Data_Nex_Name_Spawn;
void (float) Item_Data_Nex_Color_DataEvent;
void () Item_Data_Nex_Color_Spawn;
void () Item_Nex_Map_Info_Destroy;
void () Item_Nex_Map_Info_Spawn;
void () Item_Nex_MapDB_EnumFiles;
void () Item_Nex_MapDB_Destroy;
void () Item_Nex_MapDB_Spawn;
entity (string) Nex_MapDB_GetByPath;
entity (float) Nex_MapDB_GetByIndex;
float (entity) Nex_MapDB_GetIndex;
string () Nex_MapDB_GetPathAltString;
string () Nex_MapDB_GetNameAltString;
void (float) Item_DataLink_Nex_MapList_DataEvent;
void () Item_DataLink_Nex_MapList_Spawn;
void () Item_DataLink_Nex_MapList_InitWithMapList;
void (entity) DataLink_Nex_MapList_UpdateRange;
void (entity, string, string) DataLink_Nex_MapList_InsertEntryAfter;
void (entity) DataLink_Nex_MapList_DeleteEntry;
void (entity) DataLink_Nex_MapList_MoveEntryUp;
void (entity) DataLink_Nex_MapList_MoveEntryDown;
void (entity, string, string) DataLink_Nex_MapList_SetFirst;
void (entity) DataLink_Nex_MapList_Clear;
string (entity) DataLink_Nex_MapList_GetCurrentName;
string (entity) DataLink_Nex_MapList_GetCurrentPath;
void () Item_DataLink_Nex_ModSwitch_Spawn;
void (float) Item_DataLink_Nex_FileList_DataEvent;
void () Item_DataLink_Nex_FileList_Destroy;
void () Item_DataLink_Nex_FileList_Spawn;
void () Item_Nex_HostCache_Entry_Update;
void () Item_Nex_HostCache_Entry_Spawn;
void () Item_Nex_HostCache_StringField_Update;
void () Item_Nex_HostCache_StringField_Spawn;
void () Item_Nex_HostCache_ValueField_Update;
void () Item_Nex_HostCache_ValueField_Spawn;
void () Item_Nex_HostCache_Players_Update;
void () Item_Nex_HostCache_Players_Spawn;
void (float) Item_Data_Nex_Key_DataEvent;
void () Item_Data_Nex_Key_Spawn;
void () Item_Nex_KeyButton_Spawn;
void () Item_Data_Nex_Resolution_Spawn;
void () Item_Nex_Credits_Spawn;
void (string, string, string, string, event, event) Nex_MessageBox;
void () Nex_Quit_Toggle;
void() Nex_Quit_Toggle = asm
{
local entity lEntity;
local float temp_0;
local float temp_1;
	STORE_F	"QuitWnd",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lEntity;
	INDIRECT_F	lEntity,	flag,	temp_1;
	BITAND	temp_1,	FLAG_HIDDEN,	temp_1;
	IFNOT		temp_1,	11;
	ADDRESS	lEntity,	flag,	temp_1;
	INDIRECT_F	lEntity,	flag,	temp_0;
	SUB_F		temp_0,	FLAG_HIDDEN,	temp_0;
	STOREP_F	temp_0,	temp_1;
	STORE_F	"QuitWnd::Layout::Buttons::No",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		Menu_Select;
	GOTO		7;
	ADDRESS	lEntity,	flag,	temp_0;
	INDIRECT_F	lEntity,	flag,	temp_1;
	ADD_F		temp_1,	FLAG_HIDDEN,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		Menu_Reselect;
	DONE;
}

void () Nex_Quit_Action;
void() Nex_Quit_Action = asm
{
local entity lEntity;
local float temp_0;
local float temp_1;
	STORE_F	"QuitWnd",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lEntity;
	INDIRECT_F	lEntity,	flag,	temp_0;
	BITAND	temp_0,	FLAG_HIDDEN,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	lEntity,	flag,	temp_0;
	INDIRECT_F	lEntity,	flag,	temp_1;
	SUB_F		temp_1,	FLAG_HIDDEN,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	"QuitWnd::Layout::Buttons::No",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		Menu_Select;
	DONE;
}

float (float, float) Nex_Quit_Key;
float(float pKey, float pAscii) Nex_Quit_Key = asm
{
local float temp_0;
	EQ_F		pKey,	K_ESCAPE,	temp_0;
	IFNOT		temp_0,	3;
	CALL0		Nex_Quit_Toggle;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void () Nex_Quit_Yes;
void() Nex_Quit_Yes = asm
{
	STORE_F	"quit
",	parm0_x;
	CALL1		cmd;
	DONE;
}

void () Nex_Quit_No;
void() Nex_Quit_No = asm
{
	CALL0		Nex_Quit_Toggle;
	DONE;
}

void () Nex_Action_ResetData_Destroy;
void() Nex_Action_ResetData_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void () Nex_Action_ResetData_Action;
void() Nex_Action_ResetData_Action = asm
{
local float temp_0;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	STORE_F	ITEM_DATA_RESET,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Nex_Action_ResetData;
void() Nex_Action_ResetData = asm
{
local float temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityZone;
	ADDRESS	self,	destroy,	temp_0;
	STOREP_FNC	Nex_Action_ResetData_Destroy,	temp_0;
	ADDRESS	self,	action,	temp_0;
	STOREP_FNC	Nex_Action_ResetData_Action,	temp_0;
	DONE;
}

void () Nex_Automation_Option_Slider;
void() Nex_Automation_Option_Slider = asm
{
local entity lValue;
local entity lSlider;
local entity lDescription;
local float temp_0;
local float temp_1;
	INDIRECT_E	self,	_parent,	temp_0;
	INDIRECT_S	temp_0,	target,	temp_0;
	NOT_S		temp_0,	temp_0;
	IFNOT		temp_0,	8;
	INDIRECT_E	self,	_parent,	temp_0;
	INDIRECT_S	temp_0,	target,	temp_0;
	STORE_F	"Bad target '",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"'",	parm2_x;
	CALL3		objerror;
	RETURN	offset_0;
	STORE_F	"Description",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lDescription;
	STORE_F	"Slider",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lSlider;
	STORE_F	"Value",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lValue;
	ADDRESS	lDescription,	normal,	temp_0;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_S	temp_1,	text,	temp_1;
	STOREP_S	temp_1,	temp_0;
	ADDRESS	lDescription,	link,	temp_0;
	INDIRECT_S	lSlider,	name,	temp_1;
	STOREP_S	temp_1,	temp_0;
	ADDRESS	lSlider,	target,	temp_0;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_S	temp_1,	target,	temp_1;
	STOREP_S	temp_1,	temp_0;
	ADDRESS	lValue,	target,	temp_0;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_S	temp_1,	target,	temp_1;
	STOREP_S	temp_1,	temp_0;
	ADDRESS	lValue,	link,	temp_0;
	INDIRECT_S	lSlider,	name,	temp_1;
	STOREP_S	temp_1,	temp_0;
	DONE;
}

void () Nex_Automation_Option_EditBox;
void() Nex_Automation_Option_EditBox = asm
{
local entity lEditBox;
local entity lDescription;
local float temp_0;
local float temp_1;
	INDIRECT_E	self,	_parent,	temp_0;
	INDIRECT_S	temp_0,	target,	temp_0;
	NOT_S		temp_0,	temp_0;
	IFNOT		temp_0,	8;
	INDIRECT_E	self,	_parent,	temp_0;
	INDIRECT_S	temp_0,	target,	temp_0;
	STORE_F	"Bad target '",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"'",	parm2_x;
	CALL3		objerror;
	RETURN	offset_0;
	STORE_F	"Description",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lDescription;
	STORE_F	"EditBox",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lEditBox;
	ADDRESS	lDescription,	normal,	temp_0;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_S	temp_1,	text,	temp_1;
	STOREP_S	temp_1,	temp_0;
	ADDRESS	lDescription,	link,	temp_0;
	INDIRECT_S	lEditBox,	name,	temp_1;
	STOREP_S	temp_1,	temp_0;
	ADDRESS	lEditBox,	target,	temp_0;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_S	temp_1,	target,	temp_1;
	STOREP_S	temp_1,	temp_0;
	DONE;
}

void () Nex_Automation_Option_Switch;
void() Nex_Automation_Option_Switch = asm
{
local entity lSwitch;
local entity lDescription;
local float temp_0;
local float temp_1;
	INDIRECT_E	self,	_parent,	temp_0;
	INDIRECT_S	temp_0,	target,	temp_0;
	NOT_S		temp_0,	temp_0;
	IFNOT		temp_0,	8;
	INDIRECT_E	self,	_parent,	temp_0;
	INDIRECT_S	temp_0,	target,	temp_0;
	STORE_F	"Bad target '",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"'",	parm2_x;
	CALL3		objerror;
	RETURN	offset_0;
	STORE_F	"Description",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lDescription;
	STORE_F	"Switch",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lSwitch;
	ADDRESS	lDescription,	normal,	temp_0;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_S	temp_1,	text,	temp_1;
	STOREP_S	temp_1,	temp_0;
	ADDRESS	lDescription,	link,	temp_0;
	INDIRECT_S	lSwitch,	name,	temp_1;
	STOREP_S	temp_1,	temp_0;
	ADDRESS	lSwitch,	target,	temp_0;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_S	temp_1,	target,	temp_1;
	STOREP_S	temp_1,	temp_0;
	DONE;
}

float (float, float) Nex_Global_Key;
float(float pKey, float pAscii) Nex_Global_Key = asm
{
local float temp_0;
	GOTO		17;
	STORE_F	FILE_APPEND,	parm0_x;
	CALL1		Menu_SelectPrev;
	GOTO		37;
	STORE_F	FILE_APPEND,	parm0_x;
	CALL1		Menu_SelectNext;
	GOTO		34;
	STORE_F	FILE_APPEND,	parm0_x;
	CALL1		Menu_SelectUp;
	GOTO		31;
	STORE_F	FILE_APPEND,	parm0_x;
	CALL1		Menu_SelectDown;
	IF		return_x,	3;
	STORE_F	ITEM_SOUND_NOSELECT,	parm0_x;
	CALL1		Sound_Play;
	GOTO		25;
	GOTO		24;
	EQ_F		pKey,	K_UPARROW,	temp_0;
	IF		temp_0,	-17;
	EQ_F		pKey,	K_KP_UPARROW,	temp_0;
	IF		temp_0,	-19;
	EQ_F		pKey,	K_LEFTARROW,	temp_0;
	IF		temp_0,	-21;
	EQ_F		pKey,	K_KP_LEFTARROW,	temp_0;
	IF		temp_0,	-23;
	EQ_F		pKey,	K_DOWNARROW,	temp_0;
	IF		temp_0,	-22;
	EQ_F		pKey,	K_KP_DOWNARROW,	temp_0;
	IF		temp_0,	-24;
	EQ_F		pKey,	K_RIGHTARROW,	temp_0;
	IF		temp_0,	-26;
	EQ_F		pKey,	K_KP_RIGHTARROW,	temp_0;
	IF		temp_0,	-28;
	EQ_F		pKey,	K_ESCAPE,	temp_0;
	IF		temp_0,	-27;
	EQ_F		pKey,	K_MOUSE2,	temp_0;
	IF		temp_0,	-29;
	EQ_F		pKey,	K_ENTER,	temp_0;
	IF		temp_0,	-28;
	GOTO		-23;
	RETURN	FILE_APPEND;
	DONE;
}

void () Item_Nex_StressRepeat_Spawn;
void() Item_Nex_StressRepeat_Spawn = asm
{
local float locked_1020;
local float lCounter;
local entity lItem;
local float temp_1;
	ADDRESS	self,	flag,	locked_1020;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_EMBEDDED,	temp_1;
	STOREP_F	temp_1,	locked_1020;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	100.000000,	locked_1020;
	IFNOT		locked_1020,	14;
	INDIRECT_E	self,	_child,	locked_1020;
	STORE_F	lCounter,	parm0_x;
	CALL1		ftos;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_S	temp_1,	name,	temp_1;
	STORE_F	locked_1020,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	temp_1,	parm2_x;
	STORE_F	FILE_APPEND,	parm3_x;
	CALL4		Menu_DeriveItem;
	STORE_ENT	return_x,	lItem;
	ADD_F		lCounter,	FILE_APPEND,	lCounter;
	GOTO		-14;
	DONE;
}

void () Nex_Action_MakeOnlyVisible_Destroy;
void() Nex_Action_MakeOnlyVisible_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void () Nex_Action_MakeOnlyVisible_Action;
void() Nex_Action_MakeOnlyVisible_Action = asm
{
local float temp_0;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	CALL1		Nex_MakeOnlyVisible;
	DONE;
}

void () Nex_Action_MakeOnlyVisible;
void() Nex_Action_MakeOnlyVisible = asm
{
local float temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityZone;
	ADDRESS	self,	destroy,	temp_0;
	STOREP_FNC	Nex_Action_MakeOnlyVisible_Destroy,	temp_0;
	ADDRESS	self,	action,	temp_0;
	STOREP_FNC	Nex_Action_MakeOnlyVisible_Action,	temp_0;
	DONE;
}

void () Nex_Action_MakeFirstVisible;
void() Nex_Action_MakeFirstVisible = asm
{
local float temp_0;
	INDIRECT_E	self,	_child,	parm0_x;
	CALL1		Nex_MakeOnlyVisible;
	DONE;
}

void () Nex_Action_JumpToPage_Destroy;
void() Nex_Action_JumpToPage_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void () Nex_Action_JumpToPage_Action;
void() Nex_Action_JumpToPage_Action = asm
{
local entity lItem;
local float temp_0;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	lItem,	parm0_x;
	CALL1		Nex_MakeOnlyVisible;
	STORE_F	lItem,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		Menu_JumpToWindow;
	DONE;
}

void () Nex_Action_JumpToPage;
void() Nex_Action_JumpToPage = asm
{
local float temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityZone;
	ADDRESS	self,	action,	temp_0;
	STOREP_FNC	Nex_Action_JumpToPage_Action,	temp_0;
	ADDRESS	self,	destroy,	temp_0;
	STOREP_FNC	Nex_Action_JumpToPage_Destroy,	temp_0;
	DONE;
}

void () Nex_Action_SetNormalPanelLink_Destroy;
void() Nex_Action_SetNormalPanelLink_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void () Nex_Action_SetNormalPanelLink_Action;
void() Nex_Action_SetNormalPanelLink_Action = asm
{
local entity lItem;
local float temp_0;
	STORE_F	"Normal::Panel",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_S	self,	target,	temp_0;
	STORE_F	lItem,	parm0_x;
	STORE_F	link,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	lItem,	parm0_x;
	CALL1		Raise_Update;
	CALL0		Menu_UpdateRunFlags;
	INDIRECT_E	lItem,	_link,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		Menu_JumpToWindow;
	DONE;
}

void () Nex_Action_SetNormalPanelLink;
void() Nex_Action_SetNormalPanelLink = asm
{
local float temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityZone;
	ADDRESS	self,	destroy,	temp_0;
	STOREP_FNC	Nex_Action_SetNormalPanelLink_Destroy,	temp_0;
	ADDRESS	self,	action,	temp_0;
	STOREP_FNC	Nex_Action_SetNormalPanelLink_Action,	temp_0;
	DONE;
}

void () Nex_Action_SetLinkOnReinit_Destroy;
void() Nex_Action_SetLinkOnReinit_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void () Nex_Action_SetLinkOnReinitk_Reinit;
void() Nex_Action_SetLinkOnReinitk_Reinit = asm
{
local float temp_0;
	STORE_F	"Normal::Panel",	parm0_x;
	CALL1		Menu_GetItem;
	INDIRECT_S	self,	target,	temp_0;
	STORE_F	return_x,	parm0_x;
	STORE_F	link,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () Nex_Action_SetLinkOnReinit;
void() Nex_Action_SetLinkOnReinit = asm
{
local float temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityZone;
	ADDRESS	self,	destroy,	temp_0;
	STOREP_FNC	Nex_Action_SetLinkOnReinit_Destroy,	temp_0;
	ADDRESS	self,	reinit,	temp_0;
	STOREP_FNC	Nex_Action_SetLinkOnReinitk_Reinit,	temp_0;
	DONE;
}

void () Nex_Action_Color_Cancel;
void() Nex_Action_Color_Cancel = asm
{
	STORE_F	"::Data::Color",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	STORE_F	ITEM_DATA_TEST_END,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Nex_Action_Color_Reset;
void() Nex_Action_Color_Reset = asm
{
	STORE_F	"::Data::Color",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	STORE_F	ITEM_DATA_RESET,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Nex_Automation_UpdateAvatar_Update;
void() Nex_Automation_UpdateAvatar_Update = asm
{
local float locked_1020;
local entity lTarget;
local entity lItem;
	INDIRECT_E	self,	_target,	locked_1020;
	INDIRECT_S	locked_1020,	name,	locked_1020;
	NE_S		locked_1020,	"Data::Player::Avatar",	locked_1020;
	IFNOT		locked_1020,	5;
	ADDRESS	self,	_target,	locked_1020;
	STORE_F	"Data::Player::Avatar",	parm0_x;
	CALL1		Menu_GetItem;
	STOREP_ENT	return_x,	locked_1020;
	INDIRECT_E	self,	_target,	lTarget;
	STORE_F	"Picture",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_E	lTarget,	_link,	locked_1020;
	INDIRECT_S	locked_1020,	picture,	locked_1020;
	STORE_F	lItem,	parm0_x;
	STORE_F	picture,	parm1_x;
	STORE_F	locked_1020,	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	"Name",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_E	lTarget,	_link,	locked_1020;
	INDIRECT_S	locked_1020,	normal,	locked_1020;
	STORE_F	lItem,	parm0_x;
	STORE_F	text,	parm1_x;
	STORE_F	locked_1020,	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	"Description",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_E	lTarget,	_link,	locked_1020;
	INDIRECT_S	locked_1020,	text,	locked_1020;
	STORE_F	lItem,	parm0_x;
	STORE_F	text,	parm1_x;
	STORE_F	locked_1020,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () Nex_Automation_UpdateAvatar_Destroy;
void() Nex_Automation_UpdateAvatar_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void () Nex_Automation_UpdateAvatar;
void() Nex_Automation_UpdateAvatar = asm
{
local float temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityZone;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Nex_Automation_UpdateAvatar_Update,	temp_0;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Nex_Automation_UpdateAvatar_Destroy,	temp_0;
	DONE;
}

void () Nex_Action_Avatar_Next;
void() Nex_Action_Avatar_Next = asm
{
local entity lItem;
local float temp_0;
local float temp_1;
	STORE_F	"Data::Player::Avatar",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	ADDRESS	lItem,	_realValue,	temp_0;
	INDIRECT_F	lItem,	_realValue,	temp_1;
	ADD_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	lItem,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Nex_Action_Avatar_Prev;
void() Nex_Action_Avatar_Prev = asm
{
local entity lItem;
local float temp_0;
local float temp_1;
	STORE_F	"Data::Player::Avatar",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	ADDRESS	lItem,	_realValue,	temp_0;
	INDIRECT_F	lItem,	_realValue,	temp_1;
	SUB_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	lItem,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Nex_Action_Player_Apply;
void() Nex_Action_Player_Apply = asm
{
local entity lItem;
	STORE_F	"Data::Player",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	lItem,	parm0_x;
	STORE_F	ITEM_DATA_SEND,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Nex_Action_TestOnChange;
void() Nex_Action_TestOnChange = asm
{
local float temp_0;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATA_TEST_START,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void (float, float) Nex_Action_TestOnSelect;
void(float pSelect, float pUser) Nex_Action_TestOnSelect = asm
{
local float temp_0;
	NOT_F		pSelect,	temp_0;
	IFNOT		temp_0,	1;
	AND		temp_0,	pUser,	temp_0;
	IFNOT		temp_0,	4;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATA_TEST_START,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Nex_Action_PlaySound;
string string_null;
void() Nex_Action_PlaySound = asm
{
local float temp_0;
	INDIRECT_S	self,	target,	temp_0;
	NE_S		temp_0,	string_null,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		Sound_Play;
	DONE;
}

void () Nex_Action_PlaySoundOnce;
void() Nex_Action_PlaySoundOnce = asm
{
local float temp_0;
	INDIRECT_S	self,	target,	temp_0;
	NE_S		temp_0,	string_null,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		Sound_Play;
	STORE_F	self,	parm0_x;
	CALL1		Menu_DeleteAfterToggle;
	DONE;
}

void () Nex_MapSelector_UpdateMap;
void() Nex_MapSelector_UpdateMap = asm
{
local float lIndex;
local entity lSelector;
local entity lItem;
local entity lInfo;
local float temp_0;
local float temp_1;
	STORE_F	"::Data::Server::Map::Selector",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lSelector;
	STORE_F	lSelector,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_F	lSelector,	_realValue,	lIndex;
	STORE_F	lIndex,	parm0_x;
	CALL1		Nex_MapDB_GetByIndex;
	STORE_ENT	return_x,	lInfo;
	INDIRECT_F	self,	minValue,	temp_0;
	NE_F		lIndex,	temp_0,	temp_0;
	IFNOT		temp_0,	27;
	ADDRESS	self,	minValue,	temp_0;
	STOREP_F	lIndex,	temp_0;
	STORE_F	"Picture",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_S	lInfo,	picture,	temp_0;
	STORE_F	lItem,	parm0_x;
	STORE_F	picture,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	"Name",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_S	lInfo,	normal,	temp_0;
	STORE_F	lItem,	parm0_x;
	STORE_F	text,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	"Description",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_S	lInfo,	text,	temp_0;
	STORE_F	lItem,	parm0_x;
	STORE_F	text,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	"::Data::Server::Map::Cycle",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_S	lInfo,	normal,	temp_0;
	INDIRECT_S	lInfo,	link,	temp_1;
	STORE_F	lItem,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	temp_1,	parm2_x;
	CALL3		DataLink_Nex_MapList_SetFirst;
	DONE;
}

void () Nex_MapSelector_Synchronize;
void() Nex_MapSelector_Synchronize = asm
{
local float locked_1020;
local entity lMapInfo;
local string lPath;
local entity lSelector;
local entity lCycle;
	STORE_F	"::Data::Server::Map::Cycle",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lCycle;
	STORE_F	"::Data::Server::Map::Selector",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lSelector;
	INDIRECT_F	lCycle,	stepValue,	locked_1020;
	EQ_F		locked_1020,	KEY_GAME,	locked_1020;
	IFNOT		locked_1020,	5;
	STORE_F	lCycle,	parm0_x;
	STORE_F	ITEM_DATA_RESET,	parm1_x;
	CALL2		Raise_DataEvent;
	GOTO		23;
	INDIRECT_S	lCycle,	valueList,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_S	return_x,	lPath;
	STORE_F	lPath,	parm0_x;
	CALL1		Nex_MapDB_GetByPath;
	STORE_ENT	return_x,	lMapInfo;
	STORE_F	lPath,	parm0_x;
	CALL1		String_Free;
	EQ_E		lMapInfo,	null_entity,	locked_1020;
	IFNOT		locked_1020,	5;
	STORE_F	lCycle,	parm0_x;
	STORE_F	ITEM_DATA_RESET,	parm1_x;
	CALL2		Raise_DataEvent;
	GOTO		8;
	ADDRESS	lSelector,	_realValue,	locked_1020;
	STORE_F	lMapInfo,	parm0_x;
	CALL1		Nex_MapDB_GetIndex;
	STOREP_F	return_x,	locked_1020;
	STORE_F	lSelector,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Nex_Action_MapSelector_Next;
void() Nex_Action_MapSelector_Next = asm
{
local entity lItem;
local float temp_0;
local float temp_1;
	STORE_F	"::Data::Server::Map::Selector",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	lItem,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	lItem,	_realValue,	temp_0;
	INDIRECT_F	lItem,	_realValue,	temp_1;
	ADD_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	lItem,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Nex_Action_MapSelector_Prev;
void() Nex_Action_MapSelector_Prev = asm
{
local entity lItem;
local float temp_0;
local float temp_1;
	STORE_F	"::Data::Server::Map::Selector",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	lItem,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	lItem,	_realValue,	temp_0;
	INDIRECT_F	lItem,	_realValue,	temp_1;
	SUB_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	lItem,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Nex_Action_Map_Start;
void() Nex_Action_Map_Start = asm
{
local float lSkill;
local float lNumBots;
local entity lItem;
local float temp_0;
	STORE_F	"::Data::Server::NumBots",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_S	lItem,	value,	parm0_x;
	CALL1		stof;
	STORE_F	return_x,	lNumBots;
	STORE_F	"::Data::Server::BotSkill",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_S	lItem,	value,	parm0_x;
	CALL1		stof;
	STORE_F	return_x,	lSkill;
	STORE_F	"saved1",	parm0_x;
	STORE_F	"1",	parm1_x;
	CALL2		cvar_set;
	STORE_F	KEY_MENU,	parm0_x;
	STORE_F	lNumBots,	parm1_x;
	CALL2		pow;
	SUB_F		return_x,	FILE_APPEND,	parm0_x;
	CALL1		ftos;
	STORE_F	"scratch1",	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		cvar_set;
	STORE_F	lNumBots,	parm0_x;
	STORE_F	8.000000,	parm1_x;
	CALL2		min;
	STORE_F	CVAR_READONLY,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		pow;
	SUB_F		return_x,	FILE_APPEND,	temp_0;
	MUL_F		lSkill,	temp_0,	temp_0;
	DIV_F		temp_0,	KEY_UNKNOWN,	parm0_x;
	CALL1		ftos;
	STORE_F	"scratch2",	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		cvar_set;
	SUB_F		lNumBots,	8.000000,	parm0_x;
	STORE_F	8.000000,	parm1_x;
	CALL2		min;
	STORE_F	CVAR_READONLY,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		pow;
	SUB_F		return_x,	FILE_APPEND,	temp_0;
	MUL_F		lSkill,	temp_0,	temp_0;
	DIV_F		temp_0,	KEY_UNKNOWN,	parm0_x;
	CALL1		ftos;
	STORE_F	"scratch3",	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		cvar_set;
	STORE_F	"::Data::Server::MaxPlayers",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	"maxplayers "",	parm0_x;
	CALL1		cmd;
	INDIRECT_S	lItem,	value,	parm0_x;
	CALL1		cmd;
	STORE_F	""
",	parm0_x;
	CALL1		cmd;
	STORE_F	"::Data::Server::Map::Cycle",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	"map "",	parm0_x;
	CALL1		cmd;
	INDIRECT_S	lItem,	valueList,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	STORE_F	""
",	parm0_x;
	CALL1		cmd;
	STORE_F	lItem,	parm0_x;
	STORE_F	ITEM_DATA_SEND,	parm1_x;
	CALL2		Raise_DataEvent;
	CALL0		m_hide;
	DONE;
}

void () Nex_Action_Cycle_Add;
void() Nex_Action_Cycle_Add = asm
{
local string lName;
local string lPath;
local entity lCycle;
local entity lList;
local float temp_0;
local float temp_1;
	STORE_F	"::Data::Server::Map::List",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lList;
	STORE_F	"::Data::Server::Map::Cycle",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lCycle;
	STORE_F	lList,	parm0_x;
	CALL1		DataLink_Nex_MapList_GetCurrentName;
	STORE_S	return_x,	lName;
	STORE_F	lList,	parm0_x;
	CALL1		DataLink_Nex_MapList_GetCurrentPath;
	STORE_S	return_x,	lPath;
	INDIRECT_F	lCycle,	stepValue,	temp_0;
	EQ_F		temp_0,	FILE_APPEND,	temp_0;
	IFNOT		temp_0,	6;
	STORE_F	lCycle,	parm0_x;
	STORE_F	lName,	parm1_x;
	STORE_F	lPath,	parm2_x;
	CALL3		DataLink_Nex_MapList_InsertEntryAfter;
	GOTO		5;
	STORE_F	lCycle,	parm0_x;
	STORE_F	lName,	parm1_x;
	STORE_F	lPath,	parm2_x;
	CALL3		DataLink_Nex_MapList_SetFirst;
	STORE_F	lName,	parm0_x;
	CALL1		String_Free;
	STORE_F	lPath,	parm0_x;
	CALL1		String_Free;
	ADDRESS	lCycle,	_realValue,	temp_0;
	INDIRECT_F	lCycle,	_realValue,	temp_1;
	ADD_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	lCycle,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	CALL0		Nex_MapSelector_Synchronize;
	DONE;
}

void () Nex_Action_Cycle_Remove;
void() Nex_Action_Cycle_Remove = asm
{
local entity lCycle;
	STORE_F	"::Data::Server::Map::Cycle",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lCycle;
	STORE_F	lCycle,	parm0_x;
	CALL1		DataLink_Nex_MapList_DeleteEntry;
	CALL0		Nex_MapSelector_Synchronize;
	DONE;
}

void () Nex_Action_Cycle_MoveUp;
void() Nex_Action_Cycle_MoveUp = asm
{
local entity lCycle;
local float temp_0;
local float temp_1;
	STORE_F	"::Data::Server::Map::Cycle",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lCycle;
	STORE_F	lCycle,	parm0_x;
	CALL1		DataLink_Nex_MapList_MoveEntryUp;
	ADDRESS	lCycle,	_realValue,	temp_0;
	INDIRECT_F	lCycle,	_realValue,	temp_1;
	SUB_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	lCycle,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	CALL0		Nex_MapSelector_Synchronize;
	DONE;
}

void () Nex_Action_Cycle_MoveDown;
void() Nex_Action_Cycle_MoveDown = asm
{
local entity lCycle;
local float temp_0;
local float temp_1;
	STORE_F	"::Data::Server::Map::Cycle",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lCycle;
	STORE_F	lCycle,	parm0_x;
	CALL1		DataLink_Nex_MapList_MoveEntryDown;
	ADDRESS	lCycle,	_realValue,	temp_0;
	INDIRECT_F	lCycle,	_realValue,	temp_1;
	ADD_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	lCycle,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	CALL0		Nex_MapSelector_Synchronize;
	DONE;
}

void () Nex_Action_Cycle_Clear;
void() Nex_Action_Cycle_Clear = asm
{
local entity lCycle;
	STORE_F	"::Data::Server::Map::Cycle",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lCycle;
	STORE_F	lCycle,	parm0_x;
	CALL1		DataLink_Nex_MapList_Clear;
	CALL0		Nex_MapSelector_Synchronize;
	DONE;
}

entity (float) Nex_Management_GetFileList;
entity(float pType) Nex_Management_GetFileList = asm
{
local float temp_0;
	GOTO		10;
	STORE_F	"::Data::Management::FileList::Weapon",	parm0_x;
	CALL1		Menu_GetItem;
	RETURN	return_x;
	STORE_F	"::Data::Management::FileList::Game",	parm0_x;
	CALL1		Menu_GetItem;
	RETURN	return_x;
	STORE_F	"::Data::Management::FileList::MapList",	parm0_x;
	CALL1		Menu_GetItem;
	RETURN	return_x;
	IFNOT		pType,	-9;
	EQ_F		pType,	FILE_APPEND,	temp_0;
	IF		temp_0,	-8;
	EQ_F		pType,	KEY_MENU,	temp_0;
	IF		temp_0,	-7;
	CALL0		crash;
	RETURN	null_entity;
	DONE;
}

entity (float) Nex_Management_GetContainer;
entity(float pType) Nex_Management_GetContainer = asm
{
local float temp_0;
	GOTO		10;
	STORE_F	"::Data::Weapon",	parm0_x;
	CALL1		Menu_GetItem;
	RETURN	return_x;
	STORE_F	"::Data::Game",	parm0_x;
	CALL1		Menu_GetItem;
	RETURN	return_x;
	STORE_F	"::Data::Server::Map::Cycle",	parm0_x;
	CALL1		Menu_GetItem;
	RETURN	return_x;
	IFNOT		pType,	-9;
	EQ_F		pType,	FILE_APPEND,	temp_0;
	IF		temp_0,	-8;
	EQ_F		pType,	KEY_MENU,	temp_0;
	IF		temp_0,	-7;
	CALL0		crash;
	RETURN	null_entity;
	DONE;
}

float () Nex_Management_GetType;
float() Nex_Management_GetType = asm
{
local entity lTypeData;
local float temp_0;
	STORE_F	"::Data::Management::ConfigType",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lTypeData;
	INDIRECT_S	lTypeData,	value,	parm0_x;
	CALL1		stof;
	RETURN	return_x;
	DONE;
}

void (float) Nex_Management_SetType;
void(float pType) Nex_Management_SetType = asm
{
local entity lTypeData;
local entity lList;
local entity lItem;
local float temp_0;
	STORE_F	"::Data::Management::ConfigType",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lTypeData;
	STORE_F	pType,	parm0_x;
	CALL1		ftos;
	STORE_F	lTypeData,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	"FileList",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	pType,	parm0_x;
	CALL1		Nex_Management_GetFileList;
	STORE_ENT	return_x,	lList;
	INDIRECT_S	lList,	name,	temp_0;
	STORE_F	lItem,	parm0_x;
	STORE_F	target,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () Nex_Update_Management_SyncData;
void() Nex_Update_Management_SyncData = asm
{
local float temp_0;
local float temp_1;
	INDIRECT_F	self,	_realValue,	temp_0;
	LT		temp_0,	Timer_Time,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_F	self,	_realValue,	temp_1;
	GT		temp_1,	KEY_GAME,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	9;
	CALL0		Nex_Management_GetType;
	STORE_F	return_x,	parm0_x;
	CALL1		Nex_Management_GetContainer;
	STORE_F	return_x,	parm0_x;
	STORE_F	ITEM_DATA_SYNC,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_realValue,	temp_0;
	STOREP_F	KEY_GAME,	temp_0;
	DONE;
}

void () Nex_Action_Management_LoadConfig;
void() Nex_Action_Management_LoadConfig = asm
{
local entity lSyncItem;
local entity lFilenameData;
local entity lFileList;
local float temp_0;
local float temp_1;
local float temp_2;
	CALL0		Nex_Management_GetType;
	STORE_F	return_x,	parm0_x;
	CALL1		Nex_Management_GetFileList;
	STORE_ENT	return_x,	lFileList;
	STORE_F	"::Data::Management::Filename",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lFilenameData;
	INDIRECT_S	lFileList,	selected,	temp_1;
	INDIRECT_S	lFilenameData,	value,	temp_2;
	INDIRECT_S	lFileList,	normal,	temp_0;
	STORE_F	"exec "",	parm0_x;
	STORE_F	temp_1,	parm1_x;
	STORE_F	"/",	parm2_x;
	STORE_F	temp_2,	parm3_x;
	STORE_F	".",	parm4_x;
	STORE_F	temp_0,	parm5_x;
	STORE_F	""
",	parm6_x;
	CALL7		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	STORE_F	"::Data::Management::SyncCategory",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lSyncItem;
	ADDRESS	lSyncItem,	_realValue,	temp_0;
	STOREP_F	Timer_Time,	temp_0;
	DONE;
}

void () Nex_Action_Management_Load;
void() Nex_Action_Management_Load = asm
{
local string lQuestion;
local entity lItem;
local float temp_0;
	STORE_F	"::Data::Management::Filename",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_S	lItem,	value,	temp_0;
	EQ_S		temp_0,	"",	temp_0;
	IFNOT		temp_0,	9;
	STORE_F	"Loading",	parm0_x;
	STORE_F	"You must specify a filename!",	parm1_x;
	STORE_F	"Ok",	parm2_x;
	STORE_F	"",	parm3_x;
	STORE_F	Util_NullFunction,	parm4_x;
	STORE_F	Util_NullFunction,	parm5_x;
	CALL6		Nex_MessageBox;
	RETURN	offset_0;
	INDIRECT_S	lItem,	value,	temp_0;
	STORE_F	"Do you want to load '",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"'?",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lQuestion;
	STORE_F	"Loading",	parm0_x;
	STORE_F	lQuestion,	parm1_x;
	STORE_F	"Yes",	parm2_x;
	STORE_F	"No",	parm3_x;
	STORE_F	Nex_Action_Management_LoadConfig,	parm4_x;
	STORE_F	Util_NullFunction,	parm5_x;
	CALL6		Nex_MessageBox;
	STORE_F	lQuestion,	parm0_x;
	CALL1		String_Free;
	DONE;
}

void () Nex_Action_Management_SaveConfig;
void() Nex_Action_Management_SaveConfig = asm
{
local float lHandle;
local entity lContainer;
local entity lFilename;
local entity lFileList;
local float lType;
local float temp_0;
local float temp_1;
local float temp_2;
	CALL0		Nex_Management_GetType;
	STORE_F	return_x,	lType;
	STORE_F	lType,	parm0_x;
	CALL1		Nex_Management_GetFileList;
	STORE_ENT	return_x,	lFileList;
	STORE_F	lType,	parm0_x;
	CALL1		Nex_Management_GetContainer;
	STORE_ENT	return_x,	lContainer;
	STORE_F	"::Data::Management::Filename",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lFilename;
	INDIRECT_S	lFilename,	value,	temp_0;
	EQ_S		temp_0,	"",	temp_0;
	IFNOT		temp_0,	9;
	STORE_F	"Loading",	parm0_x;
	STORE_F	"You must specify a filename!",	parm1_x;
	STORE_F	"Ok",	parm2_x;
	STORE_F	"",	parm3_x;
	STORE_F	Util_NullFunction,	parm4_x;
	STORE_F	Util_NullFunction,	parm5_x;
	CALL6		Nex_MessageBox;
	RETURN	offset_0;
	INDIRECT_S	lFileList,	selected,	temp_0;
	INDIRECT_S	lFilename,	value,	temp_1;
	INDIRECT_S	lFileList,	normal,	temp_2;
	STORE_F	temp_0,	parm0_x;
	STORE_F	"/",	parm1_x;
	STORE_F	temp_1,	parm2_x;
	STORE_F	".",	parm3_x;
	STORE_F	temp_2,	parm4_x;
	CALL5		strcat;
	STORE_F	return_x,	parm0_x;
	STORE_F	KEY_MENU,	parm1_x;
	CALL2		fopen;
	STORE_F	return_x,	lHandle;
	LT		lHandle,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	offset_0;
	CALL0		Data_ExecString_BeginUse;
	STORE_F	lContainer,	parm0_x;
	STORE_F	ITEM_DATA_SAVE_EXECSTRING,	parm1_x;
	CALL2		Raise_DataEvent;
	STORE_F	lHandle,	parm0_x;
	STORE_F	Data_ExecString,	parm1_x;
	CALL2		fputs;
	CALL0		Data_ExecString_EndUse;
	STORE_F	lHandle,	parm0_x;
	CALL1		fclose;
	DONE;
}

void () Nex_Action_Management_Save;
void() Nex_Action_Management_Save = asm
{
local string lQuestion;
local float lHandle;
local entity lFilename;
local entity lFileList;
local float temp_0;
local float temp_1;
local float temp_2;
	CALL0		Nex_Management_GetType;
	STORE_F	return_x,	parm0_x;
	CALL1		Nex_Management_GetFileList;
	STORE_ENT	return_x,	lFileList;
	STORE_F	"::Data::Management::Filename",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lFilename;
	INDIRECT_S	lFileList,	selected,	temp_0;
	INDIRECT_S	lFilename,	value,	temp_1;
	INDIRECT_S	lFileList,	normal,	temp_2;
	STORE_F	temp_0,	parm0_x;
	STORE_F	"/",	parm1_x;
	STORE_F	temp_1,	parm2_x;
	STORE_F	".",	parm3_x;
	STORE_F	temp_2,	parm4_x;
	CALL5		strcat;
	STORE_F	return_x,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		fopen;
	STORE_F	return_x,	lHandle;
	EQ_F		lHandle,	ERR_CANNOTOPEN,	temp_0;
	IFNOT		temp_0,	5;
	CALL0		Nex_Action_Management_SaveConfig;
	STORE_F	lHandle,	parm0_x;
	CALL1		fclose;
	GOTO		20;
	GT		lHandle,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	18;
	INDIRECT_S	lFilename,	value,	temp_0;
	STORE_F	"Do you want to overwrite '",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"'?",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lQuestion;
	STORE_F	"Saving",	parm0_x;
	STORE_F	lQuestion,	parm1_x;
	STORE_F	"Yes",	parm2_x;
	STORE_F	"No",	parm3_x;
	STORE_F	Nex_Action_Management_SaveConfig,	parm4_x;
	STORE_F	Util_NullFunction,	parm5_x;
	CALL6		Nex_MessageBox;
	STORE_F	lQuestion,	parm0_x;
	CALL1		String_Free;
	DONE;
}

void () Nex_Action_Management_Refresh;
void() Nex_Action_Management_Refresh = asm
{
local entity lItem;
	STORE_F	"::Data::Management::FileList",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	lItem,	parm0_x;
	STORE_F	ITEM_DATA_SYNC,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Nex_Action_Management_TypeWeapon;
void() Nex_Action_Management_TypeWeapon = asm
{
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		Nex_Management_SetType;
	DONE;
}

void () Nex_Action_Management_TypeGame;
void() Nex_Action_Management_TypeGame = asm
{
	STORE_F	FILE_APPEND,	parm0_x;
	CALL1		Nex_Management_SetType;
	DONE;
}

void () Nex_Action_Management_TypeMapList;
void() Nex_Action_Management_TypeMapList = asm
{
	STORE_F	KEY_MENU,	parm0_x;
	CALL1		Nex_Management_SetType;
	DONE;
}

void () Nex_Automation_Key;
void() Nex_Automation_Key = asm
{
local entity lLink2;
local entity lLink1;
local entity lAction;
local float temp_0;
local float temp_1;
	INDIRECT_E	self,	_parent,	temp_0;
	INDIRECT_S	temp_0,	target,	temp_0;
	NOT_S		temp_0,	temp_0;
	IFNOT		temp_0,	8;
	INDIRECT_E	self,	_parent,	temp_0;
	INDIRECT_S	temp_0,	target,	temp_0;
	STORE_F	"Bad target '",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"'",	parm2_x;
	CALL3		objerror;
	RETURN	offset_0;
	STORE_F	"Action",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lAction;
	STORE_F	"Link1",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lLink1;
	STORE_F	"Link2",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lLink2;
	ADDRESS	lAction,	text,	temp_0;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_S	temp_1,	text,	temp_1;
	STOREP_S	temp_1,	temp_0;
	ADDRESS	lLink1,	link,	temp_0;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_S	temp_1,	target,	temp_1;
	STOREP_S	temp_1,	temp_0;
	ADDRESS	lLink2,	link,	temp_0;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_S	temp_1,	target,	temp_1;
	STOREP_S	temp_1,	temp_0;
	DONE;
}

void (float, float) Nex_Key_KeyHook;
void(float pKey, float pAscii) Nex_Key_KeyHook = asm
{
local entity lItem;
local float temp_0;
local float temp_1;
	NE_F		pKey,	K_ESCAPE,	temp_0;
	IFNOT		temp_0,	13;
	STORE_F	pKey,	parm0_x;
	CALL1		ftos;
	STORE_F	Menu_KeyHook_Target,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	Menu_KeyHook_Target,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	STORE_F	Menu_KeyHook_Target,	parm0_x;
	STORE_F	ITEM_DATA_TEST_START,	parm1_x;
	CALL2		Raise_DataEvent;
	STORE_F	Menu_KeyHook_Target,	parm0_x;
	STORE_F	"InfoWindow",	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		Menu_GetItemEx;
	STORE_ENT	return_x,	lItem;
	ADDRESS	lItem,	flag,	temp_0;
	INDIRECT_F	lItem,	flag,	temp_1;
	BITOR		temp_1,	FLAG_HIDDEN,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_FNC	Util_NullFunction,	Menu_KeyHook;
	DONE;
}

void () Nex_Action_KeyButton;
void() Nex_Action_KeyButton = asm
{
local entity lItem;
local float temp_0;
local float temp_1;
local float temp_2;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_E	temp_0,	_link,	Menu_KeyHook_Target;
	STORE_FNC	Nex_Key_KeyHook,	Menu_KeyHook;
	STORE_F	"InfoWindow",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	ADDRESS	lItem,	flag,	temp_0;
	INDIRECT_F	lItem,	flag,	temp_1;
	INDIRECT_F	lItem,	flag,	temp_2;
	BITAND	temp_2,	FLAG_HIDDEN,	temp_2;
	SUB_F		temp_1,	temp_2,	temp_1;
	STOREP_F	temp_1,	temp_0;
	DONE;
}

void () Nex_Action_Video_Apply;
void() Nex_Action_Video_Apply = asm
{
	STORE_F	"::Data::Video::Fullscreen",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	STORE_F	ITEM_DATA_SEND,	parm1_x;
	CALL2		Raise_DataEvent;
	STORE_F	"::Data::Video::Resolution",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	STORE_F	ITEM_DATA_SEND,	parm1_x;
	CALL2		Raise_DataEvent;
	STORE_F	"::Data::Video::BPP",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	STORE_F	ITEM_DATA_SEND,	parm1_x;
	CALL2		Raise_DataEvent;
	STORE_F	"vid_restart
",	parm0_x;
	CALL1		cmd;
	DONE;
}

void () Nex_Action_JoinGame_SortBy_Action;
void() Nex_Action_JoinGame_SortBy_Action = asm
{
local float temp_0;
local float temp_1;
	INDIRECT_F	self,	_realValue,	temp_0;
	EQ_F		HostCache_SortField,	temp_0,	temp_0;
	IFNOT		temp_0,	7;
	INDIRECT_F	self,	_realValue,	temp_0;
	NOT_F		HostCache_SortDescending,	temp_1;
	STORE_F	temp_0,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		sethostcachesort;
	GOTO		4;
	INDIRECT_F	self,	_realValue,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	CALL2		sethostcachesort;
	CALL0		HostCache_ResortViewSet;
	DONE;
}

void () Nex_Action_JoinGame_SortBy;
void() Nex_Action_JoinGame_SortBy = asm
{
local float locked_1174;
local float temp_1;
	ADDRESS	self,	_realValue,	locked_1174;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		gethostcacheindexforkey;
	STOREP_F	return_x,	locked_1174;
	ADDRESS	self,	action,	locked_1174;
	STOREP_FNC	Nex_Action_JoinGame_SortBy_Action,	locked_1174;
	DONE;
}

void () Nex_Automation_CreateEntries;
void() Nex_Automation_CreateEntries = asm
{
local entity lEntry;
local float lCounter;
local entity lTemplate;
local float temp_0;
	STORE_F	"Entry",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lTemplate;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	64.000000,	temp_0;
	IFNOT		temp_0,	17;
	STORE_F	lCounter,	parm0_x;
	CALL1		ftos;
	STORE_F	"Entry",	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		strcat;
	INDIRECT_S	self,	parent,	temp_0;
	STORE_F	lTemplate,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	STORE_F	FILE_APPEND,	parm3_x;
	CALL4		Menu_DeriveItem;
	STORE_ENT	return_x,	lEntry;
	ADDRESS	lEntry,	stepValue,	temp_0;
	STOREP_F	lCounter,	temp_0;
	ADD_F		lCounter,	FILE_APPEND,	lCounter;
	GOTO		-17;
	INDIRECT_E	self,	_parent,	parm0_x;
	CALL1		Menu_LinkItem;
	DONE;
}

void () Nex_Action_EntryConnect;
void() Nex_Action_EntryConnect = asm
{
local float temp_0;
	STORE_F	"connect "",	parm0_x;
	CALL1		cmd;
	INDIRECT_F	self,	stepValue,	temp_0;
	STORE_F	SLIST_FIELD_CNAME,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	CALL2		gethostcachestring;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	STORE_F	""
",	parm0_x;
	CALL1		cmd;
	CALL0		m_hide;
	DONE;
}

void () Nex_Action_RefreshSlist;
void() Nex_Action_RefreshSlist = asm
{
	CALL0		HostCache_RefreshHostCache;
	DONE;
}

void () Nex_Action_JumpToJoinGame;
void() Nex_Action_JumpToJoinGame = asm
{
local entity lItem;
local float temp_0;
	CALL0		resethostcachemasks;
	STORE_F	SLIST_FIELD_PING,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		sethostcachesort;
	CALL0		HostCache_RefreshHostCache;
	STORE_F	"Normal::Panel",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	lItem,	parm0_x;
	STORE_F	link,	parm1_x;
	STORE_F	"JoinGame",	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	lItem,	parm0_x;
	CALL1		Raise_Update;
	CALL0		Menu_UpdateRunFlags;
	INDIRECT_E	lItem,	_link,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		Menu_JumpToWindow;
	DONE;
}

void () Nex_Action_ExecuteQuery;
void() Nex_Action_ExecuteQuery = asm
{
local bool lIsStringArg;
local float lOperator;
local float lField;
local bool lAndMask;
local string lToken;
local float lTokenCount;
local float lTokenNum;
local float lOrPos;
local float lAndPos;
local float temp_0;
local float temp_1;
	CALL0		resethostcachemasks;
	STORE_F	KEY_GAME,	lAndPos;
	STORE_F	K_MOUSE1,	lOrPos;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_S	temp_0,	value,	parm0_x;
	CALL1		tokenize;
	STORE_F	return_x,	lTokenCount;
	STORE_F	KEY_GAME,	lTokenNum;
	LT		lTokenNum,	lTokenCount,	temp_0;
	IFNOT		temp_0,	223;
	STORE_F	lTokenNum,	parm0_x;
	CALL1		argv;
	STORE_S	return_x,	lToken;
	EQ_S		lToken,	"notempty",	temp_0;
	IFNOT		temp_0,	8;
	STORE_F	lAndPos,	parm0_x;
	STORE_F	SLIST_FIELD_NUMPLAYERS,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	STORE_F	SLIST_SORTDESCENDING,	parm3_x;
	CALL4		sethostcachemasknumber;
	ADD_F		lAndPos,	FILE_APPEND,	lAndPos;
	GOTO		209;
	EQ_S		lToken,	"compatible",	temp_0;
	IFNOT		temp_0,	8;
	STORE_F	lAndPos,	parm0_x;
	STORE_F	SLIST_FIELD_PROTOCOL,	parm1_x;
	STORE_F	KEY_UNKNOWN,	parm2_x;
	STORE_F	CVAR_READONLY,	parm3_x;
	CALL4		sethostcachemasknumber;
	ADD_F		lAndPos,	FILE_APPEND,	lAndPos;
	GOTO		200;
	EQ_S		lToken,	"goodping",	temp_0;
	IFNOT		temp_0,	8;
	STORE_F	lAndPos,	parm0_x;
	STORE_F	SLIST_FIELD_PING,	parm1_x;
	STORE_F	K_PGUP,	parm2_x;
	STORE_F	KEY_MENU,	parm3_x;
	CALL4		sethostcachemasknumber;
	ADD_F		lAndPos,	FILE_APPEND,	lAndPos;
	GOTO		191;
	EQ_S		lToken,	"mediumping",	temp_0;
	IFNOT		temp_0,	8;
	STORE_F	lAndPos,	parm0_x;
	STORE_F	SLIST_FIELD_PROTOCOL,	parm1_x;
	STORE_F	250.000000,	parm2_x;
	STORE_F	KEY_MENU,	parm3_x;
	CALL4		sethostcachemasknumber;
	ADD_F		lAndPos,	FILE_APPEND,	lAndPos;
	GOTO		182;
	EQ_S		lToken,	"mask",	temp_0;
	IFNOT		temp_0,	168;
	ADD_F		lTokenNum,	FILE_APPEND,	lTokenNum;
	GT		lTokenNum,	lTokenCount,	temp_0;
	IFNOT		temp_0,	3;
	GOTO		178;
	GOTO		4;
	STORE_F	lTokenNum,	parm0_x;
	CALL1		argv;
	STORE_S	return_x,	lToken;
	EQ_S		lToken,	"or",	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	KEY_GAME,	lAndMask;
	GOTO		6;
	EQ_S		lToken,	"and",	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	FILE_APPEND,	lAndMask;
	GOTO		2;
	GOTO		165;
	ADD_F		lTokenNum,	FILE_APPEND,	lTokenNum;
	GT		lTokenNum,	lTokenCount,	temp_0;
	IFNOT		temp_0,	3;
	GOTO		161;
	GOTO		4;
	STORE_F	lTokenNum,	parm0_x;
	CALL1		argv;
	STORE_S	return_x,	lToken;
	EQ_S		lToken,	"cname",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	SLIST_FIELD_CNAME,	lField;
	STORE_F	FILE_APPEND,	lIsStringArg;
	GOTO		46;
	EQ_S		lToken,	"ping",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	SLIST_FIELD_PING,	lField;
	STORE_F	KEY_GAME,	lIsStringArg;
	GOTO		41;
	EQ_S		lToken,	"game",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	SLIST_FIELD_GAME,	lField;
	STORE_F	FILE_APPEND,	lIsStringArg;
	GOTO		36;
	EQ_S		lToken,	"mod",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	SLIST_FIELD_MOD,	lField;
	STORE_F	FILE_APPEND,	lIsStringArg;
	GOTO		31;
	EQ_S		lToken,	"map",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	SLIST_FIELD_MAP,	lField;
	STORE_F	FILE_APPEND,	lIsStringArg;
	GOTO		26;
	EQ_S		lToken,	"name",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	SLIST_FIELD_NAME,	lField;
	STORE_F	FILE_APPEND,	lIsStringArg;
	GOTO		21;
	EQ_S		lToken,	"maxplayers",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	SLIST_FIELD_MAXPLAYERS,	lField;
	STORE_F	KEY_GAME,	lIsStringArg;
	GOTO		16;
	EQ_S		lToken,	"numplayers",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	SLIST_FIELD_NUMPLAYERS,	lField;
	STORE_F	KEY_GAME,	lIsStringArg;
	GOTO		11;
	EQ_S		lToken,	"protocol",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	SLIST_FIELD_PROTOCOL,	lField;
	STORE_F	KEY_GAME,	lIsStringArg;
	GOTO		6;
	IFNOT		lAndMask,	3;
	ADD_F		lAndPos,	FILE_APPEND,	lAndPos;
	GOTO		2;
	ADD_F		lOrPos,	FILE_APPEND,	lOrPos;
	GOTO		91;
	ADD_F		lTokenNum,	FILE_APPEND,	lTokenNum;
	GT		lTokenNum,	lTokenCount,	temp_0;
	IFNOT		temp_0,	3;
	GOTO		103;
	GOTO		4;
	STORE_F	lTokenNum,	parm0_x;
	CALL1		argv;
	STORE_S	return_x,	lToken;
	EQ_S		lToken,	"$$",	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	KEY_GAME,	lOperator;
	GOTO		40;
	EQ_S		lToken,	"!$",	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	FILE_APPEND,	lOperator;
	GOTO		36;
	EQ_S		lToken,	"<",	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	KEY_UNKNOWN,	lOperator;
	GOTO		32;
	EQ_S		lToken,	"<=",	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	KEY_MENU,	lOperator;
	GOTO		28;
	EQ_S		lToken,	"==",	temp_0;
	IF		temp_0,	2;
	EQ_S		lToken,	"=",	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	CVAR_READONLY,	lOperator;
	GOTO		21;
	EQ_S		lToken,	">",	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	SLIST_SERVERREPLYCOUNT,	lOperator;
	GOTO		17;
	EQ_S		lToken,	">=",	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	SLIST_SORTFIELD,	lOperator;
	GOTO		13;
	EQ_S		lToken,	"!=",	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	SLIST_SORTDESCENDING,	lOperator;
	GOTO		9;
	EQ_S		lToken,	":",	temp_0;
	IFNOT		temp_0,	6;
	IFNOT		lIsStringArg,	3;
	STORE_F	KEY_GAME,	lOperator;
	GOTO		2;
	STORE_F	KEY_MENU,	lOperator;
	GOTO		2;
	GOTO		56;
	ADD_F		lTokenNum,	FILE_APPEND,	lTokenNum;
	GT		lTokenNum,	lTokenCount,	temp_0;
	IFNOT		temp_0,	3;
	GOTO		52;
	GOTO		4;
	STORE_F	lTokenNum,	parm0_x;
	CALL1		argv;
	STORE_S	return_x,	lToken;
	IFNOT		lIsStringArg,	14;
	IFNOT		lAndMask,	7;
	STORE_F	lAndPos,	parm0_x;
	STORE_F	lField,	parm1_x;
	STORE_F	lToken,	parm2_x;
	STORE_F	lOperator,	parm3_x;
	CALL4		sethostcachemaskstring;
	GOTO		6;
	STORE_F	lOrPos,	parm0_x;
	STORE_F	lField,	parm1_x;
	STORE_F	lToken,	parm2_x;
	STORE_F	lOperator,	parm3_x;
	CALL4		sethostcachemaskstring;
	GOTO		17;
	IFNOT		lAndMask,	9;
	STORE_F	lToken,	parm0_x;
	CALL1		stof;
	STORE_F	lAndPos,	parm0_x;
	STORE_F	lField,	parm1_x;
	STORE_F	return_x,	parm2_x;
	STORE_F	lOperator,	parm3_x;
	CALL4		sethostcachemasknumber;
	GOTO		8;
	STORE_F	lToken,	parm0_x;
	CALL1		stof;
	STORE_F	lOrPos,	parm0_x;
	STORE_F	lField,	parm1_x;
	STORE_F	return_x,	parm2_x;
	STORE_F	lOperator,	parm3_x;
	CALL4		sethostcachemasknumber;
	GOTO		-147;
	GOTO		-157;
	GOTO		13;
	STORE_F	lOrPos,	parm0_x;
	STORE_F	SLIST_FIELD_MAP,	parm1_x;
	STORE_F	lToken,	parm2_x;
	STORE_F	KEY_GAME,	parm3_x;
	CALL4		sethostcachemaskstring;
	ADD_F		lOrPos,	FILE_APPEND,	lOrPos;
	STORE_F	lOrPos,	parm0_x;
	STORE_F	SLIST_FIELD_NAME,	parm1_x;
	STORE_F	lToken,	parm2_x;
	STORE_F	KEY_GAME,	parm3_x;
	CALL4		sethostcachemaskstring;
	ADD_F		lOrPos,	FILE_APPEND,	lOrPos;
	ADD_F		lTokenNum,	FILE_APPEND,	lTokenNum;
	GOTO		-223;
	CALL0		HostCache_ResortViewSet;
	DONE;
}

void () Nex_Credits_SetSizeX;
void() Nex_Credits_SetSizeX = asm
{
local entity lItem;
local float temp_0;
local float temp_1;
	STORE_F	"Credits",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	ADDRESS	lItem,	size_x,	temp_0;
	INDIRECT_E	self,	_parent,	temp_1;
	INDIRECT_F	temp_1,	size_x,	temp_1;
	STOREP_F	temp_1,	temp_0;
	DONE;
}

void () Nex_Credits_Scroll;
void() Nex_Credits_Scroll = asm
{
local entity lTarget;
local entity lItem;
local vector temp_0;
local vector temp_1;
local vector temp_2;
local float temp_3;
local float temp_4;
	STORE_F	"Credits",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_E	self,	_parent,	lTarget;
	ADDRESS	lTarget,	origin_x,	temp_2_x;
	INDIRECT_V	lTarget,	origin_x,	temp_1;
	INDIRECT_V	self,	direction_x,	temp_0;
	MUL_FV	Timer_Delta,	temp_0,	temp_0;
	SUB_V		temp_1,	temp_0,	temp_0;
	STOREP_V	temp_0_x,	temp_2;
	INDIRECT_F	self,	direction_x,	temp_3;
	IFNOT		temp_3,	17;
	INDIRECT_F	lTarget,	origin_x,	temp_3;
	INDIRECT_F	lItem,	size_x,	temp_4;
	SUB_F		KEY_GAME,	temp_4,	temp_4;
	LT		temp_3,	temp_4,	temp_3;
	IFNOT		temp_3,	4;
	ADDRESS	lTarget,	origin_x,	temp_3;
	INDIRECT_F	lTarget,	size_x,	temp_4;
	STOREP_F	temp_4,	temp_3;
	INDIRECT_F	lTarget,	origin_x,	temp_3;
	INDIRECT_F	lItem,	size_x,	temp_4;
	GT		temp_3,	temp_4,	temp_3;
	IFNOT		temp_3,	5;
	ADDRESS	lTarget,	origin_x,	temp_3;
	INDIRECT_F	lItem,	size_x,	temp_4;
	SUB_F		KEY_GAME,	temp_4,	temp_4;
	STOREP_F	temp_4,	temp_3;
	INDIRECT_F	self,	direction_y,	temp_3;
	IFNOT		temp_3,	17;
	INDIRECT_F	lTarget,	origin_y,	temp_3;
	INDIRECT_F	lItem,	size_y,	temp_4;
	SUB_F		KEY_GAME,	temp_4,	temp_4;
	LT		temp_3,	temp_4,	temp_3;
	IFNOT		temp_3,	4;
	ADDRESS	lTarget,	origin_y,	temp_3;
	INDIRECT_F	lTarget,	size_y,	temp_4;
	STOREP_F	temp_4,	temp_3;
	INDIRECT_F	lTarget,	origin_y,	temp_3;
	INDIRECT_F	lItem,	size_y,	temp_4;
	GT		temp_3,	temp_4,	temp_3;
	IFNOT		temp_3,	5;
	ADDRESS	lTarget,	origin_y,	temp_3;
	INDIRECT_F	lItem,	size_y,	temp_4;
	SUB_F		KEY_GAME,	temp_4,	temp_4;
	STOREP_F	temp_4,	temp_3;
	DONE;
}

void () Nex_Credits_Toggle;
void() Nex_Credits_Toggle = asm
{
local entity lEntity;
local float temp_3;
local float temp_4;
	STORE_F	"CreditsWnd",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lEntity;
	INDIRECT_F	lEntity,	flag,	temp_3;
	BITAND	temp_3,	FLAG_HIDDEN,	temp_3;
	IFNOT		temp_3,	11;
	ADDRESS	lEntity,	flag,	temp_3;
	INDIRECT_F	lEntity,	flag,	temp_4;
	SUB_F		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	STORE_F	"CreditsWnd::Layout::Items::Close",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		Menu_Select;
	GOTO		7;
	ADDRESS	lEntity,	flag,	temp_3;
	INDIRECT_F	lEntity,	flag,	temp_4;
	ADD_F		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		Menu_Reselect;
	DONE;
}

float (float, float) Nex_Credits_Key;
float(float pKey, float pAscii) Nex_Credits_Key = asm
{
local float temp_3;
	EQ_F		pKey,	K_ESCAPE,	temp_3;
	IFNOT		temp_3,	3;
	CALL0		Nex_Credits_Toggle;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void () Nex_Credits_Action;
void() Nex_Credits_Action = asm
{
local entity lEntity;
local float temp_3;
local float temp_4;
	STORE_F	"CreditsWnd",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lEntity;
	INDIRECT_F	lEntity,	flag,	temp_3;
	BITAND	temp_3,	FLAG_HIDDEN,	temp_3;
	IFNOT		temp_3,	5;
	ADDRESS	lEntity,	flag,	temp_3;
	INDIRECT_F	lEntity,	flag,	temp_4;
	SUB_F		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	STORE_F	"CreditsWnd::Layout::Items::Close",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		Menu_Select;
	STORE_F	"CreditsWnd::Layout::Items::Scroller",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lEntity;
	ADDRESS	lEntity,	origin_y,	temp_3;
	INDIRECT_F	lEntity,	size_y,	temp_4;
	STOREP_F	temp_4,	temp_3;
	DONE;
}

void() Item_Nex_Avatar_Info_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	picture,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	text,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_Nex_Avatar_Info_Spawn = asm
{
local float temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	picture,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	text,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	CALL2		String_EntityZone;
	INDIRECT_S	self,	picture,	parm0_x;
	CALL1		Gfx_Precache;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_Nex_Avatar_Info_Destroy,	temp_3;
	DONE;
}

void () _IDNA_BuildList;
void() _IDNA_BuildList = asm
{
local float locked_1174;
local string lLine;
local string lDescription;
local string lModel;
local string lSkin;
local string lPicture;
local string lName;
local float lHandle;
local string lFilename;
local entity lAvatar;
local float lSearchCounter;
local float lSearchSize;
local float lSearchHandle;
local float temp_4;
	STORE_F	self,	parm0_x;
	CALL1		Menu_EmptyWindow;
	STORE_F	"models/player/*.txt",	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		search_begin;
	STORE_F	return_x,	lSearchHandle;
	LT		lSearchHandle,	KEY_GAME,	locked_1174;
	IFNOT		locked_1174,	2;
	RETURN	offset_0;
	STORE_F	lSearchHandle,	parm0_x;
	CALL1		search_getsize;
	STORE_F	return_x,	lSearchSize;
	STORE_F	KEY_GAME,	lSearchCounter;
	LT		lSearchCounter,	lSearchSize,	locked_1174;
	IFNOT		locked_1174,	116;
	STORE_F	lSearchHandle,	parm0_x;
	STORE_F	lSearchCounter,	parm1_x;
	CALL2		search_getfilename;
	STORE_S	return_x,	lFilename;
	STORE_F	lFilename,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		fopen;
	STORE_F	return_x,	lHandle;
	LT		lHandle,	KEY_GAME,	locked_1174;
	IFNOT		locked_1174,	6;
	STORE_F	"Menu: Couldn't open model definition file '",	parm0_x;
	STORE_F	lFilename,	parm1_x;
	STORE_F	"'
",	parm2_x;
	CALL3		print;
	GOTO		99;
	STORE_F	lHandle,	parm0_x;
	CALL1		fgets;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lName;
	STORE_F	lHandle,	parm0_x;
	CALL1		fgets;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lPicture;
	STORE_F	lHandle,	parm0_x;
	CALL1		fgets;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lSkin;
	STORE_F	lHandle,	parm0_x;
	CALL1		fgets;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lModel;
	NOT_S		lName,	locked_1174;
	IF		locked_1174,	2;
	NOT_S		lPicture,	temp_4;
	OR		locked_1174,	temp_4,	locked_1174;
	IF		locked_1174,	2;
	NOT_S		lSkin,	temp_4;
	OR		locked_1174,	temp_4,	locked_1174;
	IF		locked_1174,	2;
	NOT_S		lModel,	temp_4;
	OR		locked_1174,	temp_4,	locked_1174;
	IFNOT		locked_1174,	19;
	STORE_F	lName,	parm0_x;
	CALL1		String_Free;
	STORE_F	lPicture,	parm0_x;
	CALL1		String_Free;
	STORE_F	lSkin,	parm0_x;
	CALL1		String_Free;
	STORE_F	lModel,	parm0_x;
	CALL1		String_Free;
	STORE_F	lSearchHandle,	parm0_x;
	STORE_F	lSearchCounter,	parm1_x;
	CALL2		search_getfilename;
	STORE_F	"Menu: Couldn't parse model definition file '",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"'
",	parm2_x;
	CALL3		print;
	STORE_F	lHandle,	parm0_x;
	CALL1		fclose;
	GOTO		50;
	CALL0		String_Create;
	STORE_S	return_x,	lDescription;
	STORE_F	lHandle,	parm0_x;
	CALL1		fgets;
	STORE_S	return_x,	lLine;
	STORE_F	lLine,	parm0_x;
	STORE_F	"
",	parm1_x;
	CALL2		strcat;
	STORE_F	lDescription,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Append;
	STORE_S	return_x,	lDescription;
	STORE_F	lLine,	parm0_x;
	CALL1		validstring;
	IF		return_x,	-12;
	NE_S		lDescription,	string_null,	locked_1174;
	IFNOT		locked_1174,	21;
	STORE_F	lSearchCounter,	parm0_x;
	CALL1		ftos;
	INDIRECT_S	self,	name,	locked_1174;
	STORE_F	"Item_Nex_Avatar_Info",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	locked_1174,	parm2_x;
	CALL3		Menu_CreateItem;
	STORE_ENT	return_x,	lAvatar;
	ADDRESS	lAvatar,	target,	locked_1174;
	STOREP_S	lModel,	locked_1174;
	ADDRESS	lAvatar,	link,	locked_1174;
	STOREP_S	lSkin,	locked_1174;
	ADDRESS	lAvatar,	picture,	locked_1174;
	STOREP_S	lPicture,	locked_1174;
	ADDRESS	lAvatar,	normal,	locked_1174;
	STOREP_S	lName,	locked_1174;
	ADDRESS	lAvatar,	text,	locked_1174;
	STOREP_S	lDescription,	locked_1174;
	STORE_F	lAvatar,	parm0_x;
	CALL1		Menu_LinkItem;
	STORE_F	lName,	parm0_x;
	CALL1		String_Free;
	STORE_F	lPicture,	parm0_x;
	CALL1		String_Free;
	STORE_F	lSkin,	parm0_x;
	CALL1		String_Free;
	STORE_F	lModel,	parm0_x;
	CALL1		String_Free;
	STORE_F	lDescription,	parm0_x;
	CALL1		String_Free;
	STORE_F	lHandle,	parm0_x;
	CALL1		fclose;
	ADD_F		lSearchCounter,	FILE_APPEND,	lSearchCounter;
	GOTO		-116;
	STORE_F	lSearchHandle,	parm0_x;
	CALL1		search_end;
	STORE_F	self,	parm0_x;
	CALL1		Menu_LinkChildren;
	ADDRESS	self,	minValue,	locked_1174;
	STOREP_F	FILE_APPEND,	locked_1174;
	ADDRESS	self,	stepValue,	locked_1174;
	STOREP_F	FILE_APPEND,	locked_1174;
	ADDRESS	self,	maxValue,	locked_1174;
	INDIRECT_F	lAvatar,	orderPos,	parm0_x;
	CALL1		fabs;
	STOREP_F	return_x,	locked_1174;
	DONE;
}

void () _IDNA_Sync;
void() _IDNA_Sync = asm
{
local float locked_1174;
local entity lMatch;
local string lSkin;
local string lModel;
local float temp_4;
	STORE_F	"_cl_playermodel",	parm0_x;
	CALL1		str_cvar;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lModel;
	STORE_F	"_cl_playerskin",	parm0_x;
	CALL1		str_cvar;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lSkin;
	INDIRECT_E	self,	_child,	lMatch;
	INDIRECT_E	lMatch,	_next,	locked_1174;
	IFNOT		locked_1174,	11;
	INDIRECT_S	lMatch,	target,	locked_1174;
	EQ_S		locked_1174,	lModel,	locked_1174;
	IFNOT		locked_1174,	3;
	INDIRECT_S	lMatch,	link,	temp_4;
	EQ_S		temp_4,	lSkin,	temp_4;
	AND		locked_1174,	temp_4,	locked_1174;
	IFNOT		locked_1174,	2;
	GOTO		3;
	INDIRECT_E	lMatch,	_next,	lMatch;
	GOTO		-11;
	IFNOT		lMatch,	18;
	ADDRESS	self,	_link,	locked_1174;
	STOREP_ENT	lMatch,	locked_1174;
	ADDRESS	self,	_realValue,	locked_1174;
	INDIRECT_F	lMatch,	orderPos,	parm0_x;
	CALL1		fabs;
	STOREP_F	return_x,	locked_1174;
	INDIRECT_F	self,	_realValue,	parm0_x;
	CALL1		ftos;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	value,	locked_1174;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	locked_1174,	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	lModel,	parm0_x;
	CALL1		String_Free;
	STORE_F	lSkin,	parm0_x;
	CALL1		String_Free;
	DONE;
}

void () _IDNA_UpdateLink;
void() _IDNA_UpdateLink = asm
{
local float locked_1174;
local entity lMatch;
local float lTarget;
local float lCurrent;
local float temp_4;
	INDIRECT_E	self,	_link,	locked_1174;
	INDIRECT_F	locked_1174,	orderPos,	parm0_x;
	CALL1		fabs;
	STORE_F	return_x,	lCurrent;
	INDIRECT_F	self,	_realValue,	lTarget;
	LT		lCurrent,	lTarget,	locked_1174;
	IFNOT		locked_1174,	12;
	INDIRECT_E	self,	_link,	lMatch;
	INDIRECT_E	lMatch,	_next,	locked_1174;
	IFNOT		locked_1174,	4;
	INDIRECT_F	lMatch,	orderPos,	parm0_x;
	CALL1		fabs;
	NE_F		return_x,	lTarget,	temp_4;
	AND		locked_1174,	temp_4,	locked_1174;
	IFNOT		locked_1174,	3;
	INDIRECT_E	lMatch,	_next,	lMatch;
	GOTO		-8;
	GOTO		11;
	INDIRECT_E	self,	_link,	lMatch;
	INDIRECT_E	lMatch,	_prev,	locked_1174;
	IFNOT		locked_1174,	4;
	INDIRECT_F	lMatch,	orderPos,	parm0_x;
	CALL1		fabs;
	NE_F		return_x,	lTarget,	temp_4;
	AND		locked_1174,	temp_4,	locked_1174;
	IFNOT		locked_1174,	3;
	INDIRECT_E	lMatch,	_prev,	lMatch;
	GOTO		-8;
	ADDRESS	self,	_link,	locked_1174;
	STOREP_ENT	lMatch,	locked_1174;
	ADDRESS	self,	_realValue,	locked_1174;
	INDIRECT_E	self,	_link,	temp_4;
	INDIRECT_F	temp_4,	orderPos,	parm0_x;
	CALL1		fabs;
	STOREP_F	return_x,	locked_1174;
	INDIRECT_F	self,	_realValue,	parm0_x;
	CALL1		ftos;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () _IDNA_RawSet;
void() _IDNA_RawSet = asm
{
local float temp_3;
	CALL0		_IDNA_UpdateLink;
	INDIRECT_E	self,	_link,	temp_3;
	INDIRECT_S	temp_3,	target,	temp_3;
	STORE_F	"playermodel "",	parm0_x;
	STORE_F	temp_3,	parm1_x;
	STORE_F	"";",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	INDIRECT_E	self,	_link,	temp_3;
	INDIRECT_S	temp_3,	link,	temp_3;
	STORE_F	"playerskin "",	parm0_x;
	STORE_F	temp_3,	parm1_x;
	STORE_F	""
",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	DONE;
}

void () _IDNA_Send;
void() _IDNA_Send = asm
{
local float temp_3;
	CALL0		_IDNA_RawSet;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () _IDNA_Test_Start;
void() _IDNA_Test_Start = asm
{
	CALL0		_IDNA_RawSet;
	DONE;
}

void () _IDNA_Test_End;
void() _IDNA_Test_End = asm
{
local float temp_3;
	INDIRECT_S	self,	_syncValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		_IDNA_RawSet;
	DONE;
}

void () _IDNA_Reset;
void() _IDNA_Reset = asm
{
local float temp_3;
	INDIRECT_S	self,	defValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		_IDNA_Send;
	DONE;
}

void(float pEvent) Item_Data_Nex_Avatar_DataEvent = asm
{
local float temp_3;
	GOTO		13;
	CALL0		_IDNA_Sync;
	GOTO		22;
	CALL0		_IDNA_Send;
	GOTO		20;
	CALL0		_IDNA_Reset;
	GOTO		18;
	CALL0		_IDNA_Test_Start;
	GOTO		16;
	CALL0		_IDNA_Test_End;
	GOTO		14;
	CALL0		_IDNA_UpdateLink;
	GOTO		12;
	IFNOT		pEvent,	-12;
	EQ_F		pEvent,	ITEM_DATA_SEND,	temp_3;
	IF		temp_3,	-12;
	EQ_F		pEvent,	ITEM_DATA_RESET,	temp_3;
	IF		temp_3,	-12;
	EQ_F		pEvent,	ITEM_DATA_TEST_START,	temp_3;
	IF		temp_3,	-12;
	EQ_F		pEvent,	ITEM_DATA_TEST_END,	temp_3;
	IF		temp_3,	-12;
	EQ_F		pEvent,	ITEM_DATALINK_SET,	temp_3;
	IF		temp_3,	-12;
	DONE;
}

void() Item_Data_Nex_Avatar_Spawn = asm
{
local float temp_3;
local float temp_4;
	CALL0		Item_Data_Init;
	ADDRESS	self,	flag,	temp_3;
	INDIRECT_F	self,	flag,	temp_4;
	BITOR		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	ADDRESS	self,	_reinit,	temp_3;
	STOREP_FNC	_IDNA_Sync,	temp_3;
	ADDRESS	self,	_dataEvent,	temp_3;
	STOREP_FNC	Item_Data_Nex_Avatar_DataEvent,	temp_3;
	CALL0		_IDNA_BuildList;
	DONE;
}

void () _IDNN_Sync;
void() _IDNN_Sync = asm
{
local float temp_3;
	STORE_F	"_cl_name",	parm0_x;
	CALL1		str_cvar;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () _IDNN_Send;
void() _IDNN_Send = asm
{
local float temp_3;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	"name "",	parm0_x;
	STORE_F	temp_3,	parm1_x;
	STORE_F	""
",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () _IDNN_Test_Start;
void() _IDNN_Test_Start = asm
{
local float temp_3;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	"name "",	parm0_x;
	STORE_F	temp_3,	parm1_x;
	STORE_F	""
",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	DONE;
}

void () _IDNN_Test_End;
void() _IDNN_Test_End = asm
{
local float temp_3;
	INDIRECT_S	self,	_syncValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	"name "",	parm0_x;
	STORE_F	temp_3,	parm1_x;
	STORE_F	""
",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	DONE;
}

void () _IDNN_Reset;
void() _IDNN_Reset = asm
{
local float temp_3;
	INDIRECT_S	self,	defValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		_IDNN_Send;
	DONE;
}

void(float pEvent) Item_Data_Nex_Name_DataEvent = asm
{
local float temp_3;
	GOTO		11;
	CALL0		_IDNN_Sync;
	GOTO		18;
	CALL0		_IDNN_Send;
	GOTO		16;
	CALL0		_IDNN_Reset;
	GOTO		14;
	CALL0		_IDNN_Test_Start;
	GOTO		12;
	CALL0		_IDNN_Test_End;
	GOTO		10;
	IFNOT		pEvent,	-10;
	EQ_F		pEvent,	ITEM_DATA_SEND,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_RESET,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_TEST_START,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_TEST_END,	temp_3;
	IF		temp_3,	-10;
	DONE;
}

void() Item_Data_Nex_Name_Spawn = asm
{
local float temp_3;
	CALL0		Item_Data_Init;
	ADDRESS	self,	_reinit,	temp_3;
	STOREP_FNC	_IDNN_Sync,	temp_3;
	ADDRESS	self,	_dataEvent,	temp_3;
	STOREP_FNC	Item_Data_Nex_Name_DataEvent,	temp_3;
	DONE;
}

void () _IDNC_Sync;
void() _IDNC_Sync = asm
{
local float lPants;
local float temp_3;
	STORE_F	"_cl_color",	parm0_x;
	CALL1		cvar;
	BITAND	return_x,	15.000000,	lPants;
	STORE_F	lPants,	parm0_x;
	CALL1		ftos;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () _IDNC_Send;
void() _IDNC_Send = asm
{
local float temp_3;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	"color "",	parm0_x;
	STORE_F	temp_3,	parm1_x;
	STORE_F	""
",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () _IDNC_Test_Start;
void() _IDNC_Test_Start = asm
{
local float temp_3;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	"color "",	parm0_x;
	STORE_F	temp_3,	parm1_x;
	STORE_F	""
",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	DONE;
}

void () _IDNC_Test_End;
void() _IDNC_Test_End = asm
{
local float temp_3;
	INDIRECT_S	self,	_syncValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	"color "",	parm0_x;
	STORE_F	temp_3,	parm1_x;
	STORE_F	""
",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	DONE;
}

void () _IDNC_Reset;
void() _IDNC_Reset = asm
{
local float temp_3;
	INDIRECT_S	self,	defValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		_IDNN_Send;
	DONE;
}

void(float pEvent) Item_Data_Nex_Color_DataEvent = asm
{
local float temp_3;
	GOTO		11;
	CALL0		_IDNC_Sync;
	GOTO		18;
	CALL0		_IDNC_Send;
	GOTO		16;
	CALL0		_IDNC_Reset;
	GOTO		14;
	CALL0		_IDNC_Test_Start;
	GOTO		12;
	CALL0		_IDNC_Test_End;
	GOTO		10;
	IFNOT		pEvent,	-10;
	EQ_F		pEvent,	ITEM_DATA_SEND,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_RESET,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_TEST_START,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_TEST_END,	temp_3;
	IF		temp_3,	-10;
	DONE;
}

void() Item_Data_Nex_Color_Spawn = asm
{
local float temp_3;
	CALL0		Item_Data_Init;
	ADDRESS	self,	_reinit,	temp_3;
	STOREP_FNC	_IDNC_Sync,	temp_3;
	ADDRESS	self,	_dataEvent,	temp_3;
	STOREP_FNC	Item_Data_Nex_Color_DataEvent,	temp_3;
	DONE;
}

void() Item_Nex_Map_Info_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	picture,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	text,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_Nex_Map_Info_Spawn = asm
{
local float temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	picture,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	text,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	CALL2		String_EntityZone;
	INDIRECT_S	self,	picture,	parm0_x;
	CALL1		Gfx_Precache;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_Nex_Map_Info_Destroy,	temp_3;
	DONE;
}

string _Nex_MapList_FullPath;
string _Nex_MapList_Name;
entity _Nex_MapList_Root;
void() Item_Nex_MapDB_EnumFiles = asm
{
local float locked_1174;
local string lLine;
local string lTitle;
local string lDescription;
local string lName;
local string lStripped;
local string lFilename;
local float lHandle;
local entity lMap;
local float lSearchCounter;
local float lSearchSize;
local float lSearchHandle;
local float temp_4;
	STORE_F	"maps/*.bsp",	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		search_begin;
	STORE_F	return_x,	lSearchHandle;
	LT		lSearchHandle,	KEY_GAME,	locked_1174;
	IFNOT		locked_1174,	2;
	RETURN	offset_0;
	STORE_F	lSearchHandle,	parm0_x;
	CALL1		search_getsize;
	STORE_F	return_x,	lSearchSize;
	STORE_F	KEY_GAME,	lSearchCounter;
	LT		lSearchCounter,	lSearchSize,	locked_1174;
	IFNOT		locked_1174,	105;
	STORE_F	lSearchHandle,	parm0_x;
	STORE_F	lSearchCounter,	parm1_x;
	CALL2		search_getfilename;
	STORE_S	return_x,	lFilename;
	STORE_F	lFilename,	parm0_x;
	CALL1		strlen;
	SUB_F		return_x,	CVAR_READONLY,	locked_1174;
	STORE_F	lFilename,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	locked_1174,	parm2_x;
	CALL3		substring;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lStripped;
	STORE_F	lStripped,	parm0_x;
	STORE_F	SLIST_SERVERREPLYCOUNT,	parm1_x;
	STORE_F	100000.000000,	parm2_x;
	CALL3		substring;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lName;
	STORE_F	lStripped,	parm0_x;
	STORE_F	".txt",	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		fopen;
	STORE_F	return_x,	lHandle;
	LT		lHandle,	KEY_GAME,	locked_1174;
	IFNOT		locked_1174,	11;
	STORE_F	lName,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lTitle;
	STORE_F	"--NO INFORMATION AVAILABLE--
",	parm0_x;
	STORE_F	lFilename,	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lDescription;
	GOTO		23;
	STORE_F	lHandle,	parm0_x;
	CALL1		fgets;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lTitle;
	CALL0		String_Create;
	STORE_S	return_x,	lDescription;
	STORE_F	lHandle,	parm0_x;
	CALL1		fgets;
	STORE_S	return_x,	lLine;
	STORE_F	lLine,	parm0_x;
	STORE_F	"
",	parm1_x;
	CALL2		strcat;
	STORE_F	lDescription,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Append;
	STORE_S	return_x,	lDescription;
	STORE_F	lLine,	parm0_x;
	CALL1		validstring;
	IF		return_x,	-12;
	STORE_F	lHandle,	parm0_x;
	CALL1		fclose;
	STORE_F	lSearchCounter,	parm0_x;
	CALL1		ftos;
	INDIRECT_S	self,	name,	locked_1174;
	STORE_F	"Item_Nex_Map_Info",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	locked_1174,	parm2_x;
	CALL3		Menu_CreateItem;
	STORE_ENT	return_x,	lMap;
	ADDRESS	lMap,	link,	locked_1174;
	STOREP_S	lName,	locked_1174;
	STORE_F	lStripped,	parm0_x;
	CALL1		Gfx_Precache;
	IFNOT		return_x,	4;
	ADDRESS	lMap,	picture,	locked_1174;
	STOREP_S	lStripped,	locked_1174;
	GOTO		3;
	ADDRESS	lMap,	picture,	locked_1174;
	STOREP_S	"gfx/m_nomap",	locked_1174;
	ADDRESS	lMap,	normal,	locked_1174;
	STOREP_S	lTitle,	locked_1174;
	ADDRESS	lMap,	text,	locked_1174;
	STOREP_S	lDescription,	locked_1174;
	STORE_F	_Nex_MapList_FullPath,	parm0_x;
	STORE_F	lName,	parm1_x;
	CALL2		Util_AltStringPushBack;
	STORE_S	return_x,	_Nex_MapList_FullPath;
	STORE_F	_Nex_MapList_Name,	parm0_x;
	STORE_F	lTitle,	parm1_x;
	CALL2		Util_AltStringPushBack;
	STORE_S	return_x,	_Nex_MapList_Name;
	STORE_F	lMap,	parm0_x;
	CALL1		Menu_LinkItem;
	STORE_F	lTitle,	parm0_x;
	CALL1		String_Free;
	STORE_F	lName,	parm0_x;
	CALL1		String_Free;
	STORE_F	lStripped,	parm0_x;
	CALL1		String_Free;
	STORE_F	lDescription,	parm0_x;
	CALL1		String_Free;
	ADD_F		lSearchCounter,	FILE_APPEND,	lSearchCounter;
	GOTO		-105;
	STORE_F	lSearchHandle,	parm0_x;
	CALL1		search_end;
	STORE_F	self,	parm0_x;
	CALL1		Menu_LinkChildren;
	ADDRESS	self,	minValue,	locked_1174;
	STOREP_F	FILE_APPEND,	locked_1174;
	ADDRESS	self,	stepValue,	locked_1174;
	STOREP_F	FILE_APPEND,	locked_1174;
	ADDRESS	self,	maxValue,	locked_1174;
	INDIRECT_F	lMap,	orderPos,	parm0_x;
	CALL1		fabs;
	STOREP_F	return_x,	locked_1174;
	DONE;
}

void() Item_Nex_MapDB_Destroy = asm
{
	STORE_F	_Nex_MapList_FullPath,	parm0_x;
	CALL1		String_Free;
	STORE_F	_Nex_MapList_Name,	parm0_x;
	CALL1		String_Free;
	STORE_ENT	null_entity,	_Nex_MapList_Root;
	DONE;
}

void() Item_Nex_MapDB_Spawn = asm
{
local float temp_3;
	IFNOT		_Nex_MapList_Root,	3;
	STORE_F	"There is already another Item_Nex_MapDB object!",	parm0_x;
	CALL1		error;
	CALL0		String_Create;
	STORE_S	return_x,	_Nex_MapList_FullPath;
	CALL0		String_Create;
	STORE_S	return_x,	_Nex_MapList_Name;
	STORE_ENT	self,	_Nex_MapList_Root;
	CALL0		Item_Nex_MapDB_EnumFiles;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_Nex_MapDB_Destroy,	temp_3;
	DONE;
}

entity(string pPath) Nex_MapDB_GetByPath = asm
{
local entity lNode;
local float temp_3;
	IF		_Nex_MapList_Root,	3;
	STORE_F	"No Item_Nex_MapDB found!",	parm0_x;
	CALL1		error;
	INDIRECT_E	_Nex_MapList_Root,	_child,	lNode;
	IFNOT		lNode,	7;
	INDIRECT_S	lNode,	link,	temp_3;
	EQ_S		temp_3,	pPath,	temp_3;
	IFNOT		temp_3,	2;
	RETURN	lNode;
	INDIRECT_E	lNode,	_next,	lNode;
	GOTO		-6;
	RETURN	null_entity;
	DONE;
}

entity(float pIndex) Nex_MapDB_GetByIndex = asm
{
local entity lNode;
local float temp_3;
	IF		_Nex_MapList_Root,	3;
	STORE_F	"No Item_Nex_MapDB found!",	parm0_x;
	CALL1		error;
	STORE_F	pIndex,	parm0_x;
	CALL1		fabs;
	STORE_F	return_x,	pIndex;
	INDIRECT_E	_Nex_MapList_Root,	_child,	lNode;
	IFNOT		lNode,	8;
	INDIRECT_F	lNode,	orderPos,	parm0_x;
	CALL1		fabs;
	EQ_F		return_x,	pIndex,	temp_3;
	IFNOT		temp_3,	2;
	RETURN	lNode;
	INDIRECT_E	lNode,	_next,	lNode;
	GOTO		-7;
	RETURN	null_entity;
	DONE;
}

string() Nex_MapDB_GetPathAltString = asm
{
	RETURN	_Nex_MapList_FullPath;
	DONE;
}

string() Nex_MapDB_GetNameAltString = asm
{
	RETURN	_Nex_MapList_Name;
	DONE;
}

float(entity pItem) Nex_MapDB_GetIndex = asm
{
local float temp_3;
	INDIRECT_F	pItem,	orderPos,	parm0_x;
	CALL1		fabs;
	RETURN	return_x;
	DONE;
}

void () Item_DataLink_Nex_MapList_Save;
void() Item_DataLink_Nex_MapList_Save = asm
{
local string lOutput;
local float lIndex;
local float lCount;
local float temp_3;
local float temp_4;
	STORE_F	"
",	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lOutput;
	INDIRECT_S	self,	valueList,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	STORE_F	KEY_GAME,	lIndex;
	LT		lIndex,	lCount,	temp_3;
	IFNOT		temp_3,	17;
	INDIRECT_S	self,	valueList,	parm0_x;
	STORE_F	lIndex,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	"'",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"'
",	parm2_x;
	CALL3		strcat;
	STORE_F	lOutput,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Append;
	STORE_S	return_x,	lOutput;
	STORE_F	lIndex,	temp_4;
	ADD_F		lIndex,	FILE_APPEND,	lIndex;
	GOTO		-17;
	INDIRECT_S	self,	cvarName,	parm0_x;
	STORE_F	lOutput,	parm1_x;
	CALL2		cvar_set;
	INDIRECT_S	self,	cvarName,	parm0_x;
	STORE_F	"_index",	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	STORE_F	"0",	parm1_x;
	CALL2		cvar_set;
	STORE_F	lOutput,	parm0_x;
	CALL1		String_Free;
	DONE;
}

void () Item_DataLink_Nex_MapList_Load;
void() Item_DataLink_Nex_MapList_Load = asm
{
local float locked_1174;
local float lCount;
local float lCounter;
local entity lMapInfo;
local string lEntry;
local float temp_4;
local float temp_5;
	STORE_F	self,	parm0_x;
	CALL1		DataLink_Nex_MapList_Clear;
	INDIRECT_S	self,	cvarName,	parm0_x;
	CALL1		str_cvar;
	STORE_F	return_x,	parm0_x;
	CALL1		tokenize;
	STORE_F	return_x,	lCount;
	CALL0		String_Create;
	STORE_S	return_x,	lEntry;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	locked_1174;
	IFNOT		locked_1174,	35;
	STORE_F	lCounter,	parm0_x;
	CALL1		argv;
	STORE_F	lEntry,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	lEntry;
	STORE_F	lEntry,	parm0_x;
	CALL1		Nex_MapDB_GetByPath;
	STORE_ENT	return_x,	lMapInfo;
	EQ_E		lMapInfo,	null_entity,	locked_1174;
	IFNOT		locked_1174,	7;
	INDIRECT_S	self,	cvarName,	parm0_x;
	STORE_F	": Map '",	parm1_x;
	STORE_F	lEntry,	parm2_x;
	STORE_F	"' not found in database - ignored
",	parm3_x;
	CALL4		print;
	GOTO		15;
	ADDRESS	self,	descList,	locked_1174;
	INDIRECT_S	self,	descList,	temp_4;
	INDIRECT_S	lMapInfo,	normal,	temp_5;
	STORE_F	temp_4,	parm0_x;
	STORE_F	temp_5,	parm1_x;
	CALL2		Util_AltStringPushBack;
	STOREP_S	return_x,	locked_1174;
	ADDRESS	self,	valueList,	locked_1174;
	INDIRECT_S	self,	valueList,	temp_4;
	INDIRECT_S	lMapInfo,	link,	temp_5;
	STORE_F	temp_4,	parm0_x;
	STORE_F	temp_5,	parm1_x;
	CALL2		Util_AltStringPushBack;
	STOREP_S	return_x,	locked_1174;
	STORE_F	lCounter,	temp_4;
	ADD_F		lCounter,	FILE_APPEND,	lCounter;
	GOTO		-35;
	STORE_F	lEntry,	parm0_x;
	CALL1		String_Free;
	STORE_F	self,	parm0_x;
	CALL1		DataLink_Nex_MapList_UpdateRange;
	CALL0		Nex_MapSelector_Synchronize;
	DONE;
}

void () Item_DataLink_Nex_MapList_ExecString;
void() Item_DataLink_Nex_MapList_ExecString = asm
{
local float lIndex;
local float lCount;
local float temp_3;
local float temp_4;
	INDIRECT_S	self,	cvarName,	temp_3;
	INDIRECT_S	self,	cvarName,	temp_4;
	STORE_F	"set "",	parm0_x;
	STORE_F	temp_3,	parm1_x;
	STORE_F	"_index" "0"
set "",	parm2_x;
	STORE_F	temp_4,	parm3_x;
	STORE_F	""
"
",	parm4_x;
	CALL5		strcat;
	STORE_F	Data_ExecString,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Append;
	STORE_S	return_x,	Data_ExecString;
	INDIRECT_S	self,	valueList,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	STORE_F	KEY_GAME,	lIndex;
	LT		lIndex,	lCount,	temp_3;
	IFNOT		temp_3,	17;
	INDIRECT_S	self,	valueList,	parm0_x;
	STORE_F	lIndex,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	"'",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"'
",	parm2_x;
	CALL3		strcat;
	STORE_F	Data_ExecString,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Append;
	STORE_S	return_x,	Data_ExecString;
	STORE_F	lIndex,	temp_4;
	ADD_F		lIndex,	FILE_APPEND,	lIndex;
	GOTO		-17;
	STORE_F	Data_ExecString,	parm0_x;
	STORE_F	""
",	parm1_x;
	CALL2		String_Append;
	STORE_S	return_x,	Data_ExecString;
	DONE;
}

void(float pEvent) Item_DataLink_Nex_MapList_DataEvent = asm
{
local float locked_1174;
local float temp_4;
	GOTO		39;
	INDIRECT_S	self,	cvarName,	locked_1174;
	NE_S		locked_1174,	"",	locked_1174;
	IFNOT		locked_1174,	2;
	CALL0		Item_DataLink_Nex_MapList_Load;
	GOTO		49;
	INDIRECT_S	self,	cvarName,	locked_1174;
	NE_S		locked_1174,	"",	locked_1174;
	IFNOT		locked_1174,	2;
	CALL0		Item_DataLink_Nex_MapList_Save;
	GOTO		44;
	ADDRESS	self,	_realValue,	locked_1174;
	STOREP_F	FILE_APPEND,	locked_1174;
	GOTO		41;
	GOTO		40;
	GOTO		39;
	INDIRECT_S	self,	cvarName,	locked_1174;
	NE_S		locked_1174,	"",	locked_1174;
	IFNOT		locked_1174,	2;
	CALL0		Item_DataLink_Nex_MapList_ExecString;
	GOTO		34;
	ADDRESS	self,	_realValue,	locked_1174;
	INDIRECT_F	self,	_realValue,	parm0_x;
	CALL1		floor;
	STOREP_F	return_x,	locked_1174;
	INDIRECT_F	self,	_realValue,	locked_1174;
	LT		locked_1174,	FILE_APPEND,	locked_1174;
	IFNOT		locked_1174,	4;
	ADDRESS	self,	_realValue,	locked_1174;
	STOREP_F	FILE_APPEND,	locked_1174;
	GOTO		8;
	INDIRECT_F	self,	_realValue,	locked_1174;
	INDIRECT_F	self,	maxValue,	temp_4;
	GT		locked_1174,	temp_4,	locked_1174;
	IFNOT		locked_1174,	4;
	ADDRESS	self,	_realValue,	locked_1174;
	INDIRECT_F	self,	maxValue,	temp_4;
	STOREP_F	temp_4,	locked_1174;
	GOTO		16;
	IFNOT		pEvent,	-38;
	EQ_F		pEvent,	ITEM_DATA_SEND,	locked_1174;
	IF		locked_1174,	-35;
	EQ_F		pEvent,	ITEM_DATA_RESET,	locked_1174;
	IF		locked_1174,	-32;
	EQ_F		pEvent,	ITEM_DATA_TEST_START,	locked_1174;
	IF		locked_1174,	-31;
	EQ_F		pEvent,	ITEM_DATA_TEST_END,	locked_1174;
	IF		locked_1174,	-32;
	EQ_F		pEvent,	ITEM_DATA_SAVE_EXECSTRING,	locked_1174;
	IF		locked_1174,	-33;
	EQ_F		pEvent,	ITEM_DATALINK_SET,	locked_1174;
	IF		locked_1174,	-30;
	EQ_F		pEvent,	ITEM_DATALINK_GET,	locked_1174;
	IF		locked_1174,	-32;
	DONE;
}

void () IDLNML_Reinit;
void() IDLNML_Reinit = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	ITEM_DATA_SYNC,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Item_DataLink_Nex_MapList_Destroy;
void() Item_DataLink_Nex_MapList_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	valueList,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	cvarName,	parm1_x;
	CALL2		String_EntityFree;
	CALL0		Item_DataLink_Switch_Destroy;
	DONE;
}

void() Item_DataLink_Nex_MapList_Spawn = asm
{
local float temp_3;
	CALL0		Item_DataLink_Switch_Init;
	STORE_F	self,	parm0_x;
	STORE_F	valueList,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	cvarName,	parm1_x;
	CALL2		String_EntityZone;
	INDIRECT_S	self,	cvarName,	temp_3;
	NE_S		temp_3,	"",	temp_3;
	IFNOT		temp_3,	12;
	INDIRECT_S	self,	cvarName,	parm0_x;
	STORE_F	"",	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		registercvar;
	INDIRECT_S	self,	cvarName,	parm0_x;
	STORE_F	"_index",	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	STORE_F	"",	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		registercvar;
	ADDRESS	self,	minValue,	temp_3;
	STOREP_F	FILE_APPEND,	temp_3;
	ADDRESS	self,	maxValue,	temp_3;
	STOREP_F	FILE_APPEND,	temp_3;
	ADDRESS	self,	stepValue,	temp_3;
	STOREP_F	KEY_GAME,	temp_3;
	ADDRESS	self,	_reinit,	temp_3;
	STOREP_FNC	IDLNML_Reinit,	temp_3;
	ADDRESS	self,	_dataEvent,	temp_3;
	STOREP_FNC	Item_DataLink_Nex_MapList_DataEvent,	temp_3;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_DataLink_Nex_MapList_Destroy,	temp_3;
	CALL0		CtCall_Init;
	DONE;
}

void() Item_DataLink_Nex_MapList_InitWithMapList = asm
{
	CALL0		Nex_MapDB_GetPathAltString;
	STORE_F	self,	parm0_x;
	STORE_F	valueList,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		Nex_MapDB_GetNameAltString;
	STORE_F	self,	parm0_x;
	STORE_F	descList,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	self,	parm0_x;
	CALL1		DataLink_Nex_MapList_UpdateRange;
	DONE;
}

void(entity pItem) DataLink_Nex_MapList_UpdateRange = asm
{
local float locked_1174;
local float temp_4;
	ADDRESS	pItem,	minValue,	locked_1174;
	STOREP_F	FILE_APPEND,	locked_1174;
	ADDRESS	pItem,	maxValue,	locked_1174;
	INDIRECT_S	pItem,	descList,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STOREP_F	return_x,	locked_1174;
	INDIRECT_F	pItem,	maxValue,	locked_1174;
	GE		locked_1174,	FILE_APPEND,	locked_1174;
	IFNOT		locked_1174,	4;
	ADDRESS	pItem,	stepValue,	locked_1174;
	STOREP_F	FILE_APPEND,	locked_1174;
	GOTO		5;
	ADDRESS	pItem,	maxValue,	locked_1174;
	STOREP_F	FILE_APPEND,	locked_1174;
	ADDRESS	pItem,	stepValue,	locked_1174;
	STOREP_F	KEY_GAME,	locked_1174;
	DONE;
}

void(entity pItem, string pName, string pPath) DataLink_Nex_MapList_InsertEntryAfter = asm
{
local float locked_1174;
local float lIndex;
local float temp_4;
	STORE_F	pItem,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_F	pItem,	_realValue,	locked_1174;
	SUB_F		locked_1174,	FILE_APPEND,	lIndex;
	ADDRESS	pItem,	descList,	locked_1174;
	INDIRECT_S	pItem,	descList,	parm0_x;
	STORE_F	lIndex,	parm1_x;
	STORE_F	pName,	parm2_x;
	CALL3		Util_InsAltStringItem;
	STOREP_S	return_x,	locked_1174;
	ADDRESS	pItem,	valueList,	locked_1174;
	INDIRECT_S	pItem,	valueList,	parm0_x;
	STORE_F	lIndex,	parm1_x;
	STORE_F	pPath,	parm2_x;
	CALL3		Util_InsAltStringItem;
	STOREP_S	return_x,	locked_1174;
	STORE_F	pItem,	parm0_x;
	CALL1		DataLink_Nex_MapList_UpdateRange;
	DONE;
}

void(entity pItem) DataLink_Nex_MapList_DeleteEntry = asm
{
local float locked_1174;
local float lIndex;
local float temp_4;
	INDIRECT_F	pItem,	stepValue,	locked_1174;
	EQ_F		locked_1174,	KEY_GAME,	locked_1174;
	IFNOT		locked_1174,	2;
	RETURN	offset_0;
	STORE_F	pItem,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_F	pItem,	_realValue,	locked_1174;
	SUB_F		locked_1174,	FILE_APPEND,	lIndex;
	ADDRESS	pItem,	descList,	locked_1174;
	INDIRECT_S	pItem,	descList,	parm0_x;
	STORE_F	lIndex,	parm1_x;
	CALL2		Util_DelAltStringItem;
	STOREP_S	return_x,	locked_1174;
	ADDRESS	pItem,	valueList,	locked_1174;
	INDIRECT_S	pItem,	valueList,	parm0_x;
	STORE_F	lIndex,	parm1_x;
	CALL2		Util_DelAltStringItem;
	STOREP_S	return_x,	locked_1174;
	STORE_F	pItem,	parm0_x;
	CALL1		DataLink_Nex_MapList_UpdateRange;
	DONE;
}

void(entity pItem) DataLink_Nex_MapList_MoveEntryUp = asm
{
local float locked_1020;
local float locked_1174;
local float lIndexOld;
local float lIndexNew;
local string lPath;
local string lName;
	STORE_F	pItem,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_F	pItem,	_realValue,	locked_1174;
	EQ_F		locked_1174,	FILE_APPEND,	locked_1174;
	IFNOT		locked_1174,	2;
	RETURN	offset_0;
	INDIRECT_F	pItem,	_realValue,	locked_1174;
	SUB_F		locked_1174,	FILE_APPEND,	lIndexOld;
	SUB_F		lIndexOld,	KEY_MENU,	lIndexNew;
	INDIRECT_S	pItem,	descList,	parm0_x;
	STORE_F	lIndexOld,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_S	return_x,	lName;
	INDIRECT_S	pItem,	valueList,	parm0_x;
	STORE_F	lIndexOld,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_S	return_x,	lPath;
	ADDRESS	pItem,	descList,	locked_1174;
	INDIRECT_S	pItem,	descList,	locked_1020;
	STORE_F	lName,	parm0_x;
	CALL1		String_Normal;
	STORE_F	locked_1020,	parm0_x;
	STORE_F	lIndexNew,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		Util_InsAltStringItem;
	STOREP_S	return_x,	locked_1174;
	ADDRESS	pItem,	valueList,	locked_1174;
	INDIRECT_S	pItem,	valueList,	locked_1020;
	STORE_F	lPath,	parm0_x;
	CALL1		String_Normal;
	STORE_F	locked_1020,	parm0_x;
	STORE_F	lIndexNew,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		Util_InsAltStringItem;
	STOREP_S	return_x,	locked_1174;
	ADD_F		lIndexOld,	FILE_APPEND,	lIndexOld;
	ADDRESS	pItem,	descList,	locked_1174;
	INDIRECT_S	pItem,	descList,	parm0_x;
	STORE_F	lIndexOld,	parm1_x;
	CALL2		Util_DelAltStringItem;
	STOREP_S	return_x,	locked_1174;
	ADDRESS	pItem,	valueList,	locked_1174;
	INDIRECT_S	pItem,	valueList,	parm0_x;
	STORE_F	lIndexOld,	parm1_x;
	CALL2		Util_DelAltStringItem;
	STOREP_S	return_x,	locked_1174;
	STORE_F	pItem,	parm0_x;
	CALL1		DataLink_Nex_MapList_UpdateRange;
	DONE;
}

void(entity pItem) DataLink_Nex_MapList_MoveEntryDown = asm
{
local float locked_1020;
local float locked_1174;
local float lIndexOld;
local float lIndexNew;
local string lPath;
local string lName;
	STORE_F	pItem,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_F	pItem,	_realValue,	locked_1174;
	INDIRECT_F	pItem,	maxValue,	locked_1020;
	EQ_F		locked_1174,	locked_1020,	locked_1174;
	IFNOT		locked_1174,	2;
	RETURN	offset_0;
	INDIRECT_F	pItem,	_realValue,	locked_1174;
	SUB_F		locked_1174,	FILE_APPEND,	lIndexOld;
	ADD_F		lIndexOld,	FILE_APPEND,	lIndexNew;
	INDIRECT_S	pItem,	descList,	parm0_x;
	STORE_F	lIndexOld,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_S	return_x,	lName;
	INDIRECT_S	pItem,	valueList,	parm0_x;
	STORE_F	lIndexOld,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_S	return_x,	lPath;
	ADDRESS	pItem,	descList,	locked_1174;
	INDIRECT_S	pItem,	descList,	locked_1020;
	STORE_F	lName,	parm0_x;
	CALL1		String_Normal;
	STORE_F	locked_1020,	parm0_x;
	STORE_F	lIndexNew,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		Util_InsAltStringItem;
	STOREP_S	return_x,	locked_1174;
	ADDRESS	pItem,	valueList,	locked_1174;
	INDIRECT_S	pItem,	valueList,	locked_1020;
	STORE_F	lPath,	parm0_x;
	CALL1		String_Normal;
	STORE_F	locked_1020,	parm0_x;
	STORE_F	lIndexNew,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		Util_InsAltStringItem;
	STOREP_S	return_x,	locked_1174;
	ADDRESS	pItem,	descList,	locked_1174;
	INDIRECT_S	pItem,	descList,	parm0_x;
	STORE_F	lIndexOld,	parm1_x;
	CALL2		Util_DelAltStringItem;
	STOREP_S	return_x,	locked_1174;
	ADDRESS	pItem,	valueList,	locked_1174;
	INDIRECT_S	pItem,	valueList,	parm0_x;
	STORE_F	lIndexOld,	parm1_x;
	CALL2		Util_DelAltStringItem;
	STOREP_S	return_x,	locked_1174;
	STORE_F	pItem,	parm0_x;
	CALL1		DataLink_Nex_MapList_UpdateRange;
	DONE;
}

void(entity pItem, string pName, string pPath) DataLink_Nex_MapList_SetFirst = asm
{
local float locked_1174;
local float temp_4;
	INDIRECT_F	pItem,	stepValue,	locked_1174;
	EQ_F		locked_1174,	KEY_GAME,	locked_1174;
	IFNOT		locked_1174,	12;
	ADDRESS	pItem,	descList,	locked_1174;
	INDIRECT_S	pItem,	descList,	parm0_x;
	STORE_F	pName,	parm1_x;
	CALL2		Util_AltStringPush;
	STOREP_S	return_x,	locked_1174;
	ADDRESS	pItem,	valueList,	locked_1174;
	INDIRECT_S	pItem,	valueList,	parm0_x;
	STORE_F	pPath,	parm1_x;
	CALL2		Util_AltStringPush;
	STOREP_S	return_x,	locked_1174;
	GOTO		13;
	ADDRESS	pItem,	descList,	locked_1174;
	INDIRECT_S	pItem,	descList,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	pName,	parm2_x;
	CALL3		Util_SetAltStringItem;
	STOREP_S	return_x,	locked_1174;
	ADDRESS	pItem,	valueList,	locked_1174;
	INDIRECT_S	pItem,	valueList,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	pPath,	parm2_x;
	CALL3		Util_SetAltStringItem;
	STOREP_S	return_x,	locked_1174;
	STORE_F	pItem,	parm0_x;
	CALL1		DataLink_Nex_MapList_UpdateRange;
	DONE;
}

void(entity pItem) DataLink_Nex_MapList_Clear = asm
{
	STORE_F	pItem,	parm0_x;
	STORE_F	descList,	parm1_x;
	STORE_F	"",	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	pItem,	parm0_x;
	STORE_F	valueList,	parm1_x;
	STORE_F	"",	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	pItem,	parm0_x;
	CALL1		DataLink_Nex_MapList_UpdateRange;
	DONE;
}

string(entity pItem) DataLink_Nex_MapList_GetCurrentName = asm
{
local float temp_3;
local float temp_4;
	STORE_F	pItem,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_S	pItem,	descList,	temp_3;
	INDIRECT_F	pItem,	_realValue,	temp_4;
	SUB_F		temp_4,	FILE_APPEND,	temp_4;
	STORE_F	temp_3,	parm0_x;
	STORE_F	temp_4,	parm1_x;
	CALL2		Util_GetAltStringItem;
	RETURN	return_x;
	DONE;
}

string(entity pItem) DataLink_Nex_MapList_GetCurrentPath = asm
{
local float temp_3;
local float temp_4;
	STORE_F	pItem,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_S	pItem,	valueList,	temp_3;
	INDIRECT_F	pItem,	_realValue,	temp_4;
	SUB_F		temp_4,	FILE_APPEND,	temp_4;
	STORE_F	temp_3,	parm0_x;
	STORE_F	temp_4,	parm1_x;
	CALL2		Util_GetAltStringItem;
	RETURN	return_x;
	DONE;
}

void () _IDLNMS_Build;
void() _IDLNMS_Build = asm
{
local string lLine;
local string lModPath;
local string lModName;
local string lFilename;
local float lHandle;
local float lSearchCounter;
local float lSearchSize;
local float lSearchHandle;
local float temp_3;
	STORE_F	"/*.modinfo",	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		search_begin;
	STORE_F	return_x,	lSearchHandle;
	LT		lSearchHandle,	KEY_GAME,	temp_3;
	IFNOT		temp_3,	10;
	STORE_F	self,	parm0_x;
	STORE_F	valueList,	parm1_x;
	STORE_F	"'progs.dat'",	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	self,	parm0_x;
	STORE_F	descList,	parm1_x;
	STORE_F	"'Deathmatch'",	parm2_x;
	CALL3		String_EntitySet;
	RETURN	offset_0;
	STORE_F	lSearchHandle,	parm0_x;
	CALL1		search_getsize;
	STORE_F	return_x,	lSearchSize;
	STORE_F	KEY_GAME,	lSearchCounter;
	LT		lSearchCounter,	lSearchSize,	temp_3;
	IFNOT		temp_3,	71;
	STORE_F	lSearchHandle,	parm0_x;
	STORE_F	lSearchCounter,	parm1_x;
	CALL2		search_getfilename;
	STORE_S	return_x,	lFilename;
	STORE_F	lFilename,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	100000.000000,	parm2_x;
	CALL3		substring;
	STORE_F	return_x,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		fopen;
	STORE_F	return_x,	lHandle;
	LT		lHandle,	KEY_GAME,	temp_3;
	IFNOT		temp_3,	6;
	STORE_F	"Menu: Couldn't open modinfo file '",	parm0_x;
	STORE_F	lFilename,	parm1_x;
	STORE_F	"'
",	parm2_x;
	CALL3		print;
	GOTO		50;
	CALL0		String_Create;
	STORE_S	return_x,	lModPath;
	CALL0		String_Create;
	STORE_S	return_x,	lModName;
	STORE_F	lHandle,	parm0_x;
	CALL1		fgets;
	STORE_S	return_x,	lLine;
	STORE_F	lLine,	parm0_x;
	CALL1		validstring;
	IF		return_x,	2;
	GOTO		33;
	STORE_F	lModPath,	parm0_x;
	STORE_F	lLine,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	lModPath;
	STORE_F	lHandle,	parm0_x;
	CALL1		fgets;
	STORE_S	return_x,	lLine;
	STORE_F	lLine,	parm0_x;
	CALL1		validstring;
	IF		return_x,	2;
	GOTO		22;
	STORE_F	lModName,	parm0_x;
	STORE_F	lLine,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	lModName;
	INDIRECT_S	self,	valueList,	parm0_x;
	STORE_F	lModPath,	parm1_x;
	STORE_F	" ",	parm2_x;
	CALL3		strcat;
	STORE_F	self,	parm0_x;
	STORE_F	valueList,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	descList,	parm0_x;
	STORE_F	lModName,	parm1_x;
	STORE_F	" ",	parm2_x;
	CALL3		strcat;
	STORE_F	self,	parm0_x;
	STORE_F	descList,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		-38;
	STORE_F	lModPath,	parm0_x;
	CALL1		String_Free;
	STORE_F	lModName,	parm0_x;
	CALL1		String_Free;
	STORE_F	lHandle,	parm0_x;
	CALL1		fclose;
	ADD_F		lSearchCounter,	FILE_APPEND,	lSearchCounter;
	GOTO		-71;
	STORE_F	lSearchHandle,	parm0_x;
	CALL1		search_end;
	DONE;
}

void() Item_DataLink_Nex_ModSwitch_Spawn = asm
{
local string lTemp2;
local string lTemp1;
local float temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	valueList,	parm1_x;
	CALL2		String_EntityCreate;
	STORE_F	self,	parm0_x;
	STORE_F	descList,	parm1_x;
	CALL2		String_EntityCreate;
	CALL0		_IDLNMS_Build;
	INDIRECT_S	self,	descList,	lTemp1;
	INDIRECT_S	self,	valueList,	lTemp2;
	CALL0		Item_DataLink_TextSwitch_Spawn;
	STORE_F	lTemp1,	parm0_x;
	CALL1		String_Free;
	STORE_F	lTemp2,	parm0_x;
	CALL1		String_Free;
	DONE;
}

void () IDLNFL_Sync;
void() IDLNFL_Sync = asm
{
local float locked_1020;
local float locked_1174;
local string lFilename;
local float lCounter;
local float lMaskedLength;
local float lMaskStart;
local float lHandle;
local float lCount;
local float temp_5;
	INDIRECT_S	self,	selected,	locked_1174;
	INDIRECT_S	self,	normal,	locked_1020;
	STORE_F	locked_1174,	parm0_x;
	STORE_F	"/*.",	parm1_x;
	STORE_F	locked_1020,	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		search_begin;
	STORE_F	return_x,	lHandle;
	LT		lHandle,	KEY_GAME,	locked_1174;
	IFNOT		locked_1174,	2;
	RETURN	offset_0;
	STORE_F	lHandle,	parm0_x;
	CALL1		search_getsize;
	STORE_F	return_x,	lCount;
	STORE_F	self,	parm0_x;
	STORE_F	valueList,	parm1_x;
	STORE_F	"",	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	self,	parm0_x;
	STORE_F	descList,	parm1_x;
	STORE_F	"",	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	selected,	parm0_x;
	CALL1		strlen;
	ADD_F		return_x,	FILE_APPEND,	lMaskStart;
	INDIRECT_S	self,	normal,	parm0_x;
	CALL1		strlen;
	ADD_F		lMaskStart,	return_x,	locked_1174;
	ADD_F		locked_1174,	FILE_APPEND,	lMaskedLength;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	locked_1174;
	IFNOT		locked_1174,	26;
	STORE_F	lHandle,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		search_getfilename;
	STORE_S	return_x,	lFilename;
	ADDRESS	self,	valueList,	locked_1174;
	INDIRECT_S	self,	valueList,	parm0_x;
	STORE_F	lFilename,	parm1_x;
	CALL2		Util_AltStringPushBack;
	STOREP_S	return_x,	locked_1174;
	ADDRESS	self,	descList,	locked_1174;
	INDIRECT_S	self,	descList,	locked_1020;
	STORE_F	lFilename,	parm0_x;
	CALL1		strlen;
	SUB_F		return_x,	lMaskedLength,	temp_5;
	STORE_F	lFilename,	parm0_x;
	STORE_F	lMaskStart,	parm1_x;
	STORE_F	temp_5,	parm2_x;
	CALL3		substring;
	STORE_F	locked_1020,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Util_AltStringPushBack;
	STOREP_S	return_x,	locked_1174;
	STORE_F	lCounter,	locked_1020;
	ADD_F		lCounter,	FILE_APPEND,	lCounter;
	GOTO		-26;
	ADDRESS	self,	minValue,	locked_1174;
	STOREP_F	KEY_GAME,	locked_1174;
	GT		lCount,	KEY_GAME,	locked_1174;
	IFNOT		locked_1174,	7;
	ADDRESS	self,	stepValue,	locked_1174;
	STOREP_F	FILE_APPEND,	locked_1174;
	ADDRESS	self,	maxValue,	locked_1174;
	SUB_F		lCount,	FILE_APPEND,	locked_1020;
	STOREP_F	locked_1020,	locked_1174;
	GOTO		5;
	ADDRESS	self,	stepValue,	locked_1174;
	STOREP_F	KEY_GAME,	locked_1174;
	ADDRESS	self,	maxValue,	locked_1174;
	STOREP_F	KEY_GAME,	locked_1174;
	DONE;
}

void() Item_DataLink_Nex_FileList_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	valueList,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	selected,	parm1_x;
	CALL2		String_EntityFree;
	CALL0		Item_DataLink_Switch_Destroy;
	DONE;
}

void(float pEvent) Item_DataLink_Nex_FileList_DataEvent = asm
{
local float temp_3;
	GOTO		7;
	CALL0		IDLNFL_Sync;
	GOTO		8;
	CALL0		IDLNFL_Sync;
	ADDRESS	self,	_realValue,	temp_3;
	STOREP_F	KEY_GAME,	temp_3;
	GOTO		4;
	IFNOT		pEvent,	-6;
	EQ_F		pEvent,	ITEM_DATA_RESET,	temp_3;
	IF		temp_3,	-6;
	DONE;
}

void() Item_DataLink_Nex_FileList_Spawn = asm
{
local float temp_3;
	CALL0		Item_DataLink_Switch_Init;
	STORE_F	self,	parm0_x;
	STORE_F	valueList,	parm1_x;
	CALL2		String_EntityCreate;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	selected,	parm1_x;
	CALL2		String_EntityZone;
	ADDRESS	self,	_reinit,	temp_3;
	STOREP_FNC	IDLNFL_Sync,	temp_3;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_DataLink_Nex_FileList_Destroy,	temp_3;
	ADDRESS	self,	_dataEvent,	temp_3;
	STOREP_FNC	Item_DataLink_Nex_FileList_DataEvent,	temp_3;
	DONE;
}

void(entity pItem) Nex_MakeOnlyVisible = asm
{
local entity lChild;
local float temp_3;
local float temp_4;
	INDIRECT_E	pItem,	_parent,	temp_3;
	INDIRECT_E	temp_3,	_child,	lChild;
	IFNOT		lChild,	7;
	ADDRESS	lChild,	flag,	temp_3;
	INDIRECT_F	lChild,	flag,	temp_4;
	BITOR		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-6;
	ADDRESS	pItem,	flag,	temp_3;
	INDIRECT_F	pItem,	flag,	temp_4;
	SUB_F		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	CALL0		Menu_UpdateRunFlags;
	DONE;
}

void () _IDNK_Sync;
void() _IDNK_Sync = asm
{
local float temp_3;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		Key_GetBindList;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () _IDNK_Set;
void() _IDNK_Set = asm
{
local float lCounter;
local float lCount;
local float temp_3;
	INDIRECT_S	self,	value,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	INDIRECT_S	self,	target,	temp_3;
	STORE_F	KEY_GAME,	parm0_x;
	STORE_F	temp_3,	parm1_x;
	CALL2		Key_LimitBinds;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	temp_3;
	IFNOT		temp_3,	16;
	INDIRECT_S	self,	value,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	return_x,	parm0_x;
	CALL1		stof;
	STORE_F	return_x,	parm0_x;
	CALL1		Key_GetName;
	INDIRECT_S	self,	target,	temp_3;
	STORE_F	return_x,	parm0_x;
	STORE_F	temp_3,	parm1_x;
	CALL2		Key_Bind;
	ADD_F		lCounter,	FILE_APPEND,	lCounter;
	GOTO		-16;
	DONE;
}

void () _IDNK_Send;
void() _IDNK_Send = asm
{
local float temp_3;
	CALL0		_IDNK_Set;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () _IDNK_Reset;
void() _IDNK_Reset = asm
{
local float locked_1174;
local string lKey;
local float lCounter;
local float lCount;
local float temp_4;
	INDIRECT_S	self,	defValue,	locked_1174;
	NOT_S		locked_1174,	locked_1174;
	IFNOT		locked_1174,	2;
	RETURN	offset_0;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	"",	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	defValue,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	INDIRECT_S	self,	target,	locked_1174;
	STORE_F	KEY_GAME,	parm0_x;
	STORE_F	locked_1174,	parm1_x;
	CALL2		Key_LimitBinds;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	locked_1174;
	IFNOT		locked_1174,	26;
	INDIRECT_S	self,	defValue,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_S	return_x,	lKey;
	INDIRECT_S	self,	target,	locked_1174;
	STORE_F	lKey,	parm0_x;
	STORE_F	locked_1174,	parm1_x;
	CALL2		Key_Bind;
	INDIRECT_S	self,	value,	locked_1174;
	STORE_F	lKey,	parm0_x;
	CALL1		Key_GetNum;
	STORE_F	locked_1174,	parm0_x;
	STORE_F	" '",	parm1_x;
	STORE_F	return_x,	parm2_x;
	STORE_F	"'",	parm3_x;
	CALL4		strcat;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	STORE_F	lKey,	parm0_x;
	CALL1		String_Free;
	STORE_F	lCounter,	temp_4;
	ADD_F		lCounter,	FILE_APPEND,	lCounter;
	GOTO		-26;
	INDIRECT_S	self,	value,	locked_1174;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	locked_1174,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () _IDNK_Test_Start;
void() _IDNK_Test_Start = asm
{
	CALL0		_IDNK_Set;
	DONE;
}

void () _IDNK_Test_End;
void() _IDNK_Test_End = asm
{
local float temp_3;
	INDIRECT_S	self,	_syncValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		_IDNK_Set;
	DONE;
}

void(float pEvent) Item_Data_Nex_Key_DataEvent = asm
{
local float temp_3;
	GOTO		11;
	CALL0		_IDNK_Sync;
	GOTO		18;
	CALL0		_IDNK_Send;
	GOTO		16;
	CALL0		_IDNK_Reset;
	GOTO		14;
	CALL0		_IDNK_Test_Start;
	GOTO		12;
	CALL0		_IDNK_Test_End;
	GOTO		10;
	IFNOT		pEvent,	-10;
	EQ_F		pEvent,	ITEM_DATA_SEND,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_RESET,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_TEST_START,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_TEST_END,	temp_3;
	IF		temp_3,	-10;
	DONE;
}

void () Item_Data_Nex_Key_Destroy;
void() Item_Data_Nex_Key_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityFree;
	CALL0		Item_Data_Destroy;
	DONE;
}

void() Item_Data_Nex_Key_Spawn = asm
{
local float temp_3;
	CALL0		Item_Data_Init;
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityZone;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_Data_Nex_Key_Destroy,	temp_3;
	ADDRESS	self,	_reinit,	temp_3;
	STOREP_FNC	_IDNK_Sync,	temp_3;
	ADDRESS	self,	_dataEvent,	temp_3;
	STOREP_FNC	Item_Data_Nex_Key_DataEvent,	temp_3;
	DONE;
}

float (float, float) Item_Nex_KeyButton_Key;
float(float pKey, float pAscii) Item_Nex_KeyButton_Key = asm
{
local float lNum;
local float temp_3;
	EQ_F		pKey,	K_BACKSPACE,	temp_3;
	IFNOT		temp_3,	19;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_E	self,	_target,	temp_3;
	INDIRECT_S	temp_3,	value,	parm0_x;
	CALL1		stof;
	STORE_F	return_x,	lNum;
	GE		lNum,	KEY_GAME,	temp_3;
	IFNOT		temp_3,	8;
	STORE_F	lNum,	parm0_x;
	CALL1		Key_GetName;
	STORE_F	return_x,	parm0_x;
	CALL1		Key_Unbind;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	RETURN	FILE_APPEND;
	GOTO		21;
	EQ_F		pKey,	K_UPARROW,	temp_3;
	IFNOT		temp_3,	7;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		Menu_SelectPrev;
	STORE_F	FILE_APPEND,	parm0_x;
	CALL1		Menu_SelectPrev;
	RETURN	FILE_APPEND;
	GOTO		13;
	EQ_F		pKey,	K_DOWNARROW,	temp_3;
	IFNOT		temp_3,	7;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		Menu_SelectNext;
	STORE_F	FILE_APPEND,	parm0_x;
	CALL1		Menu_SelectNext;
	RETURN	FILE_APPEND;
	GOTO		5;
	STORE_F	pKey,	parm0_x;
	STORE_F	pAscii,	parm1_x;
	CALL2		Item_Button_Key;
	RETURN	return_x;
	DONE;
}

void () Item_Nex_KeyButton_Update;
void() Item_Nex_KeyButton_Update = asm
{
local float lNum;
local float temp_3;
	CALL0		Item_DataUser_Update;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_E	self,	_target,	temp_3;
	INDIRECT_S	temp_3,	value,	parm0_x;
	CALL1		stof;
	STORE_F	return_x,	lNum;
	LT		lNum,	KEY_GAME,	temp_3;
	IFNOT		temp_3,	6;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	STORE_F	"-",	parm2_x;
	CALL3		String_EntitySet;
	GOTO		7;
	STORE_F	lNum,	parm0_x;
	CALL1		Key_GetName;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		Item_Button_Update;
	DONE;
}

void () Item_Nex_KeyButton_Destroy;
void() Item_Nex_KeyButton_Destroy = asm
{
	CALL0		Item_DataUser_Destroy;
	CALL0		Item_Button_Destroy;
	DONE;
}

void() Item_Nex_KeyButton_Spawn = asm
{
local float temp_3;
	CALL0		Item_DataUser_Init;
	CALL0		Item_Button_Spawn;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_Nex_KeyButton_Destroy,	temp_3;
	ADDRESS	self,	_update,	temp_3;
	STOREP_FNC	Item_Nex_KeyButton_Update,	temp_3;
	ADDRESS	self,	_key,	temp_3;
	STOREP_FNC	Item_Nex_KeyButton_Key,	temp_3;
	DONE;
}

void () _IDNR_Sync;
void() _IDNR_Sync = asm
{
local float temp_3;
local float temp_4;
	STORE_F	"vid_width",	parm0_x;
	CALL1		str_cvar;
	STORE_F	"vid_height",	parm0_x;
	STORE_F	return_x,	temp_3;
	CALL1		str_cvar;
	STORE_F	return_x,	temp_4;
	STORE_F	temp_3,	return_x;
	STORE_F	return_x,	parm0_x;
	STORE_F	" ",	parm1_x;
	STORE_F	temp_4,	parm2_x;
	CALL3		strcat;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () _IDNR_Set;
void() _IDNR_Set = asm
{
local float temp_3;
	INDIRECT_S	self,	value,	parm0_x;
	CALL1		tokenize;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		argv;
	STORE_F	"vid_width",	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		cvar_set;
	STORE_F	FILE_APPEND,	parm0_x;
	CALL1		argv;
	STORE_F	"vid_height",	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		cvar_set;
	DONE;
}

void () _IDNR_Send;
void() _IDNR_Send = asm
{
	CALL0		_IDNR_Set;
	CALL0		_IDNR_Sync;
	DONE;
}

void () _IDNR_Reset;
void() _IDNR_Reset = asm
{
local float temp_3;
	INDIRECT_S	self,	defValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		_IDNR_Send;
	DONE;
}

void () _IDNR_Test_Start;
void() _IDNR_Test_Start = asm
{
	CALL0		_IDNR_Set;
	DONE;
}

void () _IDNR_Test_End;
void() _IDNR_Test_End = asm
{
local float temp_3;
	INDIRECT_S	self,	_syncValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		_IDNR_Send;
	DONE;
}

void (float) Item_Data_Nex_Resolution_DataEvent;
void(float pEvent) Item_Data_Nex_Resolution_DataEvent = asm
{
local float temp_3;
	GOTO		11;
	CALL0		_IDNR_Sync;
	GOTO		18;
	CALL0		_IDNR_Send;
	GOTO		16;
	CALL0		_IDNR_Reset;
	GOTO		14;
	CALL0		_IDNR_Test_Start;
	GOTO		12;
	CALL0		_IDNR_Test_End;
	GOTO		10;
	IFNOT		pEvent,	-10;
	EQ_F		pEvent,	ITEM_DATA_SEND,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_RESET,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_TEST_START,	temp_3;
	IF		temp_3,	-10;
	EQ_F		pEvent,	ITEM_DATA_TEST_END,	temp_3;
	IF		temp_3,	-10;
	DONE;
}

void() Item_Data_Nex_Resolution_Spawn = asm
{
local float temp_3;
	CALL0		Item_Data_Init;
	ADDRESS	self,	_dataEvent,	temp_3;
	STOREP_FNC	Item_Data_Nex_Resolution_DataEvent,	temp_3;
	ADDRESS	self,	_reinit,	temp_3;
	STOREP_FNC	_IDNR_Sync,	temp_3;
	DONE;
}

void() Item_Nex_HostCache_Entry_Update = asm
{
local float temp_3;
local float temp_4;
	INDIRECT_F	self,	stepValue,	temp_3;
	LE		HostCache_ViewCount,	temp_3,	temp_3;
	IFNOT		temp_3,	7;
	ADDRESS	self,	flag,	temp_3;
	INDIRECT_F	self,	flag,	temp_4;
	BITOR		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	RETURN	offset_0;
	GOTO		8;
	INDIRECT_F	self,	flag,	temp_3;
	BITAND	temp_3,	FLAG_HIDDEN,	temp_3;
	IFNOT		temp_3,	5;
	ADDRESS	self,	flag,	temp_3;
	INDIRECT_F	self,	flag,	temp_4;
	SUB_F		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	INDIRECT_F	self,	_runFlag,	temp_3;
	BITAND	temp_3,	RUNFLAG_CLIPPED,	temp_3;
	IFNOT		temp_3,	2;
	RETURN	offset_0;
	CALL0		Item_Button_Update;
	DONE;
}

void () Item_Nex_HostCache_Entry_Draw;
void() Item_Nex_HostCache_Entry_Draw = asm
{
	CALL0		Item_Window_Draw;
	CALL0		Item_Button_Draw;
	DONE;
}

void() Item_Nex_HostCache_Entry_Spawn = asm
{
local float temp_3;
local float temp_4;
	CALL0		Item_Window_Spawn;
	CALL0		Item_Button_Spawn;
	ADDRESS	self,	flag,	temp_3;
	INDIRECT_F	self,	flag,	temp_4;
	BITOR		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	INDIRECT_F	self,	flag,	temp_3;
	BITAND	temp_3,	FLAG_NOSELECT,	temp_3;
	IFNOT		temp_3,	5;
	ADDRESS	self,	flag,	temp_3;
	INDIRECT_F	self,	flag,	temp_4;
	SUB_F		temp_4,	FLAG_NOSELECT,	temp_4;
	STOREP_F	temp_4,	temp_3;
	ADDRESS	self,	_draw,	temp_3;
	STOREP_FNC	Item_Nex_HostCache_Entry_Draw,	temp_3;
	ADDRESS	self,	_update,	temp_3;
	STOREP_FNC	Item_Nex_HostCache_Entry_Update,	temp_3;
	DONE;
}

void() Item_Nex_HostCache_StringField_Update = asm
{
local string lString;
local float lMaxLen;
local float temp_3;
local float temp_4;
	INDIRECT_E	self,	_parent,	temp_3;
	INDIRECT_F	temp_3,	stepValue,	temp_3;
	LE		HostCache_ViewCount,	temp_3,	temp_3;
	IFNOT		temp_3,	2;
	RETURN	offset_0;
	INDIRECT_F	self,	size_x,	temp_3;
	INDIRECT_F	self,	fontSize_x,	temp_4;
	DIV_F		temp_3,	temp_4,	parm0_x;
	CALL1		floor;
	STORE_F	return_x,	lMaxLen;
	INDIRECT_F	self,	_realValue,	temp_3;
	INDIRECT_E	self,	_parent,	temp_4;
	INDIRECT_F	temp_4,	stepValue,	temp_4;
	STORE_F	temp_3,	parm0_x;
	STORE_F	temp_4,	parm1_x;
	CALL2		gethostcachestring;
	STORE_S	return_x,	lString;
	STORE_F	lString,	parm0_x;
	CALL1		strlen;
	LT		lMaxLen,	return_x,	temp_3;
	IFNOT		temp_3,	10;
	SUB_F		lMaxLen,	KEY_UNKNOWN,	temp_3;
	STORE_F	lString,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		substring;
	STORE_F	return_x,	parm0_x;
	STORE_F	"...",	parm1_x;
	CALL2		strcat;
	STORE_S	return_x,	lString;
	STORE_F	self,	parm0_x;
	STORE_F	text,	parm1_x;
	STORE_F	lString,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		Item_Label_Update;
	DONE;
}

void() Item_Nex_HostCache_StringField_Spawn = asm
{
local float locked_1174;
local float temp_4;
	CALL0		Item_Label_Spawn;
	ADDRESS	self,	_realValue,	locked_1174;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		gethostcacheindexforkey;
	STOREP_F	return_x,	locked_1174;
	ADDRESS	self,	_update,	locked_1174;
	STOREP_FNC	Item_Nex_HostCache_StringField_Update,	locked_1174;
	DONE;
}

void() Item_Nex_HostCache_ValueField_Update = asm
{
local float temp_3;
local float temp_4;
	INDIRECT_E	self,	_parent,	temp_3;
	INDIRECT_F	temp_3,	stepValue,	temp_3;
	LE		HostCache_ViewCount,	temp_3,	temp_3;
	IFNOT		temp_3,	2;
	RETURN	offset_0;
	INDIRECT_F	self,	_realValue,	temp_3;
	INDIRECT_E	self,	_parent,	temp_4;
	INDIRECT_F	temp_4,	stepValue,	temp_4;
	STORE_F	temp_3,	parm0_x;
	STORE_F	temp_4,	parm1_x;
	CALL2		gethostcachenumber;
	STORE_F	return_x,	parm0_x;
	CALL1		ftos;
	STORE_F	self,	parm0_x;
	STORE_F	text,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		Item_Label_Update;
	DONE;
}

void() Item_Nex_HostCache_ValueField_Spawn = asm
{
local float locked_1174;
local float temp_4;
	CALL0		Item_Label_Spawn;
	ADDRESS	self,	_realValue,	locked_1174;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		gethostcacheindexforkey;
	STOREP_F	return_x,	locked_1174;
	ADDRESS	self,	_update,	locked_1174;
	STOREP_FNC	Item_Nex_HostCache_ValueField_Update,	locked_1174;
	DONE;
}

void() Item_Nex_HostCache_Players_Update = asm
{
local string lMax;
local string lNum;
local float temp_3;
	INDIRECT_E	self,	_parent,	temp_3;
	INDIRECT_F	temp_3,	stepValue,	temp_3;
	LE		HostCache_ViewCount,	temp_3,	temp_3;
	IFNOT		temp_3,	2;
	RETURN	offset_0;
	INDIRECT_E	self,	_parent,	temp_3;
	INDIRECT_F	temp_3,	stepValue,	temp_3;
	STORE_F	SLIST_FIELD_NUMPLAYERS,	parm0_x;
	STORE_F	temp_3,	parm1_x;
	CALL2		gethostcachenumber;
	STORE_F	return_x,	parm0_x;
	CALL1		ftos;
	STORE_S	return_x,	lNum;
	INDIRECT_E	self,	_parent,	temp_3;
	INDIRECT_F	temp_3,	stepValue,	temp_3;
	STORE_F	SLIST_FIELD_MAXPLAYERS,	parm0_x;
	STORE_F	temp_3,	parm1_x;
	CALL2		gethostcachenumber;
	STORE_F	return_x,	parm0_x;
	CALL1		ftos;
	STORE_S	return_x,	lMax;
	STORE_F	lNum,	parm0_x;
	STORE_F	"/",	parm1_x;
	STORE_F	lMax,	parm2_x;
	CALL3		strcat;
	STORE_F	self,	parm0_x;
	STORE_F	text,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		Item_Label_Update;
	DONE;
}

void() Item_Nex_HostCache_Players_Spawn = asm
{
local float temp_3;
	CALL0		Item_Label_Spawn;
	ADDRESS	self,	_update,	temp_3;
	STOREP_FNC	Item_Nex_HostCache_Players_Update,	temp_3;
	DONE;
}

void() Item_Nex_Credits_Spawn = asm
{
local string lLine;
local string lText;
local float lFile;
local float temp_3;
	INDIRECT_S	self,	target,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		fopen;
	STORE_F	return_x,	lFile;
	LT		lFile,	KEY_GAME,	temp_3;
	IFNOT		temp_3,	4;
	STORE_F	self,	parm0_x;
	CALL1		Menu_DeleteAfterToggle;
	RETURN	offset_0;
	CALL0		String_Create;
	STORE_S	return_x,	lText;
	STORE_F	lFile,	parm0_x;
	CALL1		fgets;
	STORE_S	return_x,	lLine;
	STORE_F	lLine,	parm0_x;
	STORE_F	"
",	parm1_x;
	CALL2		strcat;
	STORE_F	lText,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Append;
	STORE_S	return_x,	lText;
	STORE_F	lLine,	parm0_x;
	CALL1		validstring;
	IF		return_x,	-12;
	ADDRESS	self,	text,	temp_3;
	STOREP_S	lText,	temp_3;
	STORE_F	lFile,	parm0_x;
	CALL1		fclose;
	CALL0		Item_MultiLabel_Spawn;
	STORE_F	lText,	parm0_x;
	CALL1		String_Free;
	DONE;
}

void () Nex_MessageBox_LeftEvent;
void () Nex_MessageBox_RightEvent;
void(string pTitle, string pText, string pLeftButton, string pRightButton, void () pLeftEvent, void () pRightEvent) Nex_MessageBox = asm
{
local entity lItem;
local vector temp_0;
local float temp_3;
local float temp_4;
	STORE_F	"MessageBoxWnd::Layout::Title::Caption",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	lItem,	parm0_x;
	STORE_F	normal,	parm1_x;
	STORE_F	pTitle,	parm2_x;
	CALL3		String_EntitySet;
	ADDRESS	lItem,	size_x,	temp_0_x;
	STOREP_V	'0.000000 0.000000 0.000000',	temp_0;
	STORE_F	"MessageBoxWnd::Layout::Text",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	lItem,	parm0_x;
	STORE_F	text,	parm1_x;
	STORE_F	pText,	parm2_x;
	CALL3		String_EntitySet;
	ADDRESS	lItem,	size_x,	temp_0_x;
	STOREP_V	'0.000000 0.000000 0.000000',	temp_0;
	STORE_F	"MessageBoxWnd::Layout::Buttons::Left",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	lItem,	parm0_x;
	STORE_F	normal,	parm1_x;
	STORE_F	pLeftButton,	parm2_x;
	CALL3		String_EntitySet;
	ADDRESS	lItem,	size_x,	temp_0_x;
	STOREP_V	'0.000000 0.000000 0.000000',	temp_0;
	STORE_F	"MessageBoxWnd::Layout::Buttons::Right",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	STORE_F	lItem,	parm0_x;
	STORE_F	normal,	parm1_x;
	STORE_F	pRightButton,	parm2_x;
	CALL3		String_EntitySet;
	ADDRESS	lItem,	size_x,	temp_0_x;
	STOREP_V	'0.000000 0.000000 0.000000',	temp_0;
	STORE_F	pRightButton,	parm0_x;
	CALL1		strlen;
	EQ_F		return_x,	KEY_GAME,	temp_3;
	IFNOT		temp_3,	6;
	ADDRESS	lItem,	flag,	temp_3;
	INDIRECT_F	lItem,	flag,	temp_4;
	BITOR		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	GOTO		8;
	INDIRECT_F	lItem,	flag,	temp_3;
	BITAND	temp_3,	FLAG_HIDDEN,	temp_3;
	IFNOT		temp_3,	5;
	ADDRESS	lItem,	flag,	temp_3;
	INDIRECT_F	lItem,	flag,	temp_4;
	SUB_F		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	STORE_FNC	pLeftEvent,	Nex_MessageBox_LeftEvent;
	STORE_FNC	pRightEvent,	Nex_MessageBox_RightEvent;
	STORE_F	"MessageBoxWnd",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lItem;
	INDIRECT_F	lItem,	flag,	temp_3;
	BITAND	temp_3,	FLAG_HIDDEN,	temp_3;
	IFNOT		temp_3,	5;
	ADDRESS	lItem,	flag,	temp_3;
	INDIRECT_F	lItem,	flag,	temp_4;
	SUB_F		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	STORE_F	"MessageBoxWnd::Layout::Buttons::Right",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_F	return_x,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		Menu_Select;
	DONE;
}

void () Nex_MessageBox_Hide;
void() Nex_MessageBox_Hide = asm
{
local entity lEntity;
local float temp_3;
local float temp_4;
	STORE_F	"MessageBoxWnd",	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lEntity;
	INDIRECT_F	lEntity,	flag,	temp_3;
	BITAND	temp_3,	FLAG_HIDDEN,	temp_3;
	IF		temp_3,	7;
	ADDRESS	lEntity,	flag,	temp_3;
	INDIRECT_F	lEntity,	flag,	temp_4;
	ADD_F		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		Menu_Reselect;
	DONE;
}

void () Nex_MessageBox_LeftButton;
void() Nex_MessageBox_LeftButton = asm
{
	IFNOT		Nex_MessageBox_LeftEvent,	2;
	CALL0		Nex_MessageBox_LeftEvent;
	CALL0		Nex_MessageBox_Hide;
	DONE;
}

void () Nex_MessageBox_RightButton;
void() Nex_MessageBox_RightButton = asm
{
	IFNOT		Nex_MessageBox_RightEvent,	2;
	CALL0		Nex_MessageBox_RightEvent;
	CALL0		Nex_MessageBox_Hide;
	DONE;
}

float (float, float) Nex_MessageBox_Key;
float(float pKey, float pAscii) Nex_MessageBox_Key = asm
{
local float temp_3;
	EQ_F		pKey,	K_ESCAPE,	temp_3;
	IFNOT		temp_3,	3;
	CALL0		Nex_MessageBox_RightButton;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void() Item_Automation_Init = asm
{
local float temp_3;
	ADDRESS	self,	flag,	temp_3;
	STOREP_F	FLAG_TEMPLATE,	temp_3;
	STORE_F	self,	parm0_x;
	CALL1		Menu_DeleteAfterFrame;
	DONE;
}

void() Item_Task_Init = asm
{
local float temp_3;
	ADDRESS	self,	flag,	temp_3;
	STOREP_F	FLAG_HIDDEN,	temp_3;
	DONE;
}

void() Item_Automation_ForEach_Spawn = asm
{
local float locked_1174;
local entity lLink;
local float temp_4;
local float temp_5;
	CALL0		Item_Automation_Init;
	INDIRECT_S	self,	link,	locked_1174;
	EQ_S		locked_1174,	"",	locked_1174;
	IFNOT		locked_1174,	3;
	INDIRECT_E	self,	_parent,	lLink;
	GOTO		4;
	INDIRECT_S	self,	link,	parm0_x;
	CALL1		Menu_GetItem;
	STORE_ENT	return_x,	lLink;
	INDIRECT_S	self,	target,	locked_1174;
	NOT_S		locked_1174,	locked_1174;
	IF		locked_1174,	7;
	INDIRECT_S	self,	target,	parm0_x;
	STORE_F	"_Spawn",	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		isfunction;
	NOT_F		return_x,	temp_4;
	OR		locked_1174,	temp_4,	locked_1174;
	IFNOT		locked_1174,	4;
	STORE_F	"Bad target type!",	parm0_x;
	CALL1		objerror;
	RETURN	offset_0;
	ADDRESS	self,	_current,	locked_1174;
	INDIRECT_E	lLink,	_child,	temp_4;
	STOREP_ENT	temp_4,	locked_1174;
	INDIRECT_E	self,	_current,	locked_1174;
	IFNOT		locked_1174,	12;
	INDIRECT_E	self,	_current,	locked_1174;
	INDIRECT_S	locked_1174,	type,	locked_1174;
	INDIRECT_S	self,	target,	temp_4;
	EQ_S		locked_1174,	temp_4,	locked_1174;
	IFNOT		locked_1174,	2;
	CALL0		CtCall_Action;
	ADDRESS	self,	_current,	temp_4;
	INDIRECT_E	self,	_current,	temp_5;
	INDIRECT_E	temp_5,	_next,	temp_5;
	STOREP_ENT	temp_5,	temp_4;
	GOTO		-12;
	DONE;
}

void() Item_Automation_Job_Spawn = asm
{
	CALL0		Item_Automation_Init;
	CALL0		CtCall_Action;
	DONE;
}

void() Item_Task_Job_Spawn = asm
{
local float temp_3;
	CALL0		Item_Task_Init;
	ADDRESS	self,	_reinit,	temp_3;
	STOREP_FNC	CtCall_Reinit,	temp_3;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	CtCall_Destroy,	temp_3;
	ADDRESS	self,	_update,	temp_3;
	STOREP_FNC	CtCall_Update,	temp_3;
	CALL0		CtCall_Init;
	DONE;
}

void(entity pItem, bool pEvent) Raise_DataEvent = asm
{
local float locked_1174;
local entity lOld;
	INDIRECT_FU	pItem,	_dataEvent,	locked_1174;
	IF		locked_1174,	2;
	RETURN	offset_0;
	STORE_ENT	self,	lOld;
	STORE_ENT	pItem,	self;
	INDIRECT_FU	self,	_dataEvent,	locked_1174;
	STORE_F	pEvent,	parm0_x;
	CALL1		locked_1174;
	STORE_ENT	lOld,	self;
	DONE;
}

void() Data_ExecString_BeginUse = asm
{
	CALL0		String_Create;
	STORE_S	return_x,	Data_ExecString;
	DONE;
}

void() Data_ExecString_EndUse = asm
{
	STORE_F	Data_ExecString,	parm0_x;
	CALL1		String_Free;
	DONE;
}

void() Item_Data_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	defValue,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_Data_Init = asm
{
local float temp_3;
local float temp_4;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	defValue,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	CALL2		String_EntityCreate;
	ADDRESS	self,	flag,	temp_3;
	INDIRECT_F	self,	flag,	temp_4;
	BITOR		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_Data_Destroy,	temp_3;
	DONE;
}

void() Item_DataLink_Update = asm
{
local float locked_1174;
local float temp_4;
	INDIRECT_S	self,	link,	locked_1174;
	EQ_S		locked_1174,	"",	locked_1174;
	IFNOT		locked_1174,	4;
	ADDRESS	self,	_link,	locked_1174;
	STOREP_ENT	null_entity,	locked_1174;
	GOTO		10;
	INDIRECT_S	self,	link,	locked_1174;
	INDIRECT_E	self,	_link,	temp_4;
	INDIRECT_S	temp_4,	name,	temp_4;
	NE_S		locked_1174,	temp_4,	locked_1174;
	IFNOT		locked_1174,	5;
	ADDRESS	self,	_link,	locked_1174;
	INDIRECT_S	self,	link,	parm0_x;
	CALL1		Menu_GetItem;
	STOREP_ENT	return_x,	locked_1174;
	DONE;
}

void() Item_DataLink_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_DataLink_Init = asm
{
local float temp_3;
local float temp_4;
	ADDRESS	self,	flag,	temp_3;
	INDIRECT_F	self,	flag,	temp_4;
	BITOR		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	CALL2		String_EntityZone;
	CALL0		Item_DataLink_Update;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_DataLink_Destroy,	temp_3;
	DONE;
}

void() Item_DataLink_Switch_Destroy = asm
{
	CALL0		Item_DataLink_Destroy;
	STORE_F	self,	parm0_x;
	STORE_F	descList,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_DataLink_Switch_Init = asm
{
local float temp_3;
	CALL0		Item_DataLink_Value_Spawn;
	STORE_F	self,	parm0_x;
	STORE_F	descList,	parm1_x;
	CALL2		String_EntityZone;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_DataLink_Switch_Destroy,	temp_3;
	DONE;
}

float(entity pDataLink, float pValue) DataLink_Switch_GetOrdinal = asm
{
local float temp_3;
local float temp_4;
	INDIRECT_F	pDataLink,	stepValue,	temp_3;
	EQ_F		temp_3,	KEY_GAME,	temp_3;
	IFNOT		temp_3,	2;
	RETURN	KEY_GAME;
	INDIRECT_F	pDataLink,	minValue,	temp_3;
	SUB_F		pValue,	temp_3,	temp_3;
	INDIRECT_F	pDataLink,	stepValue,	temp_4;
	DIV_F		temp_3,	temp_4,	temp_3;
	RETURN	temp_3;
	DONE;
}

void() Item_DataUser_Update = asm
{
local float locked_1174;
local float temp_4;
	INDIRECT_S	self,	target,	locked_1174;
	EQ_S		locked_1174,	"",	locked_1174;
	IFNOT		locked_1174,	4;
	ADDRESS	self,	_target,	locked_1174;
	STOREP_ENT	null_entity,	locked_1174;
	GOTO		10;
	INDIRECT_S	self,	target,	locked_1174;
	INDIRECT_E	self,	_target,	temp_4;
	INDIRECT_S	temp_4,	name,	temp_4;
	NE_S		locked_1174,	temp_4,	locked_1174;
	IFNOT		locked_1174,	5;
	ADDRESS	self,	_target,	locked_1174;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		Menu_GetItem;
	STOREP_ENT	return_x,	locked_1174;
	DONE;
}

void() Item_DataUser_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_DataUser_Init = asm
{
local float temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityZone;
	CALL0		Item_DataUser_Update;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_DataUser_Destroy,	temp_3;
	DONE;
}

void(float pEvent) Item_DataContainer_DataEvent = asm
{
local entity lItem;
local float temp_3;
local float temp_4;
	INDIRECT_E	self,	_child,	lItem;
	NE_E		lItem,	null_entity,	temp_3;
	IFNOT		temp_3,	6;
	STORE_F	lItem,	parm0_x;
	STORE_F	pEvent,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_E	lItem,	_next,	lItem;
	GOTO		-6;
	DONE;
}

void() Item_DataContainer_Spawn = asm
{
local float temp_3;
	CALL0		Item_Container_Spawn;
	ADDRESS	self,	_dataEvent,	temp_3;
	STOREP_FNC	Item_DataContainer_DataEvent,	temp_3;
	DONE;
}

void() Item_Data_Container_Reinit = asm
{
local float temp_3;
	INDIRECT_S	self,	_syncValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void(float pEvent) Item_Data_Container_DataEvent = asm
{
local float temp_3;
	GOTO		24;
	INDIRECT_S	self,	_syncValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		23;
	INDIRECT_S	self,	value,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		17;
	INDIRECT_S	self,	defValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	defValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		6;
	IFNOT		pEvent,	-23;
	EQ_F		pEvent,	ITEM_DATA_SEND,	temp_3;
	IF		temp_3,	-19;
	EQ_F		pEvent,	ITEM_DATA_RESET,	temp_3;
	IF		temp_3,	-15;
	DONE;
}

void() Item_Data_Container_Spawn = asm
{
local float temp_3;
	CALL0		Item_Data_Init;
	ADDRESS	self,	_reinit,	temp_3;
	STOREP_FNC	Item_Data_Container_Reinit,	temp_3;
	ADDRESS	self,	_dataEvent,	temp_3;
	STOREP_FNC	Item_Data_Container_DataEvent,	temp_3;
	INDIRECT_S	self,	defValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () Item_Data_Cvar_Sync;
void() Item_Data_Cvar_Sync = asm
{
local float temp_3;
	INDIRECT_S	self,	cvarName,	parm0_x;
	CALL1		str_cvar;
	STORE_F	self,	parm0_x;
	STORE_F	_syncValue,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_S	self,	_syncValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void () Item_Data_Cvar_Send;
void() Item_Data_Cvar_Send = asm
{
local float temp_3;
local float temp_4;
	INDIRECT_S	self,	cvarName,	temp_3;
	INDIRECT_S	self,	value,	temp_4;
	STORE_F	temp_3,	parm0_x;
	STORE_F	temp_4,	parm1_x;
	CALL2		cvar_set;
	CALL0		Item_Data_Cvar_Sync;
	DONE;
}

void () Item_Data_Cvar_Reset;
void() Item_Data_Cvar_Reset = asm
{
local float temp_3;
	INDIRECT_S	self,	defValue,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		Item_Data_Cvar_Send;
	DONE;
}

void () Item_Data_Cvar_Test_Start;
void() Item_Data_Cvar_Test_Start = asm
{
local float temp_3;
local float temp_4;
	INDIRECT_S	self,	cvarName,	temp_3;
	INDIRECT_S	self,	value,	temp_4;
	STORE_F	temp_3,	parm0_x;
	STORE_F	temp_4,	parm1_x;
	CALL2		cvar_set;
	DONE;
}

void () Item_Data_Cvar_Test_End;
void() Item_Data_Cvar_Test_End = asm
{
local float temp_3;
local float temp_4;
	INDIRECT_S	self,	cvarName,	temp_3;
	INDIRECT_S	self,	_syncValue,	temp_4;
	STORE_F	temp_3,	parm0_x;
	STORE_F	temp_4,	parm1_x;
	CALL2		cvar_set;
	DONE;
}

void () Item_Data_Cvar_Save_ExecString;
void() Item_Data_Cvar_Save_ExecString = asm
{
local float temp_3;
local float temp_4;
	INDIRECT_S	self,	cvarName,	temp_3;
	INDIRECT_S	self,	value,	temp_4;
	STORE_F	"set "",	parm0_x;
	STORE_F	temp_3,	parm1_x;
	STORE_F	"" "",	parm2_x;
	STORE_F	temp_4,	parm3_x;
	STORE_F	""
",	parm4_x;
	CALL5		strcat;
	STORE_F	Data_ExecString,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Append;
	STORE_S	return_x,	Data_ExecString;
	DONE;
}

void(float pEvent) Item_Data_Cvar_DataEvent = asm
{
local float temp_3;
	GOTO		13;
	CALL0		Item_Data_Cvar_Sync;
	GOTO		22;
	CALL0		Item_Data_Cvar_Send;
	GOTO		20;
	CALL0		Item_Data_Cvar_Reset;
	GOTO		18;
	CALL0		Item_Data_Cvar_Test_Start;
	GOTO		16;
	CALL0		Item_Data_Cvar_Test_End;
	GOTO		14;
	CALL0		Item_Data_Cvar_Save_ExecString;
	GOTO		12;
	IFNOT		pEvent,	-12;
	EQ_F		pEvent,	ITEM_DATA_SEND,	temp_3;
	IF		temp_3,	-12;
	EQ_F		pEvent,	ITEM_DATA_RESET,	temp_3;
	IF		temp_3,	-12;
	EQ_F		pEvent,	ITEM_DATA_TEST_START,	temp_3;
	IF		temp_3,	-12;
	EQ_F		pEvent,	ITEM_DATA_TEST_END,	temp_3;
	IF		temp_3,	-12;
	EQ_F		pEvent,	ITEM_DATA_SAVE_EXECSTRING,	temp_3;
	IF		temp_3,	-12;
	DONE;
}

void () Item_Data_Cvar_Destroy;
void() Item_Data_Cvar_Destroy = asm
{
	CALL0		Item_Data_Destroy;
	STORE_F	self,	parm0_x;
	STORE_F	cvarName,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_Data_Cvar_Spawn = asm
{
local float temp_3;
local float temp_4;
	STORE_F	self,	parm0_x;
	STORE_F	cvarName,	parm1_x;
	CALL2		String_EntityZone;
	CALL0		Item_Data_Init;
	ADDRESS	self,	flag,	temp_3;
	INDIRECT_F	self,	flag,	temp_4;
	BITOR		temp_4,	FLAG_HIDDEN,	temp_4;
	STOREP_F	temp_4,	temp_3;
	ADDRESS	self,	_dataEvent,	temp_3;
	STOREP_FNC	Item_Data_Cvar_DataEvent,	temp_3;
	ADDRESS	self,	_reinit,	temp_3;
	STOREP_FNC	Item_Data_Cvar_Sync,	temp_3;
	ADDRESS	self,	_destroy,	temp_3;
	STOREP_FNC	Item_Data_Cvar_Destroy,	temp_3;
	DONE;
}

void() Item_Data_CvarCreateSave_Spawn = asm
{
local float temp_3;
local float temp_4;
	CALL0		Item_Data_Cvar_Spawn;
	INDIRECT_S	self,	cvarName,	temp_3;
	INDIRECT_S	self,	defValue,	temp_4;
	STORE_F	temp_3,	parm0_x;
	STORE_F	temp_4,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		registercvar;
	DONE;
}

void (float) Item_DataLink_Text_DataEvent;
void(float pEvent) Item_DataLink_Text_DataEvent = asm
{
local float temp_3;
local float temp_4;
	CALL0		Item_DataLink_Update;
	EQ_F		pEvent,	ITEM_DATALINK_SET,	temp_3;
	IFNOT		temp_3,	26;
	INDIRECT_F	self,	maxValue,	temp_3;
	GE		temp_3,	KEY_GAME,	temp_3;
	IFNOT		temp_3,	11;
	INDIRECT_S	self,	value,	temp_3;
	INDIRECT_F	self,	maxValue,	temp_4;
	STORE_F	temp_3,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	temp_4,	parm2_x;
	CALL3		substring;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_E	self,	_link,	temp_3;
	IFNOT		temp_3,	10;
	INDIRECT_E	self,	_link,	temp_3;
	INDIRECT_S	self,	value,	temp_4;
	STORE_F	temp_3,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_4,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	GOTO		33;
	INDIRECT_E	self,	_link,	temp_3;
	IF		temp_3,	3;
	RETURN	offset_0;
	GOTO		29;
	EQ_F		pEvent,	ITEM_DATALINK_GET,	temp_3;
	IFNOT		temp_3,	24;
	INDIRECT_E	self,	_link,	temp_3;
	INDIRECT_S	temp_3,	value,	temp_3;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_3,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_F	self,	maxValue,	temp_3;
	GE		temp_3,	KEY_GAME,	temp_3;
	IFNOT		temp_3,	14;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_S	self,	value,	temp_3;
	INDIRECT_F	self,	maxValue,	temp_4;
	STORE_F	temp_3,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	temp_4,	parm2_x;
	CALL3		substring;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		4;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	pEvent,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void () Item_DataLink_Text_Spawn;
void() Item_DataLink_Text_Spawn = asm
{
local float temp_3;
	CALL0		Item_DataLink_Init;
	ADDRESS	self,	_dataEvent,	temp_3;
	STOREP_FNC	Item_DataLink_Text_DataEvent,	temp_3;
	DONE;
}

void() Item_DataLink_Value_Clamp = asm
{
local float locked_285;
local float locked_1020;
local float locked_1174;
local float temp_0;
local float temp_1;
	INDIRECT_F	self,	_realValue,	locked_1174;
	INDIRECT_F	self,	maxValue,	locked_1020;
	GT		locked_1174,	locked_1020,	locked_1174;
	IFNOT		locked_1174,	4;
	INDIRECT_F	self,	maxValue,	locked_1020;
	INDIRECT_F	self,	minValue,	locked_285;
	GT		locked_1020,	locked_285,	locked_1020;
	AND		locked_1174,	locked_1020,	locked_1174;
	IFNOT		locked_1174,	5;
	ADDRESS	self,	_realValue,	locked_1174;
	INDIRECT_F	self,	maxValue,	locked_1020;
	STOREP_F	locked_1020,	locked_1174;
	GOTO		21;
	INDIRECT_F	self,	_realValue,	locked_1174;
	INDIRECT_F	self,	minValue,	locked_1020;
	LT		locked_1174,	locked_1020,	locked_1174;
	IFNOT		locked_1174,	5;
	ADDRESS	self,	_realValue,	locked_1174;
	INDIRECT_F	self,	minValue,	locked_1020;
	STOREP_F	locked_1020,	locked_1174;
	GOTO		13;
	ADDRESS	self,	_realValue,	locked_1174;
	INDIRECT_F	self,	minValue,	locked_1020;
	INDIRECT_F	self,	stepValue,	locked_285;
	INDIRECT_F	self,	_realValue,	temp_1;
	INDIRECT_F	self,	minValue,	temp_0;
	SUB_F		temp_1,	temp_0,	temp_0;
	INDIRECT_F	self,	stepValue,	temp_1;
	DIV_F		temp_0,	temp_1,	parm0_x;
	CALL1		rint;
	MUL_F		locked_285,	return_x,	temp_0;
	ADD_F		locked_1020,	temp_0,	temp_0;
	STOREP_F	temp_0,	locked_1174;
	DONE;
}

string () Item_DataLink_ClampedValue;
string() Item_DataLink_ClampedValue = asm
{
local float locked_1586;
local float lClampedStep;
local float lLen;
local float temp_1;
	INDIRECT_F	self,	stepValue,	locked_1586;
	INDIRECT_F	self,	stepValue,	parm0_x;
	CALL1		floor;
	EQ_F		locked_1586,	return_x,	locked_1586;
	IFNOT		locked_1586,	4;
	INDIRECT_F	self,	_realValue,	parm0_x;
	CALL1		ftos;
	RETURN	return_x;
	INDIRECT_F	self,	_realValue,	parm0_x;
	CALL1		rint;
	STORE_F	return_x,	parm0_x;
	CALL1		ftos;
	STORE_F	return_x,	parm0_x;
	CALL1		strlen;
	STORE_F	return_x,	lLen;
	INDIRECT_F	self,	stepValue,	locked_1586;
	INDIRECT_F	self,	stepValue,	parm0_x;
	CALL1		floor;
	SUB_F		locked_1586,	return_x,	locked_1586;
	DIV_F		FILE_APPEND,	locked_1586,	parm0_x;
	CALL1		rint;
	STORE_F	return_x,	lClampedStep;
	STORE_F	lClampedStep,	parm0_x;
	CALL1		ftos;
	STORE_F	return_x,	parm0_x;
	CALL1		strlen;
	ADD_F		lLen,	return_x,	lLen;
	INDIRECT_F	self,	_realValue,	parm0_x;
	CALL1		ftos;
	STORE_F	return_x,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	lLen,	parm2_x;
	CALL3		substring;
	RETURN	return_x;
	DONE;
}

void (float) Item_DataLink_Value_DataEvent;
void(float pEvent) Item_DataLink_Value_DataEvent = asm
{
local float locked_1586;
local float temp_1;
	CALL0		Item_DataLink_Update;
	EQ_F		pEvent,	ITEM_DATALINK_SET,	locked_1586;
	IFNOT		locked_1586,	19;
	CALL0		Item_DataLink_Value_Clamp;
	INDIRECT_E	self,	_link,	locked_1586;
	IFNOT		locked_1586,	15;
	INDIRECT_E	self,	_link,	locked_1586;
	ADDRESS	locked_1586,	_realValue,	locked_1586;
	INDIRECT_F	self,	_realValue,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	INDIRECT_E	self,	_link,	locked_1586;
	INDIRECT_F	self,	_realValue,	parm0_x;
	CALL1		ftos;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	GOTO		25;
	INDIRECT_E	self,	_link,	locked_1586;
	IF		locked_1586,	3;
	RETURN	offset_0;
	GOTO		21;
	EQ_F		pEvent,	ITEM_DATALINK_GET,	locked_1586;
	IFNOT		locked_1586,	16;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_realValue,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_S	temp_1,	value,	parm0_x;
	CALL1		stof;
	STOREP_F	return_x,	locked_1586;
	CALL0		Item_DataLink_ClampedValue;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	CALL0		Item_DataLink_Value_Clamp;
	GOTO		4;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	pEvent,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void() Item_DataLink_Value_Spawn = asm
{
local float temp_0;
	CALL0		Item_DataLink_Init;
	INDIRECT_F	self,	stepValue,	temp_0;
	EQ_F		temp_0,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	3;
	ADDRESS	self,	stepValue,	temp_0;
	STOREP_F	FILE_APPEND,	temp_0;
	ADDRESS	self,	_dataEvent,	temp_0;
	STOREP_FNC	Item_DataLink_Value_DataEvent,	temp_0;
	DONE;
}

void(float pEvent) Item_DataLink_TextSwitch_DataEvent = asm
{
local float locked_1586;
local float lCount;
local float lPos;
local float temp_1;
local float temp_5;
	CALL0		Item_DataLink_Update;
	EQ_F		pEvent,	ITEM_DATALINK_SET,	locked_1586;
	IFNOT		locked_1586,	20;
	CALL0		Item_DataLink_Value_Clamp;
	INDIRECT_E	self,	_link,	locked_1586;
	IFNOT		locked_1586,	16;
	INDIRECT_E	self,	_link,	locked_1586;
	INDIRECT_S	self,	valueList,	temp_1;
	INDIRECT_F	self,	_realValue,	temp_5;
	STORE_F	temp_1,	parm0_x;
	STORE_F	temp_5,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	GOTO		76;
	INDIRECT_E	self,	_link,	locked_1586;
	IF		locked_1586,	3;
	RETURN	offset_0;
	GOTO		72;
	EQ_F		pEvent,	ITEM_DATALINK_GET,	locked_1586;
	IFNOT		locked_1586,	67;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_S	self,	valueList,	locked_1586;
	INDIRECT_F	self,	_realValue,	temp_1;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	INDIRECT_E	self,	_link,	locked_1586;
	INDIRECT_S	locked_1586,	value,	locked_1586;
	EQ_S		return_x,	locked_1586,	locked_1586;
	IFNOT		locked_1586,	13;
	INDIRECT_S	self,	descList,	locked_1586;
	INDIRECT_F	self,	_realValue,	temp_1;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	RETURN	offset_0;
	INDIRECT_S	self,	valueList,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	STORE_F	KEY_GAME,	lPos;
	LT		lPos,	lCount,	locked_1586;
	IFNOT		locked_1586,	13;
	INDIRECT_S	self,	valueList,	parm0_x;
	STORE_F	lPos,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	INDIRECT_E	self,	_link,	locked_1586;
	INDIRECT_S	locked_1586,	value,	locked_1586;
	EQ_S		return_x,	locked_1586,	locked_1586;
	IFNOT		locked_1586,	2;
	GOTO		3;
	ADD_F		lPos,	FILE_APPEND,	lPos;
	GOTO		-13;
	GT		lPos,	lCount,	locked_1586;
	IFNOT		locked_1586,	9;
	INDIRECT_S	self,	descList,	parm0_x;
	CALL1		Util_GetAltStringCount;
	GT		return_x,	lCount,	locked_1586;
	IFNOT		locked_1586,	4;
	STORE_F	lPos,	locked_1586;
	ADD_F		lPos,	FILE_APPEND,	lPos;
	GOTO		2;
	STORE_F	KEY_GAME,	lPos;
	ADDRESS	self,	_realValue,	locked_1586;
	STOREP_F	lPos,	locked_1586;
	INDIRECT_S	self,	descList,	parm0_x;
	STORE_F	lPos,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		4;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	pEvent,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void() Item_DataLink_TextSwitch_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	valueList,	parm1_x;
	CALL2		String_EntityFree;
	CALL0		Item_DataLink_Switch_Destroy;
	DONE;
}

void() Item_DataLink_TextSwitch_Spawn = asm
{
local float locked_1586;
local float temp_1;
	CALL0		Item_DataLink_Switch_Init;
	STORE_F	self,	parm0_x;
	STORE_F	valueList,	parm1_x;
	CALL2		String_EntityZone;
	ADDRESS	self,	minValue,	locked_1586;
	STOREP_F	KEY_GAME,	locked_1586;
	INDIRECT_F	self,	maxValue,	locked_1586;
	EQ_F		locked_1586,	KEY_GAME,	locked_1586;
	IFNOT		locked_1586,	6;
	ADDRESS	self,	maxValue,	locked_1586;
	INDIRECT_S	self,	valueList,	parm0_x;
	CALL1		Util_GetAltStringCount;
	SUB_F		return_x,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	INDIRECT_F	self,	maxValue,	locked_1586;
	EQ_F		locked_1586,	KEY_GAME,	locked_1586;
	IFNOT		locked_1586,	4;
	ADDRESS	self,	stepValue,	locked_1586;
	STOREP_F	KEY_GAME,	locked_1586;
	GOTO		3;
	ADDRESS	self,	stepValue,	locked_1586;
	STOREP_F	FILE_APPEND,	locked_1586;
	ADDRESS	self,	_destroy,	locked_1586;
	STOREP_FNC	Item_DataLink_TextSwitch_Destroy,	locked_1586;
	ADDRESS	self,	_dataEvent,	locked_1586;
	STOREP_FNC	Item_DataLink_TextSwitch_DataEvent,	locked_1586;
	DONE;
}

void (float) Item_DataLink_ValueSwitch_DataEvent;
void(float pEvent) Item_DataLink_ValueSwitch_DataEvent = asm
{
local float locked_1586;
local float lPos;
local float temp_1;
	CALL0		Item_DataLink_Update;
	EQ_F		pEvent,	ITEM_DATALINK_SET,	locked_1586;
	IFNOT		locked_1586,	19;
	CALL0		Item_DataLink_Value_Clamp;
	INDIRECT_E	self,	_link,	locked_1586;
	IFNOT		locked_1586,	15;
	INDIRECT_E	self,	_link,	locked_1586;
	ADDRESS	locked_1586,	_realValue,	locked_1586;
	INDIRECT_F	self,	_realValue,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	INDIRECT_E	self,	_link,	locked_1586;
	INDIRECT_F	self,	_realValue,	parm0_x;
	CALL1		ftos;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	GOTO		36;
	INDIRECT_E	self,	_link,	locked_1586;
	IF		locked_1586,	3;
	RETURN	offset_0;
	GOTO		32;
	EQ_F		pEvent,	ITEM_DATALINK_GET,	locked_1586;
	IFNOT		locked_1586,	27;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_realValue,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_S	temp_1,	value,	parm0_x;
	CALL1		stof;
	STOREP_F	return_x,	locked_1586;
	CALL0		Item_DataLink_Value_Clamp;
	INDIRECT_F	self,	_realValue,	locked_1586;
	INDIRECT_F	self,	minValue,	temp_1;
	SUB_F		locked_1586,	temp_1,	locked_1586;
	INDIRECT_F	self,	stepValue,	temp_1;
	DIV_F		locked_1586,	temp_1,	parm0_x;
	CALL1		rint;
	STORE_F	return_x,	lPos;
	INDIRECT_S	self,	descList,	parm0_x;
	STORE_F	lPos,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		4;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	pEvent,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void() Item_DataLink_ValueSwitch_Spawn = asm
{
local float locked_1585;
local float locked_1586;
local float lCount;
local float temp_5;
local float temp_6;
	CALL0		Item_DataLink_Switch_Init;
	INDIRECT_F	self,	maxValue,	locked_1586;
	EQ_F		locked_1586,	KEY_GAME,	locked_1586;
	IFNOT		locked_1586,	11;
	ADDRESS	self,	maxValue,	locked_1586;
	INDIRECT_F	self,	minValue,	locked_1585;
	INDIRECT_S	self,	descList,	parm0_x;
	CALL1		Util_GetAltStringCount;
	SUB_F		return_x,	FILE_APPEND,	temp_5;
	INDIRECT_F	self,	stepValue,	temp_6;
	MUL_F		temp_5,	temp_6,	temp_5;
	ADD_F		locked_1585,	temp_5,	locked_1585;
	STOREP_F	locked_1585,	locked_1586;
	GOTO		15;
	INDIRECT_S	self,	descList,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	IFNOT		lCount,	9;
	ADDRESS	self,	stepValue,	locked_1586;
	INDIRECT_F	self,	maxValue,	locked_1585;
	INDIRECT_F	self,	minValue,	temp_5;
	SUB_F		locked_1585,	temp_5,	locked_1585;
	SUB_F		lCount,	FILE_APPEND,	temp_5;
	DIV_F		locked_1585,	temp_5,	locked_1585;
	STOREP_F	locked_1585,	locked_1586;
	GOTO		3;
	ADDRESS	self,	stepValue,	locked_1586;
	STOREP_F	KEY_GAME,	locked_1586;
	ADDRESS	self,	_dataEvent,	locked_1586;
	STOREP_FNC	Item_DataLink_ValueSwitch_DataEvent,	locked_1586;
	ADDRESS	self,	_destroy,	locked_1586;
	STOREP_FNC	Item_DataLink_Switch_Destroy,	locked_1586;
	DONE;
}

void (float) Item_DataLink_FastResync_DataEvent;
void(float pEvent) Item_DataLink_FastResync_DataEvent = asm
{
local float temp_0;
local float temp_1;
	EQ_F		pEvent,	ITEM_DATALINK_GET,	temp_0;
	IFNOT		temp_0,	19;
	INDIRECT_F	self,	_presstime,	temp_0;
	NE_F		temp_0,	Timer_Time,	temp_0;
	IFNOT		temp_0,	6;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATA_SYNC,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_presstime,	temp_0;
	STOREP_F	Timer_Time,	temp_0;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_E	self,	_link,	temp_0;
	INDIRECT_S	temp_0,	value,	temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		18;
	EQ_F		pEvent,	ITEM_DATALINK_SET,	temp_0;
	IFNOT		temp_0,	13;
	INDIRECT_E	self,	_link,	temp_0;
	IFNOT		temp_0,	10;
	INDIRECT_E	self,	_link,	temp_0;
	INDIRECT_S	self,	value,	temp_1;
	STORE_F	temp_0,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	temp_1,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	GOTO		4;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	pEvent,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void() Item_DataLink_FastResync_Spawn = asm
{
local float temp_0;
local float temp_1;
	CALL0		Item_DataLink_Init;
	ADDRESS	self,	_presstime,	temp_0;
	SUB_F		Timer_Time,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	ADDRESS	self,	_dataEvent,	temp_0;
	STOREP_FNC	Item_DataLink_FastResync_DataEvent,	temp_0;
	DONE;
}

void (float) Item_DataLink_TextValue_DataEvent;
void(float pEvent) Item_DataLink_TextValue_DataEvent = asm
{
local float locked_1586;
local float temp_1;
	CALL0		Item_DataLink_Update;
	EQ_F		pEvent,	ITEM_DATALINK_SET,	locked_1586;
	IFNOT		locked_1586,	14;
	INDIRECT_E	self,	_link,	locked_1586;
	ADDRESS	locked_1586,	_realValue,	locked_1586;
	INDIRECT_S	self,	value,	parm0_x;
	CALL1		stof;
	STOREP_F	return_x,	locked_1586;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_realValue,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	GOTO		39;
	INDIRECT_E	self,	_link,	locked_1586;
	IF		locked_1586,	3;
	RETURN	offset_0;
	GOTO		35;
	EQ_F		pEvent,	ITEM_DATALINK_GET,	locked_1586;
	IFNOT		locked_1586,	20;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_E	self,	_link,	locked_1586;
	INDIRECT_F	locked_1586,	_realValue,	locked_1586;
	INDIRECT_F	self,	_realValue,	temp_1;
	NE_F		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	11;
	ADDRESS	self,	_realValue,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	INDIRECT_E	self,	_link,	locked_1586;
	INDIRECT_S	locked_1586,	value,	locked_1586;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	locked_1586,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		14;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	pEvent,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_realValue,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	INDIRECT_E	self,	_link,	locked_1586;
	INDIRECT_S	locked_1586,	value,	locked_1586;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	locked_1586,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void() Item_DataLink_TextValue_Spawn = asm
{
local float temp_0;
local float temp_1;
	CALL0		Item_DataLink_Init;
	ADDRESS	self,	_dataEvent,	temp_0;
	STOREP_FNC	Item_DataLink_TextValue_DataEvent,	temp_0;
	ADDRESS	self,	_realValue,	temp_0;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_F	temp_1,	minValue,	temp_1;
	SUB_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	DONE;
}

float () _IDLTT_ConvertTime;
float() _IDLTT_ConvertTime = asm
{
local float lCounter;
local float lCount;
local float lCurrent;
local float lTotal;
local float temp_0;
	STORE_F	KEY_GAME,	lTotal;
	INDIRECT_S	self,	value,	parm0_x;
	CALL1		tokenize;
	STORE_F	return_x,	lCount;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	temp_0;
	IFNOT		temp_0,	16;
	STORE_F	lCounter,	parm0_x;
	CALL1		argv;
	STORE_F	return_x,	parm0_x;
	CALL1		stof;
	STORE_F	return_x,	lCurrent;
	MUL_F		lTotal,	60.000000,	temp_0;
	ADD_F		temp_0,	lCurrent,	lTotal;
	ADD_F		lCounter,	FILE_APPEND,	lCounter;
	STORE_F	lCounter,	parm0_x;
	CALL1		argv;
	NE_S		return_x,	":",	temp_0;
	IFNOT		temp_0,	2;
	GOTO		3;
	ADD_F		lCounter,	FILE_APPEND,	lCounter;
	GOTO		-16;
	STORE_F	lTotal,	parm0_x;
	CALL1		rint;
	RETURN	return_x;
	DONE;
}

string () _IDLTT_MakeString;
string() _IDLTT_MakeString = asm
{
local float lCurrent;
local float lTotal;
local string lString;
local float temp_0;
	INDIRECT_F	self,	_realValue,	parm0_x;
	CALL1		rint;
	STORE_F	return_x,	lTotal;
	STORE_S	"",	lString;
	STORE_F	lTotal,	parm0_x;
	STORE_F	60.000000,	parm1_x;
	CALL2		mod;
	STORE_F	return_x,	lCurrent;
	EQ_S		lString,	"",	temp_0;
	IFNOT		temp_0,	7;
	STORE_F	lCurrent,	parm0_x;
	CALL1		ftos;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lString;
	GOTO		11;
	STORE_F	lCurrent,	parm0_x;
	CALL1		ftos;
	STORE_F	return_x,	parm0_x;
	STORE_F	":",	parm1_x;
	STORE_F	lString,	parm2_x;
	CALL3		strcat;
	STORE_F	lString,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	lString;
	DIV_F		lTotal,	60.000000,	parm0_x;
	CALL1		floor;
	STORE_F	return_x,	lTotal;
	IF		lTotal,	-25;
	RETURN	lString;
	DONE;
}

void (float) Item_DataLink_TextTime_DataEvent;
void(float pEvent) Item_DataLink_TextTime_DataEvent = asm
{
local float locked_1586;
local float temp_1;
	CALL0		Item_DataLink_Update;
	EQ_F		pEvent,	ITEM_DATALINK_SET,	locked_1586;
	IFNOT		locked_1586,	13;
	INDIRECT_E	self,	_link,	locked_1586;
	ADDRESS	locked_1586,	_realValue,	locked_1586;
	CALL0		_IDLTT_ConvertTime;
	STOREP_F	return_x,	locked_1586;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_realValue,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	GOTO		41;
	INDIRECT_E	self,	_link,	locked_1586;
	IF		locked_1586,	3;
	RETURN	offset_0;
	GOTO		37;
	EQ_F		pEvent,	ITEM_DATALINK_GET,	locked_1586;
	IFNOT		locked_1586,	21;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_E	self,	_link,	locked_1586;
	INDIRECT_F	locked_1586,	_realValue,	locked_1586;
	INDIRECT_F	self,	_realValue,	temp_1;
	NE_F		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	12;
	ADDRESS	self,	_realValue,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	CALL0		_IDLTT_MakeString;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		15;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	pEvent,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_realValue,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	CALL0		_IDLTT_MakeString;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	DONE;
}

void() Item_DataLink_TextTime_Spawn = asm
{
local float temp_0;
local float temp_1;
	CALL0		Item_DataLink_Init;
	ADDRESS	self,	_dataEvent,	temp_0;
	STOREP_FNC	Item_DataLink_TextTime_DataEvent,	temp_0;
	ADDRESS	self,	_realValue,	temp_0;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_F	temp_1,	minValue,	temp_1;
	SUB_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	DONE;
}

void (float) Item_DataLink_AltString_DataEvent;
void(float pEvent) Item_DataLink_AltString_DataEvent = asm
{
local float locked_1586;
local float temp_1;
local float temp_5;
local float temp_6;
	CALL0		Item_DataLink_Update;
	INDIRECT_E	self,	_link,	locked_1586;
	IF		locked_1586,	2;
	RETURN	offset_0;
	EQ_F		pEvent,	ITEM_DATALINK_SET,	locked_1586;
	IFNOT		locked_1586,	16;
	INDIRECT_E	self,	_link,	locked_1586;
	ADDRESS	locked_1586,	value,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_S	temp_1,	value,	temp_1;
	INDIRECT_F	self,	stepValue,	temp_5;
	INDIRECT_S	self,	value,	temp_6;
	STORE_F	temp_1,	parm0_x;
	STORE_F	temp_5,	parm1_x;
	STORE_F	temp_6,	parm2_x;
	CALL3		Util_SetAltStringItem;
	STOREP_S	return_x,	locked_1586;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	GOTO		22;
	EQ_F		pEvent,	ITEM_DATALINK_GET,	locked_1586;
	IFNOT		locked_1586,	17;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_E	self,	_link,	locked_1586;
	INDIRECT_S	locked_1586,	value,	locked_1586;
	INDIRECT_F	self,	stepValue,	temp_1;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	self,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		4;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	pEvent,	parm1_x;
	CALL2		Raise_DataEvent;
	DONE;
}

void() Item_DataLink_AltString_Spawn = asm
{
local float temp_0;
	CALL0		Item_DataLink_Init;
	ADDRESS	self,	_dataEvent,	temp_0;
	STOREP_FNC	Item_DataLink_AltString_DataEvent,	temp_0;
	DONE;
}

void (float) Item_DataLink_Router_DataEvent;
void(float pEvent) Item_DataLink_Router_DataEvent = asm
{
local entity lChild;
local float temp_0;
local float temp_1;
	GOTO		29;
	INDIRECT_E	self,	_child,	lChild;
	IFNOT		lChild,	9;
	ADDRESS	lChild,	_realValue,	temp_0;
	INDIRECT_F	self,	_realValue,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	lChild,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-8;
	INDIRECT_E	self,	_child,	temp_0;
	IFNOT		temp_0,	8;
	INDIRECT_E	self,	_child,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_realValue,	temp_0;
	INDIRECT_E	self,	_child,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		14;
	INDIRECT_E	self,	_child,	lChild;
	IFNOT		lChild,	6;
	STORE_F	lChild,	parm0_x;
	STORE_F	pEvent,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-5;
	GOTO		6;
	EQ_F		pEvent,	ITEM_DATALINK_SET,	temp_0;
	IF		temp_0,	-29;
	EQ_F		pEvent,	ITEM_DATALINK_GET,	temp_0;
	IF		temp_0,	-21;
	GOTO		-12;
	DONE;
}

void() Item_DataLink_Router_Spawn = asm
{
local float temp_0;
	CALL0		Item_DataLink_Init;
	ADDRESS	self,	_dataEvent,	temp_0;
	STOREP_FNC	Item_DataLink_Router_DataEvent,	temp_0;
	DONE;
}

float(float pKey, float pAscii) Item_Window_Key = asm
{
	STORE_F	pKey,	parm0_x;
	STORE_F	pAscii,	parm1_x;
	CALL2		CtCall_Key;
	IFNOT		return_x,	2;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void() Item_Window_Draw = asm
{
local vector lColor;
local entity lChild;
local float temp_0;
local vector temp_2;
local vector temp_3;
	IF		sys_debug,	2;
	RETURN	offset_0;
	INDIRECT_F	self,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_MOUSEINAREA,	temp_0;
	IFNOT		temp_0,	56;
	IFNOT		sys_debug_area,	50;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_V	self,	size_x,	temp_3;
	STORE_V	temp_2,	parm0;
	STORE_V	temp_3,	parm1;
	STORE_V	'0.200000 0.000000 0.000000',	parm2;
	STORE_F	ITEM_BUTTON_ACTIONTIME,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Fill;
	INDIRECT_E	self,	_child,	lChild;
	IFNOT		lChild,	40;
	INDIRECT_F	lChild,	_runFlag,	temp_0;
	BITAND	temp_0,	96.000000,	temp_0;
	NOT_F		temp_0,	temp_0;
	IF		temp_0,	2;
	GOTO		33;
	INDIRECT_F	lChild,	orderPos,	parm0_x;
	CALL1		fabs;
	ADD_F		return_x,	SLIST_SERVERREPLYCOUNT,	parm0_x;
	STORE_F	K_TAB,	parm1_x;
	CALL2		mod;
	DIV_F		return_x,	8.000000,	lColor_x;
	INDIRECT_F	lChild,	orderPos,	temp_0;
	MUL_F		temp_0,	8.000000,	parm0_x;
	CALL1		fabs;
	STORE_F	return_x,	parm0_x;
	STORE_F	K_TAB,	parm1_x;
	CALL2		mod;
	DIV_F		return_x,	8.000000,	lColor_y;
	INDIRECT_F	lChild,	orderPos,	temp_0;
	MUL_F		temp_0,	SLIST_SORTDESCENDING,	parm0_x;
	CALL1		fabs;
	STORE_F	return_x,	parm0_x;
	STORE_F	K_TAB,	parm1_x;
	CALL2		mod;
	DIV_F		return_x,	8.000000,	lColor_z;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_V	self,	origin_x,	temp_3;
	ADD_V		temp_2,	temp_3,	temp_2;
	INDIRECT_V	lChild,	pos_x,	temp_3;
	ADD_V		temp_2,	temp_3,	temp_2;
	INDIRECT_V	lChild,	size_x,	temp_3;
	STORE_V	temp_2,	parm0;
	STORE_V	temp_3,	parm1;
	STORE_V	lColor,	parm2;
	STORE_F	ITEM_BUTTON_ACTIONTIME,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Fill;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-39;
	IFNOT		sys_debug_mouse,	5;
	INDIRECT_V	self,	origin_x,	temp_2;
	SUB_V		Menu_Cursor_Position,	temp_2,	temp_2;
	INDIRECT_V	self,	pos_x,	temp_3;
	SUB_V		temp_2,	temp_3,	sys_debug_cursor_localpos;
	DONE;
}

void() Item_Window_Spawn = asm
{
local float temp_0;
local float temp_1;
	ADDRESS	self,	flag,	temp_0;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_NOSELECT,	temp_1;
	STOREP_F	temp_1,	temp_0;
	ADDRESS	self,	_key,	temp_0;
	STOREP_FNC	Item_Window_Key,	temp_0;
	ADDRESS	self,	_draw,	temp_0;
	STOREP_FNC	Item_Window_Draw,	temp_0;
	DONE;
}

void() Item_Reference_Update = asm
{
local float locked_1586;
local float temp_1;
	INDIRECT_S	self,	link,	locked_1586;
	EQ_S		locked_1586,	"",	locked_1586;
	IFNOT		locked_1586,	4;
	ADDRESS	self,	_child,	locked_1586;
	STOREP_ENT	null_entity,	locked_1586;
	RETURN	offset_0;
	INDIRECT_S	self,	link,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_S	temp_1,	name,	temp_1;
	NE_S		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	5;
	ADDRESS	self,	_link,	locked_1586;
	INDIRECT_S	self,	link,	parm0_x;
	CALL1		Menu_GetItem;
	STOREP_ENT	return_x,	locked_1586;
	ADDRESS	self,	_child,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	STOREP_ENT	temp_1,	locked_1586;
	INDIRECT_E	self,	_child,	locked_1586;
	ADDRESS	locked_1586,	_parent,	locked_1586;
	STOREP_ENT	self,	locked_1586;
	DONE;
}

void() Item_Reference_Draw = asm
{
local vector temp_2;
local vector temp_3;
	IFNOT		sys_debug_ref,	9;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_V	self,	size_x,	temp_3;
	STORE_V	temp_2,	parm0;
	STORE_V	temp_3,	parm1;
	STORE_V	'0.000000 0.000000 0.200000',	parm2;
	STORE_F	FILE_APPEND,	parm3_x;
	STORE_F	FILE_APPEND,	parm4_x;
	CALL5		Menu_Fill;
	DONE;
}

void() Item_Reference_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_Reference_Spawn = asm
{
local float temp_0;
local float temp_1;
	ADDRESS	self,	flag,	temp_0;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_NOSELECT,	temp_1;
	BITOR		temp_1,	FLAG_EMBEDDED,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityZone;
	CALL0		Item_Reference_Update;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Item_Reference_Destroy,	temp_0;
	ADDRESS	self,	_draw,	temp_0;
	STOREP_FNC	Item_Reference_Draw,	temp_0;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_Reference_Update,	temp_0;
	DONE;
}

void() Item_Layout_Update = asm
{
local vector lCurrent;
local entity lChild;
local float temp_0;
local float temp_1;
	STORE_V	'0.000000 0.000000 0.000000',	lCurrent;
	INDIRECT_E	self,	_child,	lChild;
	IFNOT		lChild,	92;
	INDIRECT_F	lChild,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_HIDDEN,	temp_0;
	IFNOT		temp_0,	2;
	GOTO		86;
	INDIRECT_F	self,	direction_y,	temp_0;
	IFNOT		temp_0,	33;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	ITEM_ALIGN_FIRST,	temp_0;
	IFNOT		temp_0,	2;
	INDIRECT_E	lChild,	_child,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	7;
	ADDRESS	lChild,	pos_x,	temp_0;
	INDIRECT_E	lChild,	_child,	temp_1;
	INDIRECT_F	temp_1,	size_x,	temp_1;
	SUB_F		lCurrent_x,	temp_1,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		20;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	lChild,	pos_x,	temp_0;
	STOREP_F	lCurrent_x,	temp_0;
	GOTO		14;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	ITEM_ALIGN_CENTER,	temp_0;
	IFNOT		temp_0,	7;
	ADDRESS	lChild,	pos_x,	temp_0;
	INDIRECT_F	lChild,	size_x,	temp_1;
	DIV_F		temp_1,	KEY_MENU,	temp_1;
	SUB_F		lCurrent_x,	temp_1,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		5;
	ADDRESS	lChild,	pos_x,	temp_0;
	INDIRECT_F	lChild,	size_x,	temp_1;
	SUB_F		lCurrent_x,	temp_1,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		3;
	ADDRESS	lChild,	pos_x,	temp_0;
	STOREP_F	lCurrent_x,	temp_0;
	INDIRECT_F	self,	direction_x,	temp_0;
	IFNOT		temp_0,	33;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	lChild,	pos_y,	temp_0;
	STOREP_F	lCurrent_y,	temp_0;
	GOTO		26;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	ITEM_ALIGN_CENTER,	temp_0;
	IFNOT		temp_0,	7;
	ADDRESS	lChild,	pos_y,	temp_0;
	INDIRECT_F	lChild,	size_y,	temp_1;
	DIV_F		temp_1,	KEY_MENU,	temp_1;
	SUB_F		lCurrent_y,	temp_1,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		17;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	ITEM_ALIGN_FIRST,	temp_0;
	IFNOT		temp_0,	2;
	INDIRECT_E	lChild,	_child,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	7;
	ADDRESS	lChild,	pos_y,	temp_0;
	INDIRECT_E	lChild,	_child,	temp_1;
	INDIRECT_F	temp_1,	size_y,	temp_1;
	SUB_F		lCurrent_y,	temp_1,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		5;
	ADDRESS	lChild,	pos_y,	temp_0;
	INDIRECT_F	lChild,	size_y,	temp_1;
	SUB_F		lCurrent_y,	temp_1,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		3;
	ADDRESS	lChild,	pos_y,	temp_0;
	STOREP_F	lCurrent_y,	temp_0;
	INDIRECT_F	self,	direction_x,	temp_0;
	IFNOT		temp_0,	6;
	INDIRECT_F	lChild,	size_x,	temp_0;
	INDIRECT_F	self,	direction_x,	temp_1;
	ADD_F		temp_0,	temp_1,	temp_0;
	ADD_F		lCurrent_x,	temp_0,	lCurrent_x;
	GOTO		7;
	INDIRECT_F	self,	direction_y,	temp_0;
	IFNOT		temp_0,	5;
	INDIRECT_F	lChild,	size_y,	temp_0;
	INDIRECT_F	self,	direction_y,	temp_1;
	ADD_F		temp_0,	temp_1,	temp_0;
	ADD_F		lCurrent_y,	temp_0,	lCurrent_y;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-91;
	DONE;
}

void() Item_Layout_Spawn = asm
{
local float temp_0;
	CALL0		Item_Window_Spawn;
	CALL0		Item_Layout_Update;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_Layout_Update,	temp_0;
	DONE;
}

void() Item_Arrangement_CalculateSize = asm
{
local entity lChild;
local vector lMax;
local vector lMin;
local float temp_0;
local float temp_1;
local vector temp_2;
local vector temp_3;
	STORE_V	'0.000000 0.000000 0.000000',	lMax;
	STORE_F	INFINITY,	lMin_x;
	STORE_F	INFINITY,	lMin_y;
	INDIRECT_E	self,	_child,	lChild;
	IFNOT		lChild,	31;
	INDIRECT_F	lChild,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_HIDDEN,	temp_0;
	IFNOT		temp_0,	2;
	GOTO		25;
	INDIRECT_F	lChild,	pos_x,	temp_0;
	STORE_F	lMin_x,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	CALL2		min;
	STORE_F	return_x,	lMin_x;
	INDIRECT_F	lChild,	pos_y,	temp_0;
	STORE_F	lMin_y,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	CALL2		min;
	STORE_F	return_x,	lMin_y;
	INDIRECT_F	lChild,	pos_x,	temp_0;
	INDIRECT_F	lChild,	size_x,	temp_1;
	ADD_F		temp_0,	temp_1,	temp_0;
	STORE_F	lMax_x,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	CALL2		max;
	STORE_F	return_x,	lMax_x;
	INDIRECT_F	lChild,	pos_y,	temp_0;
	INDIRECT_F	lChild,	size_y,	temp_1;
	ADD_F		temp_0,	temp_1,	temp_0;
	STORE_F	lMax_y,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	CALL2		max;
	STORE_F	return_x,	lMax_y;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-30;
	ADDRESS	self,	size_x,	temp_2_x;
	SUB_V		lMax,	lMin,	temp_3;
	STOREP_V	temp_3_x,	temp_2;
	DONE;
}

void() Item_Arrangement_Update = asm
{
local float temp_0;
local float temp_1;
	CALL0		Item_Layout_Update;
	CALL0		Item_Arrangement_CalculateSize;
	INDIRECT_F	self,	direction_x,	temp_0;
	IFNOT		temp_0,	23;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	self,	origin_y,	temp_0;
	STOREP_F	KEY_GAME,	temp_0;
	GOTO		16;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	ITEM_ALIGN_CENTER,	temp_0;
	IF		temp_0,	3;
	INDIRECT_F	self,	alignment,	temp_1;
	EQ_F		temp_1,	ITEM_ALIGN_FIRST,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	6;
	ADDRESS	self,	origin_y,	temp_0;
	INDIRECT_F	self,	size_y,	temp_1;
	DIV_F		temp_1,	KEY_MENU,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		4;
	ADDRESS	self,	origin_y,	temp_0;
	INDIRECT_F	self,	size_y,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		3;
	ADDRESS	self,	origin_y,	temp_0;
	STOREP_F	KEY_GAME,	temp_0;
	INDIRECT_F	self,	direction_y,	temp_0;
	IFNOT		temp_0,	23;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	self,	origin_x,	temp_0;
	STOREP_F	KEY_GAME,	temp_0;
	GOTO		16;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	ITEM_ALIGN_CENTER,	temp_0;
	IF		temp_0,	3;
	INDIRECT_F	self,	alignment,	temp_1;
	EQ_F		temp_1,	ITEM_ALIGN_FIRST,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	6;
	ADDRESS	self,	origin_x,	temp_0;
	INDIRECT_F	self,	size_x,	temp_1;
	DIV_F		temp_1,	KEY_MENU,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		4;
	ADDRESS	self,	origin_x,	temp_0;
	INDIRECT_F	self,	size_x,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		3;
	ADDRESS	self,	origin_x,	temp_0;
	STOREP_F	KEY_GAME,	temp_0;
	DONE;
}

void() Item_Arrangement_Spawn = asm
{
local float temp_0;
	CALL0		Item_Layout_Spawn;
	CALL0		Item_Arrangement_Update;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_Arrangement_Update,	temp_0;
	DONE;
}

void() Item_ScrollWindow_Update = asm
{
local float locked_1586;
local entity lParent;
local float lOldLevel;
local float lLevel;
local float temp_1;
local float temp_5;
local float temp_6;
	INDIRECT_F	self,	_runFlag,	locked_1586;
	BITAND	locked_1586,	96.000000,	locked_1586;
	NOT_F		locked_1586,	locked_1586;
	NOT_F		locked_1586,	locked_1586;
	IF		locked_1586,	6;
	INDIRECT_E	self,	_child,	temp_1;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		_Menu_IsEmbeddedParentOf;
	NOT_F		return_x,	temp_1;
	OR		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	4;
	ADDRESS	self,	_link,	locked_1586;
	STOREP_ENT	null_entity,	locked_1586;
	RETURN	offset_0;
	INDIRECT_E	self,	_link,	locked_1586;
	EQ_E		locked_1586,	Menu_ActiveItem,	locked_1586;
	IFNOT		locked_1586,	3;
	RETURN	offset_0;
	GOTO		3;
	ADDRESS	self,	_link,	locked_1586;
	STOREP_ENT	Menu_ActiveItem,	locked_1586;
	INDIRECT_F	Menu_ActiveItem,	pos_y,	lLevel;
	INDIRECT_E	Menu_ActiveItem,	_parent,	lParent;
	NE_E		lParent,	self,	locked_1586;
	IFNOT		locked_1586,	7;
	INDIRECT_F	lParent,	origin_y,	locked_1586;
	INDIRECT_F	lParent,	pos_y,	temp_1;
	ADD_F		locked_1586,	temp_1,	locked_1586;
	ADD_F		lLevel,	locked_1586,	lLevel;
	INDIRECT_E	lParent,	_parent,	lParent;
	GOTO		-7;
	INDIRECT_F	self,	origin_y,	locked_1586;
	SUB_F		KEY_GAME,	locked_1586,	lOldLevel;
	INDIRECT_F	Menu_ActiveItem,	size_y,	locked_1586;
	INDIRECT_F	self,	size_y,	temp_1;
	GT		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	4;
	INDIRECT_F	Menu_ActiveItem,	size_y,	temp_1;
	ADD_F		lLevel,	temp_1,	temp_1;
	GT		temp_1,	lOldLevel,	temp_1;
	AND		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	4;
	INDIRECT_F	self,	size_y,	temp_1;
	ADD_F		temp_1,	lOldLevel,	temp_1;
	LT		lLevel,	temp_1,	temp_1;
	AND		locked_1586,	temp_1,	locked_1586;
	IF		locked_1586,	9;
	GE		lLevel,	lOldLevel,	temp_1;
	IFNOT		temp_1,	6;
	INDIRECT_F	Menu_ActiveItem,	size_y,	temp_5;
	ADD_F		lLevel,	temp_5,	temp_5;
	INDIRECT_F	self,	size_y,	temp_6;
	ADD_F		lOldLevel,	temp_6,	temp_6;
	LT		temp_5,	temp_6,	temp_5;
	AND		temp_1,	temp_5,	temp_1;
	OR		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	2;
	RETURN	offset_0;
	LT		lOldLevel,	lLevel,	locked_1586;
	IFNOT		locked_1586,	6;
	ADDRESS	self,	origin_y,	locked_1586;
	INDIRECT_F	self,	direction_x,	temp_1;
	SUB_F		temp_1,	lLevel,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	GOTO		7;
	ADDRESS	self,	origin_y,	locked_1586;
	INDIRECT_F	self,	size_y,	temp_1;
	INDIRECT_F	self,	direction_x,	temp_5;
	SUB_F		temp_1,	temp_5,	temp_1;
	SUB_F		temp_1,	lLevel,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	ADDRESS	self,	origin_y,	locked_1586;
	INDIRECT_F	self,	size_y,	temp_1;
	INDIRECT_E	self,	_child,	temp_5;
	INDIRECT_F	temp_5,	size_y,	temp_5;
	SUB_F		temp_1,	temp_5,	temp_1;
	INDIRECT_F	self,	origin_y,	temp_5;
	STORE_F	temp_1,	parm0_x;
	STORE_F	temp_5,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		bound;
	STOREP_F	return_x,	locked_1586;
	DONE;
}

void () Item_ScrollWindow_Reinit;
void() Item_ScrollWindow_Reinit = asm
{
local float temp_0;
	ADDRESS	self,	origin_y,	temp_0;
	STOREP_F	KEY_GAME,	temp_0;
	DONE;
}

void() Item_ScrollWindow_Spawn = asm
{
local float temp_0;
	CALL0		Item_Window_Spawn;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_ScrollWindow_Update,	temp_0;
	ADDRESS	self,	_reinit,	temp_0;
	STOREP_FNC	Item_ScrollWindow_Reinit,	temp_0;
	DONE;
}

void() Item_EventWindow_Spawn = asm
{
local float temp_0;
	CALL0		Item_Window_Spawn;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	CtCall_Destroy,	temp_0;
	ADDRESS	self,	_reinit,	temp_0;
	STOREP_FNC	CtCall_Reinit,	temp_0;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	CtCall_Update,	temp_0;
	CALL0		CtCall_Init;
	DONE;
}

void() Item_Frame_Spawn = asm
{
local float temp_0;
local float temp_1;
	CALL0		Item_Window_Spawn;
	ADDRESS	self,	flag,	temp_0;
	INDIRECT_F	self,	flag,	temp_1;
	SUB_F		temp_1,	FLAG_NOSELECT,	temp_1;
	STOREP_F	temp_1,	temp_0;
	DONE;
}

float () _IL_GetItemUnderCursor;
float() _IL_GetItemUnderCursor = asm
{
local float locked_1586;
local float lLines;
local float lStart;
local float lItem;
local float temp_1;
local float temp_5;
	INDIRECT_F	self,	size_y,	locked_1586;
	INDIRECT_F	self,	fontSize_y,	temp_1;
	ADD_F		temp_1,	KEY_MENU,	temp_1;
	DIV_F		locked_1586,	temp_1,	parm0_x;
	CALL1		floor;
	STORE_F	return_x,	lLines;
	INDIRECT_E	self,	_target,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		DataLink_Switch_GetOrdinal;
	DIV_F		lLines,	KEY_MENU,	locked_1586;
	SUB_F		return_x,	locked_1586,	parm0_x;
	CALL1		floor;
	STORE_F	KEY_GAME,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		max;
	STORE_F	return_x,	lStart;
	INDIRECT_F	self,	pos_y,	locked_1586;
	SUB_F		Menu_Cursor_Position_y,	locked_1586,	locked_1586;
	INDIRECT_F	self,	fontSize_y,	temp_1;
	ADD_F		temp_1,	KEY_MENU,	temp_1;
	DIV_F		locked_1586,	temp_1,	parm0_x;
	CALL1		floor;
	STORE_F	return_x,	lItem;
	ADD_F		lStart,	lItem,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_E	self,	_target,	temp_5;
	INDIRECT_F	temp_5,	maxValue,	temp_5;
	STORE_F	temp_1,	parm0_x;
	STORE_F	temp_5,	parm1_x;
	CALL2		DataLink_Switch_GetOrdinal;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		min;
	STORE_F	return_x,	lItem;
	RETURN	lItem;
	DONE;
}

void() Item_List_Draw = asm
{
local float locked_1586;
local string lText;
local float lItemUnderCursor;
local vector lPos;
local float lEnd;
local float lLine;
local float lLines;
local float lStart;
local float temp_1;
local vector temp_2;
local vector temp_3;
local float temp_5;
	INDIRECT_E	self,	_target,	locked_1586;
	IF		locked_1586,	2;
	RETURN	offset_0;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_F	self,	size_y,	locked_1586;
	INDIRECT_F	self,	fontSize_y,	temp_1;
	ADD_F		temp_1,	KEY_MENU,	temp_1;
	DIV_F		locked_1586,	temp_1,	parm0_x;
	CALL1		floor;
	STORE_F	return_x,	lLines;
	INDIRECT_E	self,	_target,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		DataLink_Switch_GetOrdinal;
	DIV_F		lLines,	KEY_MENU,	locked_1586;
	SUB_F		return_x,	locked_1586,	parm0_x;
	CALL1		floor;
	STORE_F	KEY_GAME,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		max;
	STORE_F	return_x,	lStart;
	ADD_F		lStart,	lLines,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_E	self,	_target,	temp_5;
	INDIRECT_F	temp_5,	maxValue,	temp_5;
	STORE_F	temp_1,	parm0_x;
	STORE_F	temp_5,	parm1_x;
	CALL2		DataLink_Switch_GetOrdinal;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		min;
	STORE_F	return_x,	lEnd;
	INDIRECT_F	self,	_state,	locked_1586;
	EQ_F		locked_1586,	ITEM_STATE_NORMAL,	locked_1586;
	IFNOT		locked_1586,	3;
	STORE_F	ERR_CANNOTOPEN,	lItemUnderCursor;
	GOTO		3;
	CALL0		_IL_GetItemUnderCursor;
	STORE_F	return_x,	lItemUnderCursor;
	INDIRECT_V	self,	pos_x,	temp_2;
	ADD_V		'0.000000 1.000000 0.000000',	temp_2,	lPos;
	STORE_F	lStart,	lLine;
	LE		lLine,	lEnd,	locked_1586;
	IFNOT		locked_1586,	89;
	INDIRECT_E	self,	_target,	locked_1586;
	INDIRECT_S	locked_1586,	descList,	parm0_x;
	STORE_F	lLine,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_S	return_x,	lText;
	INDIRECT_E	self,	_target,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		DataLink_Switch_GetOrdinal;
	EQ_F		lLine,	return_x,	locked_1586;
	IFNOT		locked_1586,	43;
	INDIRECT_F	self,	_state,	locked_1586;
	EQ_F		locked_1586,	ITEM_STATE_SELECTED,	locked_1586;
	IFNOT		locked_1586,	13;
	INDIRECT_V	self,	fontSize_x,	temp_2;
	INDIRECT_V	self,	colorSelected_x,	temp_3;
	INDIRECT_F	self,	alphas_y,	locked_1586;
	INDIRECT_F	self,	drawFlags_y,	temp_1;
	STORE_V	lPos,	parm0;
	STORE_F	lText,	parm1_x;
	STORE_V	temp_2,	parm2;
	STORE_V	temp_3,	parm3;
	STORE_F	locked_1586,	parm4_x;
	STORE_F	temp_1,	parm5_x;
	CALL6		Menu_DrawString;
	GOTO		27;
	INDIRECT_F	self,	_state,	locked_1586;
	EQ_F		locked_1586,	ITEM_STATE_PRESSED,	locked_1586;
	IFNOT		locked_1586,	13;
	INDIRECT_V	self,	fontSize_x,	temp_2;
	INDIRECT_V	self,	colorPressed_x,	temp_3;
	INDIRECT_F	self,	alphas_z,	locked_1586;
	INDIRECT_F	self,	drawFlags_z,	temp_1;
	STORE_V	lPos,	parm0;
	STORE_F	lText,	parm1_x;
	STORE_V	temp_2,	parm2;
	STORE_V	temp_3,	parm3;
	STORE_F	locked_1586,	parm4_x;
	STORE_F	temp_1,	parm5_x;
	CALL6		Menu_DrawString;
	GOTO		12;
	INDIRECT_V	self,	fontSize_x,	temp_2;
	INDIRECT_V	self,	colorInactive_x,	temp_3;
	INDIRECT_F	self,	alphaInactive,	locked_1586;
	INDIRECT_F	self,	drawFlagInactive,	temp_1;
	STORE_V	lPos,	parm0;
	STORE_F	lText,	parm1_x;
	STORE_V	temp_2,	parm2;
	STORE_V	temp_3,	parm3;
	STORE_F	locked_1586,	parm4_x;
	STORE_F	temp_1,	parm5_x;
	CALL6		Menu_DrawString;
	GOTO		26;
	EQ_F		lLine,	lItemUnderCursor,	locked_1586;
	IFNOT		locked_1586,	13;
	INDIRECT_V	self,	fontSize_x,	temp_2;
	INDIRECT_V	self,	colorInactive_x,	temp_3;
	INDIRECT_F	self,	alphaInactive,	locked_1586;
	INDIRECT_F	self,	drawFlagInactive,	temp_1;
	STORE_V	lPos,	parm0;
	STORE_F	lText,	parm1_x;
	STORE_V	temp_2,	parm2;
	STORE_V	temp_3,	parm3;
	STORE_F	locked_1586,	parm4_x;
	STORE_F	temp_1,	parm5_x;
	CALL6		Menu_DrawString;
	GOTO		12;
	INDIRECT_V	self,	fontSize_x,	temp_2;
	INDIRECT_V	self,	color_x,	temp_3;
	INDIRECT_F	self,	alphas_x,	locked_1586;
	INDIRECT_F	self,	drawFlags_x,	temp_1;
	STORE_V	lPos,	parm0;
	STORE_F	lText,	parm1_x;
	STORE_V	temp_2,	parm2;
	STORE_V	temp_3,	parm3;
	STORE_F	locked_1586,	parm4_x;
	STORE_F	temp_1,	parm5_x;
	CALL6		Menu_DrawString;
	INDIRECT_F	self,	fontSize_y,	locked_1586;
	ADD_F		lPos_y,	locked_1586,	locked_1586;
	ADD_F		locked_1586,	KEY_MENU,	lPos_y;
	STORE_F	lText,	parm0_x;
	CALL1		String_Free;
	STORE_F	lLine,	temp_1;
	ADD_F		lLine,	FILE_APPEND,	lLine;
	GOTO		-89;
	DONE;
}

void() Item_List_Update = asm
{
local float temp_0;
	CALL0		Item_DataUser_Update;
	INDIRECT_F	self,	_presstime,	temp_0;
	ADD_F		temp_0,	ITEM_BUTTON_ACTIONTIME,	temp_0;
	GT		temp_0,	Timer_Time,	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	self,	_state,	temp_0;
	STOREP_F	ITEM_STATE_PRESSED,	temp_0;
	GOTO		8;
	EQ_E		Menu_ActiveItem,	self,	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	self,	_state,	temp_0;
	STOREP_F	ITEM_STATE_SELECTED,	temp_0;
	GOTO		3;
	ADDRESS	self,	_state,	temp_0;
	STOREP_F	ITEM_STATE_NORMAL,	temp_0;
	DONE;
}

void(float pSelect, float pUser) Item_List_Select = asm
{
local float temp_0;
	IFNOT		pSelect,	1;
	AND		pSelect,	pUser,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_S	self,	soundSelected,	parm0_x;
	CALL1		Sound_Play;
	DONE;
}

float(float pKey, float pAscii) Item_List_Key = asm
{
local float lSelected;
local float temp_0;
local float temp_1;
	EQ_F		pKey,	K_DOWNARROW,	temp_0;
	IFNOT		temp_0,	16;
	INDIRECT_S	self,	soundPressed,	parm0_x;
	CALL1		Sound_Play;
	ADDRESS	self,	_presstime,	temp_0;
	STOREP_F	Timer_Time,	temp_0;
	INDIRECT_E	self,	_target,	temp_0;
	ADDRESS	temp_0,	_realValue,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	ADD_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	RETURN	FILE_APPEND;
	GOTO		49;
	EQ_F		pKey,	K_UPARROW,	temp_0;
	IFNOT		temp_0,	16;
	INDIRECT_S	self,	soundPressed,	parm0_x;
	CALL1		Sound_Play;
	ADDRESS	self,	_presstime,	temp_0;
	STOREP_F	Timer_Time,	temp_0;
	INDIRECT_E	self,	_target,	temp_0;
	ADDRESS	temp_0,	_realValue,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	SUB_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	RETURN	FILE_APPEND;
	GOTO		32;
	EQ_F		pKey,	K_MOUSE1,	temp_0;
	IFNOT		temp_0,	30;
	INDIRECT_S	self,	soundPressed,	parm0_x;
	CALL1		Sound_Play;
	CALL0		_IL_GetItemUnderCursor;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_F	temp_0,	stepValue,	temp_0;
	MUL_F		return_x,	temp_0,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	minValue,	temp_1;
	ADD_F		temp_0,	temp_1,	lSelected;
	INDIRECT_F	self,	_presstime,	temp_0;
	ADD_F		temp_0,	ITEM_BUTTON_ACTIONTIME,	temp_0;
	GT		temp_0,	Timer_Time,	temp_0;
	IFNOT		temp_0,	4;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	EQ_F		lSelected,	temp_1,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	3;
	CALL0		CtCall_Action;
	GOTO		9;
	ADDRESS	self,	_presstime,	temp_0;
	STOREP_F	Timer_Time,	temp_0;
	INDIRECT_E	self,	_target,	temp_0;
	ADDRESS	temp_0,	_realValue,	temp_0;
	STOREP_F	lSelected,	temp_0;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void() Item_List_Destroy = asm
{
	CALL0		CtCall_Destroy;
	STORE_F	self,	parm0_x;
	STORE_F	soundSelected,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	soundPressed,	parm1_x;
	CALL2		String_EntityFree;
	CALL0		Item_DataUser_Destroy;
	DONE;
}

void() Item_List_Spawn = asm
{
local float temp_0;
	CALL0		Item_DataUser_Init;
	STORE_F	self,	parm0_x;
	STORE_F	soundSelected,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	soundPressed,	parm1_x;
	CALL2		String_EntityZone;
	INDIRECT_S	self,	soundSelected,	parm0_x;
	CALL1		Sound_Precache;
	INDIRECT_S	self,	soundPressed,	parm0_x;
	CALL1		Sound_Precache;
	ADDRESS	self,	_draw,	temp_0;
	STOREP_FNC	Item_List_Draw,	temp_0;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_List_Update,	temp_0;
	ADDRESS	self,	_select,	temp_0;
	STOREP_FNC	Item_List_Select,	temp_0;
	ADDRESS	self,	_key,	temp_0;
	STOREP_FNC	Item_List_Key,	temp_0;
	ADDRESS	self,	_reinit,	temp_0;
	STOREP_FNC	CtCall_Reinit,	temp_0;
	CALL0		CtCall_Init;
	DONE;
}

float (string) _IB_IsPicture;
float(string pString) _IB_IsPicture = asm
{
local float temp_0;
	STORE_F	pString,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		substring;
	EQ_S		return_x,	"$",	temp_0;
	RETURN	temp_0;
	DONE;
}

string (string) _IB_GetPath;
string(string pString) _IB_GetPath = asm
{
	STORE_F	pString,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	1000.000000,	parm2_x;
	CALL3		substring;
	RETURN	return_x;
	DONE;
}

vector (string) _IB_GetSize;
vector(string pString) _IB_GetSize = asm
{
local vector lSize;
local float temp_0;
	STORE_F	pString,	parm0_x;
	CALL1		_IB_IsPicture;
	IFNOT		return_x,	6;
	STORE_F	pString,	parm0_x;
	CALL1		_IB_GetPath;
	STORE_F	return_x,	parm0_x;
	CALL1		Gfx_GetImageSize;
	RETURN	return_x;
	STORE_F	pString,	parm0_x;
	CALL1		strlen;
	INDIRECT_F	self,	fontSize_x,	temp_0;
	MUL_F		return_x,	temp_0,	lSize_x;
	INDIRECT_F	self,	fontSize_y,	lSize_y;
	STORE_F	KEY_GAME,	lSize_z;
	RETURN	lSize_x;
	DONE;
}

vector () _IB_GetMaxSize;
vector() _IB_GetMaxSize = asm
{
local vector lSize;
local vector lPressed;
local vector lSelected;
local vector lNormal;
local float temp_0;
	INDIRECT_S	self,	normal,	parm0_x;
	CALL1		_IB_GetSize;
	STORE_V	return,	lNormal;
	INDIRECT_S	self,	selected,	parm0_x;
	CALL1		_IB_GetSize;
	STORE_V	return,	lSelected;
	INDIRECT_S	self,	pressed,	parm0_x;
	CALL1		_IB_GetSize;
	STORE_V	return,	lPressed;
	STORE_F	lNormal_x,	parm0_x;
	STORE_F	lSelected_x,	parm1_x;
	STORE_F	lPressed_x,	parm2_x;
	CALL3		max;
	STORE_F	return_x,	lSize_x;
	STORE_F	lNormal_y,	parm0_x;
	STORE_F	lSelected_y,	parm1_x;
	STORE_F	lPressed_y,	parm2_x;
	CALL3		max;
	STORE_F	return_x,	lSize_y;
	STORE_F	KEY_GAME,	lSize_z;
	RETURN	lSize_x;
	DONE;
}

void (string, vector, float, float) _IB_Draw;
void(string pName, vector pColor, float pAlpha, float pDrawFlag) _IB_Draw = asm
{
local vector lMaxSize;
local vector lPos;
local vector lSize;
local float temp_0;
local float temp_1;
local vector temp_2;
	STORE_F	pName,	parm0_x;
	CALL1		_IB_GetSize;
	STORE_V	return,	lSize;
	CALL0		_IB_GetMaxSize;
	STORE_V	return,	lMaxSize;
	STORE_F	pName,	parm0_x;
	CALL1		_IB_IsPicture;
	IFNOT		return_x,	7;
	INDIRECT_F	self,	size_x,	temp_0;
	DIV_F		temp_0,	lMaxSize_x,	temp_0;
	MUL_F		lSize_x,	temp_0,	lSize_x;
	INDIRECT_F	self,	size_y,	temp_0;
	DIV_F		temp_0,	lMaxSize_y,	temp_0;
	MUL_F		lSize_y,	temp_0,	lSize_y;
	INDIRECT_F	self,	pos_y,	lPos_y;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	2;
	INDIRECT_F	self,	pos_x,	lPos_x;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	ITEM_ALIGN_CENTER,	temp_0;
	IFNOT		temp_0,	7;
	INDIRECT_F	self,	pos_x,	temp_0;
	INDIRECT_F	self,	size_x,	temp_1;
	SUB_F		temp_1,	lSize_x,	temp_1;
	DIV_F		temp_1,	KEY_MENU,	temp_1;
	ADD_F		temp_0,	temp_1,	lPos_x;
	GOTO		10;
	INDIRECT_F	self,	alignment,	temp_0;
	EQ_F		temp_0,	ITEM_ALIGN_RIGHT,	temp_0;
	IFNOT		temp_0,	6;
	INDIRECT_F	self,	pos_x,	temp_0;
	INDIRECT_F	self,	size_x,	temp_1;
	ADD_F		temp_0,	temp_1,	temp_0;
	SUB_F		temp_0,	lSize_x,	lPos_x;
	GOTO		2;
	INDIRECT_F	self,	pos_x,	lPos_x;
	STORE_F	pName,	parm0_x;
	CALL1		_IB_IsPicture;
	IFNOT		return_x,	11;
	STORE_F	pName,	parm0_x;
	CALL1		_IB_GetPath;
	STORE_V	lPos,	parm0;
	STORE_F	return_x,	parm1_x;
	STORE_V	lSize,	parm2;
	STORE_V	pColor,	parm3;
	STORE_F	pAlpha,	parm4_x;
	STORE_F	pDrawFlag,	parm5_x;
	CALL6		Menu_DrawPicture;
	GOTO		9;
	INDIRECT_V	self,	fontSize_x,	temp_2;
	STORE_V	lPos,	parm0;
	STORE_F	pName,	parm1_x;
	STORE_V	temp_2,	parm2;
	STORE_V	pColor,	parm3;
	STORE_F	pAlpha,	parm4_x;
	STORE_F	pDrawFlag,	parm5_x;
	CALL6		Menu_DrawString;
	DONE;
}

void() Item_Button_Draw = asm
{
local string lText;
local float temp_0;
local float temp_1;
local vector temp_2;
local float temp_5;
	INDIRECT_F	self,	_state,	temp_0;
	EQ_F		temp_0,	ITEM_STATE_NORMAL,	temp_0;
	IFNOT		temp_0,	11;
	INDIRECT_S	self,	normal,	temp_0;
	INDIRECT_V	self,	color_x,	temp_2;
	INDIRECT_F	self,	alphas_x,	temp_1;
	INDIRECT_F	self,	drawFlags_x,	temp_5;
	STORE_F	temp_0,	parm0_x;
	STORE_V	temp_2,	parm1;
	STORE_F	temp_1,	parm2_x;
	STORE_F	temp_5,	parm3_x;
	CALL4		_IB_Draw;
	GOTO		41;
	INDIRECT_F	self,	_state,	temp_0;
	EQ_F		temp_0,	ITEM_STATE_SELECTED,	temp_0;
	IFNOT		temp_0,	16;
	INDIRECT_S	self,	selected,	temp_0;
	NE_S		temp_0,	string_null,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_S	self,	selected,	lText;
	GOTO		2;
	INDIRECT_S	self,	normal,	lText;
	INDIRECT_V	self,	colorSelected_x,	temp_2;
	INDIRECT_F	self,	alphas_y,	temp_0;
	INDIRECT_F	self,	drawFlags_y,	temp_1;
	STORE_F	lText,	parm0_x;
	STORE_V	temp_2,	parm1;
	STORE_F	temp_0,	parm2_x;
	STORE_F	temp_1,	parm3_x;
	CALL4		_IB_Draw;
	GOTO		23;
	INDIRECT_F	self,	_state,	temp_0;
	EQ_F		temp_0,	ITEM_STATE_PRESSED,	temp_0;
	IFNOT		temp_0,	20;
	INDIRECT_S	self,	pressed,	temp_0;
	NE_S		temp_0,	string_null,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_S	self,	pressed,	lText;
	GOTO		7;
	INDIRECT_S	self,	selected,	temp_0;
	NE_S		temp_0,	string_null,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_S	self,	selected,	lText;
	GOTO		2;
	INDIRECT_S	self,	normal,	lText;
	INDIRECT_V	self,	colorPressed_x,	temp_2;
	INDIRECT_F	self,	alphas_z,	temp_0;
	INDIRECT_F	self,	drawFlags_z,	temp_1;
	STORE_F	lText,	parm0_x;
	STORE_V	temp_2,	parm1;
	STORE_F	temp_0,	parm2_x;
	STORE_F	temp_1,	parm3_x;
	CALL4		_IB_Draw;
	DONE;
}

void () _IB_Calc;
void() _IB_Calc = asm
{
local float locked_1292;
local float temp_0;
	INDIRECT_V	self,	size_x,	locked_1292;
	EQ_V		locked_1292,	'0.000000 0.000000 0.000000',	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	self,	size_x,	locked_1292;
	CALL0		_IB_GetMaxSize;
	STOREP_V	return_x,	locked_1292;
	DONE;
}

void() Item_Button_Update = asm
{
local float temp_0;
	CALL0		Item_Link_Update;
	CALL0		_IB_Calc;
	INDIRECT_F	self,	_presstime,	temp_0;
	ADD_F		temp_0,	ITEM_BUTTON_ACTIONTIME,	temp_0;
	GT		temp_0,	Timer_Time,	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	self,	_state,	temp_0;
	STOREP_F	ITEM_STATE_PRESSED,	temp_0;
	GOTO		8;
	CALL0		Item_Link_IsSelected;
	IFNOT		return_x,	4;
	ADDRESS	self,	_state,	temp_0;
	STOREP_F	ITEM_STATE_SELECTED,	temp_0;
	GOTO		3;
	ADDRESS	self,	_state,	temp_0;
	STOREP_F	ITEM_STATE_NORMAL,	temp_0;
	DONE;
}

void(float pSelect, float pUser) Item_Button_Select = asm
{
local float temp_0;
	IFNOT		pSelect,	1;
	AND		pSelect,	pUser,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_S	self,	soundSelected,	parm0_x;
	CALL1		Sound_Play;
	DONE;
}

float(float pKey, float pAscii) Item_Button_Key = asm
{
local float temp_0;
local float temp_1;
	STORE_F	pKey,	parm0_x;
	STORE_F	pAscii,	parm1_x;
	CALL2		Item_Link_Key;
	IFNOT		return_x,	2;
	RETURN	FILE_APPEND;
	EQ_F		pKey,	K_SPACE,	temp_0;
	IF		temp_0,	2;
	EQ_F		pKey,	K_ENTER,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	2;
	EQ_F		pKey,	K_MOUSE1,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	7;
	INDIRECT_S	self,	soundPressed,	parm0_x;
	CALL1		Sound_Play;
	ADDRESS	self,	_presstime,	temp_0;
	STOREP_F	Timer_Time,	temp_0;
	CALL0		CtCall_Action;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void() Item_Button_Destroy = asm
{
	CALL0		CtCall_Destroy;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	selected,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	pressed,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	soundSelected,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	soundPressed,	parm1_x;
	CALL2		String_EntityFree;
	CALL0		Item_Link_Destroy;
	DONE;
}

void() Item_Button_Spawn = asm
{
local float temp_0;
local float temp_1;
	ADDRESS	self,	_presstime,	temp_0;
	SUB_F		Timer_Time,	FILE_APPEND,	temp_1;
	SUB_F		temp_1,	ITEM_BUTTON_ACTIONTIME,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	selected,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	pressed,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	soundSelected,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	soundPressed,	parm1_x;
	CALL2		String_EntityZone;
	CALL0		Item_Link_Init;
	INDIRECT_S	self,	normal,	parm0_x;
	CALL1		_IB_IsPicture;
	IFNOT		return_x,	5;
	INDIRECT_S	self,	normal,	parm0_x;
	CALL1		_IB_GetPath;
	STORE_F	return_x,	parm0_x;
	CALL1		Gfx_Precache;
	INDIRECT_S	self,	selected,	parm0_x;
	CALL1		_IB_IsPicture;
	IFNOT		return_x,	5;
	INDIRECT_S	self,	selected,	parm0_x;
	CALL1		_IB_GetPath;
	STORE_F	return_x,	parm0_x;
	CALL1		Gfx_Precache;
	INDIRECT_S	self,	pressed,	parm0_x;
	CALL1		_IB_IsPicture;
	IFNOT		return_x,	5;
	INDIRECT_S	self,	pressed,	parm0_x;
	CALL1		_IB_GetPath;
	STORE_F	return_x,	parm0_x;
	CALL1		Gfx_Precache;
	INDIRECT_S	self,	soundSelected,	parm0_x;
	CALL1		Sound_Precache;
	INDIRECT_S	self,	soundPressed,	parm0_x;
	CALL1		Sound_Precache;
	CALL0		_IB_Calc;
	ADDRESS	self,	_reinit,	temp_0;
	STOREP_FNC	CtCall_Reinit,	temp_0;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Item_Button_Destroy,	temp_0;
	ADDRESS	self,	_key,	temp_0;
	STOREP_FNC	Item_Button_Key,	temp_0;
	ADDRESS	self,	_draw,	temp_0;
	STOREP_FNC	Item_Button_Draw,	temp_0;
	ADDRESS	self,	_select,	temp_0;
	STOREP_FNC	Item_Button_Select,	temp_0;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_Button_Update,	temp_0;
	CALL0		CtCall_Init;
	DONE;
}

void() Item_EditBox_Draw = asm
{
local float lAlpha;
local vector lCursor;
local float temp_0;
local float temp_1;
local vector temp_2;
local vector temp_3;
local vector temp_4;
local float temp_5;
	INDIRECT_E	self,	_target,	temp_0;
	IF		temp_0,	2;
	RETURN	offset_0;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_F	self,	_state,	temp_0;
	EQ_F		temp_0,	ITEM_STATE_NORMAL,	temp_0;
	IFNOT		temp_0,	18;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_V	self,	origin_x,	temp_3;
	ADD_V		temp_2,	temp_3,	temp_2;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_S	temp_0,	value,	temp_0;
	INDIRECT_V	self,	fontSize_x,	temp_3;
	INDIRECT_V	self,	color_x,	temp_4;
	INDIRECT_F	self,	alphas_x,	temp_1;
	INDIRECT_F	self,	drawFlags_x,	temp_5;
	STORE_V	temp_2,	parm0;
	STORE_F	temp_0,	parm1_x;
	STORE_V	temp_3,	parm2;
	STORE_V	temp_4,	parm3;
	STORE_F	temp_1,	parm4_x;
	STORE_F	temp_5,	parm5_x;
	CALL6		Menu_DrawString;
	RETURN	offset_0;
	INDIRECT_F	self,	_cursorPos,	temp_0;
	INDIRECT_F	self,	fontSize_x,	temp_1;
	MUL_F		temp_0,	temp_1,	lCursor_x;
	INDIRECT_F	self,	fontSize_y,	lCursor_y;
	MUL_F		Timer_Time,	1000.000000,	parm0_x;
	STORE_F	500.000000,	parm1_x;
	CALL2		mod;
	GT		return_x,	250.000000,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	FILE_APPEND,	lAlpha;
	GOTO		2;
	STORE_F	KEY_GAME,	lAlpha;
	INDIRECT_F	self,	_state,	temp_0;
	EQ_F		temp_0,	ITEM_STATE_SELECTED,	temp_0;
	IFNOT		temp_0,	35;
	INDIRECT_F	self,	sizeCursor_y,	temp_0;
	SUB_F		lCursor_y,	temp_0,	lCursor_y;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_V	self,	origin_x,	temp_3;
	ADD_V		temp_2,	temp_3,	temp_2;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_S	temp_0,	value,	temp_0;
	INDIRECT_V	self,	fontSize_x,	temp_3;
	INDIRECT_V	self,	colorSelected_x,	temp_4;
	INDIRECT_F	self,	alphas_y,	temp_1;
	INDIRECT_F	self,	drawFlags_y,	temp_5;
	STORE_V	temp_2,	parm0;
	STORE_F	temp_0,	parm1_x;
	STORE_V	temp_3,	parm2;
	STORE_V	temp_4,	parm3;
	STORE_F	temp_1,	parm4_x;
	STORE_F	temp_5,	parm5_x;
	CALL6		Menu_DrawString;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_V	self,	origin_x,	temp_3;
	ADD_V		temp_2,	temp_3,	temp_2;
	ADD_V		temp_2,	lCursor,	temp_2;
	INDIRECT_V	self,	sizeCursor_x,	temp_3;
	INDIRECT_V	self,	colorCursor_x,	temp_4;
	INDIRECT_F	self,	alphasCursor_x,	temp_0;
	MUL_F		temp_0,	lAlpha,	temp_0;
	INDIRECT_F	self,	drawFlagsCursor_x,	temp_1;
	STORE_V	temp_2,	parm0;
	STORE_V	temp_3,	parm1;
	STORE_V	temp_4,	parm2;
	STORE_F	temp_0,	parm3_x;
	STORE_F	temp_1,	parm4_x;
	CALL5		Menu_Fill;
	GOTO		34;
	INDIRECT_F	self,	sizeCursorFlash_y,	temp_0;
	SUB_F		lCursor_y,	temp_0,	lCursor_y;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_V	self,	origin_x,	temp_3;
	ADD_V		temp_2,	temp_3,	temp_2;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_S	temp_0,	value,	temp_0;
	INDIRECT_V	self,	fontSize_x,	temp_3;
	INDIRECT_V	self,	colorPressed_x,	temp_4;
	INDIRECT_F	self,	alphas_z,	temp_1;
	INDIRECT_F	self,	drawFlags_z,	temp_5;
	STORE_V	temp_2,	parm0;
	STORE_F	temp_0,	parm1_x;
	STORE_V	temp_3,	parm2;
	STORE_V	temp_4,	parm3;
	STORE_F	temp_1,	parm4_x;
	STORE_F	temp_5,	parm5_x;
	CALL6		Menu_DrawString;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_V	self,	origin_x,	temp_3;
	ADD_V		temp_2,	temp_3,	temp_2;
	ADD_V		temp_2,	lCursor,	temp_2;
	INDIRECT_V	self,	sizeCursorFlash_x,	temp_3;
	INDIRECT_V	self,	colorCursorFlash_x,	temp_4;
	INDIRECT_F	self,	alphasCursor_y,	temp_0;
	MUL_F		temp_0,	lAlpha,	temp_0;
	INDIRECT_F	self,	drawFlagsCursor_y,	temp_1;
	STORE_V	temp_2,	parm0;
	STORE_V	temp_3,	parm1;
	STORE_V	temp_4,	parm2;
	STORE_F	temp_0,	parm3_x;
	STORE_F	temp_1,	parm4_x;
	CALL5		Menu_Fill;
	DONE;
}

void() Item_EditBox_Update = asm
{
local float locked_1585;
local float locked_1586;
local float temp_5;
local float temp_6;
	CALL0		Item_DataUser_Update;
	INDIRECT_F	self,	_presstime,	locked_1586;
	ADD_F		locked_1586,	ITEM_EDITBOX_FLASHTIME,	locked_1586;
	GT		locked_1586,	Timer_Time,	locked_1586;
	IFNOT		locked_1586,	4;
	ADDRESS	self,	_state,	locked_1586;
	STOREP_F	ITEM_STATE_PRESSED,	locked_1586;
	GOTO		8;
	EQ_E		Menu_ActiveItem,	self,	locked_1586;
	IFNOT		locked_1586,	4;
	ADDRESS	self,	_state,	locked_1586;
	STOREP_F	ITEM_STATE_SELECTED,	locked_1586;
	GOTO		3;
	ADDRESS	self,	_state,	locked_1586;
	STOREP_F	ITEM_STATE_NORMAL,	locked_1586;
	INDIRECT_E	self,	_target,	locked_1586;
	IF		locked_1586,	2;
	RETURN	offset_0;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_cursorPos,	locked_1586;
	INDIRECT_F	self,	_cursorPos,	locked_1585;
	INDIRECT_E	self,	_target,	temp_5;
	INDIRECT_S	temp_5,	value,	parm0_x;
	CALL1		strlen;
	STORE_F	KEY_GAME,	parm0_x;
	STORE_F	locked_1585,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		bound;
	STOREP_F	return_x,	locked_1586;
	ADDRESS	self,	origin_y,	locked_1586;
	STOREP_F	KEY_GAME,	locked_1586;
	INDIRECT_F	self,	_cursorPos,	locked_1586;
	ADD_F		locked_1586,	ITEM_EDITBOX_SCROLLDISTANCE,	locked_1586;
	INDIRECT_F	self,	size_x,	locked_1585;
	INDIRECT_F	self,	fontSize_x,	temp_5;
	DIV_F		locked_1585,	temp_5,	locked_1585;
	GT		locked_1586,	locked_1585,	locked_1586;
	IFNOT		locked_1586,	8;
	INDIRECT_E	self,	_target,	locked_1585;
	INDIRECT_F	locked_1585,	maxValue,	locked_1585;
	SUB_F		locked_1585,	ITEM_EDITBOX_SCROLLDISTANCE,	locked_1585;
	INDIRECT_F	self,	size_x,	temp_5;
	INDIRECT_F	self,	fontSize_x,	temp_6;
	DIV_F		temp_5,	temp_6,	temp_5;
	GT		locked_1585,	temp_5,	locked_1585;
	AND		locked_1586,	locked_1585,	locked_1586;
	IFNOT		locked_1586,	13;
	ADDRESS	self,	origin_x,	locked_1586;
	INDIRECT_F	self,	fontSize_x,	locked_1585;
	INDIRECT_F	self,	size_x,	temp_5;
	INDIRECT_F	self,	fontSize_x,	temp_6;
	DIV_F		temp_5,	temp_6,	parm0_x;
	CALL1		floor;
	INDIRECT_F	self,	_cursorPos,	temp_5;
	SUB_F		return_x,	temp_5,	temp_5;
	SUB_F		temp_5,	ITEM_EDITBOX_SCROLLDISTANCE,	temp_5;
	MUL_F		locked_1585,	temp_5,	locked_1585;
	STOREP_F	locked_1585,	locked_1586;
	GOTO		3;
	ADDRESS	self,	origin_x,	locked_1586;
	STOREP_F	KEY_GAME,	locked_1586;
	DONE;
}

void () _IEB_RemoveChar;
void() _IEB_RemoveChar = asm
{
local string lValue;
local string lTemp;
local float temp_0;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_S	temp_0,	value,	lValue;
	INDIRECT_F	self,	_cursorPos,	temp_0;
	STORE_F	lValue,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		substring;
	STORE_F	return_x,	parm0_x;
	CALL1		strcat;
	STORE_S	return_x,	lTemp;
	INDIRECT_F	self,	_cursorPos,	temp_0;
	ADD_F		temp_0,	FILE_APPEND,	temp_0;
	STORE_F	lValue,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	100000.000000,	parm2_x;
	CALL3		substring;
	STORE_F	lTemp,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		strcat;
	STORE_S	return_x,	lTemp;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	lTemp,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_presstime,	temp_0;
	STOREP_F	Timer_Time,	temp_0;
	INDIRECT_S	self,	soundKey,	parm0_x;
	CALL1		Sound_Play;
	DONE;
}

void (float) _IEB_InsertChar;
void(float pAscii) _IEB_InsertChar = asm
{
local string lTemp;
local string lValue;
local float temp_0;
local float temp_1;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_S	temp_0,	value,	lValue;
	INDIRECT_F	self,	_cursorPos,	temp_0;
	STORE_F	lValue,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		substring;
	STORE_F	pAscii,	parm0_x;
	STORE_F	return_x,	temp_0;
	CALL1		chr;
	STORE_F	return_x,	temp_1;
	STORE_F	temp_0,	return_x;
	STORE_F	return_x,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		strcat;
	STORE_S	return_x,	lTemp;
	INDIRECT_F	self,	_cursorPos,	temp_0;
	STORE_F	lValue,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	100000.000000,	parm2_x;
	CALL3		substring;
	STORE_F	lTemp,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		strcat;
	STORE_S	return_x,	lTemp;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	lTemp,	parm2_x;
	CALL3		String_EntitySet;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	ADDRESS	self,	_cursorPos,	temp_0;
	INDIRECT_F	self,	_cursorPos,	temp_1;
	ADD_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	ADDRESS	self,	_presstime,	temp_0;
	STOREP_F	Timer_Time,	temp_0;
	INDIRECT_S	self,	soundKey,	parm0_x;
	CALL1		Sound_Play;
	DONE;
}

float(float pKey, float pAscii) Item_EditBox_Key = asm
{
local float locked_1586;
local float temp_1;
	INDIRECT_E	self,	_target,	locked_1586;
	IF		locked_1586,	3;
	RETURN	KEY_GAME;
	GOTO		67;
	EQ_F		pKey,	K_ENTER,	locked_1586;
	IFNOT		locked_1586,	6;
	CALL0		CtCall_Action;
	INDIRECT_S	self,	soundKey,	parm0_x;
	CALL1		Sound_Play;
	RETURN	FILE_APPEND;
	GOTO		60;
	EQ_F		pKey,	K_LEFTARROW,	locked_1586;
	IFNOT		locked_1586,	11;
	INDIRECT_F	self,	_cursorPos,	locked_1586;
	IFNOT		locked_1586,	5;
	ADDRESS	self,	_cursorPos,	locked_1586;
	INDIRECT_F	self,	_cursorPos,	temp_1;
	SUB_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	INDIRECT_S	self,	soundMove,	parm0_x;
	CALL1		Sound_Play;
	RETURN	FILE_APPEND;
	GOTO		48;
	EQ_F		pKey,	K_RIGHTARROW,	locked_1586;
	IFNOT		locked_1586,	15;
	INDIRECT_F	self,	_cursorPos,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_S	temp_1,	value,	parm0_x;
	CALL1		strlen;
	LT		locked_1586,	return_x,	locked_1586;
	IFNOT		locked_1586,	5;
	ADDRESS	self,	_cursorPos,	locked_1586;
	INDIRECT_F	self,	_cursorPos,	temp_1;
	ADD_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	INDIRECT_S	self,	soundMove,	parm0_x;
	CALL1		Sound_Play;
	RETURN	FILE_APPEND;
	GOTO		32;
	EQ_F		pKey,	K_BACKSPACE,	locked_1586;
	IFNOT		locked_1586,	11;
	INDIRECT_F	self,	_cursorPos,	locked_1586;
	GT		locked_1586,	KEY_GAME,	locked_1586;
	IFNOT		locked_1586,	6;
	ADDRESS	self,	_cursorPos,	locked_1586;
	INDIRECT_F	self,	_cursorPos,	temp_1;
	SUB_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	CALL0		_IEB_RemoveChar;
	RETURN	FILE_APPEND;
	GOTO		20;
	EQ_F		pKey,	K_DEL,	locked_1586;
	IFNOT		locked_1586,	10;
	INDIRECT_F	self,	_cursorPos,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_S	temp_1,	value,	parm0_x;
	CALL1		strlen;
	LT		locked_1586,	return_x,	locked_1586;
	IFNOT		locked_1586,	2;
	CALL0		_IEB_RemoveChar;
	RETURN	FILE_APPEND;
	GOTO		9;
	LE		30.000000,	pAscii,	locked_1586;
	IFNOT		locked_1586,	2;
	LE		pAscii,	126.000000,	temp_1;
	AND		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	4;
	STORE_F	pAscii,	parm0_x;
	CALL1		_IEB_InsertChar;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void(float pSelect, float pUser) Item_EditBox_Select = asm
{
local float temp_0;
	STORE_F	pSelect,	parm0_x;
	STORE_F	pUser,	parm1_x;
	CALL2		CtCall_Select;
	IFNOT		pSelect,	1;
	AND		pSelect,	pUser,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_S	self,	soundSelected,	parm0_x;
	CALL1		Sound_Play;
	DONE;
}

void() Item_EditBox_Destroy = asm
{
	CALL0		CtCall_Destroy;
	CALL0		Item_DataUser_Destroy;
	STORE_F	self,	parm0_x;
	STORE_F	soundSelected,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	soundKey,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	soundMove,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_EditBox_Reinit = asm
{
local float temp_0;
	ADDRESS	self,	_cursorPos,	temp_0;
	STOREP_F	KEY_GAME,	temp_0;
	CALL0		CtCall_Reinit;
	DONE;
}

void() Item_EditBox_Spawn = asm
{
local float locked_1585;
local float locked_1586;
local vector temp_2;
local float temp_5;
	CALL0		Item_DataUser_Init;
	STORE_F	self,	parm0_x;
	STORE_F	soundSelected,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	soundKey,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	soundMove,	parm1_x;
	CALL2		String_EntityZone;
	INDIRECT_S	self,	soundSelected,	parm0_x;
	CALL1		Sound_Precache;
	INDIRECT_S	self,	soundKey,	parm0_x;
	CALL1		Sound_Precache;
	INDIRECT_S	self,	soundMove,	parm0_x;
	CALL1		Sound_Precache;
	INDIRECT_V	self,	size_x,	temp_2;
	EQ_V		temp_2,	'0.000000 0.000000 0.000000',	locked_1586;
	IFNOT		locked_1586,	2;
	INDIRECT_E	self,	_target,	locked_1585;
	AND		locked_1586,	locked_1585,	locked_1586;
	IFNOT		locked_1586,	4;
	INDIRECT_E	self,	_target,	locked_1585;
	INDIRECT_F	locked_1585,	maxValue,	locked_1585;
	GE		locked_1585,	KEY_GAME,	locked_1585;
	AND		locked_1586,	locked_1585,	locked_1586;
	IFNOT		locked_1586,	16;
	ADDRESS	self,	size_x,	locked_1586;
	INDIRECT_F	self,	fontSize_x,	locked_1585;
	INDIRECT_E	self,	_target,	temp_5;
	INDIRECT_F	temp_5,	maxValue,	temp_5;
	MUL_F		locked_1585,	temp_5,	locked_1585;
	INDIRECT_F	self,	sizeCursor_x,	temp_5;
	INDIRECT_V	self,	sizeCursorFlash_x,	temp_2;
	STORE_F	temp_5,	parm0_x;
	STORE_V	temp_2,	parm1;
	CALL2		max;
	ADD_F		locked_1585,	return_x,	locked_1585;
	STOREP_F	locked_1585,	locked_1586;
	ADDRESS	self,	size_y,	locked_1586;
	INDIRECT_F	self,	fontSize_y,	locked_1585;
	STOREP_F	locked_1585,	locked_1586;
	ADDRESS	self,	_reinit,	locked_1586;
	STOREP_FNC	Item_EditBox_Reinit,	locked_1586;
	ADDRESS	self,	_destroy,	locked_1586;
	STOREP_FNC	Item_EditBox_Destroy,	locked_1586;
	ADDRESS	self,	_key,	locked_1586;
	STOREP_FNC	Item_EditBox_Key,	locked_1586;
	ADDRESS	self,	_draw,	locked_1586;
	STOREP_FNC	Item_EditBox_Draw,	locked_1586;
	ADDRESS	self,	_select,	locked_1586;
	STOREP_FNC	Item_EditBox_Select,	locked_1586;
	ADDRESS	self,	_update,	locked_1586;
	STOREP_FNC	Item_EditBox_Update,	locked_1586;
	CALL0		CtCall_Init;
	DONE;
}

void () _IL_Calc;
void() _IL_Calc = asm
{
local float locked_1585;
local float locked_1586;
local vector temp_2;
local float temp_5;
	INDIRECT_V	self,	size_x,	temp_2;
	EQ_V		temp_2,	'0.000000 0.000000 0.000000',	locked_1586;
	IFNOT		locked_1586,	11;
	ADDRESS	self,	size_x,	locked_1586;
	INDIRECT_F	self,	fontSize_x,	locked_1585;
	INDIRECT_S	self,	text,	parm0_x;
	CALL1		strlen;
	MUL_F		locked_1585,	return_x,	locked_1585;
	STOREP_F	locked_1585,	locked_1586;
	ADDRESS	self,	size_y,	locked_1586;
	INDIRECT_F	self,	fontSize_y,	locked_1585;
	STOREP_F	locked_1585,	locked_1586;
	GOTO		13;
	INDIRECT_V	self,	fontSize_x,	temp_2;
	EQ_V		temp_2,	'0.000000 0.000000 0.000000',	locked_1586;
	IFNOT		locked_1586,	10;
	ADDRESS	self,	fontSize_x,	locked_1586;
	INDIRECT_F	self,	size_x,	locked_1585;
	INDIRECT_S	self,	text,	parm0_x;
	CALL1		strlen;
	DIV_F		locked_1585,	return_x,	locked_1585;
	STOREP_F	locked_1585,	locked_1586;
	ADDRESS	self,	fontSize_y,	locked_1586;
	INDIRECT_F	self,	size_y,	locked_1585;
	STOREP_F	locked_1585,	locked_1586;
	DONE;
}

void() Item_Label_Update = asm
{
	CALL0		_IL_Calc;
	DONE;
}

void() Item_Label_Draw = asm
{
local float locked_1585;
local float locked_1586;
local vector lAligned;
local vector temp_2;
local vector temp_3;
local float temp_5;
	INDIRECT_F	self,	alignment,	locked_1586;
	EQ_F		locked_1586,	KEY_GAME,	locked_1586;
	IFNOT		locked_1586,	3;
	INDIRECT_F	self,	pos_x,	lAligned_x;
	GOTO		27;
	INDIRECT_F	self,	alignment,	locked_1586;
	BITAND	locked_1586,	ITEM_ALIGN_CENTER,	locked_1586;
	IFNOT		locked_1586,	11;
	INDIRECT_F	self,	pos_x,	locked_1586;
	INDIRECT_F	self,	size_x,	locked_1585;
	INDIRECT_S	self,	text,	parm0_x;
	CALL1		strlen;
	INDIRECT_F	self,	fontSize_x,	temp_5;
	MUL_F		return_x,	temp_5,	temp_5;
	SUB_F		locked_1585,	temp_5,	locked_1585;
	DIV_F		locked_1585,	KEY_MENU,	locked_1585;
	ADD_F		locked_1586,	locked_1585,	lAligned_x;
	GOTO		14;
	INDIRECT_F	self,	alignment,	locked_1586;
	BITAND	locked_1586,	ITEM_ALIGN_RIGHT,	locked_1586;
	IFNOT		locked_1586,	10;
	INDIRECT_F	self,	pos_x,	locked_1586;
	INDIRECT_F	self,	size_x,	locked_1585;
	ADD_F		locked_1586,	locked_1585,	locked_1586;
	INDIRECT_S	self,	text,	parm0_x;
	CALL1		strlen;
	INDIRECT_F	self,	fontSize_x,	locked_1585;
	MUL_F		return_x,	locked_1585,	locked_1585;
	SUB_F		locked_1586,	locked_1585,	lAligned_x;
	GOTO		2;
	INDIRECT_F	self,	pos_x,	lAligned_x;
	INDIRECT_F	self,	pos_y,	lAligned_y;
	INDIRECT_S	self,	text,	locked_1586;
	INDIRECT_V	self,	fontSize_x,	temp_2;
	INDIRECT_V	self,	color_x,	temp_3;
	INDIRECT_F	self,	alpha,	locked_1585;
	INDIRECT_F	self,	drawFlag,	temp_5;
	STORE_V	lAligned,	parm0;
	STORE_F	locked_1586,	parm1_x;
	STORE_V	temp_2,	parm2;
	STORE_V	temp_3,	parm3;
	STORE_F	locked_1585,	parm4_x;
	STORE_F	temp_5,	parm5_x;
	CALL6		Menu_DrawString;
	DONE;
}

void() Item_Label_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	text,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_Label_Spawn = asm
{
local float temp_0;
local float temp_1;
local float temp_5;
	INDIRECT_F	self,	flag,	temp_0;
	EQ_F		temp_0,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	self,	flag,	temp_0;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_DRAWUPDATEONLY,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	text,	parm1_x;
	CALL2		String_EntityZone;
	CALL0		_IL_Calc;
	INDIRECT_F	self,	alignment,	temp_0;
	BITAND	temp_0,	ITEM_ALIGN_FIX_CENTER,	temp_0;
	IFNOT		temp_0,	8;
	ADDRESS	self,	pos_x,	temp_0;
	INDIRECT_F	self,	pos_x,	temp_1;
	INDIRECT_F	self,	size_x,	temp_5;
	DIV_F		temp_5,	KEY_MENU,	temp_5;
	SUB_F		temp_1,	temp_5,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		9;
	INDIRECT_F	self,	alignment,	temp_0;
	BITAND	temp_0,	ITEM_ALIGN_FIX_LEFT,	temp_0;
	IFNOT		temp_0,	6;
	ADDRESS	self,	pos_x,	temp_0;
	INDIRECT_F	self,	pos_x,	temp_1;
	INDIRECT_F	self,	size_x,	temp_5;
	SUB_F		temp_1,	temp_5,	temp_1;
	STOREP_F	temp_1,	temp_0;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Item_Label_Destroy,	temp_0;
	ADDRESS	self,	_draw,	temp_0;
	STOREP_FNC	Item_Label_Draw,	temp_0;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_Label_Update,	temp_0;
	DONE;
}

void () _IML_Calc;
void() _IML_Calc = asm
{
local vector lLine;
local float lLineNumber;
local float lMaxWidth;
local float temp_0;
local float temp_1;
	STORE_F	KEY_GAME,	lMaxWidth;
	STORE_F	KEY_GAME,	lLineNumber;
	STORE_V	'0.000000 0.000000 0.000000',	lLine;
	INDIRECT_F	self,	wrap,	temp_0;
	IFNOT		temp_0,	9;
	INDIRECT_S	self,	text,	temp_0;
	INDIRECT_F	self,	wrap,	temp_1;
	STORE_F	temp_0,	parm0_x;
	STORE_V	lLine,	parm1;
	STORE_F	temp_1,	parm2_x;
	CALL3		Util_GetEndOfWrappedLine;
	STORE_V	return,	lLine;
	GOTO		5;
	INDIRECT_S	self,	text,	parm0_x;
	STORE_V	lLine,	parm1;
	CALL2		Util_GetEndOfLine;
	STORE_V	return,	lLine;
	ADD_F		lLineNumber,	FILE_APPEND,	lLineNumber;
	STORE_F	lMaxWidth,	parm0_x;
	STORE_F	lLine_z,	parm1_x;
	CALL2		max;
	STORE_F	return_x,	lMaxWidth;
	NE_F		lLine_x,	lLine_y,	temp_0;
	IF		temp_0,	-20;
	ADDRESS	self,	size_x,	temp_0;
	INDIRECT_F	self,	fontSize_x,	temp_1;
	MUL_F		lMaxWidth,	temp_1,	temp_1;
	STOREP_F	temp_1,	temp_0;
	ADDRESS	self,	size_y,	temp_0;
	INDIRECT_F	self,	fontSize_y,	temp_1;
	MUL_F		lLineNumber,	temp_1,	temp_1;
	STOREP_F	temp_1,	temp_0;
	DONE;
}

void (vector, string) _IML_DrawLine;
void(vector pPosition, string pText) _IML_DrawLine = asm
{
local float locked_1585;
local float locked_1586;
local vector temp_2;
local vector temp_3;
local float temp_5;
	INDIRECT_F	self,	alignment,	locked_1586;
	EQ_F		locked_1586,	ITEM_ALIGN_CENTER,	locked_1586;
	IFNOT		locked_1586,	11;
	INDIRECT_F	self,	pos_x,	locked_1586;
	INDIRECT_F	self,	size_x,	locked_1585;
	STORE_F	pText,	parm0_x;
	CALL1		strlen;
	INDIRECT_F	self,	fontSize_x,	temp_5;
	MUL_F		return_x,	temp_5,	temp_5;
	SUB_F		locked_1585,	temp_5,	locked_1585;
	DIV_F		locked_1585,	KEY_MENU,	locked_1585;
	ADD_F		locked_1586,	locked_1585,	pPosition_x;
	GOTO		14;
	INDIRECT_F	self,	alignment,	locked_1586;
	EQ_F		locked_1586,	ITEM_ALIGN_RIGHT,	locked_1586;
	IFNOT		locked_1586,	10;
	INDIRECT_F	self,	pos_x,	locked_1586;
	INDIRECT_F	self,	size_x,	locked_1585;
	ADD_F		locked_1586,	locked_1585,	locked_1586;
	STORE_F	pText,	parm0_x;
	CALL1		strlen;
	INDIRECT_F	self,	fontSize_x,	locked_1585;
	MUL_F		return_x,	locked_1585,	locked_1585;
	SUB_F		locked_1586,	locked_1585,	pPosition_x;
	GOTO		2;
	INDIRECT_F	self,	pos_x,	pPosition_x;
	INDIRECT_V	self,	fontSize_x,	temp_2;
	INDIRECT_V	self,	color_x,	temp_3;
	INDIRECT_F	self,	alpha,	locked_1586;
	INDIRECT_F	self,	drawFlag,	locked_1585;
	STORE_V	pPosition,	parm0;
	STORE_F	pText,	parm1_x;
	STORE_V	temp_2,	parm2;
	STORE_V	temp_3,	parm3;
	STORE_F	locked_1586,	parm4_x;
	STORE_F	locked_1585,	parm5_x;
	CALL6		Menu_DrawString;
	DONE;
}

void() Item_MultiLabel_Draw = asm
{
local vector lLine;
local vector lPosition;
local float temp_0;
local float temp_1;
	INDIRECT_F	self,	pos_y,	lPosition_y;
	STORE_V	'0.000000 0.000000 0.000000',	lLine;
	INDIRECT_F	self,	wrap,	temp_0;
	IFNOT		temp_0,	9;
	INDIRECT_S	self,	text,	temp_0;
	INDIRECT_F	self,	wrap,	temp_1;
	STORE_F	temp_0,	parm0_x;
	STORE_V	lLine,	parm1;
	STORE_F	temp_1,	parm2_x;
	CALL3		Util_GetEndOfWrappedLine;
	STORE_V	return,	lLine;
	GOTO		5;
	INDIRECT_S	self,	text,	parm0_x;
	STORE_V	lLine,	parm1;
	CALL2		Util_GetEndOfLine;
	STORE_V	return,	lLine;
	INDIRECT_S	self,	text,	temp_0;
	SUB_F		lLine_x,	lLine_z,	temp_1;
	ADD_F		temp_1,	FILE_APPEND,	temp_1;
	STORE_F	temp_0,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	STORE_F	lLine_z,	parm2_x;
	CALL3		substring;
	STORE_V	lPosition,	parm0;
	STORE_F	return_x,	parm1_x;
	CALL2		_IML_DrawLine;
	INDIRECT_F	self,	fontSize_y,	temp_0;
	ADD_F		lPosition_y,	temp_0,	lPosition_y;
	NE_F		lLine_x,	lLine_y,	temp_0;
	IF		temp_0,	-27;
	DONE;
}

void() Item_MultiLabel_Update = asm
{
local float temp_0;
local vector temp_2;
	INDIRECT_V	self,	size_x,	temp_2;
	EQ_V		temp_2,	'0.000000 0.000000 0.000000',	temp_0;
	IFNOT		temp_0,	2;
	CALL0		_IML_Calc;
	DONE;
}

void() Item_MultiLabel_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	text,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_MultiLabel_Spawn = asm
{
local float temp_0;
local float temp_1;
	INDIRECT_F	self,	flag,	temp_0;
	EQ_F		temp_0,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	self,	flag,	temp_0;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_DRAWUPDATEONLY,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	text,	parm1_x;
	CALL2		String_EntityZone;
	CALL0		Item_MultiLabel_Update;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Item_MultiLabel_Destroy,	temp_0;
	ADDRESS	self,	_draw,	temp_0;
	STOREP_FNC	Item_MultiLabel_Draw,	temp_0;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_MultiLabel_Update,	temp_0;
	DONE;
}

void() Item_Picture_Draw = asm
{
local float temp_0;
local float temp_1;
local vector temp_2;
local vector temp_3;
local vector temp_4;
local float temp_5;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_S	self,	picture,	temp_0;
	INDIRECT_V	self,	size_x,	temp_3;
	INDIRECT_V	self,	color_x,	temp_4;
	INDIRECT_F	self,	alpha,	temp_1;
	INDIRECT_F	self,	drawFlag,	temp_5;
	STORE_V	temp_2,	parm0;
	STORE_F	temp_0,	parm1_x;
	STORE_V	temp_3,	parm2;
	STORE_V	temp_4,	parm3;
	STORE_F	temp_1,	parm4_x;
	STORE_F	temp_5,	parm5_x;
	CALL6		Menu_DrawPicture;
	DONE;
}

void() Item_Picture_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	picture,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_Picture_Spawn = asm
{
local float temp_0;
local float temp_1;
	INDIRECT_S	self,	picture,	temp_0;
	NOT_S		temp_0,	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	self,	parm0_x;
	CALL1		Menu_DeleteAfterFrame;
	RETURN	offset_0;
	STORE_F	self,	parm0_x;
	STORE_F	picture,	parm1_x;
	CALL2		String_EntityZone;
	INDIRECT_S	self,	picture,	parm0_x;
	CALL1		Gfx_Precache;
	INDIRECT_F	self,	flag,	temp_0;
	EQ_F		temp_0,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	self,	flag,	temp_0;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_NOSELECT,	temp_1;
	STOREP_F	temp_1,	temp_0;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Item_Picture_Destroy,	temp_0;
	ADDRESS	self,	_draw,	temp_0;
	STOREP_FNC	Item_Picture_Draw,	temp_0;
	DONE;
}

void() Item_Rect_Draw = asm
{
local float temp_0;
local float temp_1;
local vector temp_2;
local vector temp_3;
local vector temp_4;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_V	self,	size_x,	temp_3;
	INDIRECT_V	self,	color_x,	temp_4;
	INDIRECT_F	self,	alpha,	temp_0;
	INDIRECT_F	self,	drawFlag,	temp_1;
	STORE_V	temp_2,	parm0;
	STORE_V	temp_3,	parm1;
	STORE_V	temp_4,	parm2;
	STORE_F	temp_0,	parm3_x;
	STORE_F	temp_1,	parm4_x;
	CALL5		Menu_Fill;
	DONE;
}

void() Item_Rect_Spawn = asm
{
local float temp_0;
local float temp_1;
	ADDRESS	self,	flag,	temp_0;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_NOSELECT,	temp_1;
	STOREP_F	temp_1,	temp_0;
	ADDRESS	self,	_draw,	temp_0;
	STOREP_FNC	Item_Rect_Draw,	temp_0;
	DONE;
}

float () _IS_GetValue;
float() _IS_GetValue = asm
{
local entity lLink;
local float lValue;
local float temp_0;
local float temp_1;
local float temp_5;
	INDIRECT_E	self,	_target,	temp_0;
	IF		temp_0,	2;
	RETURN	KEY_GAME;
	INDIRECT_E	self,	_target,	lLink;
	STORE_F	lLink,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_F	lLink,	maxValue,	temp_0;
	INDIRECT_F	lLink,	minValue,	temp_1;
	LE		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	KEY_GAME,	lValue;
	GOTO		8;
	INDIRECT_F	lLink,	_realValue,	temp_0;
	INDIRECT_F	lLink,	minValue,	temp_1;
	SUB_F		temp_0,	temp_1,	temp_0;
	INDIRECT_F	lLink,	maxValue,	temp_1;
	INDIRECT_F	lLink,	minValue,	temp_5;
	SUB_F		temp_1,	temp_5,	temp_1;
	DIV_F		temp_0,	temp_1,	lValue;
	RETURN	lValue;
	DONE;
}

void(float pSelect, float pUser) Item_Slider_Select = asm
{
local float temp_0;
	BITAND	pSelect,	pUser,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_S	self,	soundSelected,	parm0_x;
	CALL1		Sound_Play;
	DONE;
}

void() Item_Slider_Draw = asm
{
local vector lSliderPos;
local float lValue;
local float temp_0;
local float temp_1;
local vector temp_2;
local vector temp_3;
local vector temp_4;
local float temp_5;
local float temp_6;
	CALL0		_IS_GetValue;
	STORE_F	return_x,	lValue;
	INDIRECT_F	self,	pos_x,	temp_0;
	INDIRECT_F	self,	size_x,	temp_1;
	INDIRECT_F	self,	proportions_x,	temp_5;
	INDIRECT_F	self,	proportions_y,	temp_6;
	MUL_F		lValue,	temp_6,	temp_6;
	ADD_F		temp_5,	temp_6,	temp_5;
	MUL_F		temp_1,	temp_5,	temp_1;
	ADD_F		temp_0,	temp_1,	temp_0;
	INDIRECT_F	self,	sizeSlider_x,	temp_1;
	MUL_F		lValue,	temp_1,	temp_1;
	SUB_F		temp_0,	temp_1,	lSliderPos_x;
	INDIRECT_F	self,	pos_y,	temp_0;
	INDIRECT_F	self,	size_y,	temp_1;
	INDIRECT_F	self,	sizeSlider_y,	temp_5;
	SUB_F		temp_1,	temp_5,	temp_1;
	INDIRECT_F	self,	direction_y,	temp_5;
	INDIRECT_F	self,	direction_x,	temp_6;
	SUB_F		temp_5,	temp_6,	temp_5;
	MUL_F		temp_5,	lValue,	temp_5;
	SUB_F		FILE_APPEND,	temp_5,	temp_5;
	INDIRECT_F	self,	direction_x,	temp_6;
	SUB_F		temp_5,	temp_6,	temp_5;
	MUL_F		temp_1,	temp_5,	temp_1;
	ADD_F		temp_0,	temp_1,	lSliderPos_y;
	EQ_E		Menu_ActiveItem,	self,	temp_0;
	IFNOT		temp_0,	27;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_S	self,	picture,	temp_0;
	INDIRECT_V	self,	size_x,	temp_3;
	INDIRECT_V	self,	colorSelected_x,	temp_4;
	INDIRECT_F	self,	alphas_y,	temp_1;
	INDIRECT_F	self,	drawFlags_y,	temp_5;
	STORE_V	temp_2,	parm0;
	STORE_F	temp_0,	parm1_x;
	STORE_V	temp_3,	parm2;
	STORE_V	temp_4,	parm3;
	STORE_F	temp_1,	parm4_x;
	STORE_F	temp_5,	parm5_x;
	CALL6		Menu_DrawPicture;
	INDIRECT_S	self,	pictureSlider,	temp_0;
	INDIRECT_V	self,	sizeSlider_x,	temp_2;
	INDIRECT_V	self,	colorSelected_x,	temp_3;
	INDIRECT_F	self,	alphas_y,	temp_1;
	INDIRECT_F	self,	drawFlags_y,	temp_5;
	STORE_V	lSliderPos,	parm0;
	STORE_F	temp_0,	parm1_x;
	STORE_V	temp_2,	parm2;
	STORE_V	temp_3,	parm3;
	STORE_F	temp_1,	parm4_x;
	STORE_F	temp_5,	parm5_x;
	CALL6		Menu_DrawPicture;
	GOTO		26;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_S	self,	picture,	temp_0;
	INDIRECT_V	self,	size_x,	temp_3;
	INDIRECT_V	self,	color_x,	temp_4;
	INDIRECT_F	self,	alphas_x,	temp_1;
	INDIRECT_F	self,	drawFlags_x,	temp_5;
	STORE_V	temp_2,	parm0;
	STORE_F	temp_0,	parm1_x;
	STORE_V	temp_3,	parm2;
	STORE_V	temp_4,	parm3;
	STORE_F	temp_1,	parm4_x;
	STORE_F	temp_5,	parm5_x;
	CALL6		Menu_DrawPicture;
	INDIRECT_S	self,	pictureSlider,	temp_0;
	INDIRECT_V	self,	sizeSlider_x,	temp_2;
	INDIRECT_V	self,	color_x,	temp_3;
	INDIRECT_F	self,	alphas_x,	temp_1;
	INDIRECT_F	self,	drawFlags_x,	temp_5;
	STORE_V	lSliderPos,	parm0;
	STORE_F	temp_0,	parm1_x;
	STORE_V	temp_2,	parm2;
	STORE_V	temp_3,	parm3;
	STORE_F	temp_1,	parm4_x;
	STORE_F	temp_5,	parm5_x;
	CALL6		Menu_DrawPicture;
	DONE;
}

void (float) _IS_Change;
void(float pValue) _IS_Change = asm
{
local float temp_0;
local float temp_1;
	LT		pValue,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	4;
	INDIRECT_S	self,	soundDecrease,	parm0_x;
	CALL1		Sound_Play;
	GOTO		3;
	INDIRECT_S	self,	soundIncrease,	parm0_x;
	CALL1		Sound_Play;
	INDIRECT_E	self,	_target,	temp_0;
	ADDRESS	temp_0,	_realValue,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	ADD_F		temp_1,	pValue,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	CALL0		CtCall_Action;
	DONE;
}

float(float pKey, float pAscii) Item_Slider_Key = asm
{
local float lValue;
local float lPos;
local float temp_0;
local float temp_1;
local vector temp_2;
local vector temp_3;
local float temp_5;
	INDIRECT_E	self,	_target,	temp_0;
	IF		temp_0,	2;
	RETURN	KEY_GAME;
	GOTO		73;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_F	temp_0,	stepValue,	temp_0;
	SUB_F		KEY_GAME,	temp_0,	parm0_x;
	CALL1		_IS_Change;
	RETURN	FILE_APPEND;
	GOTO		73;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_F	temp_0,	stepValue,	parm0_x;
	CALL1		_IS_Change;
	RETURN	FILE_APPEND;
	GOTO		68;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_V	self,	size_x,	temp_3;
	STORE_V	Menu_Cursor_Position,	parm0;
	STORE_V	temp_2,	parm1;
	STORE_V	temp_3,	parm2;
	CALL3		Util_InRect;
	IF		return_x,	2;
	RETURN	KEY_GAME;
	INDIRECT_F	self,	pos_x,	temp_0;
	SUB_F		Menu_Cursor_Position_x,	temp_0,	temp_0;
	INDIRECT_F	self,	size_x,	temp_1;
	DIV_F		temp_0,	temp_1,	lPos;
	INDIRECT_F	self,	proportions_x,	temp_0;
	LE		lPos,	temp_0,	temp_0;
	IFNOT		temp_0,	6;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_F	temp_0,	stepValue,	temp_0;
	SUB_F		KEY_GAME,	temp_0,	parm0_x;
	CALL1		_IS_Change;
	GOTO		41;
	INDIRECT_F	self,	proportions_x,	temp_0;
	INDIRECT_F	self,	proportions_y,	temp_1;
	ADD_F		temp_0,	temp_1,	temp_0;
	LE		lPos,	temp_0,	temp_0;
	IFNOT		temp_0,	2;
	INDIRECT_F	self,	proportions_y,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	30;
	INDIRECT_F	self,	pos_x,	temp_0;
	SUB_F		Menu_Cursor_Position_x,	temp_0,	temp_0;
	INDIRECT_F	self,	sizeSlider_x,	temp_1;
	DIV_F		temp_1,	KEY_MENU,	temp_1;
	SUB_F		temp_0,	temp_1,	temp_0;
	INDIRECT_F	self,	size_x,	temp_1;
	INDIRECT_F	self,	proportions_x,	temp_5;
	MUL_F		temp_1,	temp_5,	temp_1;
	SUB_F		temp_0,	temp_1,	lValue;
	INDIRECT_F	self,	size_x,	temp_0;
	INDIRECT_F	self,	proportions_y,	temp_1;
	MUL_F		temp_0,	temp_1,	temp_0;
	INDIRECT_F	self,	sizeSlider_x,	temp_1;
	SUB_F		temp_0,	temp_1,	temp_0;
	DIV_F		lValue,	temp_0,	lValue;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_F	temp_0,	maxValue,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	minValue,	temp_1;
	SUB_F		temp_0,	temp_1,	temp_0;
	MUL_F		lValue,	temp_0,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	minValue,	temp_1;
	ADD_F		temp_0,	temp_1,	lValue;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_F	temp_0,	_realValue,	temp_0;
	SUB_F		lValue,	temp_0,	parm0_x;
	CALL1		_IS_Change;
	GOTO		4;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_F	temp_0,	stepValue,	parm0_x;
	CALL1		_IS_Change;
	RETURN	FILE_APPEND;
	EQ_F		pKey,	K_LEFTARROW,	temp_0;
	IF		temp_0,	-73;
	EQ_F		pKey,	K_RIGHTARROW,	temp_0;
	IF		temp_0,	-69;
	EQ_F		pKey,	K_MOUSE1,	temp_0;
	IF		temp_0,	-66;
	RETURN	KEY_GAME;
	DONE;
}

void() Item_Slider_Destroy = asm
{
	CALL0		CtCall_Destroy;
	CALL0		Item_DataUser_Destroy;
	STORE_F	self,	parm0_x;
	STORE_F	picture,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	pictureSlider,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	soundSelected,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	soundIncrease,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	soundDecrease,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_Slider_Spawn = asm
{
local float locked_1292;
local float temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	picture,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	pictureSlider,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	soundSelected,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	soundIncrease,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	soundDecrease,	parm1_x;
	CALL2		String_EntityZone;
	CALL0		Item_DataUser_Init;
	INDIRECT_S	self,	picture,	parm0_x;
	CALL1		Gfx_Precache;
	INDIRECT_S	self,	pictureSlider,	parm0_x;
	CALL1		Gfx_Precache;
	INDIRECT_S	self,	soundSelected,	parm0_x;
	CALL1		Sound_Precache;
	INDIRECT_S	self,	soundIncrease,	parm0_x;
	CALL1		Sound_Precache;
	INDIRECT_S	self,	soundDecrease,	parm0_x;
	CALL1		Sound_Precache;
	INDIRECT_V	self,	size_x,	locked_1292;
	EQ_V		locked_1292,	'0.000000 0.000000 0.000000',	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	self,	size_x,	locked_1292;
	INDIRECT_S	self,	picture,	parm0_x;
	CALL1		Gfx_GetImageSize;
	STOREP_V	return_x,	locked_1292;
	INDIRECT_V	self,	sizeSlider_x,	locked_1292;
	EQ_V		locked_1292,	'0.000000 0.000000 0.000000',	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	self,	sizeSlider_x,	locked_1292;
	INDIRECT_S	self,	pictureSlider,	parm0_x;
	CALL1		Gfx_GetImageSize;
	STOREP_V	return_x,	locked_1292;
	ADDRESS	self,	_reinit,	temp_0;
	STOREP_FNC	CtCall_Reinit,	temp_0;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Item_Slider_Destroy,	temp_0;
	ADDRESS	self,	_key,	temp_0;
	STOREP_FNC	Item_Slider_Key,	temp_0;
	ADDRESS	self,	_draw,	temp_0;
	STOREP_FNC	Item_Slider_Draw,	temp_0;
	ADDRESS	self,	_select,	temp_0;
	STOREP_FNC	Item_Slider_Select,	temp_0;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_DataUser_Update,	temp_0;
	CALL0		CtCall_Init;
	DONE;
}

void() Item_ValueButton_Update = asm
{
local float temp_0;
local vector temp_2;
	CALL0		Item_DataUser_Update;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_GET,	parm1_x;
	CALL2		Raise_DataEvent;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_S	temp_0,	value,	temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		String_EntitySet;
	ADDRESS	self,	size_x,	temp_2_x;
	STOREP_V	'0.000000 0.000000 0.000000',	temp_2;
	CALL0		Item_Button_Update;
	DONE;
}

void() Item_ValueButton_Destroy = asm
{
	CALL0		Item_DataUser_Destroy;
	CALL0		Item_Button_Destroy;
	DONE;
}

void() Item_ValueButton_Spawn = asm
{
local float temp_0;
	CALL0		Item_DataUser_Init;
	CALL0		Item_Button_Spawn;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Item_ValueButton_Destroy,	temp_0;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_ValueButton_Update,	temp_0;
	DONE;
}

float(float pKey, float pAscii) Item_FloatingArea_Key = asm
{
local float temp_0;
local float temp_1;
	EQ_F		pKey,	K_MOUSE1,	temp_0;
	IF		temp_0,	2;
	EQ_F		pKey,	K_ENTER,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	11;
	INDIRECT_F	self,	_state,	temp_0;
	NE_F		temp_0,	ITEM_STATE_PRESSED,	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	self,	_state,	temp_0;
	STOREP_F	ITEM_STATE_PRESSED,	temp_0;
	GOTO		3;
	ADDRESS	self,	_state,	temp_0;
	STOREP_F	ITEM_STATE_NORMAL,	temp_0;
	RETURN	FILE_APPEND;
	GOTO		5;
	EQ_F		pKey,	K_ESCAPE,	temp_0;
	IFNOT		temp_0,	3;
	ADDRESS	self,	_state,	temp_0;
	STOREP_F	ITEM_STATE_NORMAL,	temp_0;
	RETURN	KEY_GAME;
	DONE;
}

void() Item_FloatingArea_Update = asm
{
local float locked_1586;
local float temp_1;
local vector temp_2;
local vector temp_3;
	INDIRECT_S	self,	target,	locked_1586;
	NOT_S		locked_1586,	locked_1586;
	IFNOT		locked_1586,	5;
	ADDRESS	self,	_state,	locked_1586;
	STOREP_F	ITEM_STATE_NORMAL,	locked_1586;
	RETURN	offset_0;
	GOTO		10;
	INDIRECT_S	self,	target,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_S	temp_1,	name,	temp_1;
	NE_S		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	5;
	ADDRESS	self,	_target,	locked_1586;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		Menu_GetItem;
	STOREP_ENT	return_x,	locked_1586;
	INDIRECT_F	self,	_state,	locked_1586;
	EQ_F		locked_1586,	ITEM_STATE_PRESSED,	locked_1586;
	IFNOT		locked_1586,	8;
	INDIRECT_E	self,	_target,	locked_1586;
	ADDRESS	locked_1586,	pos_x,	temp_2_x;
	INDIRECT_E	self,	_target,	locked_1586;
	INDIRECT_V	locked_1586,	pos_x,	temp_3;
	ADD_V		temp_3,	Cursor_Relative,	temp_3;
	STOREP_V	temp_3_x,	temp_2;
	GOTO		5;
	EQ_E		Menu_ActiveItem,	self,	locked_1586;
	IFNOT		locked_1586,	3;
	ADDRESS	self,	_state,	locked_1586;
	STOREP_F	ITEM_STATE_SELECTED,	locked_1586;
	DONE;
}

void () Item_FloatingArea_Destroy;
void() Item_FloatingArea_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void (float, float) Item_FloatingArea_Select;
void(float pSelect, float pUser) Item_FloatingArea_Select = asm
{
local float temp_0;
local float temp_1;
	NOT_F		pSelect,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_F	self,	_state,	temp_1;
	EQ_F		temp_1,	ITEM_STATE_PRESSED,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	self,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		Menu_CorrectSelection;
	DONE;
}

void() Item_FloatingArea_Spawn = asm
{
local float temp_0;
local float temp_1;
	ADDRESS	self,	flag,	temp_0;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_CHILDDRAWUPDATEONLY,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityZone;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_FloatingArea_Update,	temp_0;
	ADDRESS	self,	_key,	temp_0;
	STOREP_FNC	Item_FloatingArea_Key,	temp_0;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Item_FloatingArea_Destroy,	temp_0;
	ADDRESS	self,	_select,	temp_0;
	STOREP_FNC	Item_FloatingArea_Select,	temp_0;
	DONE;
}

float(float pKey, float pAscii) Item_SwitchButton_Key = asm
{
local float temp_0;
local float temp_1;
	INDIRECT_E	self,	_target,	temp_0;
	IF		temp_0,	2;
	RETURN	KEY_GAME;
	EQ_F		pKey,	K_SPACE,	temp_0;
	IF		temp_0,	2;
	EQ_F		pKey,	K_ENTER,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	2;
	EQ_F		pKey,	K_MOUSE1,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	2;
	EQ_F		pKey,	K_RIGHTARROW,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	28;
	INDIRECT_S	self,	soundPressed,	parm0_x;
	CALL1		Sound_Play;
	ADDRESS	self,	_presstime,	temp_0;
	STOREP_F	Timer_Time,	temp_0;
	INDIRECT_E	self,	_target,	temp_0;
	ADDRESS	temp_0,	_realValue,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	ADD_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_F	temp_0,	_realValue,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	maxValue,	temp_1;
	GT		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	6;
	INDIRECT_E	self,	_target,	temp_0;
	ADDRESS	temp_0,	_realValue,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	minValue,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	CALL0		CtCall_Action;
	RETURN	FILE_APPEND;
	GOTO		35;
	EQ_F		pKey,	K_BACKSPACE,	temp_0;
	IF		temp_0,	2;
	EQ_F		pKey,	K_MOUSE2,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	2;
	EQ_F		pKey,	K_LEFTARROW,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	27;
	INDIRECT_S	self,	soundPressed,	parm0_x;
	CALL1		Sound_Play;
	ADDRESS	self,	_presstime,	temp_0;
	STOREP_F	Timer_Time,	temp_0;
	INDIRECT_E	self,	_target,	temp_0;
	ADDRESS	temp_0,	_realValue,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	_realValue,	temp_1;
	SUB_F		temp_1,	FILE_APPEND,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_F	temp_0,	_realValue,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	minValue,	temp_1;
	LT		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	6;
	INDIRECT_E	self,	_target,	temp_0;
	ADDRESS	temp_0,	_realValue,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	maxValue,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_E	self,	_target,	parm0_x;
	STORE_F	ITEM_DATALINK_SET,	parm1_x;
	CALL2		Raise_DataEvent;
	CALL0		CtCall_Action;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void() Item_SwitchButton_Spawn = asm
{
local float temp_0;
	CALL0		Item_ValueButton_Spawn;
	ADDRESS	self,	_key,	temp_0;
	STOREP_FNC	Item_SwitchButton_Key,	temp_0;
	DONE;
}

float _VSB_UP_HEIGHT;
float _VSB_DOWN_HEIGHT;
float _VSB_PRECISION;
float _VSB_MINHEIGHT;
float _VSB_CLICKAREA_COLOR_x;
float _VSB_CLICKAREA_COLOR_y;
float _VSB_CLICKAREA_COLOR_z;
vector _VSB_CLICKAREA_COLOR;
float _VSB_SCOLLER_COLOR_x;
float _VSB_SCOLLER_COLOR_y;
float _VSB_SCOLLER_COLOR_z;
vector _VSB_SCOLLER_COLOR;
float _VSB_SCROLLAREA_COLOR_x;
float _VSB_SCROLLAREA_COLOR_y;
float _VSB_SCROLLAREA_COLOR_z;
vector _VSB_SCROLLAREA_COLOR;
float () _IVSB_GetSizeOfScroller;
float() _IVSB_GetSizeOfScroller = asm
{
local float lScrollerSize;
local float lTotalSize;
local float lVisibleSize;
local float lScrollerRange;
local float temp_0;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_E	temp_0,	_child,	temp_0;
	INDIRECT_F	temp_0,	size_y,	lTotalSize;
	INDIRECT_F	self,	size_y,	lVisibleSize;
	INDIRECT_F	self,	size_y,	temp_0;
	SUB_F		temp_0,	_VSB_UP_HEIGHT,	temp_0;
	SUB_F		temp_0,	_VSB_UP_HEIGHT,	lScrollerRange;
	MUL_F		lVisibleSize,	lScrollerRange,	temp_0;
	DIV_F		temp_0,	lTotalSize,	lScrollerSize;
	STORE_F	_VSB_MINHEIGHT,	parm0_x;
	STORE_F	lScrollerSize,	parm1_x;
	CALL2		max;
	STORE_F	return_x,	lScrollerSize;
	RETURN	lScrollerSize;
	DONE;
}

void() Item_VScrollBar_Draw = asm
{
local vector lSize;
local vector lPosition;
local float temp_0;
local float temp_1;
local vector temp_2;
local float temp_5;
local float temp_6;
	INDIRECT_E	self,	_target,	temp_0;
	EQ_E		temp_0,	null_entity,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	offset_0;
	INDIRECT_V	self,	pos_x,	lPosition;
	INDIRECT_V	self,	size_x,	lSize;
	STORE_F	_VSB_UP_HEIGHT,	lSize_y;
	STORE_V	lPosition,	parm0;
	STORE_V	lSize,	parm1;
	STORE_V	_VSB_CLICKAREA_COLOR,	parm2;
	STORE_F	FILE_APPEND,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Fill;
	INDIRECT_F	self,	pos_y,	temp_0;
	ADD_F		temp_0,	_VSB_UP_HEIGHT,	lPosition_y;
	INDIRECT_F	self,	size_y,	temp_0;
	SUB_F		temp_0,	_VSB_UP_HEIGHT,	temp_0;
	SUB_F		temp_0,	_VSB_UP_HEIGHT,	lSize_y;
	STORE_V	lPosition,	parm0;
	STORE_V	lSize,	parm1;
	STORE_V	_VSB_SCROLLAREA_COLOR,	parm2;
	STORE_F	FILE_APPEND,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Fill;
	INDIRECT_F	self,	pos_y,	temp_0;
	INDIRECT_F	self,	size_y,	temp_1;
	ADD_F		temp_0,	temp_1,	temp_0;
	SUB_F		temp_0,	_VSB_UP_HEIGHT,	lPosition_y;
	STORE_F	_VSB_UP_HEIGHT,	lSize_y;
	STORE_V	lPosition,	parm0;
	STORE_V	lSize,	parm1;
	STORE_V	_VSB_CLICKAREA_COLOR,	parm2;
	STORE_F	FILE_APPEND,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Fill;
	CALL0		_IVSB_GetSizeOfScroller;
	STORE_F	return_x,	lSize_y;
	INDIRECT_F	self,	pos_y,	temp_0;
	ADD_F		temp_0,	_VSB_UP_HEIGHT,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	origin_y,	temp_1;
	INDIRECT_F	self,	size_y,	temp_5;
	SUB_F		temp_5,	_VSB_UP_HEIGHT,	temp_5;
	SUB_F		temp_5,	_VSB_UP_HEIGHT,	temp_5;
	SUB_F		temp_5,	lSize_y,	temp_5;
	MUL_F		temp_1,	temp_5,	temp_1;
	INDIRECT_E	self,	_target,	temp_5;
	INDIRECT_E	temp_5,	_child,	temp_5;
	INDIRECT_F	temp_5,	size_y,	temp_5;
	INDIRECT_F	self,	size_y,	temp_6;
	SUB_F		temp_5,	temp_6,	temp_5;
	DIV_F		temp_1,	temp_5,	temp_1;
	SUB_F		temp_0,	temp_1,	lPosition_y;
	STORE_V	lPosition,	parm0;
	STORE_V	lSize,	parm1;
	STORE_V	_VSB_SCOLLER_COLOR,	parm2;
	STORE_F	FILE_APPEND,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Fill;
	DONE;
}

void () _IVSB_RangeBound;
void() _IVSB_RangeBound = asm
{
local float locked_1586;
local float temp_1;
local float temp_5;
	INDIRECT_E	self,	_target,	locked_1586;
	ADDRESS	locked_1586,	origin_y,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_E	temp_1,	_child,	temp_1;
	INDIRECT_F	temp_1,	size_y,	temp_1;
	INDIRECT_F	self,	size_y,	temp_5;
	SUB_F		temp_1,	temp_5,	temp_1;
	SUB_F		KEY_GAME,	temp_1,	temp_1;
	INDIRECT_E	self,	_target,	temp_5;
	INDIRECT_F	temp_5,	origin_y,	temp_5;
	STORE_F	temp_1,	parm0_x;
	STORE_F	temp_5,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		bound;
	STOREP_F	return_x,	locked_1586;
	DONE;
}

void () _IVSB_ScrollUp;
void() _IVSB_ScrollUp = asm
{
local float temp_0;
local float temp_1;
	INDIRECT_E	self,	_target,	temp_0;
	ADDRESS	temp_0,	origin_y,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	origin_y,	temp_1;
	ADD_F		temp_1,	SLIST_SERVERREPLYCOUNT,	temp_1;
	STOREP_F	temp_1,	temp_0;
	CALL0		_IVSB_RangeBound;
	DONE;
}

void () _IVSB_ScrollDown;
void() _IVSB_ScrollDown = asm
{
local float temp_0;
local float temp_1;
	INDIRECT_E	self,	_target,	temp_0;
	ADDRESS	temp_0,	origin_y,	temp_0;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	origin_y,	temp_1;
	SUB_F		temp_1,	SLIST_SERVERREPLYCOUNT,	temp_1;
	STOREP_F	temp_1,	temp_0;
	CALL0		_IVSB_RangeBound;
	DONE;
}

void (float) _IVSB_MouseSelect;
void(float lLevel) _IVSB_MouseSelect = asm
{
local float lScrollerSize;
local float lTotalSize;
local float lVisibleSize;
local float lScrollerRange;
local float temp_0;
local float temp_1;
local float temp_5;
	INDIRECT_E	self,	_target,	temp_0;
	INDIRECT_E	temp_0,	_child,	temp_0;
	INDIRECT_F	temp_0,	size_y,	lTotalSize;
	INDIRECT_F	self,	size_y,	lVisibleSize;
	INDIRECT_F	self,	size_y,	temp_0;
	SUB_F		temp_0,	_VSB_UP_HEIGHT,	temp_0;
	SUB_F		temp_0,	_VSB_UP_HEIGHT,	lScrollerRange;
	CALL0		_IVSB_GetSizeOfScroller;
	STORE_F	return_x,	lScrollerSize;
	SUB_F		lLevel,	_VSB_UP_HEIGHT,	temp_0;
	DIV_F		lScrollerSize,	KEY_MENU,	temp_1;
	SUB_F		temp_0,	temp_1,	lLevel;
	INDIRECT_E	self,	_target,	temp_0;
	ADDRESS	temp_0,	origin_y,	temp_0;
	SUB_F		lTotalSize,	lVisibleSize,	temp_1;
	MUL_F		lLevel,	temp_1,	temp_1;
	SUB_F		lScrollerRange,	lScrollerSize,	temp_5;
	DIV_F		temp_1,	temp_5,	temp_1;
	SUB_F		KEY_GAME,	temp_1,	temp_1;
	STOREP_F	temp_1,	temp_0;
	CALL0		_IVSB_RangeBound;
	DONE;
}

float(float pKey, float Ascii) Item_VScrollBar_Key = asm
{
local float lLevel;
local float temp_0;
local vector temp_2;
local vector temp_3;
	INDIRECT_E	self,	_target,	temp_0;
	EQ_E		temp_0,	null_entity,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	KEY_GAME;
	EQ_F		pKey,	K_UPARROW,	temp_0;
	IFNOT		temp_0,	4;
	CALL0		_IVSB_ScrollUp;
	RETURN	FILE_APPEND;
	GOTO		41;
	EQ_F		pKey,	K_DOWNARROW,	temp_0;
	IFNOT		temp_0,	4;
	CALL0		_IVSB_ScrollDown;
	RETURN	FILE_APPEND;
	GOTO		36;
	EQ_F		pKey,	K_MOUSE1,	temp_0;
	IFNOT		temp_0,	25;
	INDIRECT_V	self,	pos_x,	temp_2;
	INDIRECT_V	self,	size_x,	temp_3;
	STORE_V	Menu_Cursor_Position,	parm0;
	STORE_V	temp_2,	parm1;
	STORE_V	temp_3,	parm2;
	CALL3		Util_InRect;
	IF		return_x,	2;
	RETURN	KEY_GAME;
	INDIRECT_F	self,	pos_y,	temp_0;
	SUB_F		Menu_Cursor_Position_y,	temp_0,	lLevel;
	LT		lLevel,	_VSB_UP_HEIGHT,	temp_0;
	IFNOT		temp_0,	3;
	CALL0		_IVSB_ScrollUp;
	GOTO		9;
	INDIRECT_F	self,	size_y,	temp_0;
	SUB_F		temp_0,	_VSB_UP_HEIGHT,	temp_0;
	GE		lLevel,	temp_0,	temp_0;
	IFNOT		temp_0,	3;
	CALL0		_IVSB_ScrollDown;
	GOTO		3;
	STORE_F	lLevel,	parm0_x;
	CALL1		_IVSB_MouseSelect;
	RETURN	FILE_APPEND;
	GOTO		10;
	EQ_F		pKey,	K_MWHEELUP,	temp_0;
	IFNOT		temp_0,	4;
	CALL0		_IVSB_ScrollUp;
	RETURN	FILE_APPEND;
	GOTO		5;
	EQ_F		pKey,	K_MWHEELDOWN,	temp_0;
	IFNOT		temp_0,	3;
	CALL0		_IVSB_ScrollDown;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void() Item_VScrollBar_Update = asm
{
local float locked_1586;
local float temp_1;
	INDIRECT_S	self,	target,	locked_1586;
	EQ_S		locked_1586,	"",	locked_1586;
	IFNOT		locked_1586,	4;
	ADDRESS	self,	_target,	locked_1586;
	STOREP_ENT	null_entity,	locked_1586;
	GOTO		10;
	INDIRECT_S	self,	target,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_S	temp_1,	name,	temp_1;
	NE_S		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	5;
	ADDRESS	self,	_target,	locked_1586;
	INDIRECT_S	self,	target,	parm0_x;
	CALL1		Menu_GetItem;
	STOREP_ENT	return_x,	locked_1586;
	INDIRECT_E	self,	_target,	locked_1586;
	EQ_E		locked_1586,	null_entity,	locked_1586;
	IFNOT		locked_1586,	2;
	RETURN	offset_0;
	ADDRESS	self,	size_y,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_F	temp_1,	size_y,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	INDIRECT_F	self,	size_y,	locked_1586;
	INDIRECT_E	self,	_target,	temp_1;
	INDIRECT_E	temp_1,	_child,	temp_1;
	INDIRECT_F	temp_1,	size_y,	temp_1;
	GE		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	6;
	ADDRESS	self,	flag,	locked_1586;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_HIDDEN,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	GOTO		8;
	INDIRECT_F	self,	flag,	locked_1586;
	BITAND	locked_1586,	FLAG_HIDDEN,	locked_1586;
	IFNOT		locked_1586,	5;
	ADDRESS	self,	flag,	locked_1586;
	INDIRECT_F	self,	flag,	temp_1;
	SUB_F		temp_1,	FLAG_HIDDEN,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	DONE;
}

void () Item_VScrollBar_Destroy;
void() Item_VScrollBar_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_VScrollBar_Spawn = asm
{
local float temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	target,	parm1_x;
	CALL2		String_EntityZone;
	CALL0		Item_VScrollBar_Update;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_VScrollBar_Update,	temp_0;
	ADDRESS	self,	_key,	temp_0;
	STOREP_FNC	Item_VScrollBar_Key,	temp_0;
	ADDRESS	self,	_draw,	temp_0;
	STOREP_FNC	Item_VScrollBar_Draw,	temp_0;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Item_VScrollBar_Destroy,	temp_0;
	DONE;
}

void() Item_Cinematic_Destroy = asm
{
local float temp_0;
	INDIRECT_S	self,	normal,	parm0_x;
	CALL1		cin_close;
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityFree;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_Cinematic_Init = asm
{
local float temp_0;
local float temp_1;
	ADDRESS	self,	flag,	temp_0;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_HIDDEN,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	self,	parm0_x;
	STORE_F	normal,	parm1_x;
	CALL2		String_EntityZone;
	INDIRECT_S	self,	link,	temp_0;
	INDIRECT_S	self,	normal,	temp_1;
	STORE_F	temp_0,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		cin_open;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Item_Cinematic_Destroy,	temp_0;
	DONE;
}

void() Item_Cinematic_Loop_Spawn = asm
{
local float temp_0;
	CALL0		Item_Cinematic_Init;
	INDIRECT_S	self,	normal,	parm0_x;
	STORE_F	KEY_MENU,	parm1_x;
	CALL2		cin_setstate;
	DONE;
}

void() Item_Container_Spawn = asm
{
local float temp_0;
local float temp_1;
	ADDRESS	self,	flag,	temp_0;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_HIDDEN,	temp_1;
	STOREP_F	temp_1,	temp_0;
	DONE;
}

void () Item_Custom_Spawn;
void() Item_Custom_Spawn = asm
{
local float temp_0;
	ADDRESS	self,	_reinit,	temp_0;
	STOREP_FNC	CtCall_Reinit,	temp_0;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	CtCall_Destroy,	temp_0;
	ADDRESS	self,	_key,	temp_0;
	STOREP_FNC	CtCall_Key,	temp_0;
	ADDRESS	self,	_draw,	temp_0;
	STOREP_FNC	CtCall_Draw,	temp_0;
	ADDRESS	self,	_mouseEnter,	temp_0;
	STOREP_FNC	CtCall_MouseEnter,	temp_0;
	ADDRESS	self,	_mouseLeave,	temp_0;
	STOREP_FNC	CtCall_MouseLeave,	temp_0;
	ADDRESS	self,	_select,	temp_0;
	STOREP_FNC	CtCall_Select,	temp_0;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	CtCall_Update,	temp_0;
	CALL0		CtCall_Init;
	DONE;
}

void() Item_Link_Update = asm
{
local float locked_1586;
local float temp_1;
	INDIRECT_S	self,	link,	locked_1586;
	EQ_S		locked_1586,	"",	locked_1586;
	IFNOT		locked_1586,	4;
	ADDRESS	self,	_link,	locked_1586;
	STOREP_ENT	null_entity,	locked_1586;
	GOTO		14;
	INDIRECT_S	self,	link,	locked_1586;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_S	temp_1,	name,	temp_1;
	NE_S		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	9;
	ADDRESS	self,	_link,	locked_1586;
	INDIRECT_S	self,	link,	parm0_x;
	CALL1		Menu_GetItem;
	STOREP_ENT	return_x,	locked_1586;
	ADDRESS	self,	flag,	locked_1586;
	INDIRECT_F	self,	flag,	temp_1;
	BITOR		temp_1,	FLAG_NOSELECT,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	DONE;
}

float(float pKey, float pAscii) Item_Link_Key = asm
{
local float temp_0;
	INDIRECT_E	self,	_link,	temp_0;
	IFNOT		temp_0,	6;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	pKey,	parm1_x;
	STORE_F	pAscii,	parm2_x;
	CALL3		Raise_Key;
	RETURN	return_x;
	RETURN	KEY_GAME;
	DONE;
}

void() Item_Link_MouseEnter = asm
{
local float temp_0;
local float temp_1;
	INDIRECT_E	self,	_link,	temp_0;
	IFNOT		temp_0,	5;
	INDIRECT_E	self,	_link,	temp_1;
	INDIRECT_F	temp_1,	_runFlag,	temp_1;
	BITAND	temp_1,	RUNFLAG_NOSELECT,	temp_1;
	NOT_F		temp_1,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	4;
	INDIRECT_E	self,	_link,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	CALL2		Menu_Select;
	DONE;
}

float() Item_Link_IsSelected = asm
{
local float temp_0;
	EQ_E		Menu_ActiveItem,	self,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	FILE_APPEND;
	INDIRECT_E	self,	_link,	temp_0;
	IFNOT		temp_0,	5;
	INDIRECT_E	self,	_link,	temp_0;
	EQ_E		Menu_ActiveItem,	temp_0,	temp_0;
	RETURN	temp_0;
	GOTO		2;
	RETURN	KEY_GAME;
	DONE;
}

void() Item_Link_Destroy = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityFree;
	DONE;
}

void() Item_Link_Init = asm
{
local float temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	link,	parm1_x;
	CALL2		String_EntityZone;
	CALL0		Item_Link_Update;
	ADDRESS	self,	_destroy,	temp_0;
	STOREP_FNC	Item_Link_Destroy,	temp_0;
	ADDRESS	self,	_key,	temp_0;
	STOREP_FNC	Item_Link_Key,	temp_0;
	ADDRESS	self,	_mouseEnter,	temp_0;
	STOREP_FNC	Item_Link_MouseEnter,	temp_0;
	ADDRESS	self,	_update,	temp_0;
	STOREP_FNC	Item_Link_MouseEnter,	temp_0;
	DONE;
}

void(entity pEntity, void () pPopFunction) Menu_History_Push = asm
{
local entity lHistory;
local float temp_0;
	STORE_FNC	Util_NullFunction,	Menu_KeyHook;
	CALL0		spawn;
	STORE_ENT	return_x,	lHistory;
	ADDRESS	lHistory,	type,	temp_0;
	STOREP_S	"MMANAGER_HISTORY",	temp_0;
	ADDRESS	lHistory,	_prev,	temp_0;
	STOREP_ENT	Menu_History,	temp_0;
	ADDRESS	lHistory,	_child,	temp_0;
	STOREP_ENT	Menu_ActiveItem,	temp_0;
	ADDRESS	lHistory,	_parent,	temp_0;
	STOREP_ENT	Menu_ActiveWindow,	temp_0;
	ADDRESS	lHistory,	_next,	temp_0;
	STOREP_ENT	pEntity,	temp_0;
	ADDRESS	lHistory,	_destroy,	temp_0;
	STOREP_FNC	pPopFunction,	temp_0;
	STORE_ENT	lHistory,	Menu_History;
	DONE;
}

void() Menu_History_Pop = asm
{
local entity lTemp;
local float temp_0;
	EQ_E		Menu_History,	null_entity,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	offset_0;
	STORE_FNC	Util_NullFunction,	Menu_KeyHook;
	INDIRECT_E	Menu_History,	_child,	Menu_ActiveItem;
	INDIRECT_E	Menu_History,	_parent,	Menu_ActiveWindow;
	STORE_ENT	Menu_History,	lTemp;
	STORE_F	lTemp,	parm0_x;
	CALL1		Raise_Destroy;
	INDIRECT_E	Menu_History,	_prev,	Menu_History;
	STORE_F	lTemp,	parm0_x;
	CALL1		remove;
	DONE;
}

float(entity pEntity) Menu_History_Verify = asm
{
local float temp_0;
	EQ_E		Menu_History,	null_entity,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	KEY_GAME;
	INDIRECT_E	Menu_History,	_next,	temp_0;
	EQ_E		temp_0,	pEntity,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void() Menu_History_Clear = asm
{
local entity lEntity;
local float temp_0;
	STORE_ENT	null_entity,	lEntity;
	STORE_F	lEntity,	parm0_x;
	STORE_F	type,	parm1_x;
	STORE_F	"MMANAGER_HISTORY",	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lEntity;
	NE_E		return_x,	null_entity,	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	lEntity,	parm0_x;
	CALL1		remove;
	GOTO		-9;
	STORE_ENT	null_entity,	Menu_History;
	DONE;
}

void (float, float) _Menu_Process_Debug_Filter;
void(float pMode, float pSelectState) _Menu_Process_Debug_Filter = asm
{
local float temp_0;
local float temp_1;
	IF		sys_debug_process,	3;
	STORE_F	KEY_GAME,	_menu_process_filtered;
	GOTO		5;
	IFNOT		sys_debug_process_filter,	3;
	BITAND	pMode,	sys_debug_process_filter,	_menu_process_filtered;
	GOTO		2;
	STORE_F	FILE_APPEND,	_menu_process_filtered;
	EQ_F		_menu_process_filtered,	MENU_PROCESS_MOUSE,	temp_0;
	IFNOT		temp_0,	2;
	EQ_F		pSelectState,	MENU_SELECT_NEVER,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	2;
	STORE_F	KEY_GAME,	_menu_process_filtered;
	DONE;
}

void() Menu_Process_Setup = asm
{
	STORE_V	'0.000000 0.000000 0.000000',	Menu_Origin;
	STORE_V	'0.000000 0.000000 0.000000',	Menu_Clip_Position;
	STORE_V	'0.000000 0.000000 0.000000',	Menu_Clip_Size;
	DONE;
}

void (entity) _Menu_Env_LoadClipArea;
void(entity pItem) _Menu_Env_LoadClipArea = asm
{
local float temp_0;
local float temp_1;
local vector temp_2;
	INDIRECT_V	pItem,	_cache_clip_pos_x,	Menu_Clip_Position;
	INDIRECT_V	pItem,	_cache_clip_size_x,	Menu_Clip_Size;
	IFNOT		sys_debug_mgfx,	1;
	AND		sys_debug_mgfx,	_menu_process_filtered,	temp_0;
	IFNOT		temp_0,	14;
	STORE_V	Menu_Clip_Position,	parm0;
	CALL1		vtos;
	STORE_V	Menu_Clip_Size,	parm0;
	STORE_F	return_x,	temp_0;
	CALL1		vtos;
	STORE_F	return_x,	temp_1;
	STORE_F	temp_0,	return_x;
	STORE_F	"MGFX Loaded clip area = (",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"; ",	parm2_x;
	STORE_F	temp_1,	parm3_x;
	STORE_F	")
",	parm4_x;
	CALL5		print;
	DONE;
}

void (entity) _Menu_Env_LoadOrigin;
void(entity pItem) _Menu_Env_LoadOrigin = asm
{
local float temp_0;
local vector temp_2;
	INDIRECT_V	pItem,	_cache_origin_x,	Menu_Origin;
	SUB_V		Cursor_Position,	Menu_Origin,	Menu_Cursor_Position;
	IFNOT		sys_debug_mgfx,	1;
	AND		sys_debug_mgfx,	_menu_process_filtered,	temp_0;
	IFNOT		temp_0,	7;
	STORE_V	Menu_Origin,	parm0;
	CALL1		vtos;
	STORE_F	"MGFX Loaded org = ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		print;
	DONE;
}

void (entity) _Menu_Env_Reload;
void(entity pItem) _Menu_Env_Reload = asm
{
local float locked_1585;
local float temp_0;
local vector temp_2;
local float temp_5;
	INDIRECT_V	pItem,	_cache_origin_x,	Menu_Origin;
	SUB_V		Cursor_Position,	Menu_Origin,	Menu_Cursor_Position;
	INDIRECT_V	pItem,	_cache_clip_pos_x,	Menu_Clip_Position;
	INDIRECT_V	pItem,	_cache_clip_size_x,	Menu_Clip_Size;
	IFNOT		sys_debug_mgfx,	1;
	AND		sys_debug_mgfx,	_menu_process_filtered,	temp_0;
	IFNOT		temp_0,	21;
	STORE_V	Menu_Origin,	parm0;
	CALL1		vtos;
	STORE_V	Menu_Clip_Position,	parm0;
	STORE_F	return_x,	temp_0;
	CALL1		vtos;
	STORE_F	return_x,	locked_1585;
	STORE_F	temp_0,	return_x;
	STORE_V	Menu_Clip_Size,	parm0;
	STORE_F	return_x,	temp_0;
	CALL1		vtos;
	STORE_F	return_x,	temp_5;
	STORE_F	temp_0,	return_x;
	STORE_F	"MGFX Reloaded env for: org = ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"; clip area = (",	parm2_x;
	STORE_F	locked_1585,	parm3_x;
	STORE_F	"; ",	parm4_x;
	STORE_F	temp_5,	parm5_x;
	STORE_F	")
",	parm6_x;
	CALL7		print;
	DONE;
}

void () _MGX_SetClipArea;
void() _MGX_SetClipArea = asm
{
local float temp_0;
local float temp_1;
	EQ_V		Menu_Clip_Position,	'0.000000 0.000000 0.000000',	temp_0;
	IFNOT		temp_0,	2;
	EQ_V		Menu_Clip_Size,	'0.000000 0.000000 0.000000',	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	3;
	CALL0		Gfx_ResetClipArea;
	GOTO		6;
	STORE_F	Menu_Clip_Position_x,	parm0_x;
	STORE_F	Menu_Clip_Position_y,	parm1_x;
	STORE_F	Menu_Clip_Size_x,	parm2_x;
	STORE_F	Menu_Clip_Size_y,	parm3_x;
	CALL4		Gfx_SetClipArea;
	DONE;
}

void (entity) _Menu_Env_SetupClipArea;
void(entity pItem) _Menu_Env_SetupClipArea = asm
{
local vector lSize;
local vector lPos;
local vector lDelta;
local float temp_0;
local float temp_1;
local vector temp_2;
	INDIRECT_V	pItem,	pos_x,	lPos;
	INDIRECT_V	pItem,	size_x,	lSize;
	NE_V		lPos,	'0.000000 0.000000 0.000000',	temp_0;
	IF		temp_0,	2;
	NE_V		lSize,	'0.000000 0.000000 0.000000',	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	22;
	NE_V		Menu_Clip_Position,	'0.000000 0.000000 0.000000',	temp_0;
	IF		temp_0,	2;
	NE_V		Menu_Clip_Size,	'0.000000 0.000000 0.000000',	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	15;
	ADD_V		Menu_Origin,	lPos,	lPos;
	STORE_V	lPos,	parm0;
	STORE_V	Menu_Clip_Position,	parm1;
	STORE_V	Menu_Clip_Size,	parm2;
	CALL3		Util_GetClipDelta;
	STORE_V	return,	lDelta;
	ADD_V		lPos,	lDelta,	lPos;
	SUB_V		lSize,	lDelta,	temp_2;
	STORE_V	lPos,	parm0;
	STORE_V	temp_2,	parm1;
	STORE_V	Menu_Clip_Position,	parm2;
	STORE_V	Menu_Clip_Size,	parm3;
	CALL4		Util_ClipRect;
	STORE_V	return,	lSize;
	STORE_V	lPos,	Menu_Clip_Position;
	STORE_V	lSize,	Menu_Clip_Size;
	ADDRESS	pItem,	_cache_clip_pos_x,	temp_2_x;
	STOREP_V	Menu_Clip_Position_x,	temp_2;
	ADDRESS	pItem,	_cache_clip_size_x,	temp_2_x;
	STOREP_V	Menu_Clip_Size_x,	temp_2;
	IFNOT		sys_debug_mgfx,	1;
	AND		sys_debug_mgfx,	_menu_process_filtered,	temp_0;
	IFNOT		temp_0,	26;
	INDIRECT_V	pItem,	pos_x,	parm0;
	CALL1		vtos;
	INDIRECT_V	pItem,	size_x,	parm0;
	STORE_F	return_x,	temp_0;
	CALL1		vtos;
	STORE_F	return_x,	temp_1;
	STORE_F	temp_0,	return_x;
	STORE_F	"MGFX Setup clip area: (",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"; ",	parm2_x;
	STORE_F	temp_1,	parm3_x;
	CALL4		print;
	STORE_V	Menu_Clip_Position,	parm0;
	CALL1		vtos;
	STORE_V	Menu_Clip_Size,	parm0;
	STORE_F	return_x,	temp_0;
	CALL1		vtos;
	STORE_F	return_x,	temp_1;
	STORE_F	temp_0,	return_x;
	STORE_F	") clipped to (",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"; ",	parm2_x;
	STORE_F	temp_1,	parm3_x;
	STORE_F	")
",	parm4_x;
	CALL5		print;
	DONE;
}

void (entity) _Menu_Env_SetupOrigin;
void(entity pItem) _Menu_Env_SetupOrigin = asm
{
local float temp_0;
local vector temp_2;
local vector temp_3;
	INDIRECT_V	pItem,	origin_x,	temp_2;
	ADD_V		Menu_Origin,	temp_2,	temp_2;
	INDIRECT_V	pItem,	pos_x,	temp_3;
	ADD_V		temp_2,	temp_3,	Menu_Origin;
	ADDRESS	pItem,	_cache_origin_x,	temp_2_x;
	STOREP_V	Menu_Origin_x,	temp_2;
	IFNOT		sys_debug_mgfx,	1;
	AND		sys_debug_mgfx,	_menu_process_filtered,	temp_0;
	IFNOT		temp_0,	7;
	STORE_V	Menu_Origin,	parm0;
	CALL1		vtos;
	STORE_F	"MGFX Setup org = ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		print;
	DONE;
}

void (entity) _Menu_ProcessRunFlag;
void(entity pItem) _Menu_ProcessRunFlag = asm
{
local entity lChild;
local float temp_0;
	IFNOT		_menu_process_filtered,	8;
	INDIRECT_S	pItem,	name,	temp_0;
	STORE_F	"R ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		print;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_SetupClipArea;
	STORE_F	pItem,	parm0_x;
	CALL1		Menu_SetRunFlag;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_SetupOrigin;
	INDIRECT_E	pItem,	_child,	lChild;
	IFNOT		lChild,	10;
	STORE_F	pItem,	parm0_x;
	STORE_F	lChild,	parm1_x;
	CALL2		Menu_InheritRunFlag;
	STORE_F	lChild,	parm0_x;
	CALL1		_Menu_ProcessRunFlag;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_Reload;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-9;
	DONE;
}

void (entity) _Menu_ProcessDraw;
void(entity pItem) _Menu_ProcessDraw = asm
{
local entity lChild;
local float temp_0;
	IFNOT		_menu_process_filtered,	8;
	INDIRECT_S	pItem,	name,	temp_0;
	STORE_F	"D ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	" ",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		print;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	96.000000,	temp_0;
	NOT_F		temp_0,	temp_0;
	IF		temp_0,	5;
	IFNOT		_menu_process_filtered,	3;
	STORE_F	"Failed (Not visible)
",	parm0_x;
	CALL1		print;
	RETURN	offset_0;
	IFNOT		_menu_process_filtered,	3;
	STORE_F	"
",	parm0_x;
	CALL1		print;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_LoadClipArea;
	CALL0		_MGX_SetClipArea;
	STORE_F	pItem,	parm0_x;
	CALL1		Raise_Draw;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_LoadOrigin;
	INDIRECT_E	pItem,	_child,	lChild;
	IFNOT		lChild,	8;
	STORE_F	lChild,	parm0_x;
	CALL1		_Menu_ProcessDraw;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_Reload;
	CALL0		_MGX_SetClipArea;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-7;
	DONE;
}

void (entity) _Menu_ProcessUpdate;
void(entity pItem) _Menu_ProcessUpdate = asm
{
local entity lChild;
local float temp_0;
	IFNOT		_menu_process_filtered,	8;
	INDIRECT_S	pItem,	name,	temp_0;
	STORE_F	"U ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	" ",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		print;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_CHILDDRAWONLY,	temp_0;
	IFNOT		temp_0,	5;
	IFNOT		_menu_process_filtered,	3;
	STORE_F	"Failed (RUNFLAG_CHILDDRAWONLY)
",	parm0_x;
	CALL1		print;
	RETURN	offset_0;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_LoadClipArea;
	STORE_F	pItem,	parm0_x;
	CALL1		Raise_Update;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_HIDDEN,	temp_0;
	IFNOT		temp_0,	5;
	IFNOT		_menu_process_filtered,	3;
	STORE_F	"Aborted branching (RUNFLAG_HIDDEN)
",	parm0_x;
	CALL1		print;
	RETURN	offset_0;
	IFNOT		_menu_process_filtered,	3;
	STORE_F	"
",	parm0_x;
	CALL1		print;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_LoadOrigin;
	INDIRECT_E	pItem,	_child,	lChild;
	IFNOT		lChild,	7;
	STORE_F	lChild,	parm0_x;
	CALL1		_Menu_ProcessUpdate;
	STORE_F	lChild,	parm0_x;
	CALL1		_Menu_Env_Reload;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-6;
	DONE;
}

void (entity, bool) _Menu_ProcessMouse;
void(entity pItem, bool pSelectMode) _Menu_ProcessMouse = asm
{
local float locked_1586;
local entity lChild;
local float temp_1;
local float temp_5;
	IFNOT		_menu_process_filtered,	21;
	STORE_F	"M ",	parm0_x;
	CALL1		print;
	GOTO		10;
	STORE_F	"S ",	parm0_x;
	CALL1		print;
	GOTO		12;
	STORE_F	"A ",	parm0_x;
	CALL1		print;
	GOTO		9;
	STORE_F	"N ",	parm0_x;
	CALL1		print;
	GOTO		6;
	IFNOT		pSelectMode,	-9;
	EQ_F		pSelectMode,	MENU_SELECT_ALWAYS,	locked_1586;
	IF		locked_1586,	-8;
	EQ_F		pSelectMode,	MENU_SELECT_NEVER,	locked_1586;
	IF		locked_1586,	-7;
	INDIRECT_S	pItem,	name,	parm0_x;
	STORE_F	" ",	parm1_x;
	CALL2		print;
	INDIRECT_F	pItem,	_runFlag,	locked_1586;
	BITAND	locked_1586,	96.000000,	locked_1586;
	NOT_F		locked_1586,	locked_1586;
	IF		locked_1586,	5;
	IFNOT		_menu_process_filtered,	3;
	STORE_F	"Failed (Not visible)
",	parm0_x;
	CALL1		print;
	RETURN	offset_0;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_LoadClipArea;
	STORE_V	Cursor_Position,	parm0;
	STORE_V	Menu_Clip_Position,	parm1;
	STORE_V	Menu_Clip_Size,	parm2;
	CALL3		Util_InRect;
	IF		return_x,	5;
	EQ_V		Menu_Clip_Position,	'0.000000 0.000000 0.000000',	locked_1586;
	IFNOT		locked_1586,	2;
	EQ_V		Menu_Clip_Size,	'0.000000 0.000000 0.000000',	temp_1;
	AND		locked_1586,	temp_1,	locked_1586;
	OR		return_x,	locked_1586,	locked_1586;
	IFNOT		locked_1586,	34;
	ADDRESS	pItem,	_runFlag,	locked_1586;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITOR		temp_1,	RUNFLAG_MOUSEINAREA,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	INDIRECT_F	pItem,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_HADMOUSE,	locked_1586;
	NOT_F		locked_1586,	locked_1586;
	IFNOT		locked_1586,	3;
	STORE_F	pItem,	parm0_x;
	CALL1		Menu_HasEvents;
	AND		locked_1586,	return_x,	locked_1586;
	IFNOT		locked_1586,	3;
	STORE_F	pItem,	parm0_x;
	CALL1		Raise_MouseEnter;
	NE_F		pSelectMode,	MENU_SELECT_NEVER,	locked_1586;
	IFNOT		locked_1586,	3;
	INDIRECT_F	pItem,	flag,	temp_1;
	BITAND	temp_1,	FLAG_SEALOFFMOUSE,	temp_1;
	AND		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	2;
	STORE_ENT	null_entity,	Menu_ActiveItem;
	EQ_F		pSelectMode,	MENU_SELECT_ALWAYS,	locked_1586;
	IF		locked_1586,	7;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITAND	temp_1,	RUNFLAG_NOSELECT,	temp_1;
	NOT_F		temp_1,	temp_1;
	IFNOT		temp_1,	2;
	EQ_F		pSelectMode,	MENU_SELECT_SELECTABLE,	temp_5;
	AND		temp_1,	temp_5,	temp_1;
	OR		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	2;
	STORE_ENT	pItem,	Menu_ActiveItem;
	GOTO		14;
	INDIRECT_F	pItem,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_HADMOUSE,	locked_1586;
	IFNOT		locked_1586,	3;
	STORE_F	pItem,	parm0_x;
	CALL1		Menu_HasEvents;
	AND		locked_1586,	return_x,	locked_1586;
	IFNOT		locked_1586,	3;
	STORE_F	pItem,	parm0_x;
	CALL1		Raise_MouseLeave;
	IFNOT		_menu_process_filtered,	3;
	STORE_F	"Aborted branching (Outside the clip area)
",	parm0_x;
	CALL1		print;
	RETURN	offset_0;
	IFNOT		_menu_process_filtered,	3;
	STORE_F	"
",	parm0_x;
	CALL1		print;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_LoadOrigin;
	INDIRECT_E	pItem,	_child,	lChild;
	IFNOT		lChild,	21;
	INDIRECT_F	pItem,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_CHILDDRAWUPDATEONLY,	locked_1586;
	NOT_F		locked_1586,	locked_1586;
	IF		locked_1586,	4;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITAND	temp_1,	RUNFLAG_CHILDDRAWONLY,	temp_1;
	NOT_F		temp_1,	temp_1;
	OR		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	5;
	STORE_F	lChild,	parm0_x;
	STORE_F	pSelectMode,	parm1_x;
	CALL2		_Menu_ProcessMouse;
	GOTO		4;
	STORE_F	lChild,	parm0_x;
	STORE_F	MENU_SELECT_NEVER,	parm1_x;
	CALL2		_Menu_ProcessMouse;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_Reload;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-20;
	DONE;
}

float (float) _Menu_Process_Debug_Return;
float(float pRetValue) _Menu_Process_Debug_Return = asm
{
local float temp_0;
	IFNOT		_menu_process_filtered,	17;
	GOTO		10;
	STORE_F	"MENU_EVENT_CONTINUE
",	parm0_x;
	CALL1		print;
	GOTO		13;
	STORE_F	"MENU_EVENT_RAISEPARENT
",	parm0_x;
	CALL1		print;
	GOTO		10;
	STORE_F	"MENU_EVENT_PROCESSED
",	parm0_x;
	CALL1		print;
	GOTO		7;
	IFNOT		pRetValue,	-9;
	IFNOT		pRetValue,	-10;
	EQ_F		pRetValue,	MENU_EVENT_RAISEPARENT,	temp_0;
	IF		temp_0,	-9;
	EQ_F		pRetValue,	MENU_EVENT_PROCESSED,	temp_0;
	IF		temp_0,	-8;
	RETURN	pRetValue;
	DONE;
}

bool (entity, float, float) _Menu_ProcessKey;
bool(entity pItem, float pKey, float pAscii) _Menu_ProcessKey = asm
{
local float lResult;
local entity lChild;
local float temp_0;
local float temp_1;
	IFNOT		_menu_process_filtered,	12;
	STORE_F	pKey,	parm0_x;
	CALL1		ftos;
	INDIRECT_S	pItem,	name,	temp_0;
	STORE_F	"K ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	" ",	parm2_x;
	STORE_F	temp_0,	parm3_x;
	STORE_F	" ",	parm4_x;
	CALL5		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		print;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_CHILDDRAWUPDATEONLY,	temp_0;
	IF		temp_0,	3;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITAND	temp_1,	RUNFLAG_CHILDDRAWONLY,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	MENU_EVENT_CONTINUE,	parm0_x;
	CALL1		_Menu_Process_Debug_Return;
	RETURN	return_x;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_LoadClipArea;
	EQ_E		Menu_ActiveItem,	pItem,	temp_0;
	IFNOT		temp_0,	12;
	STORE_F	pItem,	parm0_x;
	STORE_F	pKey,	parm1_x;
	STORE_F	pAscii,	parm2_x;
	CALL3		Raise_Key;
	IFNOT		return_x,	3;
	STORE_F	MENU_EVENT_PROCESSED,	lResult;
	GOTO		2;
	STORE_F	MENU_EVENT_RAISEPARENT,	lResult;
	STORE_F	lResult,	parm0_x;
	CALL1		_Menu_Process_Debug_Return;
	RETURN	return_x;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_LoadOrigin;
	INDIRECT_E	pItem,	_child,	lChild;
	IFNOT		lChild,	30;
	STORE_F	lChild,	parm0_x;
	STORE_F	pKey,	parm1_x;
	STORE_F	pAscii,	parm2_x;
	CALL3		_Menu_ProcessKey;
	STORE_F	return_x,	lResult;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_Env_Reload;
	EQ_F		lResult,	MENU_EVENT_PROCESSED,	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	MENU_EVENT_PROCESSED,	parm0_x;
	CALL1		_Menu_Process_Debug_Return;
	RETURN	return_x;
	GOTO		15;
	EQ_F		lResult,	MENU_EVENT_RAISEPARENT,	temp_0;
	IFNOT		temp_0,	13;
	STORE_F	pItem,	parm0_x;
	STORE_F	pKey,	parm1_x;
	STORE_F	pAscii,	parm2_x;
	CALL3		Raise_Key;
	IFNOT		return_x,	5;
	STORE_F	MENU_EVENT_PROCESSED,	parm0_x;
	CALL1		_Menu_Process_Debug_Return;
	RETURN	return_x;
	GOTO		4;
	STORE_F	MENU_EVENT_RAISEPARENT,	parm0_x;
	CALL1		_Menu_Process_Debug_Return;
	RETURN	return_x;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-29;
	STORE_F	MENU_EVENT_CONTINUE,	parm0_x;
	CALL1		_Menu_Process_Debug_Return;
	RETURN	return_x;
	DONE;
}

float(entity pItem, float pMode, float pSelectMode, float pKey, float pAscii) Menu_Process = asm
{
local float lResult;
local vector lOrigin;
local vector lPos;
local vector lSize;
local float temp_0;
local vector temp_2;
	STORE_V	Menu_Clip_Size,	lSize;
	STORE_V	Menu_Clip_Position,	lPos;
	STORE_V	Menu_Origin,	lOrigin;
	STORE_F	pMode,	parm0_x;
	STORE_F	pSelectMode,	parm1_x;
	CALL2		_Menu_Process_Debug_Filter;
	STORE_F	KEY_GAME,	lResult;
	GOTO		20;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_ProcessRunFlag;
	GOTO		27;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_ProcessUpdate;
	GOTO		24;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_ProcessDraw;
	GOTO		21;
	STORE_F	pItem,	parm0_x;
	STORE_F	pSelectMode,	parm1_x;
	CALL2		_Menu_ProcessMouse;
	GOTO		17;
	STORE_F	pItem,	parm0_x;
	STORE_F	pKey,	parm1_x;
	STORE_F	pAscii,	parm2_x;
	CALL3		_Menu_ProcessKey;
	STORE_F	return_x,	lResult;
	GOTO		11;
	EQ_F		pMode,	MENU_PROCESS_RUNFLAG,	temp_0;
	IF		temp_0,	-20;
	EQ_F		pMode,	MENU_PROCESS_UPDATE,	temp_0;
	IF		temp_0,	-19;
	EQ_F		pMode,	MENU_PROCESS_DRAW,	temp_0;
	IF		temp_0,	-18;
	EQ_F		pMode,	MENU_PROCESS_MOUSE,	temp_0;
	IF		temp_0,	-17;
	EQ_F		pMode,	MENU_PROCESS_KEY,	temp_0;
	IF		temp_0,	-15;
	STORE_V	lSize,	Menu_Clip_Size;
	STORE_V	lPos,	Menu_Clip_Position;
	STORE_V	lOrigin,	Menu_Origin;
	SUB_V		Cursor_Position,	Menu_Origin,	Menu_Cursor_Position;
	EQ_F		pMode,	MENU_PROCESS_DRAW,	temp_0;
	IFNOT		temp_0,	2;
	CALL0		_MGX_SetClipArea;
	RETURN	lResult;
	DONE;
}

void() Menu_Frame = asm
{
local entity lOld;
local float temp_0;
	CALL0		Sys_Debug_Frame;
	IFNOT		sys_debug_halt,	2;
	RETURN	offset_0;
	CALL0		Menu_UpdateRunFlags;
	CALL0		Menu_Process_Setup;
	NE_V		Cursor_Relative,	'0.000000 0.000000 0.000000',	temp_0;
	IFNOT		temp_0,	22;
	STORE_ENT	Menu_ActiveItem,	lOld;
	STORE_F	Menu_ActiveWindow,	parm0_x;
	STORE_F	MENU_PROCESS_MOUSE,	parm1_x;
	STORE_F	MENU_SELECT_SELECTABLE,	parm2_x;
	STORE_F	KEY_GAME,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Process;
	IF		Menu_ActiveItem,	3;
	STORE_ENT	lOld,	Menu_ActiveItem;
	GOTO		11;
	NE_E		lOld,	Menu_ActiveItem,	temp_0;
	IFNOT		temp_0,	9;
	STORE_F	lOld,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		Raise_Select;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		Raise_Select;
	GOTO		7;
	STORE_F	Menu_ActiveWindow,	parm0_x;
	STORE_F	MENU_PROCESS_MOUSE,	parm1_x;
	STORE_F	MENU_SELECT_NEVER,	parm2_x;
	STORE_F	KEY_GAME,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Process;
	CALL0		Menu_Process_Setup;
	STORE_F	Menu_ActiveWindow,	parm0_x;
	STORE_F	MENU_PROCESS_UPDATE,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	STORE_F	KEY_GAME,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Process;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		Menu_CollectGarbage;
	DONE;
}

void() Menu_Draw = asm
{
local float temp_0;
	IFNOT		sys_debug_halt,	2;
	RETURN	offset_0;
	INDIRECT_F	Menu_ActiveWindow,	_runFlag,	temp_0;
	BITAND	temp_0,	96.000000,	temp_0;
	IF		temp_0,	8;
	CALL0		Menu_Process_Setup;
	STORE_F	Menu_ActiveWindow,	parm0_x;
	STORE_F	MENU_PROCESS_DRAW,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	STORE_F	KEY_GAME,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Process;
	CALL0		Sys_Debug_Draw;
	DONE;
}

void(float pKey, float pAscii) Menu_Key = asm
{
local float locked_1586;
local entity lOld;
local float temp_1;
	IFNOT		sys_debug_halt,	2;
	RETURN	offset_0;
	NE_FNC	Menu_KeyHook,	Util_NullFunction,	locked_1586;
	IFNOT		locked_1586,	5;
	STORE_F	pKey,	parm0_x;
	STORE_F	pAscii,	parm1_x;
	CALL2		Menu_KeyHook;
	RETURN	offset_0;
	LE		K_MOUSE1,	pKey,	locked_1586;
	IFNOT		locked_1586,	2;
	LE		pKey,	K_MOUSE10,	temp_1;
	AND		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	23;
	STORE_ENT	Menu_ActiveItem,	lOld;
	STORE_ENT	null_entity,	Menu_ActiveItem;
	STORE_F	Menu_ActiveWindow,	parm0_x;
	STORE_F	MENU_PROCESS_MOUSE,	parm1_x;
	STORE_F	MENU_SELECT_SELECTABLE,	parm2_x;
	STORE_F	KEY_GAME,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Process;
	IF		Menu_ActiveItem,	4;
	STORE_ENT	lOld,	Menu_ActiveItem;
	RETURN	offset_0;
	GOTO		11;
	NE_E		lOld,	Menu_ActiveItem,	locked_1586;
	IFNOT		locked_1586,	9;
	STORE_F	lOld,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		Raise_Select;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		Raise_Select;
	EQ_E		Menu_ActiveItem,	null_entity,	locked_1586;
	IFNOT		locked_1586,	3;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		Menu_Reselect;
	INDIRECT_F	Menu_ActiveItem,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_NOSELECT,	locked_1586;
	NOT_F		locked_1586,	locked_1586;
	NOT_F		locked_1586,	locked_1586;
	IFNOT		locked_1586,	2;
	NE_E		Menu_ActiveItem,	Menu_ActiveWindow,	temp_1;
	AND		locked_1586,	temp_1,	locked_1586;
	IF		locked_1586,	8;
	STORE_F	Menu_ActiveWindow,	parm0_x;
	STORE_F	MENU_PROCESS_KEY,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	STORE_F	pKey,	parm3_x;
	STORE_F	pAscii,	parm4_x;
	CALL5		Menu_Process;
	NE_F		return_x,	MENU_EVENT_PROCESSED,	temp_1;
	OR		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	25;
	EQ_F		pKey,	K_ESCAPE,	locked_1586;
	IFNOT		locked_1586,	10;
	BITAND	gamestatus,	CVAR_READONLY,	locked_1586;
	IFNOT		locked_1586,	4;
	STORE_F	" K_ESCAPE wasnt processed!
",	parm0_x;
	CALL1		error;
	GOTO		4;
	CALL0		Menu_Toggle;
	STORE_F	"menu_restart
",	parm0_x;
	CALL1		cmd;
	GOTO		14;
	BITAND	gamestatus,	CVAR_READONLY,	locked_1586;
	IFNOT		locked_1586,	12;
	STORE_F	pKey,	parm0_x;
	CALL1		ftos;
	STORE_F	" Key ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	" ('",	parm2_x;
	CALL3		print;
	STORE_F	pAscii,	parm0_x;
	CALL1		chr;
	STORE_F	return_x,	parm0_x;
	STORE_F	"') wasn't processed!
",	parm1_x;
	CALL2		print;
	DONE;
}

float() Menu_Toggle = asm
{
local float temp_0;
local float temp_1;
	BITAND	gamestatus,	KEY_MENU,	temp_0;
	IF		temp_0,	2;
	BITAND	gamestatus,	CVAR_READONLY,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	4;
	CALL0		m_hide;
	RETURN	FILE_APPEND;
	GOTO		2;
	RETURN	KEY_GAME;
	DONE;
}

void(entity pEntity) Raise_Reinit = asm
{
local float locked_1586;
local entity lOld;
	INDIRECT_FU	pEntity,	_reinit,	locked_1586;
	IF		locked_1586,	2;
	RETURN	offset_0;
	STORE_ENT	self,	lOld;
	STORE_ENT	pEntity,	self;
	INDIRECT_FU	self,	_reinit,	locked_1586;
	CALL0		locked_1586;
	STORE_ENT	lOld,	self;
	DONE;
}

void(entity pEntity) Raise_Destroy = asm
{
local float locked_1586;
local entity lOld;
	INDIRECT_FU	pEntity,	_destroy,	locked_1586;
	IF		locked_1586,	2;
	RETURN	offset_0;
	STORE_ENT	self,	lOld;
	STORE_ENT	pEntity,	self;
	INDIRECT_FU	self,	_destroy,	locked_1586;
	CALL0		locked_1586;
	STORE_ENT	lOld,	self;
	DONE;
}

bool(entity pEntity, float pKey, float pAscii) Raise_Key = asm
{
local float locked_1586;
local bool lResult;
local entity lOld;
	INDIRECT_FU	pEntity,	_key,	locked_1586;
	IF		locked_1586,	2;
	RETURN	KEY_GAME;
	STORE_ENT	self,	lOld;
	STORE_ENT	pEntity,	self;
	INDIRECT_FU	self,	_key,	locked_1586;
	STORE_F	pKey,	parm0_x;
	STORE_F	pAscii,	parm1_x;
	CALL2		locked_1586;
	STORE_F	return_x,	lResult;
	STORE_ENT	lOld,	self;
	RETURN	lResult;
	DONE;
}

void(entity pEntity) Raise_Draw = asm
{
local float locked_1586;
local entity lOld;
	INDIRECT_FU	pEntity,	_draw,	locked_1586;
	IF		locked_1586,	2;
	RETURN	offset_0;
	STORE_ENT	self,	lOld;
	STORE_ENT	pEntity,	self;
	INDIRECT_FU	self,	_draw,	locked_1586;
	CALL0		locked_1586;
	STORE_ENT	lOld,	self;
	DONE;
}

void(entity pEntity) Raise_MouseEnter = asm
{
local float locked_1586;
local entity lOld;
	INDIRECT_FU	pEntity,	_mouseEnter,	locked_1586;
	IF		locked_1586,	2;
	RETURN	offset_0;
	STORE_ENT	self,	lOld;
	STORE_ENT	pEntity,	self;
	INDIRECT_FU	self,	_mouseEnter,	locked_1586;
	CALL0		locked_1586;
	STORE_ENT	lOld,	self;
	DONE;
}

void(entity pEntity) Raise_MouseLeave = asm
{
local float locked_1586;
local entity lOld;
	INDIRECT_FU	pEntity,	_mouseLeave,	locked_1586;
	IF		locked_1586,	2;
	RETURN	offset_0;
	STORE_ENT	self,	lOld;
	STORE_ENT	pEntity,	self;
	INDIRECT_FU	self,	_mouseLeave,	locked_1586;
	CALL0		locked_1586;
	STORE_ENT	lOld,	self;
	DONE;
}

void(entity pEntity) Raise_Update = asm
{
local float locked_1586;
local entity lOld;
	INDIRECT_FU	pEntity,	_update,	locked_1586;
	IF		locked_1586,	2;
	RETURN	offset_0;
	STORE_ENT	self,	lOld;
	STORE_ENT	pEntity,	self;
	INDIRECT_FU	self,	_update,	locked_1586;
	CALL0		locked_1586;
	STORE_ENT	lOld,	self;
	DONE;
}

void(entity pEntity, float pSelect, float pUser) Raise_Select = asm
{
local float locked_1586;
local entity lOld;
	INDIRECT_FU	pEntity,	_select,	locked_1586;
	IF		locked_1586,	2;
	RETURN	offset_0;
	STORE_ENT	self,	lOld;
	STORE_ENT	pEntity,	self;
	INDIRECT_FU	self,	_select,	locked_1586;
	STORE_F	pSelect,	parm0_x;
	STORE_F	pUser,	parm1_x;
	CALL2		locked_1586;
	STORE_ENT	lOld,	self;
	DONE;
}

void() CtCall_Init = asm
{
local float locked_1586;
	INDIRECT_FU	self,	init,	locked_1586;
	IFNOT		locked_1586,	3;
	INDIRECT_FU	self,	init,	locked_1586;
	CALL0		locked_1586;
	DONE;
}

void() CtCall_Reinit = asm
{
local float locked_1586;
	INDIRECT_FU	self,	reinit,	locked_1586;
	IFNOT		locked_1586,	3;
	INDIRECT_FU	self,	reinit,	locked_1586;
	CALL0		locked_1586;
	DONE;
}

void() CtCall_Destroy = asm
{
local float locked_1586;
	INDIRECT_FU	self,	destroy,	locked_1586;
	IFNOT		locked_1586,	3;
	INDIRECT_FU	self,	destroy,	locked_1586;
	CALL0		locked_1586;
	DONE;
}

float(float pKey, float pAscii) CtCall_Key = asm
{
local float locked_1586;
	INDIRECT_FU	self,	key,	locked_1586;
	IFNOT		locked_1586,	6;
	INDIRECT_FU	self,	key,	locked_1586;
	STORE_F	pKey,	parm0_x;
	STORE_F	pAscii,	parm1_x;
	CALL2		locked_1586;
	RETURN	return_x;
	RETURN	KEY_GAME;
	DONE;
}

void() CtCall_Draw = asm
{
local float locked_1586;
	INDIRECT_FU	self,	draw,	locked_1586;
	IFNOT		locked_1586,	3;
	INDIRECT_FU	self,	draw,	locked_1586;
	CALL0		locked_1586;
	DONE;
}

void() CtCall_MouseEnter = asm
{
local float locked_1586;
	INDIRECT_FU	self,	mouseEnter,	locked_1586;
	IFNOT		locked_1586,	3;
	INDIRECT_FU	self,	mouseEnter,	locked_1586;
	CALL0		locked_1586;
	DONE;
}

void() CtCall_MouseLeave = asm
{
local float locked_1586;
	INDIRECT_FU	self,	mouseLeave,	locked_1586;
	IFNOT		locked_1586,	3;
	INDIRECT_FU	self,	mouseLeave,	locked_1586;
	CALL0		locked_1586;
	DONE;
}

void() CtCall_Action = asm
{
local float locked_1586;
	INDIRECT_FU	self,	action,	locked_1586;
	IFNOT		locked_1586,	3;
	INDIRECT_FU	self,	action,	locked_1586;
	CALL0		locked_1586;
	DONE;
}

void() CtCall_Update = asm
{
local float locked_1586;
	INDIRECT_FU	self,	update,	locked_1586;
	IFNOT		locked_1586,	3;
	INDIRECT_FU	self,	update,	locked_1586;
	CALL0		locked_1586;
	DONE;
}

void(float pSelect, float pUser) CtCall_Select = asm
{
local float locked_1586;
	INDIRECT_FU	self,	select,	locked_1586;
	IFNOT		locked_1586,	5;
	INDIRECT_FU	self,	select,	locked_1586;
	STORE_F	pSelect,	parm0_x;
	STORE_F	pUser,	parm1_x;
	CALL2		locked_1586;
	DONE;
}

void() DefCt_Reinit = asm
{
	DONE;
}

void() DefCt_Destroy = asm
{
	DONE;
}

float(float pKey, float pAscii) DefCt_Key = asm
{
	RETURN	KEY_GAME;
	DONE;
}

void() DefCt_Draw = asm
{
	DONE;
}

void() DefCt_MouseEnter = asm
{
	DONE;
}

void() DefCt_MouseLeave = asm
{
	DONE;
}

void () DefCt_Action;
void() DefCt_Action = asm
{
	DONE;
}

void(float pSelect, float pUser) DefCt_Select = asm
{
	DONE;
}

void() DefCt_Update = asm
{
	DONE;
}

void (float, string) _Menu_Structure_Debug;
void(float pLevel, string pText) _Menu_Structure_Debug = asm
{
local float temp_0;
	LE		pLevel,	sys_debug_structure,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	pText,	parm0_x;
	CALL1		print;
	DONE;
}

void (float) _Menu_Select;
void(float pUser) _Menu_Select = asm
{
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	DONE;
}

entity(entity pItem) _Menu_GetParent = asm
{
local float temp_0;
	INDIRECT_E	pItem,	_parent,	temp_0;
	IF		temp_0,	2;
	RETURN	null_entity;
	INDIRECT_E	pItem,	_parent,	temp_0;
	INDIRECT_F	temp_0,	flag,	temp_0;
	BITAND	temp_0,	FLAG_EMBEDDED,	temp_0;
	IFNOT		temp_0,	4;
	INDIRECT_E	pItem,	_parent,	parm0_x;
	CALL1		_Menu_GetParent;
	RETURN	return_x;
	INDIRECT_E	pItem,	_parent,	temp_0;
	RETURN	temp_0;
	DONE;
}

bool(entity pItem, entity pParent) _Menu_IsEmbeddedParentOf = asm
{
local float temp_0;
	INDIRECT_E	pItem,	_parent,	temp_0;
	EQ_E		temp_0,	pParent,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	FILE_APPEND;
	INDIRECT_E	pItem,	_parent,	temp_0;
	INDIRECT_F	temp_0,	flag,	temp_0;
	BITAND	temp_0,	FLAG_EMBEDDED,	temp_0;
	IFNOT		temp_0,	5;
	INDIRECT_E	pItem,	_parent,	parm0_x;
	STORE_F	pParent,	parm1_x;
	CALL2		_Menu_IsEmbeddedParentOf;
	RETURN	return_x;
	RETURN	KEY_GAME;
	DONE;
}

entity(entity pItem) _Menu_GetFirst = asm
{
local float temp_0;
local float temp_1;
	INDIRECT_F	pItem,	flag,	temp_0;
	BITAND	temp_0,	FLAG_EMBEDDED,	temp_0;
	IFNOT		temp_0,	2;
	INDIRECT_E	pItem,	_child,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	4;
	INDIRECT_E	pItem,	_child,	parm0_x;
	CALL1		_Menu_GetFirst;
	RETURN	return_x;
	RETURN	pItem;
	DONE;
}

entity(entity pItem) _Menu_GetLast = asm
{
local entity lNode;
local float temp_0;
local float temp_1;
	INDIRECT_F	pItem,	flag,	temp_0;
	BITAND	temp_0,	FLAG_EMBEDDED,	temp_0;
	IFNOT		temp_0,	2;
	INDIRECT_E	pItem,	_child,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	9;
	INDIRECT_E	pItem,	_child,	lNode;
	INDIRECT_E	lNode,	_next,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_E	lNode,	_next,	lNode;
	GOTO		-3;
	STORE_F	lNode,	parm0_x;
	CALL1		_Menu_GetLast;
	RETURN	return_x;
	RETURN	pItem;
	DONE;
}

entity(entity pItem) _Menu_GetNext = asm
{
local entity lNext;
local float temp_0;
local float temp_1;
	INDIRECT_E	pItem,	_next,	lNext;
	IFNOT		lNext,	4;
	STORE_F	lNext,	parm0_x;
	CALL1		_Menu_GetFirst;
	RETURN	return_x;
	INDIRECT_E	pItem,	_parent,	temp_0;
	INDIRECT_F	temp_0,	flag,	temp_0;
	BITAND	temp_0,	FLAG_EMBEDDED,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_E	pItem,	_parent,	temp_1;
	NE_E		temp_1,	Menu_ActiveWindow,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	5;
	INDIRECT_E	pItem,	_parent,	parm0_x;
	CALL1		_Menu_GetNext;
	RETURN	return_x;
	GOTO		2;
	RETURN	null_entity;
	DONE;
}

entity(entity pItem) _Menu_GetPrev = asm
{
local entity lPrev;
local float temp_0;
local float temp_1;
	INDIRECT_E	pItem,	_prev,	lPrev;
	IFNOT		lPrev,	4;
	STORE_F	lPrev,	parm0_x;
	CALL1		_Menu_GetLast;
	RETURN	return_x;
	INDIRECT_E	pItem,	_parent,	temp_0;
	INDIRECT_F	temp_0,	flag,	temp_0;
	BITAND	temp_0,	FLAG_EMBEDDED,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_E	pItem,	_parent,	temp_1;
	NE_E		temp_1,	Menu_ActiveWindow,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	5;
	INDIRECT_E	pItem,	_parent,	parm0_x;
	CALL1		_Menu_GetPrev;
	RETURN	return_x;
	GOTO		2;
	RETURN	null_entity;
	DONE;
}

void() _Menu_SelectNext = asm
{
local float locked_1586;
local entity lTemp;
local float temp_1;
	IF		Menu_ActiveItem,	5;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	"_SelectNext: Bad Menu_ActiveItem!
",	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	offset_0;
	STORE_ENT	Menu_ActiveItem,	lTemp;
	STORE_F	lTemp,	parm0_x;
	CALL1		_Menu_GetNext;
	STORE_ENT	return_x,	lTemp;
	NE_E		return_x,	null_entity,	locked_1586;
	IFNOT		locked_1586,	15;
	INDIRECT_F	lTemp,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_NOSELECT,	locked_1586;
	IF		locked_1586,	11;
	STORE_ENT	lTemp,	Menu_ActiveItem;
	INDIRECT_S	lTemp,	name,	locked_1586;
	STORE_F	"_SelectNext: ",	parm0_x;
	STORE_F	locked_1586,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		strcat;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	offset_0;
	GOTO		-18;
	STORE_ENT	Menu_ActiveItem,	lTemp;
	STORE_F	lTemp,	parm0_x;
	CALL1		_Menu_GetPrev;
	IFNOT		return_x,	8;
	STORE_F	lTemp,	parm0_x;
	STORE_F	return_x,	locked_1586;
	CALL1		_Menu_GetPrev;
	STORE_F	return_x,	temp_1;
	STORE_F	locked_1586,	return_x;
	STORE_ENT	temp_1,	lTemp;
	GOTO		-9;
	NE_E		lTemp,	Menu_ActiveItem,	locked_1586;
	IFNOT		locked_1586,	18;
	INDIRECT_F	lTemp,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_NOSELECT,	locked_1586;
	IF		locked_1586,	11;
	STORE_ENT	lTemp,	Menu_ActiveItem;
	INDIRECT_S	lTemp,	name,	locked_1586;
	STORE_F	"_SelectNext after loop: ",	parm0_x;
	STORE_F	locked_1586,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		strcat;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	offset_0;
	STORE_F	lTemp,	parm0_x;
	CALL1		_Menu_GetNext;
	STORE_ENT	return_x,	lTemp;
	GOTO		-18;
	DONE;
}

void() _Menu_SelectPrev = asm
{
local float locked_1586;
local entity lTemp;
local float temp_1;
	IF		Menu_ActiveItem,	5;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	"_SelectPrev: Bad Menu_ActiveItem!
",	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	offset_0;
	STORE_ENT	Menu_ActiveItem,	lTemp;
	STORE_F	lTemp,	parm0_x;
	CALL1		_Menu_GetPrev;
	STORE_ENT	return_x,	lTemp;
	NE_E		return_x,	null_entity,	locked_1586;
	IFNOT		locked_1586,	15;
	INDIRECT_F	lTemp,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_NOSELECT,	locked_1586;
	IF		locked_1586,	11;
	STORE_ENT	lTemp,	Menu_ActiveItem;
	INDIRECT_S	lTemp,	name,	locked_1586;
	STORE_F	"_SelectPrev: ",	parm0_x;
	STORE_F	locked_1586,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		strcat;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	offset_0;
	GOTO		-18;
	STORE_ENT	Menu_ActiveItem,	lTemp;
	STORE_F	lTemp,	parm0_x;
	CALL1		_Menu_GetNext;
	IFNOT		return_x,	8;
	STORE_F	lTemp,	parm0_x;
	STORE_F	return_x,	locked_1586;
	CALL1		_Menu_GetNext;
	STORE_F	return_x,	temp_1;
	STORE_F	locked_1586,	return_x;
	STORE_ENT	temp_1,	lTemp;
	GOTO		-9;
	NE_E		lTemp,	Menu_ActiveItem,	locked_1586;
	IFNOT		locked_1586,	18;
	INDIRECT_F	lTemp,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_NOSELECT,	locked_1586;
	IF		locked_1586,	11;
	STORE_ENT	lTemp,	Menu_ActiveItem;
	INDIRECT_S	lTemp,	name,	locked_1586;
	STORE_F	"_SelectPrev after loop: ",	parm0_x;
	STORE_F	locked_1586,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		strcat;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	offset_0;
	STORE_F	lTemp,	parm0_x;
	CALL1		_Menu_GetPrev;
	STORE_ENT	return_x,	lTemp;
	GOTO		-18;
	DONE;
}

float() _Menu_SelectUp = asm
{
local entity lNode;
local entity lParent;
local entity lSelected;
local float temp_0;
	STORE_ENT	Menu_ActiveItem,	lSelected;
	IF		lSelected,	5;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	"_SelectUp: Bad Menu_ActiveItem!
",	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	KEY_GAME;
	EQ_E		lSelected,	Menu_ActiveWindow,	temp_0;
	IFNOT		temp_0,	18;
	STORE_F	KEY_MENU,	parm0_x;
	STORE_F	"_SelectUp: Selecting up current active window..
",	parm1_x;
	CALL2		_Menu_Structure_Debug;
	EQ_E		Menu_History,	null_entity,	temp_0;
	IFNOT		temp_0,	9;
	STORE_F	KEY_MENU,	parm0_x;
	STORE_F	"_SelectUp: Empty history -> toggling menu..
",	parm1_x;
	CALL2		_Menu_Structure_Debug;
	CALL0		Menu_Toggle;
	IF		return_x,	3;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		Menu_Reselect;
	RETURN	FILE_APPEND;
	STORE_F	KEY_MENU,	parm0_x;
	STORE_F	"_SelectUp: Popping history..
",	parm1_x;
	CALL2		_Menu_Structure_Debug;
	CALL0		Menu_History_Pop;
	STORE_F	lSelected,	parm0_x;
	CALL1		_Menu_GetParent;
	STORE_ENT	return_x,	lParent;
	IF		lParent,	5;
	STORE_F	KEY_MENU,	parm0_x;
	STORE_F	"_SelectUp: No parent and not active window!
",	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	KEY_GAME;
	INDIRECT_F	lParent,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_NOSELECT,	temp_0;
	IF		temp_0,	11;
	STORE_ENT	lParent,	Menu_ActiveItem;
	INDIRECT_S	lParent,	name,	temp_0;
	STORE_F	"_SelectUp: first parent: ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		strcat;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	FILE_APPEND;
	EQ_E		lParent,	Menu_ActiveWindow,	temp_0;
	IFNOT		temp_0,	16;
	STORE_ENT	Menu_ActiveWindow,	Menu_ActiveItem;
	INDIRECT_S	Menu_ActiveItem,	name,	temp_0;
	STORE_F	"_SelectUp: select up parent: ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		strcat;
	STORE_F	KEY_MENU,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Menu_Structure_Debug;
	CALL0		_Menu_SelectUp;
	IFNOT		return_x,	2;
	RETURN	FILE_APPEND;
	STORE_ENT	lSelected,	Menu_ActiveItem;
	RETURN	KEY_GAME;
	GOTO		7;
	INDIRECT_E	lParent,	_parent,	temp_0;
	IF		temp_0,	5;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	"_SelectUp: No parent of parent and not active window!
",	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	KEY_GAME;
	STORE_F	lParent,	parm0_x;
	CALL1		_Menu_GetParent;
	STORE_ENT	return_x,	Menu_ActiveItem;
	INDIRECT_S	Menu_ActiveItem,	name,	temp_0;
	STORE_F	"_SelectUp: SelectDown on parent of parent '",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"' 
",	parm2_x;
	CALL3		strcat;
	STORE_F	KEY_MENU,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Menu_Structure_Debug;
	CALL0		_Menu_SelectDown;
	STORE_ENT	Menu_ActiveItem,	lNode;
	IFNOT		lNode,	14;
	INDIRECT_E	lNode,	_parent,	temp_0;
	EQ_E		temp_0,	lParent,	temp_0;
	IFNOT		temp_0,	9;
	STORE_F	lSelected,	parm0_x;
	CALL1		_Menu_GetParent;
	STORE_ENT	return_x,	Menu_ActiveItem;
	CALL0		_Menu_SelectUp;
	IFNOT		return_x,	2;
	RETURN	FILE_APPEND;
	STORE_ENT	lSelected,	Menu_ActiveItem;
	RETURN	KEY_GAME;
	INDIRECT_E	lNode,	_parent,	lNode;
	GOTO		-13;
	RETURN	FILE_APPEND;
	DONE;
}

void (entity) _Menu_PrintRunFlag;
float() _Menu_SelectDown = asm
{
local entity lChild;
local entity lParent;
local float temp_0;
	STORE_ENT	Menu_ActiveItem,	lParent;
	IF		lParent,	5;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	"_SelectDown: Bad Menu_ActiveItem!
",	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	KEY_GAME;
	INDIRECT_E	lParent,	_child,	parm0_x;
	CALL1		_Menu_GetFirst;
	STORE_ENT	return_x,	lChild;
	IFNOT		lChild,	20;
	INDIRECT_F	lChild,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_NOSELECT,	temp_0;
	IF		temp_0,	13;
	STORE_ENT	lChild,	Menu_ActiveItem;
	STORE_F	lChild,	parm0_x;
	CALL1		_Menu_PrintRunFlag;
	INDIRECT_S	lChild,	name,	temp_0;
	STORE_F	"_SelectDown: ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		strcat;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Menu_Structure_Debug;
	RETURN	FILE_APPEND;
	STORE_F	lChild,	parm0_x;
	CALL1		_Menu_GetNext;
	STORE_ENT	return_x,	lChild;
	GOTO		-19;
	INDIRECT_E	lParent,	_child,	parm0_x;
	CALL1		_Menu_GetFirst;
	STORE_ENT	return_x,	lChild;
	IFNOT		lChild,	20;
	INDIRECT_F	lChild,	flag,	temp_0;
	BITAND	temp_0,	FLAG_EMBEDDED,	temp_0;
	IF		temp_0,	13;
	STORE_ENT	lChild,	Menu_ActiveItem;
	INDIRECT_S	Menu_ActiveItem,	name,	temp_0;
	STORE_F	"_SelectDown: Try child: ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		strcat;
	STORE_F	KEY_MENU,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Menu_Structure_Debug;
	CALL0		_Menu_SelectDown;
	IFNOT		return_x,	2;
	RETURN	FILE_APPEND;
	STORE_F	lChild,	parm0_x;
	CALL1		_Menu_GetNext;
	STORE_ENT	return_x,	lChild;
	GOTO		-19;
	STORE_ENT	lParent,	Menu_ActiveItem;
	RETURN	KEY_GAME;
	DONE;
}

void() _Menu_Reselect = asm
{
	STORE_ENT	Menu_ActiveWindow,	Menu_ActiveItem;
	CALL0		_Menu_SelectDown;
	DONE;
}

void(float pUser) Menu_SelectNext = asm
{
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	CALL0		_Menu_SelectNext;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	DONE;
}

void(float pUser) Menu_SelectPrev = asm
{
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	CALL0		_Menu_SelectPrev;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	DONE;
}

float(float pUser) Menu_SelectUp = asm
{
local entity lOld;
	STORE_ENT	Menu_ActiveItem,	lOld;
	CALL0		_Menu_SelectUp;
	IFNOT		return_x,	10;
	STORE_F	lOld,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

float(float pUser) Menu_SelectDown = asm
{
local entity lOld;
	STORE_ENT	Menu_ActiveItem,	lOld;
	CALL0		_Menu_SelectDown;
	IFNOT		return_x,	10;
	STORE_F	lOld,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void(entity pItem, bool pUser) Menu_Select = asm
{
local float temp_0;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	INDIRECT_S	pItem,	name,	temp_0;
	STORE_F	"Menu_Select: ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		strcat;
	STORE_F	FILE_APPEND,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Menu_Structure_Debug;
	STORE_ENT	pItem,	Menu_ActiveItem;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	DONE;
}

void(entity pItem, bool pUser) Menu_CorrectSelection = asm
{
local float temp_0;
	NE_E		Menu_ActiveItem,	pItem,	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	pItem,	parm0_x;
	STORE_F	pUser,	parm1_x;
	CALL2		Menu_Select;
	DONE;
}

void(float pUser) Menu_Reselect = asm
{
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	CALL0		_Menu_Reselect;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	DONE;
}

void(entity pMenu, float pMakeActive, float pUser) Menu_JumpToWindow = asm
{
local float temp_0;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	INDIRECT_E	pMenu,	_child,	temp_0;
	IF		temp_0,	6;
	INDIRECT_S	pMenu,	name,	temp_0;
	STORE_F	"Cant jump to ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	" !
",	parm2_x;
	CALL3		error;
	IFNOT		pMakeActive,	5;
	STORE_F	pMenu,	parm0_x;
	STORE_F	Util_NullFunction,	parm1_x;
	CALL2		Menu_History_Push;
	STORE_ENT	pMenu,	Menu_ActiveWindow;
	STORE_ENT	pMenu,	Menu_ActiveItem;
	CALL0		_Menu_SelectDown;
	IF		return_x,	6;
	INDIRECT_S	pMenu,	name,	temp_0;
	STORE_F	"Couldn't jump to ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	" !
",	parm2_x;
	CALL3		error;
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	STORE_F	pUser,	parm2_x;
	CALL3		Raise_Select;
	DONE;
}

entity(entity pOrigin, string pName, bool pThrow) Menu_GetItemEx = asm
{
local float lCounter;
local float lCount;
local string lToken;
local string lFirstTwo;
local entity lItem;
local float temp_0;
local float temp_1;
	STORE_F	pName,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	KEY_MENU,	parm2_x;
	CALL3		substring;
	STORE_S	return_x,	lFirstTwo;
	EQ_S		lFirstTwo,	"::",	temp_0;
	IFNOT		temp_0,	11;
	STORE_F	pName,	parm0_x;
	STORE_F	KEY_MENU,	parm1_x;
	STORE_F	100000.000000,	parm2_x;
	CALL3		substring;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lItem;
	GOTO		65;
	EQ_S		lFirstTwo,	"##",	temp_0;
	IFNOT		temp_0,	40;
	STORE_ENT	pOrigin,	lItem;
	STORE_F	pName,	parm0_x;
	STORE_F	KEY_MENU,	parm1_x;
	STORE_F	100000.000000,	parm2_x;
	CALL3		substring;
	STORE_F	return_x,	parm0_x;
	CALL1		tokenize;
	STORE_F	return_x,	lCount;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	temp_0;
	IFNOT		temp_0,	1;
	AND		temp_0,	lItem,	temp_0;
	IFNOT		temp_0,	26;
	STORE_F	lCounter,	parm0_x;
	CALL1		argv;
	STORE_S	return_x,	lToken;
	EQ_S		lToken,	"up",	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_E	lItem,	_parent,	lItem;
	GOTO		17;
	EQ_S		lToken,	"down",	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_E	lItem,	_child,	lItem;
	GOTO		13;
	EQ_S		lToken,	"next",	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_E	lItem,	_next,	lItem;
	GOTO		9;
	EQ_S		lToken,	"prev",	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_E	lItem,	_prev,	lItem;
	GOTO		5;
	STORE_F	"Bad direction link(bad token): '",	parm0_x;
	STORE_F	pName,	parm1_x;
	STORE_F	"'!",	parm2_x;
	CALL3		error;
	ADD_F		lCounter,	FILE_APPEND,	lCounter;
	GOTO		-28;
	GOTO		24;
	STORE_ENT	null_entity,	lItem;
	NOT_ENT	lItem,	temp_0;
	IFNOT		temp_0,	3;
	INDIRECT_E	pOrigin,	_parent,	pOrigin;
	NE_E		pOrigin,	null_entity,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	11;
	INDIRECT_S	pOrigin,	name,	parm0_x;
	STORE_F	"::",	parm1_x;
	STORE_F	pName,	parm2_x;
	CALL3		strcat;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lItem;
	GOTO		-15;
	IF		lItem,	6;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	pName,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lItem;
	EQ_E		lItem,	null_entity,	temp_0;
	IFNOT		temp_0,	1;
	AND		temp_0,	pThrow,	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	"Couldn't find item '",	parm0_x;
	STORE_F	pName,	parm1_x;
	STORE_F	"'!",	parm2_x;
	CALL3		error;
	RETURN	lItem;
	DONE;
}

entity(entity pOrigin, string pName, bool pThrow) Menu_GetChildEx = asm
{
local entity lItem;
local float temp_0;
	IFNOT		pOrigin,	11;
	INDIRECT_S	pOrigin,	name,	parm0_x;
	STORE_F	"::",	parm1_x;
	STORE_F	pName,	parm2_x;
	CALL3		strcat;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lItem;
	GOTO		6;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	pName,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lItem;
	EQ_E		lItem,	null_entity,	temp_0;
	IFNOT		temp_0,	1;
	AND		temp_0,	pThrow,	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	"Couldn't find item '",	parm0_x;
	STORE_F	pName,	parm1_x;
	STORE_F	"'!",	parm2_x;
	CALL3		error;
	RETURN	lItem;
	DONE;
}

entity(string pName) Menu_GetItem = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	pName,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		Menu_GetItemEx;
	RETURN	return_x;
	DONE;
}

entity(string pName) Menu_GetChild = asm
{
	STORE_F	self,	parm0_x;
	STORE_F	pName,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		Menu_GetChildEx;
	RETURN	return_x;
	DONE;
}

void(entity pWindow) Menu_EmptyWindow = asm
{
local entity lChild;
local float temp_0;
	INDIRECT_E	pWindow,	_child,	lChild;
	IFNOT		lChild,	9;
	STORE_F	lChild,	parm0_x;
	CALL1		Menu_EmptyWindow;
	STORE_F	lChild,	parm0_x;
	CALL1		Raise_Destroy;
	STORE_F	lChild,	parm0_x;
	CALL1		remove;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-8;
	ADDRESS	pWindow,	_child,	temp_0;
	STOREP_ENT	null_entity,	temp_0;
	DONE;
}

void(entity pEntity) Menu_RemoveItem = asm
{
local entity lParent;
local float temp_0;
	INDIRECT_E	pEntity,	_parent,	lParent;
	STORE_F	pEntity,	parm0_x;
	CALL1		Menu_EmptyWindow;
	STORE_F	pEntity,	parm0_x;
	CALL1		Raise_Destroy;
	STORE_F	pEntity,	parm0_x;
	CALL1		remove;
	IFNOT		lParent,	3;
	STORE_F	lParent,	parm0_x;
	CALL1		Menu_LinkChildren;
	DONE;
}

void(entity pItem) _Menu_PrintRunFlag = asm
{
local float temp_0;
	IFNOT		sys_debug_runflag,	48;
	INDIRECT_S	pItem,	name,	temp_0;
	STORE_F	" ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	" Runflags: ",	parm2_x;
	CALL3		print;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_TEMPLATE,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	"TEMPLATE ",	parm0_x;
	CALL1		print;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_MOUSEINAREA,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	"MOUSEINAREA ",	parm0_x;
	CALL1		print;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_HADMOUSE,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	"HADMOUSE ",	parm0_x;
	CALL1		print;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_CHILDDRAWONLY,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	"CHILDDRAWONLY ",	parm0_x;
	CALL1		print;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_CHILDDRAWUPDATEONLY,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	"CHILDDRAWUPDATEONLY ",	parm0_x;
	CALL1		print;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_HIDDEN,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	"HIDDEN ",	parm0_x;
	CALL1		print;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_CLIPPED,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	"CLIPPED ",	parm0_x;
	CALL1		print;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_NOSELECT,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	"NOSELECT ",	parm0_x;
	CALL1		print;
	STORE_F	"
",	parm0_x;
	CALL1		print;
	DONE;
}

void(entity pItem) Menu_SetRunFlag = asm
{
local float lRunFlag;
local float lFlag;
local float temp_0;
local float temp_1;
local float temp_5;
	INDIRECT_F	pItem,	flag,	lFlag;
	BITAND	lFlag,	FLAG_TEMPLATE,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	pItem,	_runFlag,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITOR		temp_1,	RUNFLAG_TEMPLATE,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	lRunFlag;
	BITAND	lRunFlag,	RUNFLAG_MOUSEINAREA,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	pItem,	_runFlag,	temp_0;
	SUB_F		lRunFlag,	RUNFLAG_MOUSEINAREA,	temp_1;
	BITOR		temp_1,	RUNFLAG_HADMOUSE,	temp_1;
	STOREP_F	temp_1,	temp_0;
	EQ_V		Menu_Clip_Size,	'0.000000 0.000000 0.000000',	temp_0;
	IFNOT		temp_0,	2;
	NE_V		Menu_Clip_Position,	'0.000000 0.000000 0.000000',	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	pItem,	_runFlag,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITOR		temp_1,	RUNFLAG_CLIPPED,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	lRunFlag;
	BITAND	lFlag,	FLAG_HIDDEN,	temp_0;
	IF		temp_0,	2;
	BITAND	lRunFlag,	RUNFLAG_TEMPLATE,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	6;
	BITAND	lFlag,	FLAG_SERVERONLY,	temp_1;
	IFNOT		temp_1,	3;
	BITAND	gamestatus,	FILE_APPEND,	temp_5;
	NOT_F		temp_5,	temp_5;
	AND		temp_1,	temp_5,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	6;
	BITAND	lFlag,	FLAG_CONNECTEDONLY,	temp_1;
	IFNOT		temp_1,	3;
	BITAND	gamestatus,	KEY_MENU,	temp_5;
	NOT_F		temp_5,	temp_5;
	AND		temp_1,	temp_5,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	6;
	BITAND	lFlag,	FLAG_DEVELOPERONLY,	temp_1;
	IFNOT		temp_1,	3;
	BITAND	gamestatus,	CVAR_READONLY,	temp_5;
	NOT_F		temp_5,	temp_5;
	AND		temp_1,	temp_5,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	pItem,	_runFlag,	temp_0;
	BITOR		lRunFlag,	RUNFLAG_HIDDEN,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	lRunFlag;
	BITAND	lFlag,	FLAG_NOSELECT,	temp_0;
	IF		temp_0,	2;
	BITAND	lFlag,	FLAG_DRAWONLY,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	2;
	BITAND	lFlag,	FLAG_DRAWUPDATEONLY,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	2;
	BITAND	lFlag,	FLAG_EMBEDDED,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	2;
	BITAND	lRunFlag,	RUNFLAG_TEMPLATE,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	2;
	BITAND	lRunFlag,	RUNFLAG_HIDDEN,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	2;
	BITAND	lRunFlag,	RUNFLAG_CHILDDRAWONLY,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	2;
	BITAND	lRunFlag,	RUNFLAG_CHILDDRAWUPDATEONLY,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	pItem,	_runFlag,	temp_0;
	BITOR		lRunFlag,	RUNFLAG_NOSELECT,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	pItem,	parm0_x;
	CALL1		_Menu_PrintRunFlag;
	DONE;
}

void(entity pParent, entity pItem) Menu_InheritRunFlag = asm
{
local float temp_0;
local float temp_1;
	ADDRESS	pItem,	_runFlag,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITAND	temp_1,	3588.000000,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_F	pParent,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_TEMPLATE,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	pItem,	_runFlag,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITOR		temp_1,	RUNFLAG_TEMPLATE,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_F	pParent,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_CHILDDRAWONLY,	temp_0;
	IF		temp_0,	3;
	INDIRECT_F	pParent,	flag,	temp_1;
	BITAND	temp_1,	FLAG_CHILDDRAWONLY,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	pItem,	_runFlag,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITOR		temp_1,	RUNFLAG_CHILDDRAWONLY,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_F	pParent,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_CHILDDRAWUPDATEONLY,	temp_0;
	IF		temp_0,	3;
	INDIRECT_F	pParent,	flag,	temp_1;
	BITAND	temp_1,	FLAG_CHILDDRAWUPDATEONLY,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	pItem,	_runFlag,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITOR		temp_1,	RUNFLAG_CHILDDRAWUPDATEONLY,	temp_1;
	STOREP_F	temp_1,	temp_0;
	INDIRECT_F	pParent,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_HIDDEN,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	pItem,	_runFlag,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITOR		temp_1,	RUNFLAG_HIDDEN,	temp_1;
	STOREP_F	temp_1,	temp_0;
	DONE;
}

void() Menu_UpdateRunFlags = asm
{
local vector lOrg;
local vector lSize;
local vector lPos;
local float temp_0;
local float temp_1;
local vector temp_2;
	STORE_V	Menu_Clip_Position,	lPos;
	STORE_V	Menu_Clip_Size,	lSize;
	STORE_V	Menu_Origin,	lOrg;
	CALL0		Menu_Process_Setup;
	ADDRESS	Menu_ActiveWindow,	_runFlag,	temp_0;
	INDIRECT_F	Menu_ActiveWindow,	_runFlag,	temp_1;
	BITAND	temp_1,	RUNFLAG_MOUSEINAREA,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	Menu_ActiveWindow,	parm0_x;
	STORE_F	MENU_PROCESS_RUNFLAG,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	STORE_F	KEY_GAME,	parm3_x;
	STORE_F	KEY_GAME,	parm4_x;
	CALL5		Menu_Process;
	STORE_V	lSize,	Menu_Clip_Size;
	STORE_V	lPos,	Menu_Clip_Position;
	STORE_V	lOrg,	Menu_Origin;
	SUB_V		Cursor_Position,	Menu_Origin,	Menu_Cursor_Position;
	DONE;
}

float(entity pEntity) Menu_HasEvents = asm
{
local float temp_0;
	INDIRECT_F	pEntity,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_CHILDDRAWONLY,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	KEY_GAME;
	INDIRECT_F	pEntity,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_CHILDDRAWUPDATEONLY,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	KEY_GAME;
	INDIRECT_F	pEntity,	flag,	temp_0;
	BITAND	temp_0,	FLAG_DRAWONLY,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	KEY_GAME;
	INDIRECT_F	pEntity,	flag,	temp_0;
	BITAND	temp_0,	FLAG_DRAWUPDATEONLY,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	KEY_GAME;
	RETURN	FILE_APPEND;
	DONE;
}

void (vector, vector, vector, float, float, string) _Mgfx_Debug_Info;
void(vector pPos, vector pSize, vector pColor, float pAlpha, float pDrawFlag, string pText) _Mgfx_Debug_Info = asm
{
local float locked_1585;
local float temp_0;
local float temp_5;
	IF		sys_debug_mgfx,	2;
	RETURN	offset_0;
	STORE_F	pText,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	pText;
	STORE_V	pPos,	parm0;
	CALL1		vtos;
	STORE_V	pSize,	parm0;
	STORE_F	return_x,	temp_0;
	CALL1		vtos;
	STORE_F	return_x,	locked_1585;
	STORE_F	temp_0,	return_x;
	STORE_V	pColor,	parm0;
	STORE_F	return_x,	temp_0;
	CALL1		vtos;
	STORE_F	return_x,	temp_5;
	STORE_F	temp_0,	return_x;
	STORE_F	"MGFX output: ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	" - ",	parm2_x;
	STORE_F	locked_1585,	parm3_x;
	STORE_F	" C",	parm4_x;
	STORE_F	temp_5,	parm5_x;
	CALL6		print;
	STORE_F	pAlpha,	parm0_x;
	CALL1		ftos;
	STORE_F	pDrawFlag,	parm0_x;
	STORE_F	return_x,	temp_0;
	CALL1		ftos;
	STORE_F	return_x,	locked_1585;
	STORE_F	temp_0,	return_x;
	STORE_F	" A",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	" X",	parm2_x;
	STORE_F	locked_1585,	parm3_x;
	STORE_F	" ",	parm4_x;
	STORE_F	pText,	parm5_x;
	STORE_F	"
",	parm6_x;
	CALL7		print;
	STORE_F	pText,	parm0_x;
	CALL1		String_Free;
	DONE;
}

vector(vector pPos) Menu_MenToOrg = asm
{
local vector temp_2;
	SUB_V		pPos,	Menu_Origin,	temp_2;
	RETURN	temp_2_x;
	DONE;
}

vector(vector pPos) Menu_OrgToMen = asm
{
local vector temp_2;
	ADD_V		pPos,	Menu_Origin,	temp_2;
	RETURN	temp_2_x;
	DONE;
}

vector(vector pPos) Menu_ConToOrg = asm
{
	STORE_V	pPos,	parm0;
	CALL1		Gfx_ConToMen;
	STORE_V	return,	pPos;
	STORE_V	pPos,	parm0;
	CALL1		Menu_MenToOrg;
	RETURN	return_x;
	DONE;
}

vector(vector pPos) Menu_OrgToCon = asm
{
	STORE_V	pPos,	parm0;
	CALL1		Menu_OrgToMen;
	STORE_V	return,	pPos;
	STORE_V	pPos,	parm0;
	CALL1		Gfx_MenToCon;
	RETURN	return_x;
	DONE;
}

float(vector pPosition, float pCharacter, vector pScale, vector pRGB, float pAlpha, float pFlag) Menu_DrawCharacter = asm
{
	STORE_F	pCharacter,	parm0_x;
	CALL1		ftos;
	STORE_F	"DrawChar: ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		strcat;
	STORE_V	pPosition,	parm0;
	STORE_V	pScale,	parm1;
	STORE_V	pRGB,	parm2;
	STORE_F	pAlpha,	parm3_x;
	STORE_F	pFlag,	parm4_x;
	STORE_F	return_x,	parm5_x;
	CALL6		_Mgfx_Debug_Info;
	STORE_V	pPosition,	parm0;
	CALL1		Menu_OrgToMen;
	STORE_V	return,	pPosition;
	STORE_V	pPosition,	parm0;
	STORE_F	pCharacter,	parm1_x;
	STORE_V	pScale,	parm2;
	STORE_V	pRGB,	parm3;
	STORE_F	pAlpha,	parm4_x;
	STORE_F	pFlag,	parm5_x;
	CALL6		Gfx_DrawCharacter;
	RETURN	return_x;
	DONE;
}

float(vector pPosition, string pText, vector pScale, vector pRGB, float pAlpha, float pFlag) Menu_DrawString = asm
{
local float temp_0;
	NOT_S		pText,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	FILE_APPEND;
	STORE_F	"DrawString: ",	parm0_x;
	STORE_F	pText,	parm1_x;
	CALL2		strcat;
	STORE_V	pPosition,	parm0;
	STORE_V	pScale,	parm1;
	STORE_V	pRGB,	parm2;
	STORE_F	pAlpha,	parm3_x;
	STORE_F	pFlag,	parm4_x;
	STORE_F	return_x,	parm5_x;
	CALL6		_Mgfx_Debug_Info;
	STORE_V	pPosition,	parm0;
	CALL1		Menu_OrgToMen;
	STORE_V	return,	pPosition;
	STORE_V	pPosition,	parm0;
	STORE_F	pText,	parm1_x;
	STORE_V	pScale,	parm2;
	STORE_V	pRGB,	parm3;
	STORE_F	pAlpha,	parm4_x;
	STORE_F	pFlag,	parm5_x;
	CALL6		Gfx_DrawString;
	RETURN	return_x;
	DONE;
}

float(vector pPosition, string pPicture, vector pSize, vector pRGB, float pAlpha, float pFlag) Menu_DrawPicture = asm
{
	STORE_F	"DrawPicture: ",	parm0_x;
	STORE_F	pPicture,	parm1_x;
	CALL2		strcat;
	STORE_V	pPosition,	parm0;
	STORE_V	pSize,	parm1;
	STORE_V	pRGB,	parm2;
	STORE_F	pAlpha,	parm3_x;
	STORE_F	pFlag,	parm4_x;
	STORE_F	return_x,	parm5_x;
	CALL6		_Mgfx_Debug_Info;
	STORE_V	pPosition,	parm0;
	CALL1		Menu_OrgToMen;
	STORE_V	return,	pPosition;
	STORE_V	pPosition,	parm0;
	STORE_F	pPicture,	parm1_x;
	STORE_V	pSize,	parm2;
	STORE_V	pRGB,	parm3;
	STORE_F	pAlpha,	parm4_x;
	STORE_F	pFlag,	parm5_x;
	CALL6		Gfx_DrawPic;
	RETURN	return_x;
	DONE;
}

float(vector pPosition, vector pSize, vector pRGB, float pAlpha, float pFlag) Menu_Fill = asm
{
	STORE_V	pPosition,	parm0;
	STORE_V	pSize,	parm1;
	STORE_V	pRGB,	parm2;
	STORE_F	pAlpha,	parm3_x;
	STORE_F	pFlag,	parm4_x;
	STORE_F	"Fill",	parm5_x;
	CALL6		_Mgfx_Debug_Info;
	STORE_V	pPosition,	parm0;
	CALL1		Menu_OrgToMen;
	STORE_V	return,	pPosition;
	STORE_V	pPosition,	parm0;
	STORE_V	pSize,	parm1;
	STORE_V	pRGB,	parm2;
	STORE_F	pAlpha,	parm3_x;
	STORE_F	pFlag,	parm4_x;
	CALL5		Gfx_Fill;
	RETURN	return_x;
	DONE;
}

void(float pX, float pY, float pWidth, float pHeight) Menu_SetClipArea = asm
{
local vector lSize;
local vector lDelta;
local vector lPosition;
local vector temp_2;
	STORE_F	pX,	lPosition_x;
	STORE_F	pY,	lPosition_y;
	STORE_V	lPosition,	parm0;
	CALL1		Menu_OrgToMen;
	STORE_V	return,	lPosition;
	STORE_F	pWidth,	lSize_x;
	STORE_F	pHeight,	lSize_y;
	STORE_V	lPosition,	parm0;
	STORE_V	Menu_Clip_Position,	parm1;
	STORE_V	Menu_Clip_Size,	parm2;
	CALL3		Util_GetClipDelta;
	STORE_V	return,	lDelta;
	ADD_V		lPosition,	lDelta,	lPosition;
	SUB_V		lSize,	lDelta,	temp_2;
	STORE_V	lPosition,	parm0;
	STORE_V	temp_2,	parm1;
	STORE_V	Menu_Clip_Position,	parm2;
	STORE_V	Menu_Clip_Size,	parm3;
	CALL4		Util_ClipRect;
	STORE_V	return,	lSize;
	STORE_F	lPosition_x,	parm0_x;
	STORE_F	lPosition_y,	parm1_x;
	STORE_F	pWidth,	parm2_x;
	STORE_F	pHeight,	parm3_x;
	CALL4		Gfx_SetClipArea;
	DONE;
}

void() Menu_ResetClipArea = asm
{
local float temp_0;
local float temp_1;
	EQ_V		Menu_Clip_Position,	'0.000000 0.000000 0.000000',	temp_0;
	IFNOT		temp_0,	2;
	EQ_V		Menu_Clip_Size,	'0.000000 0.000000 0.000000',	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	3;
	CALL0		Gfx_ResetClipArea;
	GOTO		6;
	STORE_F	Menu_Clip_Position_x,	parm0_x;
	STORE_F	Menu_Clip_Position_y,	parm1_x;
	STORE_F	Menu_Clip_Size_x,	parm2_x;
	STORE_F	Menu_Clip_Size_y,	parm3_x;
	CALL4		Gfx_SetClipArea;
	DONE;
}

void() Menu_Init = asm
{
	CALL0		Sys_Debug_Init;
	CALL0		Sys_Debug_Frame;
	CALL0		Menu_InitGarbageStats;
	CALL0		Menu_Load;
	DONE;
}

void() Menu_Load = asm
{
	STORE_F	MENU_MAINFILE,	parm0_x;
	CALL1		Parser_ParseMenu;
	CALL0		Menu_LinkWindows;
	DONE;
}

entity (entity, FIELD TYPE, string, FIELD TYPE, float) finddef;
entity(entity pStart, .string pFind1, string pMatch, .float pFind2, float pMatch2) finddef = asm
{
local float temp_0;
	STORE_F	pStart,	parm0_x;
	STORE_F	pFind1,	parm1_x;
	STORE_F	pMatch,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	pStart;
	EQ_E		pStart,	null_entity,	temp_0;
	IFNOT		temp_0,	2;
	GOTO		6;
	INDIRECT_F	pStart,	pFind2,	temp_0;
	EQ_F		temp_0,	pMatch2,	temp_0;
	IFNOT		temp_0,	2;
	GOTO		2;
	GOTO		-12;
	RETURN	pStart;
	DONE;
}

void(entity pParent) Menu_LinkChildren = asm
{
local entity lOPrevious;
local entity lOverwrite;
local entity lNext;
local entity lPrevious;
local float lOrder;
local entity lChild;
local float temp_0;
local float temp_1;
	INDIRECT_S	pParent,	name,	temp_0;
	STORE_F	parent,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	CALL2		findchainstring;
	STORE_ENT	return_x,	lChild;
	EQ_E		lChild,	null_entity,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	offset_0;
	STORE_ENT	null_entity,	lPrevious;
	IFNOT		lChild,	7;
	INDIRECT_E	lChild,	chain,	lNext;
	ADDRESS	lChild,	chain,	temp_0;
	STOREP_ENT	lPrevious,	temp_0;
	STORE_ENT	lChild,	lPrevious;
	STORE_ENT	lNext,	lChild;
	GOTO		-6;
	STORE_ENT	lPrevious,	lChild;
	STORE_F	FILE_APPEND,	lOrder;
	STORE_ENT	null_entity,	lPrevious;
	IFNOT		lChild,	45;
	INDIRECT_S	pParent,	name,	temp_0;
	STORE_F	null_entity,	parm0_x;
	STORE_F	parent,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	STORE_F	orderPos,	parm3_x;
	STORE_F	lOrder,	parm4_x;
	CALL5		finddef;
	STORE_ENT	return_x,	lOverwrite;
	EQ_E		lOverwrite,	lChild,	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	lChild,	orderPos,	temp_0;
	STOREP_F	lOrder,	temp_0;
	GOTO		17;
	IFNOT		lOverwrite,	13;
	STORE_F	null_entity,	parm0_x;
	STORE_F	chain,	parm1_x;
	STORE_F	lOverwrite,	parm2_x;
	CALL3		findentity;
	STORE_ENT	return_x,	lOPrevious;
	ADDRESS	lOPrevious,	chain,	temp_0;
	INDIRECT_E	lOverwrite,	chain,	temp_1;
	STOREP_ENT	temp_1,	temp_0;
	ADDRESS	lOverwrite,	chain,	temp_0;
	STOREP_ENT	lChild,	temp_0;
	STORE_ENT	lOverwrite,	lChild;
	GOTO		4;
	ADDRESS	lChild,	orderPos,	temp_0;
	SUB_F		KEY_GAME,	lOrder,	temp_1;
	STOREP_F	temp_1,	temp_0;
	IFNOT		lPrevious,	4;
	ADDRESS	lPrevious,	_next,	temp_0;
	STOREP_ENT	lChild,	temp_0;
	GOTO		3;
	ADDRESS	pParent,	_child,	temp_0;
	STOREP_ENT	lChild,	temp_0;
	ADDRESS	lChild,	_prev,	temp_0;
	STOREP_ENT	lPrevious,	temp_0;
	ADDRESS	lChild,	_parent,	temp_0;
	STOREP_ENT	pParent,	temp_0;
	STORE_ENT	lChild,	lPrevious;
	INDIRECT_E	lChild,	chain,	lChild;
	STORE_F	lOrder,	temp_0;
	ADD_F		lOrder,	FILE_APPEND,	lOrder;
	GOTO		-44;
	ADDRESS	lPrevious,	_next,	temp_0;
	STOREP_ENT	null_entity,	temp_0;
	DONE;
}

void() Menu_LinkWindows = asm
{
local entity lEntity;
local float temp_0;
local float temp_1;
	STORE_F	"Loading defaults if necessary
",	parm0_x;
	CALL1		dprint;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	MENU_NORMAL_NAME,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lEntity;
	EQ_E		lEntity,	null_entity,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	MENU_NORMAL_DEFAULT,	parm0_x;
	CALL1		loadfromdata;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	MENU_NORMAL_NAME,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lEntity;
	EQ_E		lEntity,	null_entity,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	"Bad MENU_NORMAL_DEFAULT!
",	parm0_x;
	CALL1		error;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	MENU_INGAME_NAME,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lEntity;
	EQ_E		lEntity,	null_entity,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	MENU_INGAME_DEFAULT,	parm0_x;
	CALL1		loadfromdata;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	MENU_INGAME_NAME,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lEntity;
	EQ_E		lEntity,	null_entity,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	"Bad MENU_INGAME_DEFAULT!
",	parm0_x;
	CALL1		error;
	STORE_F	"Verifying that every name is used only once
",	parm0_x;
	CALL1		dprint;
	STORE_ENT	null_entity,	lEntity;
	STORE_F	lEntity,	parm0_x;
	CALL1		nextent;
	STORE_ENT	return_x,	lEntity;
	NE_E		return_x,	null_entity,	temp_0;
	IFNOT		temp_0,	19;
	STORE_ENT	lEntity,	self;
	INDIRECT_S	lEntity,	name,	temp_0;
	STORE_F	self,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	self;
	NE_E		return_x,	null_entity,	temp_0;
	IFNOT		temp_0,	9;
	NE_E		self,	null_entity,	temp_0;
	IFNOT		temp_0,	6;
	INDIRECT_S	lEntity,	name,	temp_0;
	STORE_F	"Name ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	" already used!
",	parm2_x;
	CALL3		objerror;
	GOTO		-15;
	GOTO		-22;
	STORE_F	"Verification of: name, type and parent fields
",	parm0_x;
	CALL1		dprint;
	STORE_ENT	null_entity,	self;
	STORE_F	self,	parm0_x;
	CALL1		nextent;
	STORE_ENT	return_x,	self;
	NE_E		return_x,	null_entity,	temp_0;
	IFNOT		temp_0,	46;
	INDIRECT_S	self,	name,	temp_0;
	EQ_S		temp_0,	"",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	"Name is missing!
",	parm0_x;
	CALL1		objerror;
	GOTO		-10;
	INDIRECT_S	self,	type,	temp_0;
	EQ_S		temp_0,	"",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	"Type is missing!
",	parm0_x;
	CALL1		objerror;
	GOTO		-16;
	INDIRECT_S	self,	type,	parm0_x;
	STORE_F	"_Spawn",	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		isfunction;
	IF		return_x,	7;
	INDIRECT_S	self,	type,	temp_0;
	STORE_F	"Control ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	" not found!
",	parm2_x;
	CALL3		objerror;
	GOTO		-28;
	INDIRECT_S	self,	parent,	temp_0;
	NE_S		temp_0,	"",	temp_0;
	IFNOT		temp_0,	16;
	INDIRECT_S	self,	parent,	temp_0;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lEntity;
	EQ_E		lEntity,	null_entity,	temp_0;
	IFNOT		temp_0,	7;
	INDIRECT_S	self,	parent,	temp_0;
	STORE_F	"Item ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	" not found!
",	parm2_x;
	CALL3		objerror;
	GOTO		-45;
	GOTO		3;
	ADDRESS	self,	_parent,	temp_0;
	STOREP_ENT	null_entity,	temp_0;
	GOTO		-49;
	STORE_F	"Building the child lists
",	parm0_x;
	CALL1		dprint;
	STORE_ENT	null_entity,	lEntity;
	STORE_F	lEntity,	parm0_x;
	CALL1		nextent;
	STORE_ENT	return_x,	lEntity;
	NE_E		return_x,	null_entity,	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	lEntity,	parm0_x;
	CALL1		Menu_LinkChildren;
	GOTO		-7;
	STORE_F	"Calling the type functions
",	parm0_x;
	CALL1		dprint;
	STORE_ENT	null_entity,	lEntity;
	STORE_F	lEntity,	parm0_x;
	CALL1		nextent;
	STORE_ENT	return_x,	lEntity;
	NE_E		return_x,	null_entity,	temp_0;
	IFNOT		temp_0,	21;
	STORE_ENT	lEntity,	self;
	INDIRECT_F	self,	flag,	temp_0;
	BITAND	temp_0,	FLAG_TEMPLATE,	temp_0;
	NOT_F		temp_0,	temp_0;
	IFNOT		temp_0,	4;
	INDIRECT_F	self,	_runFlag,	temp_1;
	BITAND	temp_1,	RUNFLAG_SPAWNED,	temp_1;
	NOT_F		temp_1,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	10;
	INDIRECT_S	self,	type,	parm0_x;
	STORE_F	"_Spawn",	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		callfunction;
	ADDRESS	self,	_runFlag,	temp_0;
	INDIRECT_F	self,	_runFlag,	temp_1;
	BITOR		temp_1,	RUNFLAG_SPAWNED,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		-24;
	STORE_F	"Linking windows finished.
",	parm0_x;
	CALL1		dprint;
	DONE;
}

void(entity pItem) Menu_LinkItem = asm
{
local float locked_1586;
local entity lOldSelf;
local entity lEntity;
local float temp_1;
local float temp_5;
	INDIRECT_F	pItem,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_SPAWNED,	locked_1586;
	IFNOT		locked_1586,	2;
	RETURN	offset_0;
	INDIRECT_S	pItem,	type,	locked_1586;
	EQ_S		locked_1586,	"",	locked_1586;
	IFNOT		locked_1586,	7;
	STORE_F	pItem,	parm0_x;
	CALL1		etos;
	STORE_F	"LinkItem: Type is missing (",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	")!
",	parm2_x;
	CALL3		error;
	INDIRECT_S	pItem,	type,	parm0_x;
	STORE_F	"_Spawn",	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		isfunction;
	IF		return_x,	10;
	INDIRECT_S	pItem,	type,	locked_1586;
	STORE_F	pItem,	parm0_x;
	CALL1		etos;
	STORE_F	"LinkItem: Control ",	parm0_x;
	STORE_F	locked_1586,	parm1_x;
	STORE_F	" not found (",	parm2_x;
	STORE_F	return_x,	parm3_x;
	STORE_F	")!
",	parm4_x;
	CALL5		error;
	STORE_ENT	null_entity,	lEntity;
	INDIRECT_S	pItem,	name,	locked_1586;
	STORE_F	lEntity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	locked_1586,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lEntity;
	NE_E		return_x,	null_entity,	locked_1586;
	IFNOT		locked_1586,	20;
	NE_E		lEntity,	pItem,	locked_1586;
	IFNOT		locked_1586,	17;
	INDIRECT_S	pItem,	name,	locked_1586;
	STORE_F	pItem,	parm0_x;
	CALL1		etos;
	STORE_F	lEntity,	parm0_x;
	STORE_F	return_x,	temp_1;
	CALL1		etos;
	STORE_F	return_x,	temp_5;
	STORE_F	temp_1,	return_x;
	STORE_F	"LinkItem: Name '",	parm0_x;
	STORE_F	locked_1586,	parm1_x;
	STORE_F	"' already in use (",	parm2_x;
	STORE_F	return_x,	parm3_x;
	STORE_F	", ",	parm4_x;
	STORE_F	temp_5,	parm5_x;
	STORE_F	")!",	parm6_x;
	CALL7		error;
	GOTO		-26;
	INDIRECT_S	pItem,	parent,	locked_1586;
	NE_S		locked_1586,	"",	locked_1586;
	IFNOT		locked_1586,	20;
	ADDRESS	pItem,	_parent,	locked_1586;
	INDIRECT_S	pItem,	parent,	temp_1;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	temp_1,	parm2_x;
	CALL3		findstring;
	STOREP_ENT	return_x,	locked_1586;
	INDIRECT_E	pItem,	_parent,	locked_1586;
	IF		locked_1586,	10;
	INDIRECT_S	pItem,	parent,	locked_1586;
	STORE_F	pItem,	parm0_x;
	CALL1		etos;
	STORE_F	"LinkItem: Couldnt find parent '",	parm0_x;
	STORE_F	locked_1586,	parm1_x;
	STORE_F	"' (",	parm2_x;
	STORE_F	return_x,	parm3_x;
	STORE_F	")!",	parm4_x;
	CALL5		error;
	GOTO		3;
	ADDRESS	pItem,	_parent,	locked_1586;
	STOREP_ENT	null_entity,	locked_1586;
	STORE_F	pItem,	parm0_x;
	CALL1		Menu_LinkChildren;
	INDIRECT_E	pItem,	_child,	lEntity;
	IFNOT		lEntity,	5;
	STORE_F	lEntity,	parm0_x;
	CALL1		Menu_LinkItem;
	INDIRECT_E	lEntity,	_next,	lEntity;
	GOTO		-4;
	STORE_ENT	self,	lOldSelf;
	STORE_ENT	pItem,	self;
	INDIRECT_F	self,	flag,	locked_1586;
	BITAND	locked_1586,	FLAG_TEMPLATE,	locked_1586;
	IF		locked_1586,	10;
	INDIRECT_S	self,	type,	parm0_x;
	STORE_F	"_Spawn",	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		callfunction;
	ADDRESS	self,	_runFlag,	locked_1586;
	INDIRECT_F	self,	_runFlag,	temp_1;
	BITOR		temp_1,	RUNFLAG_SPAWNED,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	STORE_ENT	lOldSelf,	self;
	DONE;
}

void() Menu_Hide = asm
{
	STORE_F	Menu_ActiveItem,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		Raise_Select;
	STORE_F	FILE_APPEND,	parm0_x;
	CALL1		Menu_CollectGarbage;
	CALL0		Menu_ResetGarbageStats;
	DONE;
}

void() Menu_PerformReinit = asm
{
local float temp_0;
local float temp_1;
local float temp_5;
	CALL0		Menu_History_Clear;
	STORE_FNC	Util_NullFunction,	Menu_KeyHook;
	STORE_ENT	null_entity,	self;
	STORE_F	self,	parm0_x;
	CALL1		nextent;
	STORE_ENT	return_x,	self;
	NE_E		return_x,	null_entity,	temp_0;
	IFNOT		temp_0,	27;
	INDIRECT_S	self,	parent,	temp_0;
	EQ_S		temp_0,	"",	temp_0;
	IFNOT		temp_0,	4;
	ADDRESS	self,	_parent,	temp_0;
	STOREP_ENT	null_entity,	temp_0;
	GOTO		18;
	INDIRECT_E	self,	_parent,	temp_0;
	INDIRECT_S	temp_0,	name,	temp_0;
	INDIRECT_S	self,	parent,	temp_1;
	NE_S		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	13;
	INDIRECT_S	self,	parent,	temp_0;
	INDIRECT_S	self,	name,	temp_1;
	INDIRECT_E	self,	_parent,	temp_5;
	INDIRECT_S	temp_5,	name,	temp_5;
	STORE_F	"Parent (should be ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	") of menu item ",	parm2_x;
	STORE_F	temp_1,	parm3_x;
	STORE_F	" changed to ",	parm4_x;
	STORE_F	temp_5,	parm5_x;
	STORE_F	" !
",	parm6_x;
	CALL7		objerror;
	STORE_F	self,	parm0_x;
	CALL1		Raise_Reinit;
	GOTO		-30;
	IFNOT		MENU_ALLOWINGAME,	2;
	BITAND	gamestatus,	KEY_MENU,	temp_0;
	AND		MENU_ALLOWINGAME,	temp_0,	temp_0;
	IFNOT		temp_0,	7;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	MENU_INGAME_NAME,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	Menu_ActiveWindow;
	GOTO		6;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	MENU_NORMAL_NAME,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	Menu_ActiveWindow;
	CALL0		Menu_UpdateRunFlags;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		Menu_Reselect;
	DONE;
}

void() Menu_Shutdown = asm
{
local float temp_0;
	STORE_ENT	null_entity,	self;
	STORE_F	self,	parm0_x;
	CALL1		nextent;
	STORE_ENT	return_x,	self;
	NE_E		return_x,	null_entity,	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	self,	parm0_x;
	CALL1		Raise_Destroy;
	GOTO		-7;
	DONE;
}

entity(string pType, string pName, string pParent) Menu_CreateItem = asm
{
local entity lItem;
local float temp_0;
	NOT_S		pType,	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	"Bad pType '",	parm0_x;
	STORE_F	pType,	parm1_x;
	STORE_F	"'!",	parm2_x;
	CALL3		error;
	NOT_S		pName,	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	"Bad pName '",	parm0_x;
	STORE_F	pName,	parm1_x;
	STORE_F	"'!",	parm2_x;
	CALL3		error;
	CALL0		spawn;
	STORE_ENT	return_x,	lItem;
	STORE_F	pParent,	parm0_x;
	STORE_F	"::",	parm1_x;
	STORE_F	pName,	parm2_x;
	CALL3		strcat;
	STORE_F	"{ type "",	parm0_x;
	STORE_F	pType,	parm1_x;
	STORE_F	"" name "",	parm2_x;
	STORE_F	return_x,	parm3_x;
	STORE_F	"" parent "",	parm4_x;
	STORE_F	pParent,	parm5_x;
	STORE_F	"" }",	parm6_x;
	CALL7		strcat;
	STORE_F	lItem,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		parseentitydata;
	RETURN	lItem;
	DONE;
}

entity(entity pTemplate, string pName, string pParent, bool pTree) Menu_DeriveItem = asm
{
local float locked_1586;
local string lName;
local entity lChild;
local entity lItem;
local float temp_1;
	IF		pTemplate,	3;
	STORE_F	"Null pTemplate!",	parm0_x;
	CALL1		error;
	NOT_S		pName,	locked_1586;
	IFNOT		locked_1586,	5;
	STORE_F	"Bad pName '",	parm0_x;
	STORE_F	pName,	parm1_x;
	STORE_F	"'!",	parm2_x;
	CALL3		error;
	CALL0		spawn;
	STORE_ENT	return_x,	lItem;
	STORE_F	pTemplate,	parm0_x;
	STORE_F	lItem,	parm1_x;
	CALL2		copyentity;
	INDIRECT_F	lItem,	flag,	locked_1586;
	BITAND	locked_1586,	FLAG_TEMPLATE,	locked_1586;
	IFNOT		locked_1586,	5;
	ADDRESS	lItem,	flag,	locked_1586;
	INDIRECT_F	lItem,	flag,	temp_1;
	SUB_F		temp_1,	FLAG_TEMPLATE,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	INDIRECT_F	lItem,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_SPAWNED,	locked_1586;
	IFNOT		locked_1586,	5;
	ADDRESS	lItem,	_runFlag,	locked_1586;
	INDIRECT_F	lItem,	_runFlag,	temp_1;
	SUB_F		temp_1,	RUNFLAG_SPAWNED,	temp_1;
	STOREP_F	temp_1,	locked_1586;
	STORE_F	pParent,	parm0_x;
	STORE_F	"::",	parm1_x;
	STORE_F	pName,	parm2_x;
	CALL3		strcat;
	STORE_F	"{ name "",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"" parent "",	parm2_x;
	STORE_F	pParent,	parm3_x;
	STORE_F	"" }",	parm4_x;
	CALL5		strcat;
	STORE_F	lItem,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		parseentitydata;
	IFNOT		pTree,	24;
	INDIRECT_E	pTemplate,	_child,	lChild;
	IFNOT		lChild,	22;
	INDIRECT_S	lChild,	name,	locked_1586;
	INDIRECT_S	lChild,	parent,	parm0_x;
	CALL1		strlen;
	ADD_F		return_x,	KEY_MENU,	temp_1;
	STORE_F	locked_1586,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	STORE_F	100000.000000,	parm2_x;
	CALL3		substring;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lName;
	INDIRECT_S	lItem,	name,	locked_1586;
	STORE_F	lChild,	parm0_x;
	STORE_F	lName,	parm1_x;
	STORE_F	locked_1586,	parm2_x;
	STORE_F	FILE_APPEND,	parm3_x;
	CALL4		Menu_DeriveItem;
	STORE_F	lName,	parm0_x;
	CALL1		String_Free;
	INDIRECT_E	lChild,	_next,	lChild;
	GOTO		-21;
	RETURN	lItem;
	DONE;
}

void(entity pItem, string pData) Menu_AddEntityData = asm
{
	STORE_F	pItem,	parm0_x;
	STORE_F	pData,	parm1_x;
	CALL2		parseentitydata;
	DONE;
}

void(entity pWindow) Menu_LinkWindow = asm
{
	STORE_F	pWindow,	parm0_x;
	CALL1		Menu_LinkItem;
	DONE;
}

void() Sys_Debug_Init = asm
{
	STORE_F	SYSTEM_CVAR_VERSION_BUILDDATE,	parm0_x;
	STORE_F	"",	parm1_x;
	STORE_F	CVAR_READONLY,	parm2_x;
	CALL3		registercvar;
	STORE_F	SYSTEM_CVAR_VERSION_BUILDDATE,	parm0_x;
	STORE_F	SYSTEM_CVAR_VERSION_BUILDDATE_VALUE,	parm1_x;
	CALL2		cvar_set;
	STORE_F	SYSTEM_CVAR_VERSION_BUILDTIME,	parm0_x;
	STORE_F	"",	parm1_x;
	STORE_F	CVAR_READONLY,	parm2_x;
	CALL3		registercvar;
	STORE_F	SYSTEM_CVAR_VERSION_BUILDTIME,	parm0_x;
	STORE_F	SYSTEM_CVAR_VERSION_BUILDTIME_VALUE,	parm1_x;
	CALL2		cvar_set;
	STORE_F	SYSTEM_CVAR_VERSION,	parm0_x;
	STORE_F	"",	parm1_x;
	STORE_F	CVAR_READONLY,	parm2_x;
	CALL3		registercvar;
	STORE_F	SYSTEM_CVAR_VERSION,	parm0_x;
	STORE_F	SYSTEM_CVAR_VERSION_VALUE,	parm1_x;
	CALL2		cvar_set;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		ftos;
	STORE_F	SYSTEM_CVAR_DEBUG,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		ftos;
	STORE_F	SYSTEM_CVAR_DEBUG_REF,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		ftos;
	STORE_F	SYSTEM_CVAR_DEBUG_RUNFLAG,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		ftos;
	STORE_F	SYSTEM_CVAR_DEBUG_PROCESS,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		ftos;
	STORE_F	SYSTEM_CVAR_DEBUG_MGFX,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		ftos;
	STORE_F	SYSTEM_CVAR_DEBUG_STRUCTURE,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	SYSTEM_CVAR_DEBUG_PARSER,	parm0_x;
	STORE_F	SYSTEM_CVAR_DEBUG_PARSER_DEFAULT,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	SYSTEM_CVAR_DEBUG_PROCESS_FILTER,	parm0_x;
	STORE_F	SYSTEM_CVAR_DEBUG_PROCESS_FILTER_DEFAULT,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		ftos;
	STORE_F	SYSTEM_CVAR_DEBUG_SOUND,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	SYSTEM_CVAR_DEBUG_DUMP_NAMES,	parm0_x;
	STORE_F	"0",	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		ftos;
	STORE_F	SYSTEM_CVAR_DEBUG_AREA,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		ftos;
	STORE_F	SYSTEM_CVAR_DEBUG_STEP,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		ftos;
	STORE_F	SYSTEM_CVAR_DEBUG_MOUSE,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	DONE;
}

void() Sys_Debug_Frame = asm
{
local float lStep;
local float lTemp2;
local float lTemp1;
local float temp_0;
	STORE_F	SYSTEM_CVAR_DEBUG,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	sys_debug;
	IFNOT		sys_debug,	155;
	STORE_F	SYSTEM_CVAR_DEBUG_REF,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	sys_debug_ref;
	STORE_F	SYSTEM_CVAR_DEBUG_AREA,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	sys_debug_area;
	STORE_F	SYSTEM_CVAR_DEBUG_SOUND,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	sys_debug_sound;
	STORE_F	SYSTEM_CVAR_DEBUG_STRUCTURE,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	sys_debug_structure;
	STORE_F	SYSTEM_CVAR_DEBUG_MOUSE,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	sys_debug_mouse;
	STORE_F	SYSTEM_CVAR_DEBUG_STEP,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	lStep;
	EQ_F		lStep,	FILE_APPEND,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	FILE_APPEND,	sys_debug_halt;
	GOTO		16;
	EQ_F		lStep,	KEY_MENU,	temp_0;
	IFNOT		temp_0,	13;
	STORE_F	KEY_GAME,	sys_debug_halt;
	STORE_F	SYSTEM_CVAR_DEBUG_STEP,	parm0_x;
	STORE_F	"1",	parm1_x;
	CALL2		cvar_set;
	CALL0		gettime;
	STORE_F	return_x,	parm0_x;
	CALL1		ftos;
	STORE_F	"Menu: -- Step: Time:",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		print;
	GOTO		2;
	STORE_F	KEY_GAME,	sys_debug_halt;
	STORE_F	SYSTEM_CVAR_DEBUG_RUNFLAG,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	sys_debug_runflag;
	GOTO		8;
	STORE_F	KEY_GAME,	sys_debug_runflag;
	GOTO		11;
	STORE_F	SYSTEM_CVAR_DEBUG_RUNFLAG,	parm0_x;
	STORE_F	"0",	parm1_x;
	CALL2		cvar_set;
	STORE_F	FILE_APPEND,	sys_debug_runflag;
	GOTO		6;
	IFNOT		sys_debug_runflag,	-7;
	EQ_F		sys_debug_runflag,	FILE_APPEND,	temp_0;
	IF		temp_0,	-7;
	EQ_F		sys_debug_runflag,	KEY_MENU,	temp_0;
	IF		temp_0,	-6;
	STORE_F	SYSTEM_CVAR_DEBUG_PROCESS,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	sys_debug_process;
	GOTO		8;
	STORE_F	KEY_GAME,	sys_debug_process;
	GOTO		11;
	STORE_F	SYSTEM_CVAR_DEBUG_PROCESS,	parm0_x;
	STORE_F	"0",	parm1_x;
	CALL2		cvar_set;
	STORE_F	FILE_APPEND,	sys_debug_process;
	GOTO		6;
	IFNOT		sys_debug_process,	-7;
	EQ_F		sys_debug_process,	FILE_APPEND,	temp_0;
	IF		temp_0,	-7;
	EQ_F		sys_debug_process,	KEY_MENU,	temp_0;
	IF		temp_0,	-6;
	STORE_F	SYSTEM_CVAR_DEBUG_MGFX,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	sys_debug_mgfx;
	GOTO		8;
	STORE_F	KEY_GAME,	sys_debug_mgfx;
	GOTO		11;
	STORE_F	SYSTEM_CVAR_DEBUG_MGFX,	parm0_x;
	STORE_F	"0",	parm1_x;
	CALL2		cvar_set;
	STORE_F	FILE_APPEND,	sys_debug_mgfx;
	GOTO		6;
	IFNOT		sys_debug_mgfx,	-7;
	EQ_F		sys_debug_mgfx,	FILE_APPEND,	temp_0;
	IF		temp_0,	-7;
	EQ_F		sys_debug_mgfx,	KEY_MENU,	temp_0;
	IF		temp_0,	-6;
	STORE_F	SYSTEM_CVAR_DEBUG_PROCESS_FILTER,	parm0_x;
	CALL1		str_cvar;
	STORE_F	return_x,	parm0_x;
	CALL1		tokenize;
	STORE_F	return_x,	lTemp1;
	STORE_F	KEY_GAME,	sys_debug_process_filter;
	STORE_F	KEY_GAME,	lTemp2;
	LT		lTemp2,	lTemp1,	temp_0;
	IFNOT		temp_0,	32;
	STORE_F	lTemp2,	parm0_x;
	CALL1		argv;
	EQ_S		return_x,	"runflag",	temp_0;
	IFNOT		temp_0,	3;
	BITOR		sys_debug_process_filter,	MENU_PROCESS_RUNFLAG,	sys_debug_process_filter;
	GOTO		24;
	STORE_F	lTemp2,	parm0_x;
	CALL1		argv;
	EQ_S		return_x,	"draw",	temp_0;
	IFNOT		temp_0,	3;
	BITOR		sys_debug_process_filter,	MENU_PROCESS_DRAW,	sys_debug_process_filter;
	GOTO		18;
	STORE_F	lTemp2,	parm0_x;
	CALL1		argv;
	EQ_S		return_x,	"update",	temp_0;
	IFNOT		temp_0,	3;
	BITOR		sys_debug_process_filter,	MENU_PROCESS_UPDATE,	sys_debug_process_filter;
	GOTO		12;
	STORE_F	lTemp2,	parm0_x;
	CALL1		argv;
	EQ_S		return_x,	"mouse",	temp_0;
	IFNOT		temp_0,	3;
	BITOR		sys_debug_process_filter,	MENU_PROCESS_MOUSE,	sys_debug_process_filter;
	GOTO		6;
	STORE_F	lTemp2,	parm0_x;
	CALL1		argv;
	EQ_S		return_x,	"key",	temp_0;
	IFNOT		temp_0,	2;
	BITOR		sys_debug_process_filter,	MENU_PROCESS_KEY,	sys_debug_process_filter;
	ADD_F		lTemp2,	FILE_APPEND,	lTemp2;
	GOTO		-32;
	STORE_F	SYSTEM_CVAR_DEBUG_PARSER,	parm0_x;
	CALL1		str_cvar;
	STORE_F	return_x,	parm0_x;
	CALL1		tokenize;
	STORE_F	return_x,	lTemp1;
	STORE_F	KEY_GAME,	sys_debug_parser;
	STORE_F	KEY_GAME,	lTemp2;
	LT		lTemp2,	lTemp1,	temp_0;
	IFNOT		temp_0,	20;
	STORE_F	lTemp2,	parm0_x;
	CALL1		argv;
	EQ_S		return_x,	"info",	temp_0;
	IFNOT		temp_0,	3;
	BITOR		sys_debug_parser,	PARSER_INFO,	sys_debug_parser;
	GOTO		12;
	STORE_F	lTemp2,	parm0_x;
	CALL1		argv;
	EQ_S		return_x,	"high",	temp_0;
	IFNOT		temp_0,	3;
	BITOR		sys_debug_parser,	PARSER_HIGH,	sys_debug_parser;
	GOTO		6;
	STORE_F	lTemp2,	parm0_x;
	CALL1		argv;
	EQ_S		return_x,	"low",	temp_0;
	IFNOT		temp_0,	2;
	BITOR		sys_debug_parser,	PARSER_LOW,	sys_debug_parser;
	ADD_F		lTemp2,	FILE_APPEND,	lTemp2;
	GOTO		-20;
	GOTO		12;
	STORE_F	KEY_GAME,	sys_debug_halt;
	STORE_F	KEY_GAME,	sys_debug_ref;
	STORE_F	KEY_GAME,	sys_debug_area;
	STORE_F	KEY_GAME,	sys_debug_sound;
	STORE_F	KEY_GAME,	sys_debug_runflag;
	STORE_F	KEY_GAME,	sys_debug_process;
	STORE_F	KEY_GAME,	sys_debug_mgfx;
	STORE_F	KEY_GAME,	sys_debug_structure;
	STORE_F	KEY_GAME,	sys_debug_parser;
	STORE_F	KEY_GAME,	sys_debug_process_filter;
	STORE_F	KEY_GAME,	sys_debug_mouse;
	STORE_F	SYSTEM_CVAR_DEBUG_DUMP_NAMES,	parm0_x;
	CALL1		cvar;
	IFNOT		return_x,	5;
	CALL0		Sys_Debug_DumpNames;
	STORE_F	SYSTEM_CVAR_DEBUG_DUMP_NAMES,	parm0_x;
	STORE_F	"0",	parm1_x;
	CALL2		cvar_set;
	STORE_V	'-1.000000 -1.000000 -1.000000',	sys_debug_cursor_localpos;
	DONE;
}

void() Sys_Debug_Draw = asm
{
local float temp_0;
local float temp_1;
	EQ_F		sys_debug_mouse,	FILE_APPEND,	temp_0;
	IFNOT		temp_0,	27;
	STORE_F	sys_debug_cursor_localpos_x,	parm0_x;
	CALL1		floor;
	STORE_F	return_x,	parm0_x;
	CALL1		ftos;
	STORE_F	sys_debug_cursor_localpos_y,	parm0_x;
	STORE_F	return_x,	temp_0;
	CALL1		floor;
	STORE_F	return_x,	temp_1;
	STORE_F	temp_0,	return_x;
	STORE_F	temp_1,	parm0_x;
	STORE_F	return_x,	temp_0;
	CALL1		ftos;
	STORE_F	return_x,	temp_1;
	STORE_F	temp_0,	return_x;
	STORE_F	return_x,	parm0_x;
	STORE_F	" ",	parm1_x;
	STORE_F	temp_1,	parm2_x;
	CALL3		strcat;
	STORE_V	'1.000000 0.000000 0.000000',	parm0;
	STORE_F	return_x,	parm1_x;
	STORE_V	'9.000000 9.000000 0.000000',	parm2;
	STORE_V	'0.800000 0.800000 0.800000',	parm3;
	STORE_F	FILE_APPEND,	parm4_x;
	STORE_F	FILE_APPEND,	parm5_x;
	CALL6		Cursor_PrintInfo;
	GOTO		28;
	EQ_F		sys_debug_mouse,	KEY_MENU,	temp_0;
	IFNOT		temp_0,	26;
	STORE_F	Cursor_Position_x,	parm0_x;
	CALL1		floor;
	STORE_F	return_x,	parm0_x;
	CALL1		ftos;
	STORE_F	Cursor_Position_y,	parm0_x;
	STORE_F	return_x,	temp_0;
	CALL1		floor;
	STORE_F	return_x,	temp_1;
	STORE_F	temp_0,	return_x;
	STORE_F	temp_1,	parm0_x;
	STORE_F	return_x,	temp_0;
	CALL1		ftos;
	STORE_F	return_x,	temp_1;
	STORE_F	temp_0,	return_x;
	STORE_F	return_x,	parm0_x;
	STORE_F	" ",	parm1_x;
	STORE_F	temp_1,	parm2_x;
	CALL3		strcat;
	STORE_V	'1.000000 0.000000 0.000000',	parm0;
	STORE_F	return_x,	parm1_x;
	STORE_V	'9.000000 9.000000 0.000000',	parm2;
	STORE_V	'0.800000 0.800000 0.800000',	parm3;
	STORE_F	FILE_APPEND,	parm4_x;
	STORE_F	FILE_APPEND,	parm5_x;
	CALL6		Cursor_PrintInfo;
	DONE;
}

void() Sys_Debug_DumpNames = asm
{
local entity lNode;
local float temp_0;
	STORE_F	"Menu: Dumping names..
",	parm0_x;
	CALL1		print;
	STORE_ENT	null_entity,	lNode;
	STORE_F	lNode,	parm0_x;
	CALL1		nextent;
	STORE_ENT	return_x,	lNode;
	NE_E		return_x,	null_entity,	temp_0;
	IFNOT		temp_0,	11;
	STORE_F	lNode,	parm0_x;
	CALL1		etos;
	INDIRECT_S	lNode,	name,	temp_0;
	STORE_F	"Menu: ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	" <-> ",	parm2_x;
	STORE_F	temp_0,	parm3_x;
	STORE_F	"
",	parm4_x;
	CALL5		print;
	GOTO		-14;
	STORE_F	"
",	parm0_x;
	CALL1		print;
	DONE;
}

void () Parser_Define_Spawn;
void() Parser_Define_Spawn = asm
{
	DONE;
}

void () Parser_TokenizeLine;
void() Parser_TokenizeLine = asm
{
	STORE_F	Parser_Line,	parm0_x;
	CALL1		tokenize;
	STORE_F	return_x,	Parser_NumTokens;
	STORE_F	KEY_GAME,	Parser_TokenNum;
	DONE;
}

float() Parser_GetToken = asm
{
local string lLine;
local float temp_0;
	GE		Parser_TokenNum,	Parser_NumTokens,	temp_0;
	IFNOT		temp_0,	22;
	STORE_F	Parser_File,	parm0_x;
	CALL1		fgets;
	STORE_S	return_x,	lLine;
	ADD_F		Parser_LineNumber,	FILE_APPEND,	Parser_LineNumber;
	NOT_S		lLine,	temp_0;
	IFNOT		temp_0,	8;
	STORE_F	lLine,	parm0_x;
	CALL1		validstring;
	IF		return_x,	3;
	RETURN	KEY_GAME;
	GOTO		3;
	CALL0		Parser_GetToken;
	RETURN	return_x;
	STORE_F	Parser_Line,	parm0_x;
	STORE_F	lLine,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	Parser_Line;
	CALL0		Parser_TokenizeLine;
	CALL0		Parser_GetToken;
	RETURN	return_x;
	GOTO		9;
	STORE_F	Parser_TokenNum,	parm0_x;
	CALL1		argv;
	STORE_F	Parser_Token,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	Parser_Token;
	STORE_F	Parser_TokenNum,	temp_0;
	ADD_F		Parser_TokenNum,	FILE_APPEND,	Parser_TokenNum;
	STORE_F	"Read token '",	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	STORE_F	"'",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_LOW,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	CALL0		Parser_GetTokenType;
	STORE_F	return_x,	Parser_TokenType;
	EQ_F		Parser_TokenType,	PARSER_TT_BRACKETOPEN,	temp_0;
	IFNOT		temp_0,	4;
	CALL0		Parser_ProcessDefine;
	CALL0		Parser_GetToken;
	RETURN	return_x;
	RETURN	FILE_APPEND;
	DONE;
}

float() Parser_GetTokenType = asm
{
local float temp_0;
	EQ_S		Parser_Token,	"Item",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_ITEM;
	GOTO		48;
	EQ_S		Parser_Token,	"Template",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_TEMPLATE;
	GOTO		44;
	EQ_S		Parser_Token,	"Derive",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_DERIVE;
	GOTO		40;
	EQ_S		Parser_Token,	"DeriveTemplate",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_DERIVETEMPLATE;
	GOTO		36;
	EQ_S		Parser_Token,	"#define",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_DEFINE;
	GOTO		32;
	EQ_S		Parser_Token,	"Ignore",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_IGNORE;
	GOTO		28;
	EQ_S		Parser_Token,	"#undef",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_UNDEF;
	GOTO		24;
	EQ_S		Parser_Token,	"Namespace",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_NAMESPACE;
	GOTO		20;
	EQ_S		Parser_Token,	"#include",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_INCLUDE;
	GOTO		16;
	EQ_S		Parser_Token,	"}",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_BRACECLOSE;
	GOTO		12;
	EQ_S		Parser_Token,	"{",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_BRACEOPEN;
	GOTO		8;
	EQ_S		Parser_Token,	"[",	temp_0;
	IFNOT		temp_0,	3;
	RETURN	PARSER_TT_BRACKETOPEN;
	GOTO		4;
	EQ_S		Parser_Token,	"]",	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_BRACKETCLOSE;
	RETURN	PARSER_TT_TOKEN;
	DONE;
}

void (float, string) _Parser_Print;
void(float pLevel, string pText) _Parser_Print = asm
{
local float temp_0;
local float temp_1;
	EQ_F		pLevel,	KEY_GAME,	temp_0;
	IF		temp_0,	2;
	BITAND	sys_debug_parser,	pLevel,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	"Parser: ",	parm0_x;
	STORE_F	pText,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		print;
	DONE;
}

void(float pLevel, string pInfo) Parser_Print = asm
{
local float temp_0;
local float temp_1;
	EQ_F		pLevel,	KEY_GAME,	temp_0;
	IF		temp_0,	2;
	BITAND	sys_debug_parser,	pLevel,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	11;
	STORE_F	Parser_LineNumber,	parm0_x;
	CALL1		ftos;
	STORE_F	"Parser: ",	parm0_x;
	STORE_F	Parser_Filename,	parm1_x;
	STORE_F	":",	parm2_x;
	STORE_F	return_x,	parm3_x;
	STORE_F	": ",	parm4_x;
	STORE_F	pInfo,	parm5_x;
	STORE_F	"
",	parm6_x;
	CALL7		print;
	DONE;
}

void(string pInfo) Parser_Error = asm
{
	STORE_F	Parser_LineNumber,	parm0_x;
	CALL1		ftos;
	STORE_F	"Parser: ",	parm0_x;
	STORE_F	Parser_Filename,	parm1_x;
	STORE_F	":",	parm2_x;
	STORE_F	return_x,	parm3_x;
	STORE_F	": Error: '",	parm4_x;
	CALL5		print;
	STORE_F	Parser_Token,	parm0_x;
	STORE_F	"' not expected (",	parm1_x;
	STORE_F	pInfo,	parm2_x;
	STORE_F	")!
",	parm3_x;
	CALL4		print;
	STORE_F	Parser_File,	parm0_x;
	CALL1		fclose;
	STORE_F	"Error in the menu parser!",	parm0_x;
	CALL1		error;
	DONE;
}

void () ArrayGet*PARSER_TT_TEXT;
void(float pType) Parser_Expect = asm
{
local float temp_0;
local float temp_1;
local float temp_5;
	CALL0		Parser_GetToken;
	NOT_F		return_x,	temp_0;
	IF		temp_0,	5;
	NE_F		Parser_TokenType,	pType,	temp_1;
	IFNOT		temp_1,	2;
	NE_F		Parser_TokenType,	PARSER_TT_BRACKETOPEN,	temp_5;
	AND		temp_1,	temp_5,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	8;
	SUB_F		pType,	PARSER_TT_ITEM,	parm0_x;
	CALL1		ArrayGet*PARSER_TT_TEXT;
	STORE_F	"expected ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		Parser_Error;
	DONE;
}

void(string pNamespace) Parser_IncludeFile = asm
{
local float lTokenNum;
local float lNumTokens;
local float lLineNumber;
local float lFile;
local string lLine;
local string lFilename;
local float temp_0;
	STORE_F	PARSER_TT_TOKEN,	parm0_x;
	CALL1		Parser_Expect;
	STORE_F	"#include: Including file '",	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	STORE_F	"'",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_INFO,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	STORE_F	Parser_Token,	parm0_x;
	CALL1		Util_AltStringPrepare;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	" {'",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"'",	parm2_x;
	CALL3		strcat;
	STORE_F	Parser_FileList,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Append;
	STORE_S	return_x,	Parser_FileList;
	STORE_S	Parser_Filename,	lFilename;
	STORE_S	Parser_Line,	lLine;
	STORE_F	Parser_File,	lFile;
	STORE_F	Parser_LineNumber,	lLineNumber;
	STORE_F	Parser_NumTokens,	lNumTokens;
	STORE_F	Parser_TokenNum,	lTokenNum;
	SUB_F		Parser_IncludeDepth,	FILE_APPEND,	Parser_IncludeDepth;
	GT		Parser_IncludeDepth,	K_SPACE,	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	KEY_GAME,	parm0_x;
	STORE_F	"#include: Maximum depth reached!",	parm1_x;
	CALL2		Parser_Print;
	GOTO		4;
	STORE_F	Parser_Token,	parm0_x;
	STORE_F	pNamespace,	parm1_x;
	CALL2		Parser_ParseFile;
	SUB_F		Parser_IncludeDepth,	FILE_APPEND,	Parser_IncludeDepth;
	STORE_S	lFilename,	Parser_Filename;
	STORE_S	lLine,	Parser_Line;
	STORE_F	lFile,	Parser_File;
	STORE_F	lLineNumber,	Parser_LineNumber;
	CALL0		Parser_TokenizeLine;
	STORE_F	lNumTokens,	Parser_NumTokens;
	STORE_F	lTokenNum,	Parser_TokenNum;
	STORE_F	Parser_FileList,	parm0_x;
	STORE_F	"}",	parm1_x;
	CALL2		String_Append;
	STORE_S	return_x,	Parser_FileList;
	DONE;
}

void() Parser_ParseDefine = asm
{
local float locked_1586;
local float lOldLine;
local entity lDefine;
local float temp_1;
	STORE_F	KEY_MENU,	parm0_x;
	STORE_F	"Parsing #define...",	parm1_x;
	CALL2		Parser_Print;
	STORE_F	PARSER_TT_TOKEN,	parm0_x;
	CALL1		Parser_Expect;
	STORE_ENT	Parser_DefineChain,	lDefine;
	IFNOT		lDefine,	16;
	INDIRECT_S	lDefine,	name,	locked_1586;
	EQ_S		Parser_Token,	locked_1586,	locked_1586;
	IFNOT		locked_1586,	11;
	STORE_F	"#define: [",	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	STORE_F	"] already defined!",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_INFO,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	STORE_F	PARSER_TT_TOKEN,	parm0_x;
	CALL1		Parser_Expect;
	RETURN	offset_0;
	INDIRECT_E	lDefine,	chain,	lDefine;
	GOTO		-15;
	CALL0		spawn;
	STORE_ENT	return_x,	lDefine;
	ADDRESS	lDefine,	type,	locked_1586;
	STOREP_S	"Parser_Define",	locked_1586;
	ADDRESS	lDefine,	name,	locked_1586;
	STORE_F	Parser_Token,	parm0_x;
	CALL1		String_Zone;
	STOREP_S	return_x,	locked_1586;
	STORE_F	lDefine,	parm0_x;
	STORE_F	value,	parm1_x;
	CALL2		String_EntityZone;
	STORE_F	Parser_LineNumber,	lOldLine;
	CALL0		Parser_GetToken;
	IF		return_x,	3;
	GOTO		21;
	GOTO		19;
	NE_F		lOldLine,	Parser_LineNumber,	locked_1586;
	IFNOT		locked_1586,	4;
	SUB_F		Parser_TokenNum,	FILE_APPEND,	Parser_TokenNum;
	GOTO		16;
	GOTO		14;
	EQ_S		Parser_Token,	"\",	locked_1586;
	IFNOT		locked_1586,	3;
	ADD_F		lOldLine,	FILE_APPEND,	lOldLine;
	GOTO		10;
	INDIRECT_S	lDefine,	value,	parm0_x;
	STORE_F	""",	parm1_x;
	STORE_F	Parser_Token,	parm2_x;
	STORE_F	"" ",	parm3_x;
	CALL4		strcat;
	STORE_F	lDefine,	parm0_x;
	STORE_F	value,	parm1_x;
	STORE_F	return_x,	parm2_x;
	CALL3		String_EntitySet;
	GOTO		-22;
	INDIRECT_S	lDefine,	name,	locked_1586;
	INDIRECT_S	lDefine,	value,	temp_1;
	STORE_F	" Name = '",	parm0_x;
	STORE_F	locked_1586,	parm1_x;
	STORE_F	"' Replacement = '",	parm2_x;
	STORE_F	temp_1,	parm3_x;
	STORE_F	"'",	parm4_x;
	CALL5		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	ADDRESS	lDefine,	chain,	locked_1586;
	STOREP_ENT	Parser_DefineChain,	locked_1586;
	STORE_ENT	lDefine,	Parser_DefineChain;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	"Done parsing #define",	parm1_x;
	CALL2		Parser_Print;
	DONE;
}

void() Parser_ParseUndef = asm
{
local entity lPrevious;
local entity lEntity;
local float temp_0;
local float temp_1;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	"Parsing #undef...",	parm1_x;
	CALL2		Parser_Print;
	STORE_F	PARSER_TT_TOKEN,	parm0_x;
	CALL1		Parser_Expect;
	STORE_ENT	null_entity,	lPrevious;
	STORE_ENT	Parser_DefineChain,	lEntity;
	IFNOT		lEntity,	27;
	INDIRECT_S	lEntity,	name,	temp_0;
	EQ_S		temp_0,	Parser_Token,	temp_0;
	IFNOT		temp_0,	21;
	IFNOT		lPrevious,	5;
	ADDRESS	lPrevious,	chain,	temp_0;
	INDIRECT_E	lEntity,	chain,	temp_1;
	STOREP_ENT	temp_1,	temp_0;
	GOTO		2;
	INDIRECT_E	lEntity,	chain,	Parser_DefineChain;
	STORE_F	"#undef: Removed [",	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	STORE_F	"]",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_INFO,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	INDIRECT_S	lEntity,	name,	parm0_x;
	CALL1		String_Free;
	INDIRECT_S	lEntity,	value,	parm0_x;
	CALL1		String_Free;
	STORE_F	lEntity,	parm0_x;
	CALL1		remove;
	RETURN	offset_0;
	STORE_ENT	lEntity,	lPrevious;
	INDIRECT_E	lEntity,	chain,	lEntity;
	GOTO		-26;
	STORE_F	"#undef: [",	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	STORE_F	"] not found!",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_INFO,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	DONE;
}

void() Parser_ProcessDefine = asm
{
local entity lDefine;
local string lConstant;
local float temp_0;
local float temp_1;
	STORE_F	PARSER_TT_TOKEN,	parm0_x;
	CALL1		Parser_Expect;
	STORE_F	Parser_Token,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lConstant;
	STORE_F	PARSER_TT_BRACKETCLOSE,	parm0_x;
	CALL1		Parser_Expect;
	STORE_F	"Processing [",	parm0_x;
	STORE_F	lConstant,	parm1_x;
	STORE_F	"]...",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	STORE_ENT	Parser_DefineChain,	lDefine;
	IFNOT		lDefine,	41;
	INDIRECT_S	lDefine,	name,	temp_0;
	EQ_S		temp_0,	lConstant,	temp_0;
	IFNOT		temp_0,	36;
	INDIRECT_S	lDefine,	value,	temp_0;
	STORE_F	" ",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	CALL2		strcat;
	STORE_F	Parser_Line,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	Parser_Line;
	STORE_F	"Replacing with '",	parm0_x;
	STORE_F	Parser_Line,	parm1_x;
	STORE_F	"'",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	LT		Parser_TokenNum,	Parser_NumTokens,	temp_0;
	IFNOT		temp_0,	15;
	STORE_F	Parser_TokenNum,	parm0_x;
	CALL1		argv;
	STORE_F	Parser_Line,	parm0_x;
	STORE_F	" "",	parm1_x;
	STORE_F	return_x,	parm2_x;
	STORE_F	""",	parm3_x;
	CALL4		strcat;
	STORE_F	Parser_Line,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	Parser_Line;
	STORE_F	Parser_TokenNum,	temp_1;
	ADD_F		Parser_TokenNum,	FILE_APPEND,	Parser_TokenNum;
	GOTO		-15;
	CALL0		Parser_TokenizeLine;
	STORE_F	lConstant,	parm0_x;
	CALL1		String_Free;
	RETURN	offset_0;
	INDIRECT_E	lDefine,	chain,	lDefine;
	GOTO		-40;
	STORE_F	lConstant,	parm0_x;
	CALL1		String_Normal;
	STORE_F	Parser_Token,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	Parser_Token;
	STORE_F	"#define: Couldn't find constant '",	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	STORE_F	"'!",	parm2_x;
	CALL3		strcat;
	STORE_F	KEY_GAME,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	STORE_F	"constant not found",	parm0_x;
	CALL1		Parser_Error;
	DONE;
}

void(string pNamespace) Parser_ParseDefinition = asm
{
local entity lEntity;
local float temp_0;
local float temp_1;
	EQ_F		Parser_TokenType,	PARSER_TT_ITEM,	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	pNamespace,	parm0_x;
	CALL1		Parser_ParseItem;
	GOTO		50;
	EQ_F		Parser_TokenType,	PARSER_TT_TEMPLATE,	temp_0;
	IFNOT		temp_0,	9;
	STORE_F	pNamespace,	parm0_x;
	CALL1		Parser_ParseItem;
	STORE_ENT	return_x,	lEntity;
	ADDRESS	lEntity,	flag,	temp_0;
	INDIRECT_F	lEntity,	flag,	temp_1;
	BITOR		temp_1,	FLAG_TEMPLATE,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		40;
	EQ_F		Parser_TokenType,	PARSER_TT_DEFINE,	temp_0;
	IFNOT		temp_0,	3;
	CALL0		Parser_ParseDefine;
	GOTO		36;
	EQ_F		Parser_TokenType,	PARSER_TT_DERIVE,	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	pNamespace,	parm0_x;
	CALL1		Parser_DeriveItem;
	GOTO		31;
	EQ_F		Parser_TokenType,	PARSER_TT_DERIVETEMPLATE,	temp_0;
	IFNOT		temp_0,	9;
	STORE_F	pNamespace,	parm0_x;
	CALL1		Parser_DeriveItem;
	STORE_ENT	return_x,	lEntity;
	ADDRESS	lEntity,	flag,	temp_0;
	INDIRECT_F	lEntity,	flag,	temp_1;
	BITOR		temp_1,	FLAG_TEMPLATE,	temp_1;
	STOREP_F	temp_1,	temp_0;
	GOTO		21;
	EQ_F		Parser_TokenType,	PARSER_TT_UNDEF,	temp_0;
	IFNOT		temp_0,	3;
	CALL0		Parser_ParseUndef;
	GOTO		17;
	EQ_F		Parser_TokenType,	PARSER_TT_NAMESPACE,	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	pNamespace,	parm0_x;
	CALL1		Parser_ParseNamespace;
	GOTO		12;
	EQ_F		Parser_TokenType,	PARSER_TT_INCLUDE,	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	pNamespace,	parm0_x;
	CALL1		Parser_IncludeFile;
	GOTO		7;
	EQ_F		Parser_TokenType,	PARSER_TT_IGNORE,	temp_0;
	IFNOT		temp_0,	3;
	CALL0		Parser_ParseIgnore;
	GOTO		3;
	STORE_F	"couldn't find type in Parser_ParseDef",	parm0_x;
	CALL1		Parser_Error;
	DONE;
}

void() Parser_ParseIgnore = asm
{
local float lBraceCount;
local float temp_0;
	STORE_F	PARSER_TT_BRACEOPEN,	parm0_x;
	CALL1		Parser_Expect;
	STORE_F	FILE_APPEND,	lBraceCount;
	GT		lBraceCount,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	13;
	CALL0		Parser_GetToken;
	IF		return_x,	3;
	GOTO		10;
	GOTO		8;
	EQ_F		Parser_TokenType,	PARSER_TT_BRACEOPEN,	temp_0;
	IFNOT		temp_0,	3;
	ADD_F		lBraceCount,	FILE_APPEND,	lBraceCount;
	GOTO		4;
	EQ_F		Parser_TokenType,	PARSER_TT_BRACECLOSE,	temp_0;
	IFNOT		temp_0,	2;
	SUB_F		lBraceCount,	FILE_APPEND,	lBraceCount;
	GOTO		-13;
	DONE;
}

entity(string pNamespace) Parser_ParseItem = asm
{
local entity lEntity;
local string lEntityText;
local string lNamespace;
local float temp_0;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	"Parsing item..",	parm1_x;
	CALL2		Parser_Print;
	STORE_F	PARSER_TT_TOKEN,	parm0_x;
	CALL1		Parser_Expect;
	STORE_F	"{ "type" "Item_",	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	STORE_F	"" ",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lEntityText;
	STORE_F	" Type = '",	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	STORE_F	"'",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	STORE_F	PARSER_TT_TOKEN,	parm0_x;
	CALL1		Parser_Expect;
	NE_S		pNamespace,	"",	temp_0;
	IFNOT		temp_0,	9;
	STORE_F	pNamespace,	parm0_x;
	STORE_F	"::",	parm1_x;
	STORE_F	Parser_Token,	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lNamespace;
	GOTO		4;
	STORE_F	Parser_Token,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lNamespace;
	STORE_F	lEntityText,	parm0_x;
	STORE_F	""name" "",	parm1_x;
	STORE_F	lNamespace,	parm2_x;
	STORE_F	"" ",	parm3_x;
	CALL4		strcat;
	STORE_F	lEntityText,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	lEntityText;
	STORE_F	lEntityText,	parm0_x;
	STORE_F	""parent" "",	parm1_x;
	STORE_F	pNamespace,	parm2_x;
	STORE_F	"" ",	parm3_x;
	CALL4		strcat;
	STORE_F	lEntityText,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	lEntityText;
	STORE_F	" Name = '",	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	STORE_F	"' Parent = '",	parm2_x;
	STORE_F	pNamespace,	parm3_x;
	STORE_F	"' Namespace = '",	parm4_x;
	STORE_F	lNamespace,	parm5_x;
	STORE_F	"'",	parm6_x;
	CALL7		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	STORE_F	PARSER_TT_BRACEOPEN,	parm0_x;
	CALL1		Parser_Expect;
	STORE_F	lNamespace,	parm0_x;
	STORE_F	lEntityText,	parm1_x;
	CALL2		Parser_ParseEntity;
	STORE_S	return_x,	lEntityText;
	CALL0		spawn;
	STORE_ENT	return_x,	lEntity;
	STORE_F	lEntity,	parm0_x;
	STORE_F	lEntityText,	parm1_x;
	CALL2		parseentitydata;
	STORE_F	lEntityText,	parm0_x;
	CALL1		String_Free;
	STORE_F	lNamespace,	parm0_x;
	CALL1		String_Free;
	INDIRECT_S	lEntity,	name,	temp_0;
	STORE_F	"Parsing '",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"' finished",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	RETURN	lEntity;
	DONE;
}

void(entity pSource, entity pTarget) Parser_CloneChildren = asm
{
local float locked_1585;
local float locked_1586;
local string lModifierString;
local entity lClone;
local entity lNode;
local float temp_5;
	STORE_ENT	null_entity,	lNode;
	INDIRECT_S	pSource,	name,	locked_1586;
	STORE_F	lNode,	parm0_x;
	STORE_F	parent,	parm1_x;
	STORE_F	locked_1586,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lNode;
	NE_E		return_x,	null_entity,	locked_1586;
	IFNOT		locked_1586,	37;
	CALL0		spawn;
	STORE_ENT	return_x,	lClone;
	STORE_F	lNode,	parm0_x;
	STORE_F	lClone,	parm1_x;
	CALL2		copyentity;
	INDIRECT_F	lClone,	flag,	locked_1586;
	BITAND	locked_1586,	FLAG_TEMPLATE,	locked_1586;
	IFNOT		locked_1586,	5;
	ADDRESS	lClone,	flag,	locked_1586;
	INDIRECT_F	lClone,	flag,	locked_1585;
	SUB_F		locked_1585,	FLAG_TEMPLATE,	locked_1585;
	STOREP_F	locked_1585,	locked_1586;
	INDIRECT_S	pTarget,	name,	locked_1586;
	INDIRECT_S	lNode,	name,	locked_1585;
	INDIRECT_S	pSource,	name,	parm0_x;
	CALL1		strlen;
	STORE_F	locked_1585,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	100000.000000,	parm2_x;
	CALL3		substring;
	INDIRECT_S	pTarget,	name,	locked_1585;
	STORE_F	"{ name "",	parm0_x;
	STORE_F	locked_1586,	parm1_x;
	STORE_F	return_x,	parm2_x;
	STORE_F	"" parent "",	parm3_x;
	STORE_F	locked_1585,	parm4_x;
	STORE_F	"" }",	parm5_x;
	CALL6		strcat;
	STORE_S	return_x,	lModifierString;
	STORE_F	lClone,	parm0_x;
	STORE_F	lModifierString,	parm1_x;
	CALL2		parseentitydata;
	STORE_F	lNode,	parm0_x;
	STORE_F	lClone,	parm1_x;
	CALL2		Parser_CloneChildren;
	GOTO		-43;
	DONE;
}

entity(string pNamespace) Parser_DeriveItem = asm
{
local entity lEntity;
local string lBaseName;
local entity lBase;
local string lEntityText;
local string lNamespace;
local float temp_0;
local float temp_1;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	"Parsing derived item..",	parm1_x;
	CALL2		Parser_Print;
	STORE_F	PARSER_TT_TOKEN,	parm0_x;
	CALL1		Parser_Expect;
	STORE_F	Parser_Token,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	KEY_MENU,	parm2_x;
	CALL3		substring;
	EQ_S		return_x,	"::",	temp_0;
	IFNOT		temp_0,	12;
	STORE_F	Parser_Token,	parm0_x;
	CALL1		strlen;
	SUB_F		return_x,	KEY_MENU,	temp_0;
	STORE_F	Parser_Token,	parm0_x;
	STORE_F	KEY_MENU,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		substring;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lBaseName;
	GOTO		24;
	EQ_S		pNamespace,	"",	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	Parser_Token,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lBaseName;
	GOTO		18;
	STORE_F	pNamespace,	parm0_x;
	STORE_F	"::",	parm1_x;
	STORE_F	Parser_Token,	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lBaseName;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	lBaseName,	parm2_x;
	CALL3		findstring;
	EQ_E		return_x,	null_entity,	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	lBaseName,	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	lBaseName;
	STORE_F	" Base = '",	parm0_x;
	STORE_F	lBaseName,	parm1_x;
	STORE_F	"'",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	STORE_F	null_entity,	parm0_x;
	STORE_F	name,	parm1_x;
	STORE_F	lBaseName,	parm2_x;
	CALL3		findstring;
	STORE_ENT	return_x,	lBase;
	EQ_E		lBase,	null_entity,	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	"couldnt find item",	parm0_x;
	CALL1		Parser_Error;
	STORE_F	PARSER_TT_TOKEN,	parm0_x;
	CALL1		Parser_Expect;
	NE_S		pNamespace,	"",	temp_0;
	IFNOT		temp_0,	9;
	STORE_F	pNamespace,	parm0_x;
	STORE_F	"::",	parm1_x;
	STORE_F	Parser_Token,	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lNamespace;
	GOTO		4;
	STORE_F	Parser_Token,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lNamespace;
	STORE_F	"{ "name" "",	parm0_x;
	STORE_F	lNamespace,	parm1_x;
	STORE_F	"" ",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lEntityText;
	STORE_F	lEntityText,	parm0_x;
	STORE_F	""parent" "",	parm1_x;
	STORE_F	pNamespace,	parm2_x;
	STORE_F	"" ",	parm3_x;
	CALL4		strcat;
	STORE_F	lEntityText,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	lEntityText;
	STORE_F	" Name = '",	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	STORE_F	"' Parent = '",	parm2_x;
	STORE_F	pNamespace,	parm3_x;
	STORE_F	"' Namespace = '",	parm4_x;
	STORE_F	lNamespace,	parm5_x;
	STORE_F	"'",	parm6_x;
	CALL7		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	STORE_F	PARSER_TT_BRACEOPEN,	parm0_x;
	CALL1		Parser_Expect;
	STORE_F	lNamespace,	parm0_x;
	STORE_F	lEntityText,	parm1_x;
	CALL2		Parser_ParseEntity;
	STORE_S	return_x,	lEntityText;
	CALL0		spawn;
	STORE_ENT	return_x,	lEntity;
	STORE_F	lBase,	parm0_x;
	STORE_F	lEntity,	parm1_x;
	CALL2		copyentity;
	INDIRECT_F	lEntity,	flag,	temp_0;
	BITAND	temp_0,	FLAG_TEMPLATE,	temp_0;
	IFNOT		temp_0,	5;
	ADDRESS	lEntity,	flag,	temp_0;
	INDIRECT_F	lEntity,	flag,	temp_1;
	SUB_F		temp_1,	FLAG_TEMPLATE,	temp_1;
	STOREP_F	temp_1,	temp_0;
	STORE_F	lEntity,	parm0_x;
	STORE_F	lEntityText,	parm1_x;
	CALL2		parseentitydata;
	STORE_F	lEntityText,	parm0_x;
	CALL1		String_Free;
	STORE_F	lNamespace,	parm0_x;
	CALL1		String_Free;
	STORE_F	lBaseName,	parm0_x;
	CALL1		String_Free;
	STORE_F	lBase,	parm0_x;
	STORE_F	lEntity,	parm1_x;
	CALL2		Parser_CloneChildren;
	INDIRECT_S	lEntity,	name,	temp_0;
	STORE_F	"Parsing '",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"' finished",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	RETURN	lEntity;
	DONE;
}

string(string pNamespace, string pEntityText) Parser_ParseEntity = asm
{
local float temp_0;
	CALL0		Parser_GetToken;
	IFNOT		return_x,	31;
	EQ_F		Parser_TokenType,	PARSER_TT_TOKEN,	temp_0;
	IFNOT		temp_0,	22;
	STORE_F	pEntityText,	parm0_x;
	STORE_F	""",	parm1_x;
	STORE_F	Parser_Token,	parm2_x;
	STORE_F	"" ",	parm3_x;
	CALL4		strcat;
	STORE_F	pEntityText,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	pEntityText;
	STORE_F	PARSER_TT_TOKEN,	parm0_x;
	CALL1		Parser_Expect;
	STORE_F	pEntityText,	parm0_x;
	STORE_F	""",	parm1_x;
	STORE_F	Parser_Token,	parm2_x;
	STORE_F	"" ",	parm3_x;
	CALL4		strcat;
	STORE_F	pEntityText,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	STORE_S	return_x,	pEntityText;
	GOTO		7;
	EQ_F		Parser_TokenType,	PARSER_TT_BRACECLOSE,	temp_0;
	IFNOT		temp_0,	3;
	GOTO		5;
	GOTO		3;
	STORE_F	pNamespace,	parm0_x;
	CALL1		Parser_ParseDefinition;
	GOTO		-31;
	STORE_F	pEntityText,	parm0_x;
	STORE_F	" }",	parm1_x;
	CALL2		String_Append;
	RETURN	return_x;
	DONE;
}

void(string pNamespace) Parser_ParseNamespace = asm
{
local string lNamespace;
local float temp_0;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	"Parsing Namespace...",	parm1_x;
	CALL2		Parser_Print;
	STORE_F	PARSER_TT_TOKEN,	parm0_x;
	CALL1		Parser_Expect;
	NE_S		pNamespace,	"",	temp_0;
	IFNOT		temp_0,	9;
	STORE_F	pNamespace,	parm0_x;
	STORE_F	"::",	parm1_x;
	STORE_F	Parser_Token,	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lNamespace;
	GOTO		4;
	STORE_F	Parser_Token,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	lNamespace;
	STORE_F	" Subnamespace = '",	parm0_x;
	STORE_F	Parser_Token,	parm1_x;
	STORE_F	"' New namespace = '",	parm2_x;
	STORE_F	lNamespace,	parm3_x;
	STORE_F	"'",	parm4_x;
	CALL5		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	STORE_F	PARSER_TT_BRACEOPEN,	parm0_x;
	CALL1		Parser_Expect;
	CALL0		Parser_GetToken;
	IFNOT		return_x,	7;
	EQ_F		Parser_TokenType,	PARSER_TT_BRACECLOSE,	temp_0;
	IFNOT		temp_0,	2;
	GOTO		4;
	STORE_F	lNamespace,	parm0_x;
	CALL1		Parser_ParseDefinition;
	GOTO		-7;
	STORE_F	"Finished parsing Namespace. Namespace = '",	parm0_x;
	STORE_F	pNamespace,	parm1_x;
	STORE_F	"'",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Parser_Print;
	STORE_F	lNamespace,	parm0_x;
	CALL1		String_Free;
	DONE;
}

void(string pFilename, string pNamespace) Parser_ParseFile = asm
{
local float temp_0;
	STORE_F	pFilename,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	Parser_Filename;
	STORE_F	Parser_Filename,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		fopen;
	STORE_F	return_x,	Parser_File;
	EQ_F		Parser_File,	ERR_CANNOTOPEN,	temp_0;
	IFNOT		temp_0,	6;
	STORE_F	"Parser: Couldn't open ",	parm0_x;
	STORE_F	Parser_Filename,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		print;
	RETURN	offset_0;
	CALL0		String_Create;
	STORE_S	return_x,	Parser_Line;
	STORE_F	KEY_GAME,	Parser_LineNumber;
	STORE_F	KEY_GAME,	Parser_TokenNum;
	STORE_F	KEY_GAME,	Parser_NumTokens;
	CALL0		Parser_GetToken;
	IFNOT		return_x,	4;
	STORE_F	pNamespace,	parm0_x;
	CALL1		Parser_ParseDefinition;
	GOTO		-4;
	STORE_F	Parser_File,	parm0_x;
	CALL1		fclose;
	STORE_F	Parser_Filename,	parm0_x;
	CALL1		String_Free;
	STORE_F	Parser_Line,	parm0_x;
	CALL1		String_Free;
	DONE;
}

void() Parser_Init = asm
{
	CALL0		String_Create;
	STORE_S	return_x,	Parser_Token;
	STORE_ENT	null_entity,	Parser_DefineChain;
	STORE_F	KEY_GAME,	Parser_IncludeDepth;
	CALL0		String_Create;
	STORE_S	return_x,	Parser_FileList;
	DONE;
}

void() Parser_Quit = asm
{
local entity lNext;
local float temp_0;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	"Deleting #defines:",	parm1_x;
	CALL2		_Parser_Print;
	IFNOT		Parser_DefineChain,	18;
	INDIRECT_E	Parser_DefineChain,	chain,	lNext;
	INDIRECT_S	Parser_DefineChain,	name,	temp_0;
	STORE_F	"  [",	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	"]",	parm2_x;
	CALL3		strcat;
	STORE_F	PARSER_HIGH,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Parser_Print;
	INDIRECT_S	Parser_DefineChain,	name,	parm0_x;
	CALL1		String_Free;
	INDIRECT_S	Parser_DefineChain,	value,	parm0_x;
	CALL1		String_Free;
	STORE_F	Parser_DefineChain,	parm0_x;
	CALL1		remove;
	STORE_ENT	lNext,	Parser_DefineChain;
	GOTO		-17;
	STORE_F	Parser_Token,	parm0_x;
	CALL1		String_Free;
	STORE_F	Parser_FileList,	parm0_x;
	CALL1		String_Free;
	DONE;
}

void(string pMain) Parser_ParseMenu = asm
{
	CALL0		Parser_Init;
	STORE_F	pMain,	parm0_x;
	CALL1		String_Zone;
	STORE_S	return_x,	pMain;
	STORE_F	Parser_FileList,	parm0_x;
	STORE_F	pMain,	parm1_x;
	CALL2		Util_AltStringPush;
	STORE_S	return_x,	Parser_FileList;
	STORE_F	pMain,	parm0_x;
	STORE_F	"",	parm1_x;
	CALL2		Parser_ParseFile;
	STORE_F	"Files parsed: ",	parm0_x;
	STORE_F	Parser_FileList,	parm1_x;
	CALL2		strcat;
	STORE_F	PARSER_INFO,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		_Parser_Print;
	STORE_F	pMain,	parm0_x;
	CALL1		String_Free;
	CALL0		Parser_Quit;
	DONE;
}

void() Menu_InitGarbageStats = asm
{
	STORE_F	KEY_GAME,	Menu_GarbageFrameCount;
	STORE_F	KEY_GAME,	Menu_GarbageToggleCount;
	DONE;
}

void() Menu_ResetGarbageStats = asm
{
	IFNOT		Menu_GarbageFrameCount,	7;
	STORE_F	Menu_GarbageFrameCount,	parm0_x;
	CALL1		ftos;
	STORE_F	"Menu: GC: ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	" items marked for frame deletion but couldnt be reached!
",	parm2_x;
	CALL3		print;
	IFNOT		Menu_GarbageToggleCount,	7;
	STORE_F	Menu_GarbageToggleCount,	parm0_x;
	CALL1		ftos;
	STORE_F	"Menu: GC: ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	" items marked for toggle delition but couldnt be reached!
",	parm2_x;
	CALL3		print;
	STORE_F	KEY_GAME,	Menu_GarbageFrameCount;
	STORE_F	KEY_GAME,	Menu_GarbageToggleCount;
	DONE;
}

float(entity pItem) Menu_CheckForGarbage = asm
{
local float temp_0;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_DELETEFRAME,	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	pItem,	parm0_x;
	CALL1		Menu_RemoveItem;
	SUB_F		Menu_GarbageFrameCount,	FILE_APPEND,	Menu_GarbageFrameCount;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void(float pToggle) Menu_CollectGarbage = asm
{
local float locked_1586;
local entity lNode;
local float temp_1;
	STORE_ENT	null_entity,	lNode;
	IFNOT		pToggle,	25;
	IF		Menu_GarbageFrameCount,	1;
	OR		Menu_GarbageFrameCount,	Menu_GarbageToggleCount,	locked_1586;
	IFNOT		locked_1586,	5;
	STORE_F	lNode,	parm0_x;
	CALL1		nextent;
	STORE_ENT	return_x,	lNode;
	NE_E		return_x,	null_entity,	temp_1;
	AND		locked_1586,	temp_1,	locked_1586;
	IFNOT		locked_1586,	15;
	INDIRECT_F	lNode,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_DELETEFRAME,	locked_1586;
	IFNOT		locked_1586,	5;
	STORE_F	lNode,	parm0_x;
	CALL1		Menu_RemoveItem;
	SUB_F		Menu_GarbageFrameCount,	FILE_APPEND,	Menu_GarbageFrameCount;
	GOTO		7;
	INDIRECT_F	lNode,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_DELETETOGGLE,	locked_1586;
	IFNOT		locked_1586,	4;
	STORE_F	lNode,	parm0_x;
	CALL1		Menu_RemoveItem;
	SUB_F		Menu_GarbageToggleCount,	FILE_APPEND,	Menu_GarbageToggleCount;
	GOTO		-22;
	GOTO		15;
	IFNOT		Menu_GarbageFrameCount,	5;
	STORE_F	lNode,	parm0_x;
	CALL1		nextent;
	STORE_ENT	return_x,	lNode;
	NE_E		return_x,	null_entity,	locked_1586;
	AND		Menu_GarbageFrameCount,	locked_1586,	locked_1586;
	IFNOT		locked_1586,	8;
	INDIRECT_F	lNode,	_runFlag,	locked_1586;
	BITAND	locked_1586,	RUNFLAG_DELETEFRAME,	locked_1586;
	IFNOT		locked_1586,	4;
	STORE_F	lNode,	parm0_x;
	CALL1		Menu_RemoveItem;
	SUB_F		Menu_GarbageFrameCount,	FILE_APPEND,	Menu_GarbageFrameCount;
	GOTO		-13;
	DONE;
}

void(entity pItem) Menu_DeleteAfterFrame = asm
{
local float temp_0;
local float temp_1;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_DELETEFRAME,	temp_0;
	IF		temp_0,	16;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_DELETETOGGLE,	temp_0;
	IFNOT		temp_0,	8;
	ADDRESS	pItem,	_runFlag,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	ADD_F		temp_1,	RUNFLAG_DELETEFRAME,	temp_1;
	SUB_F		temp_1,	RUNFLAG_DELETETOGGLE,	temp_1;
	STOREP_F	temp_1,	temp_0;
	SUB_F		Menu_GarbageToggleCount,	FILE_APPEND,	Menu_GarbageToggleCount;
	GOTO		5;
	ADDRESS	pItem,	_runFlag,	temp_0;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	ADD_F		temp_1,	RUNFLAG_DELETEFRAME,	temp_1;
	STOREP_F	temp_1,	temp_0;
	ADD_F		Menu_GarbageFrameCount,	FILE_APPEND,	Menu_GarbageFrameCount;
	DONE;
}

void(entity pItem) Menu_DeleteAfterToggle = asm
{
local float temp_0;
local float temp_1;
	INDIRECT_F	pItem,	_runFlag,	temp_0;
	BITAND	temp_0,	RUNFLAG_DELETEFRAME,	temp_0;
	IF		temp_0,	3;
	INDIRECT_F	pItem,	_runFlag,	temp_1;
	BITAND	temp_1,	RUNFLAG_DELETETOGGLE,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	offset_0;
	ADDRESS	pItem,	_runFlag,	temp_0;
	INDIRECT_F	self,	_runFlag,	temp_1;
	ADD_F		temp_1,	RUNFLAG_DELETETOGGLE,	temp_1;
	STOREP_F	temp_1,	temp_0;
	ADD_F		Menu_GarbageToggleCount,	FILE_APPEND,	Menu_GarbageToggleCount;
	DONE;
}

void() Key_Init = asm
{
	DONE;
}

void() Key_Quit = asm
{
	DONE;
}

void() Key_Display = asm
{
	STORE_F	KEY_MENU,	parm0_x;
	CALL1		setkeydest;
	DONE;
}

void() Key_Update = asm
{
local float temp_0;
	CALL0		getkeydest;
	NE_F		return_x,	KEY_MENU,	temp_0;
	IFNOT		temp_0,	2;
	CALL0		m_hide;
	DONE;
}

void() Key_Hide = asm
{
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		setkeydest;
	DONE;
}

void(string pKey) Key_Unbind = asm
{
	STORE_F	"unbind ",	parm0_x;
	STORE_F	pKey,	parm1_x;
	STORE_F	"
",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	DONE;
}

string(float pKey) Key_GetName = asm
{
	STORE_F	pKey,	parm0_x;
	CALL1		keynumtostring;
	RETURN	return_x;
	DONE;
}

float(string pKey) Key_GetNum = asm
{
	STORE_F	pKey,	parm0_x;
	CALL1		stringtokeynum;
	RETURN	return_x;
	DONE;
}

string(string pCommand) Key_GetBindList = asm
{
	STORE_F	pCommand,	parm0_x;
	CALL1		findkeysforcommand;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	RETURN	return_x;
	DONE;
}

void(string pKey, string pCommand) Key_Bind = asm
{
	STORE_F	"bind "",	parm0_x;
	STORE_F	pKey,	parm1_x;
	STORE_F	"" "",	parm2_x;
	STORE_F	pCommand,	parm3_x;
	STORE_F	""
",	parm4_x;
	CALL5		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		cmd;
	DONE;
}

void(float pNum, string pCommand) Key_LimitBinds = asm
{
local float lValue;
local float lMaxnum;
local float lCounter;
local string lAltlist;
local float temp_0;
local float temp_1;
	STORE_F	pCommand,	parm0_x;
	CALL1		Key_GetBindList;
	STORE_S	return_x,	lAltlist;
	STORE_F	lAltlist,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lMaxnum;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lMaxnum,	temp_0;
	IFNOT		temp_0,	20;
	STORE_F	lAltlist,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	return_x,	parm0_x;
	CALL1		stof;
	STORE_F	return_x,	lValue;
	EQ_F		lValue,	ERR_CANNOTOPEN,	temp_0;
	IFNOT		temp_0,	2;
	GOTO		9;
	GE		lCounter,	pNum,	temp_0;
	IFNOT		temp_0,	5;
	STORE_F	lValue,	parm0_x;
	CALL1		Key_GetName;
	STORE_F	return_x,	parm0_x;
	CALL1		Key_Unbind;
	ADD_F		lCounter,	FILE_APPEND,	lCounter;
	GOTO		-20;
	STORE_F	lAltlist,	parm0_x;
	CALL1		String_Free;
	DONE;
}

void() Cursor_Init = asm
{
	STORE_F	CURSOR_PATH,	parm0_x;
	CALL1		Gfx_Precache;
	IFNOT		return_x,	3;
	STORE_S	CURSOR_PATH,	Cursor_Current;
	GOTO		4;
	STORE_S	"ui/mousepointer.tga",	Cursor_Current;
	STORE_F	Cursor_Current,	parm0_x;
	CALL1		Gfx_Precache;
	STORE_V	'0.000000 0.000000 0.000000',	Cursor_Relative;
	STORE_V	'0.000000 0.000000 0.000000',	Cursor_Position;
	STORE_FNC	Cursor_DefaultAnimation,	Cursor_Animation;
	DONE;
}

void() Cursor_Quit = asm
{
	DONE;
}

void() Cursor_Display = asm
{
	STORE_F	FILE_APPEND,	parm0_x;
	CALL1		setmousetarget;
	DONE;
}

void() Cursor_Hide = asm
{
	STORE_F	KEY_MENU,	parm0_x;
	CALL1		setmousetarget;
	DONE;
}

void() Cursor_Draw = asm
{
local vector lSize;
local vector lPos;
local float temp_0;
local vector temp_2;
	STORE_F	Cursor_Current,	parm0_x;
	CALL1		Gfx_GetImageSize;
	MUL_VF	return,	FILE_APPEND,	lSize;
	MUL_F		lSize_x,	Cursor_Offset_x,	temp_0;
	ADD_F		Cursor_Position_x,	temp_0,	lPos_x;
	MUL_F		lSize_y,	Cursor_Offset_y,	temp_0;
	ADD_F		Cursor_Position_y,	temp_0,	lPos_y;
	STORE_F	KEY_GAME,	lPos_z;
	STORE_V	lPos,	parm0;
	STORE_F	Cursor_Current,	parm1_x;
	STORE_V	lSize,	parm2;
	STORE_V	Cursor_Color,	parm3;
	STORE_F	FILE_APPEND,	parm4_x;
	STORE_F	KEY_GAME,	parm5_x;
	CALL6		Gfx_DrawPic;
	DONE;
}

void() Cursor_Update = asm
{
local vector lRelPos;
local float temp_0;
	CALL0		getmousepos;
	STORE_V	return,	lRelPos;
	STORE_V	lRelPos,	parm0;
	CALL1		Gfx_ConToMen;
	STORE_V	return,	lRelPos;
	MUL_F		lRelPos_x,	Cursor_Speed_x,	Cursor_Relative_x;
	MUL_F		lRelPos_y,	Cursor_Speed_y,	Cursor_Relative_y;
	ADD_F		Cursor_Position_x,	Cursor_Relative_x,	temp_0;
	STORE_F	KEY_GAME,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	Gfx_Menu_Width,	parm2_x;
	CALL3		bound;
	SUB_F		return_x,	Cursor_Position_x,	Cursor_Relative_x;
	ADD_F		Cursor_Position_y,	Cursor_Relative_y,	temp_0;
	STORE_F	KEY_GAME,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	Gfx_Menu_Height,	parm2_x;
	CALL3		bound;
	SUB_F		return_x,	Cursor_Position_y,	Cursor_Relative_y;
	ADD_F		Cursor_Position_x,	Cursor_Relative_x,	Cursor_Position_x;
	ADD_F		Cursor_Position_y,	Cursor_Relative_y,	Cursor_Position_y;
	STORE_F	KEY_GAME,	Cursor_Position_z;
	CALL0		Cursor_Animation;
	DONE;
}

void() Cursor_DefaultAnimation = asm
{
	DONE;
}

void(vector pRelPos, string pText, vector pScale, vector pColor, float pAlpha, float pDrawFlag) Cursor_PrintInfo = asm
{
local float locked_1586;
local vector lSize;
local vector lPosition;
local float temp_1;
local vector temp_2;
	STORE_F	Cursor_Current,	parm0_x;
	CALL1		Gfx_GetImageSize;
	MUL_VF	return,	FILE_APPEND,	lSize;
	NE_F		pRelPos_x,	KEY_GAME,	locked_1586;
	IFNOT		locked_1586,	28;
	GT		pRelPos_x,	KEY_GAME,	locked_1586;
	IFNOT		locked_1586,	7;
	ADD_F		Cursor_Offset_x,	0.500000,	locked_1586;
	DIV_F		pRelPos_x,	KEY_MENU,	temp_1;
	ADD_F		locked_1586,	temp_1,	locked_1586;
	MUL_F		lSize_x,	locked_1586,	locked_1586;
	ADD_F		Cursor_Position_x,	locked_1586,	lPosition_x;
	GOTO		12;
	LT		pRelPos_x,	KEY_GAME,	locked_1586;
	IFNOT		locked_1586,	10;
	ADD_F		Cursor_Offset_x,	0.500000,	locked_1586;
	DIV_F		pRelPos_x,	KEY_MENU,	temp_1;
	ADD_F		locked_1586,	temp_1,	locked_1586;
	MUL_F		lSize_x,	locked_1586,	locked_1586;
	ADD_F		Cursor_Position_x,	locked_1586,	locked_1586;
	STORE_F	pText,	parm0_x;
	CALL1		strlen;
	MUL_F		pScale_x,	return_x,	temp_1;
	SUB_F		locked_1586,	temp_1,	lPosition_x;
	ADD_F		Cursor_Offset_y,	0.500000,	locked_1586;
	DIV_F		pRelPos_y,	KEY_MENU,	temp_1;
	ADD_F		locked_1586,	temp_1,	locked_1586;
	MUL_F		lSize_y,	locked_1586,	locked_1586;
	ADD_F		Cursor_Position_y,	locked_1586,	locked_1586;
	DIV_F		pScale_y,	KEY_MENU,	temp_1;
	SUB_F		locked_1586,	temp_1,	lPosition_y;
	GOTO		9;
	ADD_F		Cursor_Offset_x,	0.500000,	locked_1586;
	MUL_F		lSize_x,	locked_1586,	locked_1586;
	ADD_F		Cursor_Position_x,	locked_1586,	locked_1586;
	STORE_F	pText,	parm0_x;
	CALL1		strlen;
	MUL_F		pScale_x,	return_x,	temp_1;
	DIV_F		temp_1,	KEY_MENU,	temp_1;
	SUB_F		locked_1586,	temp_1,	lPosition_x;
	NE_F		pRelPos_y,	KEY_GAME,	locked_1586;
	IFNOT		locked_1586,	17;
	GT		pRelPos_y,	KEY_GAME,	locked_1586;
	IFNOT		locked_1586,	8;
	ADD_F		Cursor_Offset_y,	0.500000,	locked_1586;
	DIV_F		pRelPos_y,	KEY_MENU,	temp_1;
	SUB_F		locked_1586,	temp_1,	locked_1586;
	MUL_F		lSize_y,	locked_1586,	locked_1586;
	ADD_F		Cursor_Position_y,	locked_1586,	locked_1586;
	SUB_F		locked_1586,	pScale_y,	lPosition_y;
	GOTO		8;
	LT		pRelPos_y,	KEY_GAME,	locked_1586;
	IFNOT		locked_1586,	6;
	ADD_F		Cursor_Offset_y,	0.500000,	locked_1586;
	DIV_F		pRelPos_y,	KEY_MENU,	temp_1;
	SUB_F		locked_1586,	temp_1,	locked_1586;
	MUL_F		lSize_y,	locked_1586,	locked_1586;
	ADD_F		Cursor_Position_y,	locked_1586,	lPosition_y;
	STORE_V	lPosition,	parm0;
	STORE_F	pText,	parm1_x;
	STORE_V	pScale,	parm2;
	STORE_V	pColor,	parm3;
	STORE_F	pAlpha,	parm4_x;
	STORE_F	pDrawFlag,	parm5_x;
	CALL6		Gfx_DrawString;
	DONE;
}

void (string) _Sound_DPrint;
void(string pText) _Sound_DPrint = asm
{
	IFNOT		sys_debug_sound,	3;
	STORE_F	pText,	parm0_x;
	CALL1		print;
	DONE;
}

float(string pSnd) Sound_Precache = asm
{
local float temp_0;
	STORE_F	"Precaching sound '",	parm0_x;
	STORE_F	pSnd,	parm1_x;
	STORE_F	"'
",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		_Sound_DPrint;
	EQ_S		pSnd,	"",	temp_0;
	IFNOT		temp_0,	2;
	RETURN	KEY_GAME;
	STORE_F	pSnd,	parm0_x;
	CALL1		precache_sound;
	NE_S		pSnd,	return_x,	temp_0;
	IFNOT		temp_0,	3;
	RETURN	KEY_GAME;
	GOTO		2;
	RETURN	FILE_APPEND;
	DONE;
}

void(string pSnd) Sound_Free = asm
{
	DONE;
}

void(string pSnd) Sound_Play = asm
{
	STORE_F	"Playing sound '",	parm0_x;
	STORE_F	pSnd,	parm1_x;
	STORE_F	"'
",	parm2_x;
	CALL3		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		_Sound_DPrint;
	STORE_F	pSnd,	parm0_x;
	CALL1		localsound;
	DONE;
}

float _Gfx_FPS;
float _Gfx_LastTime;
float _Gfx_FrameCount;
void () _Gfx_UpdateFPS;
void() _Gfx_UpdateFPS = asm
{
local float lDeltaTime;
local float temp_0;
	ADD_F		_Gfx_FrameCount,	FILE_APPEND,	_Gfx_FrameCount;
	SUB_F		Timer_Time,	_Gfx_LastTime,	lDeltaTime;
	LT		FILE_APPEND,	lDeltaTime,	temp_0;
	IFNOT		temp_0,	4;
	DIV_F		_Gfx_FrameCount,	lDeltaTime,	_Gfx_FPS;
	STORE_F	Timer_Time,	_Gfx_LastTime;
	STORE_F	KEY_GAME,	_Gfx_FrameCount;
	DONE;
}

void () _Gfx_UpdateRes;
void() _Gfx_UpdateRes = asm
{
local float temp_0;
	STORE_F	"vid_conwidth",	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	Gfx_Real_Width;
	STORE_F	"vid_conheight",	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	Gfx_Real_Height;
	STORE_F	CVAR_SCMENU_MENU_WIDTH,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	Gfx_Menu_Width;
	STORE_F	CVAR_SCMENU_MENU_HEIGHT,	parm0_x;
	CALL1		cvar;
	STORE_F	return_x,	Gfx_Menu_Height;
	EQ_F		Gfx_Menu_Width,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	2;
	STORE_F	SLIST_LEGACY_LINE1,	Gfx_Menu_Width;
	EQ_F		Gfx_Menu_Height,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	2;
	STORE_F	K_JOY1,	Gfx_Menu_Height;
	DONE;
}

void() Gfx_Init = asm
{
local string lHeight;
local string lWidth;
	STORE_F	SLIST_LEGACY_LINE1,	parm0_x;
	CALL1		ftos;
	STORE_S	return_x,	lWidth;
	STORE_F	K_JOY1,	parm0_x;
	CALL1		ftos;
	STORE_S	return_x,	lHeight;
	STORE_F	CVAR_SCMENU_MENU_WIDTH,	parm0_x;
	STORE_F	lWidth,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		registercvar;
	STORE_F	CVAR_SCMENU_MENU_HEIGHT,	parm0_x;
	STORE_F	lHeight,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		registercvar;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		ftos;
	STORE_F	CVAR_SCMENU_SHOWFPS,	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	KEY_GAME,	parm2_x;
	CALL3		registercvar;
	CALL0		_Gfx_UpdateRes;
	DONE;
}

void() Gfx_Quit = asm
{
	DONE;
}

void() Gfx_Display = asm
{
	CALL0		Gfx_ResetClipArea;
	DONE;
}

void() Gfx_Hide = asm
{
	DONE;
}

void() Gfx_Update = asm
{
	CALL0		_Gfx_UpdateRes;
	CALL0		_Gfx_UpdateFPS;
	DONE;
}

void() Gfx_Draw = asm
{
local vector lPosition;
local vector lScale;
local string lText;
local float temp_0;
	STORE_F	CVAR_SCMENU_SHOWFPS,	parm0_x;
	CALL1		cvar;
	IFNOT		return_x,	21;
	STORE_F	_Gfx_FPS,	parm0_x;
	CALL1		floor;
	STORE_F	return_x,	parm0_x;
	CALL1		ftos;
	STORE_F	"FPS: ",	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		strcat;
	STORE_S	return_x,	lText;
	STORE_V	'15.000000 15.000000 0.000000',	lScale;
	STORE_F	KEY_GAME,	lPosition_x;
	SUB_F		Gfx_Menu_Height,	lScale_y,	temp_0;
	SUB_F		temp_0,	SLIST_SERVERREPLYCOUNT,	lPosition_y;
	STORE_F	KEY_GAME,	lPosition_z;
	STORE_V	lPosition,	parm0;
	STORE_F	lText,	parm1_x;
	STORE_V	lScale,	parm2;
	STORE_V	Cursor_Color,	parm3;
	STORE_F	FILE_APPEND,	parm4_x;
	STORE_F	KEY_GAME,	parm5_x;
	CALL6		Gfx_DrawString;
	DONE;
}

float(string pPic) Gfx_IsCached = asm
{
	STORE_F	pPic,	parm0_x;
	CALL1		iscachedpic;
	RETURN	return_x;
	DONE;
}

float(string pPic) Gfx_Precache = asm
{
local float temp_0;
	EQ_S		pPic,	"",	temp_0;
	IFNOT		temp_0,	2;
	RETURN	KEY_GAME;
	STORE_F	pPic,	parm0_x;
	CALL1		iscachedpic;
	IFNOT		return_x,	2;
	RETURN	FILE_APPEND;
	STORE_F	pPic,	parm0_x;
	CALL1		precache_pic;
	EQ_S		return_x,	pPic,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	FILE_APPEND;
	RETURN	KEY_GAME;
	DONE;
}

void(string pPic) Gfx_Free = asm
{
	DONE;
}

vector(string pPic) Gfx_GetImageSize = asm
{
	STORE_F	pPic,	parm0_x;
	CALL1		drawgetimagesize;
	RETURN	return_x;
	DONE;
}

vector(vector pPos) Gfx_ConToMen = asm
{
local float temp_0;
	MUL_F		pPos_x,	Gfx_Menu_Width,	temp_0;
	DIV_F		temp_0,	Gfx_Real_Width,	pPos_x;
	MUL_F		pPos_y,	Gfx_Menu_Height,	temp_0;
	DIV_F		temp_0,	Gfx_Real_Height,	pPos_y;
	STORE_F	KEY_GAME,	pPos_z;
	RETURN	pPos_x;
	DONE;
}

vector(vector pPos) Gfx_MenToCon = asm
{
local float temp_0;
	MUL_F		pPos_x,	Gfx_Real_Width,	temp_0;
	DIV_F		temp_0,	Gfx_Menu_Width,	pPos_x;
	MUL_F		pPos_y,	Gfx_Real_Height,	temp_0;
	DIV_F		temp_0,	Gfx_Menu_Height,	pPos_y;
	STORE_F	KEY_GAME,	pPos_z;
	RETURN	pPos_x;
	DONE;
}

void() Gfx_ResetClipArea = asm
{
	CALL0		drawresetcliparea;
	DONE;
}

vector (vector) _Gfx_FitCenter;
vector(vector pPosition) _Gfx_FitCenter = asm
{
local vector temp_2;
	ADD_V		pPosition,	'0.375000 0.375000 0.000000',	temp_2;
	RETURN	temp_2_x;
	DONE;
}

float(vector pPosition, float pCharacter, vector pScale, vector pRGB, float pAlpha, float pFlag) Gfx_DrawCharacter = asm
{
	STORE_V	pPosition,	parm0;
	CALL1		Gfx_MenToCon;
	STORE_V	return,	parm0;
	CALL1		_Gfx_FitCenter;
	STORE_V	return,	pPosition;
	STORE_V	pScale,	parm0;
	CALL1		Gfx_MenToCon;
	STORE_V	return,	pScale;
	STORE_V	pPosition,	parm0;
	STORE_F	pCharacter,	parm1_x;
	STORE_V	pScale,	parm2;
	STORE_V	pRGB,	parm3;
	STORE_F	pAlpha,	parm4_x;
	STORE_F	pFlag,	parm5_x;
	CALL6		drawcharacter;
	RETURN	return_x;
	DONE;
}

float(vector pPosition, string pText, vector pScale, vector pRGB, float pAlpha, float pFlag) Gfx_DrawString = asm
{
	STORE_V	pPosition,	parm0;
	CALL1		Gfx_MenToCon;
	STORE_V	return,	parm0;
	CALL1		_Gfx_FitCenter;
	STORE_V	return,	pPosition;
	STORE_V	pScale,	parm0;
	CALL1		Gfx_MenToCon;
	STORE_V	return,	pScale;
	STORE_V	pPosition,	parm0;
	STORE_F	pText,	parm1_x;
	STORE_V	pScale,	parm2;
	STORE_V	pRGB,	parm3;
	STORE_F	pAlpha,	parm4_x;
	STORE_F	pFlag,	parm5_x;
	CALL6		drawstring;
	RETURN	return_x;
	DONE;
}

float(vector pPosition, string pPicture, vector pSize, vector pRGB, float pAlpha, float pFlag) Gfx_DrawPic = asm
{
	STORE_V	pPosition,	parm0;
	CALL1		Gfx_MenToCon;
	STORE_V	return,	parm0;
	CALL1		_Gfx_FitCenter;
	STORE_V	return,	pPosition;
	STORE_V	pSize,	parm0;
	CALL1		Gfx_MenToCon;
	STORE_V	return,	pSize;
	STORE_V	pPosition,	parm0;
	STORE_F	pPicture,	parm1_x;
	STORE_V	pSize,	parm2;
	STORE_V	pRGB,	parm3;
	STORE_F	pAlpha,	parm4_x;
	STORE_F	pFlag,	parm5_x;
	CALL6		drawpic;
	RETURN	return_x;
	DONE;
}

float(vector pPosition, vector pSize, vector pRGB, float pAlpha, float pFlag) Gfx_Fill = asm
{
	STORE_V	pPosition,	parm0;
	CALL1		Gfx_MenToCon;
	STORE_V	return,	parm0;
	CALL1		_Gfx_FitCenter;
	STORE_V	return,	pPosition;
	STORE_V	pSize,	parm0;
	CALL1		Gfx_MenToCon;
	STORE_V	return,	pSize;
	STORE_V	pPosition,	parm0;
	STORE_V	pSize,	parm1;
	STORE_V	pRGB,	parm2;
	STORE_F	pAlpha,	parm3_x;
	STORE_F	pFlag,	parm4_x;
	CALL5		drawfill;
	RETURN	return_x;
	DONE;
}

void(float pX, float pY, float pWidth, float pHeight) Gfx_SetClipArea = asm
{
local vector lSize;
local vector lPosition;
local vector temp_2;
	STORE_F	pX,	lPosition_x;
	STORE_F	pY,	lPosition_y;
	STORE_F	pWidth,	lSize_x;
	STORE_F	pHeight,	lSize_y;
	STORE_V	lPosition,	parm0;
	CALL1		Gfx_MenToCon;
	STORE_V	return,	parm0;
	CALL1		_Gfx_FitCenter;
	STORE_V	return,	lPosition;
	STORE_V	lSize,	parm0;
	CALL1		Gfx_MenToCon;
	ADD_V		return,	Cursor_Speed,	lSize;
	STORE_F	lPosition_x,	parm0_x;
	STORE_F	lPosition_y,	parm1_x;
	STORE_F	lSize_x,	parm2_x;
	STORE_F	lSize_y,	parm3_x;
	CALL4		drawsetcliparea;
	DONE;
}

float _Timer_LastTime;
void() Timer_Init = asm
{
	CALL0		gettime;
	STORE_F	return_x,	Timer_Time;
	STORE_F	KEY_GAME,	Timer_Delta;
	DONE;
}

void() Timer_Update = asm
{
local float temp_0;
	STORE_F	Timer_Time,	_Timer_LastTime;
	CALL0		gettime;
	STORE_F	return_x,	Timer_Time;
	SUB_F		Timer_Time,	_Timer_LastTime,	Timer_Delta;
	DONE;
}

void() Timer_Quit = asm
{
	DONE;
}

void() HostCache_Init = asm
{
	STORE_F	"cname",	parm0_x;
	CALL1		gethostcacheindexforkey;
	STORE_F	return_x,	SLIST_FIELD_CNAME;
	STORE_F	"ping",	parm0_x;
	CALL1		gethostcacheindexforkey;
	STORE_F	return_x,	SLIST_FIELD_PING;
	STORE_F	"game",	parm0_x;
	CALL1		gethostcacheindexforkey;
	STORE_F	return_x,	SLIST_FIELD_GAME;
	STORE_F	"mod",	parm0_x;
	CALL1		gethostcacheindexforkey;
	STORE_F	return_x,	SLIST_FIELD_MOD;
	STORE_F	"map",	parm0_x;
	CALL1		gethostcacheindexforkey;
	STORE_F	return_x,	SLIST_FIELD_MAP;
	STORE_F	"name",	parm0_x;
	CALL1		gethostcacheindexforkey;
	STORE_F	return_x,	SLIST_FIELD_NAME;
	STORE_F	"maxplayers",	parm0_x;
	CALL1		gethostcacheindexforkey;
	STORE_F	return_x,	SLIST_FIELD_MAXPLAYERS;
	STORE_F	"numplayers",	parm0_x;
	CALL1		gethostcacheindexforkey;
	STORE_F	return_x,	SLIST_FIELD_NUMPLAYERS;
	STORE_F	"protocol",	parm0_x;
	CALL1		gethostcacheindexforkey;
	STORE_F	return_x,	SLIST_FIELD_PROTOCOL;
	DONE;
}

void() HostCache_Update = asm
{
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		gethostcachevalue;
	STORE_F	return_x,	HostCache_ViewCount;
	STORE_F	FILE_APPEND,	parm0_x;
	CALL1		gethostcachevalue;
	STORE_F	return_x,	HostCache_TotalCount;
	STORE_F	KEY_MENU,	parm0_x;
	CALL1		gethostcachevalue;
	STORE_F	return_x,	HostCache_MasterQueryCount;
	STORE_F	KEY_UNKNOWN,	parm0_x;
	CALL1		gethostcachevalue;
	STORE_F	return_x,	HostCache_MasterReplyCount;
	STORE_F	CVAR_READONLY,	parm0_x;
	CALL1		gethostcachevalue;
	STORE_F	return_x,	HostCache_ServerQueryCount;
	STORE_F	SLIST_SERVERREPLYCOUNT,	parm0_x;
	CALL1		gethostcachevalue;
	STORE_F	return_x,	HostCache_ServerReplyCount;
	STORE_F	SLIST_SORTFIELD,	parm0_x;
	CALL1		gethostcachevalue;
	STORE_F	return_x,	HostCache_SortField;
	STORE_F	SLIST_SORTDESCENDING,	parm0_x;
	CALL1		gethostcachevalue;
	STORE_F	return_x,	HostCache_SortDescending;
	DONE;
}

void() HostCache_ResortViewSet = asm
{
	CALL0		resorthostcache;
	CALL0		HostCache_Update;
	DONE;
}

void() HostCache_RefreshHostCache = asm
{
	CALL0		refreshhostcache;
	CALL0		HostCache_Update;
	DONE;
}

string() Property_Create = asm
{
	CALL0		String_Create;
	RETURN	return_x;
	DONE;
}

string(string pString) Property_Zone = asm
{
	STORE_F	pString,	parm0_x;
	CALL1		String_Zone;
	RETURN	return_x;
	DONE;
}

string(string pString) Propery_Free = asm
{
	STORE_F	pString,	parm0_x;
	CALL1		String_Free;
	RETURN	return_x;
	DONE;
}

float(string pString) Property_Validate = asm
{
local float lCount;
local float temp_0;
	STORE_F	pString,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	DIV_F		lCount,	KEY_MENU,	parm0_x;
	CALL1		rint;
	DIV_F		lCount,	KEY_MENU,	temp_0;
	NE_F		return_x,	temp_0,	temp_0;
	IFNOT		temp_0,	7;
	STORE_F	"Property_Validate",	parm0_x;
	STORE_F	"Invalid property string "",	parm1_x;
	STORE_F	pString,	parm2_x;
	STORE_F	""!
",	parm3_x;
	CALL4		dprint;
	RETURN	KEY_GAME;
	RETURN	FILE_APPEND;
	DONE;
}

float(string pString, string pName) Property_Exists = asm
{
local float lCounter;
local float lCount;
local float temp_0;
	IF		FILE_APPEND,	2;
	RETURN	KEY_GAME;
	STORE_F	pString,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	temp_0;
	IFNOT		temp_0,	11;
	STORE_F	pString,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	EQ_S		return_x,	pName,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	FILE_APPEND;
	ADD_F		lCounter,	KEY_MENU,	lCounter;
	GOTO		-11;
	RETURN	KEY_GAME;
	DONE;
}

string(string pString, string pName, string pInitValue) Property_Register = asm
{
local float lCounter;
local float lCount;
local float temp_0;
	IF		FILE_APPEND,	2;
	RETURN	pString;
	STORE_F	pString,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	temp_0;
	IFNOT		temp_0,	11;
	STORE_F	pString,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	EQ_S		return_x,	pName,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	pString;
	ADD_F		lCounter,	KEY_MENU,	lCounter;
	GOTO		-11;
	STORE_F	pString,	parm0_x;
	STORE_F	pInitValue,	parm1_x;
	CALL2		Util_AltStringPush;
	STORE_S	return_x,	pString;
	STORE_F	pString,	parm0_x;
	STORE_F	pName,	parm1_x;
	CALL2		Util_AltStringPush;
	STORE_S	return_x,	pString;
	RETURN	pString;
	DONE;
}

string(string pString, string pName, string pValue) Property_Set = asm
{
local float lCounter;
local float lCount;
local float temp_0;
	IF		FILE_APPEND,	2;
	RETURN	pString;
	STORE_F	pString,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	temp_0;
	IFNOT		temp_0,	16;
	STORE_F	pString,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	EQ_S		return_x,	pName,	temp_0;
	IFNOT		temp_0,	7;
	ADD_F		lCounter,	FILE_APPEND,	temp_0;
	STORE_F	pString,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	pValue,	parm2_x;
	CALL3		Util_SetAltStringItem;
	RETURN	return_x;
	ADD_F		lCounter,	KEY_MENU,	lCounter;
	GOTO		-16;
	STORE_F	"Property_Set",	parm0_x;
	STORE_F	"The property "",	parm1_x;
	STORE_F	pName,	parm2_x;
	STORE_F	"" hasn't been declared!
pString = "",	parm3_x;
	STORE_F	pString,	parm4_x;
	STORE_F	""",	parm5_x;
	CALL6		dprint;
	RETURN	pString;
	DONE;
}

string(string pString, string pOldName, string pNewName) Property_Rename = asm
{
local float lCounter;
local float lCount;
local float temp_0;
	IF		FILE_APPEND,	2;
	RETURN	pString;
	STORE_F	pString,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	temp_0;
	IFNOT		temp_0,	15;
	STORE_F	pString,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	EQ_S		return_x,	pOldName,	temp_0;
	IFNOT		temp_0,	6;
	STORE_F	pString,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	STORE_F	pNewName,	parm2_x;
	CALL3		Util_SetAltStringItem;
	RETURN	return_x;
	ADD_F		lCounter,	KEY_MENU,	lCounter;
	GOTO		-15;
	STORE_F	"Property_Rename",	parm0_x;
	STORE_F	"The property "",	parm1_x;
	STORE_F	pOldName,	parm2_x;
	STORE_F	"" hasn't been declared!
pString = "",	parm3_x;
	STORE_F	pString,	parm4_x;
	STORE_F	""",	parm5_x;
	CALL6		dprint;
	RETURN	pString;
	DONE;
}

string(string pString, string pName) Property_Delete = asm
{
local float lCounter;
local float lCount;
local float temp_0;
	IF		FILE_APPEND,	2;
	RETURN	pString;
	STORE_F	pString,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	temp_0;
	IFNOT		temp_0,	19;
	STORE_F	pString,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	EQ_S		return_x,	pName,	temp_0;
	IFNOT		temp_0,	10;
	STORE_F	pString,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		Util_DelAltStringItem;
	STORE_S	return_x,	pString;
	STORE_F	pString,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		Util_DelAltStringItem;
	STORE_S	return_x,	pString;
	RETURN	pString;
	ADD_F		lCounter,	KEY_MENU,	lCounter;
	GOTO		-19;
	STORE_F	"Property_Delete",	parm0_x;
	STORE_F	"The property "",	parm1_x;
	STORE_F	pName,	parm2_x;
	STORE_F	"" hasn't been declared!
pString = "",	parm3_x;
	STORE_F	pString,	parm4_x;
	STORE_F	""",	parm5_x;
	CALL6		dprint;
	RETURN	pString;
	DONE;
}

string(string pString, string pName) Property_Get = asm
{
local float lCounter;
local float lCount;
local float temp_0;
	IF		FILE_APPEND,	2;
	RETURN	pString;
	STORE_F	pString,	parm0_x;
	CALL1		Util_GetAltStringCount;
	STORE_F	return_x,	lCount;
	STORE_F	KEY_GAME,	lCounter;
	LT		lCounter,	lCount,	temp_0;
	IFNOT		temp_0,	15;
	STORE_F	pString,	parm0_x;
	STORE_F	lCounter,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	EQ_S		return_x,	pName,	temp_0;
	IFNOT		temp_0,	6;
	ADD_F		lCounter,	FILE_APPEND,	temp_0;
	STORE_F	pString,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	CALL2		Util_GetAltStringItem;
	RETURN	return_x;
	ADD_F		lCounter,	KEY_MENU,	lCounter;
	GOTO		-15;
	STORE_F	"The property "",	parm0_x;
	STORE_F	pName,	parm1_x;
	STORE_F	"" hasn't been declared!
pString = "",	parm2_x;
	STORE_F	pString,	parm3_x;
	STORE_F	""",	parm4_x;
	CALL5		dprint;
	STORE_F	"",	parm0_x;
	CALL1		String_Zone;
	RETURN	return_x;
	DONE;
}

string(string pString, string pName) Property_GetString = asm
{
	STORE_F	pString,	parm0_x;
	STORE_F	pName,	parm1_x;
	CALL2		Property_Get;
	RETURN	return_x;
	DONE;
}

float(string pString, string pName) Property_GetFloat = asm
{
	STORE_F	pString,	parm0_x;
	STORE_F	pName,	parm1_x;
	CALL2		Property_Get;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	return_x,	parm0_x;
	CALL1		stof;
	RETURN	return_x;
	DONE;
}

vector(string pString, string pName) Property_GetVector = asm
{
	STORE_F	pString,	parm0_x;
	STORE_F	pName,	parm1_x;
	CALL2		Property_Get;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	return_x,	parm0_x;
	CALL1		stov;
	RETURN	return_x;
	DONE;
}

entity(string pString, string pName) Property_GetEntity = asm
{
	STORE_F	pString,	parm0_x;
	STORE_F	pName,	parm1_x;
	CALL2		Property_GetFloat;
	STORE_F	return_x,	parm0_x;
	CALL1		ftoe;
	RETURN	return_x;
	DONE;
}

vector(string pText, vector pLast) Util_GetEndOfLine = asm
{
local string lChar;
local float temp_0;
	STORE_F	pLast_y,	pLast_x;
	STORE_F	KEY_GAME,	pLast_z;
	STORE_F	pText,	parm0_x;
	STORE_F	pLast_x,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		substring;
	STORE_S	return_x,	lChar;
	EQ_S		lChar,	"
",	temp_0;
	IFNOT		temp_0,	5;
	ADD_F		pLast_x,	FILE_APPEND,	pLast_y;
	SUB_F		pLast_x,	FILE_APPEND,	pLast_x;
	RETURN	pLast_x;
	GOTO		9;
	EQ_S		lChar,	"",	temp_0;
	IFNOT		temp_0,	5;
	SUB_F		pLast_x,	FILE_APPEND,	pLast_x;
	STORE_F	pLast_x,	pLast_y;
	RETURN	pLast_x;
	GOTO		3;
	ADD_F		pLast_x,	FILE_APPEND,	pLast_x;
	ADD_F		pLast_z,	FILE_APPEND,	pLast_z;
	GOTO		-19;
	DONE;
}

vector(string pText, vector pLast, float pWrapLength) Util_GetEndOfWrappedLine = asm
{
local string lChar;
local float temp_0;
	STORE_F	pLast_y,	pLast_x;
	STORE_F	KEY_GAME,	pLast_z;
	STORE_F	pText,	parm0_x;
	STORE_F	pLast_x,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		substring;
	STORE_S	return_x,	lChar;
	EQ_S		lChar,	"
",	temp_0;
	IFNOT		temp_0,	5;
	SUB_F		pLast_x,	FILE_APPEND,	pLast_x;
	ADD_F		pLast_x,	KEY_MENU,	pLast_y;
	RETURN	pLast_x;
	GOTO		14;
	EQ_S		lChar,	"",	temp_0;
	IFNOT		temp_0,	5;
	SUB_F		pLast_x,	FILE_APPEND,	pLast_x;
	STORE_F	pLast_x,	pLast_y;
	RETURN	pLast_x;
	GOTO		8;
	ADD_F		pLast_x,	FILE_APPEND,	pLast_x;
	ADD_F		pLast_z,	FILE_APPEND,	pLast_z;
	SUB_F		pWrapLength,	FILE_APPEND,	pWrapLength;
	IF		pWrapLength,	4;
	STORE_F	pLast_x,	pLast_y;
	SUB_F		pLast_x,	FILE_APPEND,	pLast_x;
	RETURN	pLast_x;
	GOTO		-24;
	DONE;
}

float _m_uid_counter;
string() Util_CreateUID = asm
{
local string lName;
local float temp_0;
	STORE_F	_m_uid_counter,	parm0_x;
	CALL1		ftos;
	STORE_F	"M_UID_",	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		strzone;
	STORE_S	return_x,	lName;
	ADD_F		_m_uid_counter,	FILE_APPEND,	_m_uid_counter;
	RETURN	lName;
	DONE;
}

string(float pNum) Util_GetUIDName = asm
{
local string lName;
	STORE_F	pNum,	parm0_x;
	CALL1		ftos;
	STORE_F	"M_UID_",	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		strcat;
	STORE_F	return_x,	parm0_x;
	CALL1		strzone;
	STORE_S	return_x,	lName;
	RETURN	lName;
	DONE;
}

float(string pUid) Util_GetUIDNum = asm
{
local string lNum;
	STORE_F	pUid,	parm0_x;
	STORE_F	SLIST_SORTFIELD,	parm1_x;
	STORE_F	100000.000000,	parm2_x;
	CALL3		substring;
	STORE_S	return_x,	lNum;
	STORE_F	lNum,	parm0_x;
	CALL1		stof;
	RETURN	return_x;
	DONE;
}

string() String_Create = asm
{
	STORE_F	"",	parm0_x;
	CALL1		strzone;
	RETURN	return_x;
	DONE;
}

string(string pStr) String_Zone = asm
{
	STORE_F	pStr,	parm0_x;
	CALL1		strzone;
	RETURN	return_x;
	DONE;
}

string(string pStr) String_Normal = asm
{
local string lResult;
	STORE_F	pStr,	parm0_x;
	CALL1		strcat;
	STORE_S	return_x,	lResult;
	STORE_F	pStr,	parm0_x;
	CALL1		strunzone;
	RETURN	lResult;
	DONE;
}

string(string pStr) String_Free = asm
{
	STORE_F	pStr,	parm0_x;
	CALL1		strunzone;
	RETURN	"";
	DONE;
}

void(entity pEntity, .string pField) String_EntityCreate = asm
{
local float locked_1586;
	ADDRESS	pEntity,	pField,	locked_1586;
	STORE_F	"",	parm0_x;
	CALL1		strzone;
	STOREP_S	return_x,	locked_1586;
	DONE;
}

void(entity pEntity, .string pField) String_EntityZone = asm
{
local float locked_1586;
local float temp_1;
	ADDRESS	pEntity,	pField,	locked_1586;
	INDIRECT_S	pEntity,	pField,	parm0_x;
	CALL1		strzone;
	STOREP_S	return_x,	locked_1586;
	DONE;
}

void(entity pEntity, .string pField, string pSet) String_EntitySet = asm
{
local float locked_1586;
	INDIRECT_S	pEntity,	pField,	parm0_x;
	CALL1		strunzone;
	ADDRESS	pEntity,	pField,	locked_1586;
	STORE_F	pSet,	parm0_x;
	CALL1		strzone;
	STOREP_S	return_x,	locked_1586;
	DONE;
}

void(entity pEntity, .string pField) String_EntityFree = asm
{
local float temp_0;
	INDIRECT_S	pEntity,	pField,	parm0_x;
	CALL1		strunzone;
	ADDRESS	pEntity,	pField,	temp_0;
	STOREP_S	"",	temp_0;
	DONE;
}

string(string pStr, string pApp) String_Append = asm
{
	STORE_F	pStr,	parm0_x;
	STORE_F	pApp,	parm1_x;
	CALL2		strcat;
	STORE_F	pStr,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	RETURN	return_x;
	DONE;
}

string(string pStr, float pStart, float pLength) String_Substring = asm
{
	STORE_F	pStr,	parm0_x;
	STORE_F	pStart,	parm1_x;
	STORE_F	pLength,	parm2_x;
	CALL3		substring;
	STORE_F	return_x,	parm0_x;
	CALL1		strzone;
	RETURN	return_x;
	DONE;
}

string(string pStr, string pSet) String_Set = asm
{
	STORE_F	pStr,	parm0_x;
	CALL1		strunzone;
	STORE_F	pSet,	parm0_x;
	CALL1		strzone;
	RETURN	return_x;
	DONE;
}

bool(vector pPoint, vector pPos, vector pSize) Util_InRect = asm
{
local float temp_0;
local float temp_1;
	LT		pPoint_x,	pPos_x,	temp_0;
	IF		temp_0,	2;
	LT		pPoint_y,	pPos_y,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	3;
	ADD_F		pPos_x,	pSize_x,	temp_1;
	GT		pPoint_x,	temp_1,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IF		temp_0,	3;
	ADD_F		pPos_y,	pSize_y,	temp_1;
	GT		pPoint_y,	temp_1,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	KEY_GAME;
	RETURN	FILE_APPEND;
	DONE;
}

bool(vector pPos1, vector pSize1, vector pPos2, vector pSize2) Util_RectInRect = asm
{
local vector lFPos2;
local vector lFPos1;
local float temp_0;
local float temp_1;
local vector temp_2;
	ADD_V		pPos1,	pSize1,	lFPos1;
	ADD_V		pPos2,	pSize2,	lFPos2;
	LE		pPos1_x,	lFPos2_x,	temp_0;
	IFNOT		temp_0,	2;
	LE		pPos2_x,	lFPos1_x,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	2;
	LE		pPos1_y,	lFPos2_y,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	2;
	LE		pPos2_y,	lFPos1_y,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	KEY_GAME;
	RETURN	FILE_APPEND;
	DONE;
}

vector(vector pPoint, vector pClipPos, vector pClipSize) Util_GetClipDelta = asm
{
local vector lPoint;
local float temp_0;
	ADD_F		pClipPos_x,	pClipSize_x,	temp_0;
	STORE_F	pClipPos_x,	parm0_x;
	STORE_F	pPoint_x,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		bound;
	SUB_F		return_x,	pPoint_x,	lPoint_x;
	ADD_F		pClipPos_y,	pClipSize_y,	temp_0;
	STORE_F	pClipPos_y,	parm0_x;
	STORE_F	pPoint_y,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		bound;
	SUB_F		return_x,	pPoint_y,	lPoint_y;
	STORE_F	KEY_GAME,	lPoint_z;
	RETURN	lPoint_x;
	DONE;
}

vector(vector pPos, vector pSize, vector pClipPos, vector pClipSize) Util_ClipRect = asm
{
local vector lSize;
local float temp_0;
local float temp_1;
	ADD_F		pPos_x,	pSize_x,	temp_0;
	ADD_F		pClipPos_x,	pClipSize_x,	temp_1;
	STORE_F	temp_0,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		min;
	SUB_F		return_x,	pPos_x,	lSize_x;
	ADD_F		pPos_y,	pSize_y,	temp_0;
	ADD_F		pClipPos_y,	pClipSize_y,	temp_1;
	STORE_F	temp_0,	parm0_x;
	STORE_F	temp_1,	parm1_x;
	CALL2		min;
	SUB_F		return_x,	pPos_y,	lSize_y;
	STORE_F	KEY_GAME,	lSize_z;
	LE		lSize_x,	KEY_GAME,	temp_0;
	IF		temp_0,	2;
	LE		lSize_y,	KEY_GAME,	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	'0.000000 0.000000 0.000000';
	RETURN	lSize_x;
	DONE;
}

string(string pStack) Util_ClipStack_Reset = asm
{
	STORE_F	pStack,	parm0_x;
	CALL1		String_Free;
	CALL0		String_Create;
	RETURN	return_x;
	DONE;
}

string(string pStack, vector pPos, vector pSize) Util_ClipStack_Push = asm
{
local vector lDelta;
local vector lOldSize;
local vector lOldPos;
local float temp_0;
local float temp_1;
local vector temp_2;
	STORE_F	pStack,	parm0_x;
	CALL1		Util_ClipStack_GetPosition;
	STORE_V	return,	lOldPos;
	STORE_F	pStack,	parm0_x;
	CALL1		Util_ClipStack_GetSize;
	STORE_V	return,	lOldSize;
	EQ_V		pPos,	'0.000000 0.000000 0.000000',	temp_0;
	IFNOT		temp_0,	2;
	EQ_V		pSize,	'0.000000 0.000000 0.000000',	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	4;
	STORE_V	lOldPos,	pPos;
	STORE_V	lOldSize,	pSize;
	GOTO		19;
	NE_V		lOldPos,	'0.000000 0.000000 0.000000',	temp_0;
	IF		temp_0,	2;
	NE_V		lOldSize,	'0.000000 0.000000 0.000000',	temp_1;
	OR		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	14;
	STORE_V	pPos,	parm0;
	STORE_V	lOldPos,	parm1;
	STORE_V	lOldSize,	parm2;
	CALL3		Util_GetClipDelta;
	STORE_V	return,	lDelta;
	ADD_V		pPos,	lDelta,	pPos;
	SUB_V		pSize,	lDelta,	temp_2;
	STORE_V	pPos,	parm0;
	STORE_V	temp_2,	parm1;
	STORE_V	lOldPos,	parm2;
	STORE_V	lOldSize,	parm3;
	CALL4		Util_ClipRect;
	STORE_V	return,	pSize;
	STORE_V	pSize,	parm0;
	CALL1		vtos;
	STORE_F	pStack,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Util_AltStringPush;
	STORE_S	return_x,	pStack;
	STORE_V	pPos,	parm0;
	CALL1		vtos;
	STORE_F	pStack,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Util_AltStringPush;
	STORE_S	return_x,	pStack;
	RETURN	pStack;
	DONE;
}

string(string pStack) Util_ClipStack_Pop = asm
{
	STORE_F	pStack,	parm0_x;
	CALL1		Util_AltStringPop;
	STORE_S	return_x,	pStack;
	STORE_F	pStack,	parm0_x;
	CALL1		Util_AltStringPop;
	STORE_S	return_x,	pStack;
	RETURN	pStack;
	DONE;
}

vector(string pStack) Util_ClipStack_GetPosition = asm
{
	STORE_F	pStack,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	return_x,	parm0_x;
	CALL1		stov;
	RETURN	return_x;
	DONE;
}

vector(string pStack) Util_ClipStack_GetSize = asm
{
	STORE_F	pStack,	parm0_x;
	STORE_F	FILE_APPEND,	parm1_x;
	CALL2		Util_GetAltStringItem;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	return_x,	parm0_x;
	CALL1		stov;
	RETURN	return_x;
	DONE;
}

string(string pStack) Util_OriginStack_Reset = asm
{
	STORE_F	pStack,	parm0_x;
	CALL1		String_Free;
	CALL0		String_Create;
	RETURN	return_x;
	DONE;
}

string(string pStack, vector pOrigin) Util_OriginStack_Push = asm
{
	STORE_V	pOrigin,	parm0;
	CALL1		vtos;
	STORE_F	pStack,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		Util_AltStringPush;
	RETURN	return_x;
	DONE;
}

string(string pStack) Util_OriginStack_Pop = asm
{
	STORE_F	pStack,	parm0_x;
	CALL1		Util_AltStringPop;
	RETURN	return_x;
	DONE;
}

vector(string pStack) Util_OriginStack_Get = asm
{
	STORE_F	pStack,	parm0_x;
	CALL1		Util_GetAltStringTop;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Normal;
	STORE_F	return_x,	parm0_x;
	CALL1		stov;
	RETURN	return_x;
	DONE;
}

float(string pStr) Util_GetAltStringCount = asm
{
	STORE_F	pStr,	parm0_x;
	CALL1		altstr_count;
	RETURN	return_x;
	DONE;
}

string(string pStr, float pCount) Util_GetAltStringItem = asm
{
	STORE_F	pStr,	parm0_x;
	STORE_F	pCount,	parm1_x;
	CALL2		altstr_get;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	RETURN	return_x;
	DONE;
}

string(string pAlt, float pIndex, string pSet) Util_SetAltStringItem = asm
{
	STORE_F	pAlt,	parm0_x;
	STORE_F	pIndex,	parm1_x;
	STORE_F	pSet,	parm2_x;
	CALL3		altstr_set;
	STORE_F	pAlt,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	RETURN	return_x;
	DONE;
}

string(string pAlt, float pIndex) Util_DelAltStringItem = asm
{
local string lOut;
local string lLetter;
local float lLength;
local float lStart;
local float lPosition;
local float lCount;
local float temp_0;
local float temp_1;
	MUL_F		pIndex,	KEY_MENU,	temp_0;
	ADD_F		temp_0,	FILE_APPEND,	pIndex;
	STORE_F	KEY_GAME,	lPosition;
	STORE_F	KEY_GAME,	lCount;
	STORE_F	pAlt,	parm0_x;
	CALL1		strlen;
	STORE_F	return_x,	lLength;
	LT		lPosition,	lLength,	temp_0;
	IFNOT		temp_0,	2;
	LT		lCount,	pIndex,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	15;
	STORE_F	pAlt,	parm0_x;
	STORE_F	lPosition,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		substring;
	STORE_S	return_x,	lLetter;
	EQ_S		lLetter,	"'",	temp_0;
	IFNOT		temp_0,	3;
	ADD_F		lCount,	FILE_APPEND,	lCount;
	GOTO		4;
	EQ_S		lLetter,	"\",	temp_0;
	IFNOT		temp_0,	2;
	ADD_F		lPosition,	FILE_APPEND,	lPosition;
	ADD_F		lPosition,	FILE_APPEND,	lPosition;
	GOTO		-18;
	NE_F		lCount,	pIndex,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	pAlt;
	STORE_F	lPosition,	lStart;
	LT		lPosition,	lLength,	temp_0;
	IFNOT		temp_0,	16;
	STORE_F	pAlt,	parm0_x;
	STORE_F	lPosition,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		substring;
	STORE_S	return_x,	lLetter;
	EQ_S		lLetter,	"'",	temp_0;
	IFNOT		temp_0,	3;
	GOTO		8;
	GOTO		4;
	EQ_S		lLetter,	"\",	temp_0;
	IFNOT		temp_0,	2;
	ADD_F		lPosition,	FILE_APPEND,	lPosition;
	STORE_F	lPosition,	temp_1;
	ADD_F		lPosition,	FILE_APPEND,	lPosition;
	GOTO		-16;
	GT		lStart,	KEY_GAME,	temp_0;
	IFNOT		temp_0,	7;
	SUB_F		lStart,	FILE_APPEND,	temp_0;
	STORE_F	pAlt,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		substring;
	STORE_S	return_x,	lOut;
	SUB_F		lLength,	FILE_APPEND,	temp_0;
	LT		lPosition,	temp_0,	temp_0;
	IFNOT		temp_0,	12;
	ADD_F		lPosition,	FILE_APPEND,	temp_0;
	SUB_F		lLength,	lPosition,	temp_1;
	SUB_F		temp_1,	FILE_APPEND,	temp_1;
	STORE_F	pAlt,	parm0_x;
	STORE_F	temp_0,	parm1_x;
	STORE_F	temp_1,	parm2_x;
	CALL3		substring;
	STORE_F	lOut,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		strcat;
	STORE_S	return_x,	lOut;
	STORE_F	pAlt,	parm0_x;
	STORE_F	lOut,	parm1_x;
	CALL2		String_Set;
	RETURN	return_x;
	DONE;
}

string(string pAlt, float pIndex, string pSet) Util_InsAltStringItem = asm
{
	STORE_F	pAlt,	parm0_x;
	STORE_F	pIndex,	parm1_x;
	STORE_F	pSet,	parm2_x;
	CALL3		altstr_ins;
	STORE_F	pAlt,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	RETURN	return_x;
	DONE;
}

string(string pString) Util_AltStringPrepare = asm
{
	STORE_F	pString,	parm0_x;
	CALL1		altstr_prepare;
	STORE_F	return_x,	parm0_x;
	CALL1		String_Zone;
	RETURN	return_x;
	DONE;
}

string(string pAlt, string pPush) Util_AltStringPush = asm
{
	STORE_F	pPush,	parm0_x;
	CALL1		altstr_prepare;
	STORE_F	"'",	parm0_x;
	STORE_F	return_x,	parm1_x;
	STORE_F	"'",	parm2_x;
	STORE_F	pAlt,	parm3_x;
	CALL4		strcat;
	STORE_F	pAlt,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	RETURN	return_x;
	DONE;
}

string(string pAlt, string pPush) Util_AltStringPushBack = asm
{
	STORE_F	pPush,	parm0_x;
	CALL1		altstr_prepare;
	STORE_F	pAlt,	parm0_x;
	STORE_F	"'",	parm1_x;
	STORE_F	return_x,	parm2_x;
	STORE_F	"'",	parm3_x;
	CALL4		strcat;
	STORE_F	pAlt,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	RETURN	return_x;
	DONE;
}

string(string pAlt) Util_GetAltStringTop = asm
{
	STORE_F	pAlt,	parm0_x;
	STORE_F	KEY_GAME,	parm1_x;
	CALL2		Util_GetAltStringItem;
	RETURN	return_x;
	DONE;
}

string(string pAlt) Util_AltStringPop = asm
{
local string lChar;
local float lLength;
local float lCount;
local float lPos;
local float temp_0;
local float temp_1;
	STORE_F	KEY_GAME,	lCount;
	STORE_F	pAlt,	parm0_x;
	CALL1		strlen;
	STORE_F	return_x,	lLength;
	STORE_F	KEY_GAME,	lPos;
	LT		lPos,	lLength,	temp_0;
	IFNOT		temp_0,	2;
	LT		lCount,	KEY_MENU,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	18;
	STORE_F	pAlt,	parm0_x;
	STORE_F	lPos,	parm1_x;
	STORE_F	FILE_APPEND,	parm2_x;
	CALL3		substring;
	STORE_S	return_x,	lChar;
	EQ_S		lChar,	"\",	temp_0;
	IFNOT		temp_0,	4;
	STORE_F	lPos,	temp_0;
	ADD_F		lPos,	FILE_APPEND,	lPos;
	GOTO		5;
	EQ_S		lChar,	"'",	temp_0;
	IFNOT		temp_0,	3;
	STORE_F	lCount,	temp_0;
	ADD_F		lCount,	FILE_APPEND,	lCount;
	STORE_F	lPos,	temp_1;
	ADD_F		lPos,	FILE_APPEND,	lPos;
	GOTO		-21;
	SUB_F		lLength,	lPos,	temp_0;
	STORE_F	pAlt,	parm0_x;
	STORE_F	lPos,	parm1_x;
	STORE_F	temp_0,	parm2_x;
	CALL3		substring;
	STORE_F	pAlt,	parm0_x;
	STORE_F	return_x,	parm1_x;
	CALL2		String_Set;
	RETURN	return_x;
	DONE;
}

void() Util_NullFunction = asm
{
	DONE;
}

float() Util_TrueFunction = asm
{
	RETURN	FILE_APPEND;
	DONE;
}

float() Util_FalseFunction = asm
{
	RETURN	KEY_GAME;
	DONE;
}

string() Util_StringFuntion = asm
{
	RETURN	"";
	DONE;
}

vector() Util_VectorFunction = asm
{
	RETURN	'0.000000 0.000000 0.000000';
	DONE;
}

entity() Util_EntityFunction = asm
{
	RETURN	null_entity;
	DONE;
}

void () m_updategamestate;
void() m_updategamestate = asm
{
local float temp_0;
	STORE_F	KEY_GAME,	gamestatus;
	CALL0		isserver;
	IFNOT		return_x,	2;
	BITOR		gamestatus,	FILE_APPEND,	gamestatus;
	CALL0		clientstate;
	EQ_F		return_x,	KEY_MENU,	temp_0;
	IFNOT		temp_0,	2;
	BITOR		gamestatus,	KEY_MENU,	gamestatus;
	STORE_F	"developer",	parm0_x;
	CALL1		cvar;
	IFNOT		return_x,	2;
	BITOR		gamestatus,	CVAR_READONLY,	gamestatus;
	DONE;
}

void() m_init = asm
{
	CALL0		Gfx_Init;
	CALL0		Cursor_Init;
	CALL0		Key_Init;
	CALL0		HostCache_Init;
	CALL0		Menu_Init;
	DONE;
}

void(float pKey, float pAscii) m_keydown = asm
{
local float temp_0;
	IF		Menu_Active,	2;
	RETURN	offset_0;
	STORE_F	pKey,	parm0_x;
	STORE_F	pAscii,	parm1_x;
	CALL2		Menu_Key;
	DONE;
}

void () m_frame;
void() m_frame = asm
{
	CALL0		Timer_Update;
	CALL0		HostCache_Update;
	CALL0		Key_Update;
	CALL0		Gfx_Update;
	CALL0		Cursor_Update;
	CALL0		Menu_Frame;
	DONE;
}

void() m_draw = asm
{
local float temp_0;
local float temp_1;
	CALL0		m_updategamestate;
	IF		Menu_Active,	11;
	BITAND	gamestatus,	KEY_MENU,	temp_0;
	NOT_F		temp_0,	temp_0;
	IFNOT		temp_0,	3;
	BITAND	gamestatus,	CVAR_READONLY,	temp_1;
	NOT_F		temp_1,	temp_1;
	AND		temp_0,	temp_1,	temp_0;
	IFNOT		temp_0,	3;
	CALL0		m_display;
	GOTO		2;
	RETURN	offset_0;
	CALL0		m_frame;
	CALL0		Menu_Draw;
	CALL0		Cursor_Draw;
	CALL0		Gfx_Draw;
	DONE;
}

void() m_display = asm
{
	STORE_F	FILE_APPEND,	Menu_Active;
	CALL0		m_updategamestate;
	CALL0		Gfx_Display;
	CALL0		Cursor_Display;
	CALL0		Key_Display;
	CALL0		Menu_PerformReinit;
	DONE;
}

void() m_hide = asm
{
	CALL0		Gfx_Hide;
	CALL0		Cursor_Hide;
	CALL0		Key_Hide;
	CALL0		Menu_Hide;
	STORE_F	KEY_GAME,	Menu_Active;
	DONE;
}

void() m_toggle = asm
{
	CALL0		Timer_Update;
	IFNOT		Menu_Active,	3;
	CALL0		m_hide;
	GOTO		2;
	CALL0		m_display;
	DONE;
}

void() m_shutdown = asm
{
	CALL0		Timer_Update;
	CALL0		Menu_Shutdown;
	CALL0		Timer_Quit;
	CALL0		Key_Quit;
	CALL0		Cursor_Quit;
	CALL0		Gfx_Quit;
	STORE_F	KEY_GAME,	parm0_x;
	CALL1		setkeydest;
	STORE_F	KEY_MENU,	parm0_x;
	CALL1		setmousetarget;
	DONE;
}

void() ArrayGet*PARSER_TT_TEXT = asm
{
local float indexg___;
local float temp_0;
	BITAND	offset_2806,	offset_2806,	offset_2806;
	LT		offset_2806,	7.500000,	temp_0;
	IFNOT		temp_0,	24;
	LT		offset_2806,	3.500000,	temp_0;
	IFNOT		temp_0,	10;
	LT		offset_2806,	0.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT;
	LT		offset_2806,	ITEM_EDITBOX_SCROLLDISTANCE,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[1];
	LT		offset_2806,	2.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[2];
	LT		offset_2806,	3.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[3];
	LT		offset_2806,	4.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[4];
	LT		offset_2806,	5.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[5];
	LT		offset_2806,	6.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[6];
	LT		offset_2806,	10.500000,	temp_0;
	IFNOT		temp_0,	10;
	LT		offset_2806,	7.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[7];
	LT		offset_2806,	8.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[8];
	LT		offset_2806,	9.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[9];
	LT		offset_2806,	10.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[10];
	LT		offset_2806,	11.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[11];
	LT		offset_2806,	12.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[12];
	LT		offset_2806,	13.500000,	temp_0;
	IFNOT		temp_0,	2;
	RETURN	PARSER_TT_TEXT[13];
	RETURN	KEY_GAME;
	DONE;
}

