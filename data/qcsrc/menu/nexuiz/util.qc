void forAllDescendants(entity root, void(entity, entity) funcPre, void(entity, entity) funcPost, entity pass)
{
	depthfirst(root, parent, firstChild, nextSibling, funcPre, funcPost, pass);
}

.string cvarName;
void SUB_Null_ee(entity e1, entity e2)
{
}
void saveCvarsOf(entity ignore, entity e)
{
	if(e.cvarName)
		e.saveCvars(e);
}
void loadCvarsOf(entity ignore, entity e)
{
	if(e.cvarName)
		e.loadCvars(e);
}
void saveAllCvars(entity root)
{
	forAllDescendants(root, saveCvarsOf, SUB_Null_ee, NULL);
}
void loadAllCvars(entity root)
{
	forAllDescendants(root, loadCvarsOf, SUB_Null_ee, NULL);
}

.void(entity) draw_setDependent;
.string cvar_setDependent;
.float cvarMin_setDependent;
.float cvarMax_setDependent;
.string cvar2_setDependent;
.float cvar2Min_setDependent;
.float cvar2Max_setDependent;
.float op_setDependent;
void setDependent_Check(entity e)
{
	float f;
	f = cvar(e.cvar_setDependent);
	if(e.cvarMin_setDependent <= e.cvarMax_setDependent)
		e.disabled = ((f < e.cvarMin_setDependent) || (f > e.cvarMax_setDependent));
	else
		e.disabled = ((f >= e.cvarMax_setDependent) && (f <= e.cvarMin_setDependent));
	if(e.cvar2_setDependent)
	{
		f = cvar(e.cvar2_setDependent);
		if(e.cvar2Min_setDependent <= e.cvar2Max_setDependent)
			e.disabled = (e.disabled + ((f < e.cvar2Min_setDependent) || (f > e.cvar2Max_setDependent)) > e.op_setDependent);
		else
			e.disabled = (e.disabled + ((f >= e.cvar2Max_setDependent) && (f <= e.cvar2Min_setDependent)) > e.op_setDependent);
	}
}
void setDependent_Draw(entity e)
{
	setDependent_Check(e);
	e.draw_setDependent(e);
}
void setDependent(entity e, string theCvarName, float theCvarMin, float theCvarMax)
{
	e.draw_setDependent = e.draw;
	e.cvar_setDependent = theCvarName;
	e.cvarMin_setDependent = theCvarMin;
	e.cvarMax_setDependent = theCvarMax;
	e.cvar2_setDependent = string_null;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}
void setDependentAND(entity e, string theCvarName, float theCvarMin, float theCvarMax, string theCvar2Name, float theCvar2Min, float theCvar2Max)
{
	e.draw_setDependent = e.draw;
	e.cvar_setDependent = theCvarName;
	e.cvarMin_setDependent = theCvarMin;
	e.cvarMax_setDependent = theCvarMax;
	e.cvar2_setDependent = theCvar2Name;
	e.cvar2Min_setDependent = theCvar2Min;
	e.cvar2Max_setDependent = theCvar2Max;
	e.op_setDependent = 0;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}
void setDependentOR(entity e, string theCvarName, float theCvarMin, float theCvarMax, string theCvar2Name, float theCvar2Min, float theCvar2Max)
{
	e.draw_setDependent = e.draw;
	e.cvar_setDependent = theCvarName;
	e.cvarMin_setDependent = theCvarMin;
	e.cvarMax_setDependent = theCvarMax;
	e.cvar2_setDependent = theCvar2Name;
	e.cvar2Min_setDependent = theCvar2Min;
	e.cvar2Max_setDependent = theCvar2Max;
	e.op_setDependent = 1;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}

// EXTRESPONSE SYSTEM ////////////////////////////////////////////////////////

float _Nex_ExtResponseSystem_RequestsSent;
float _Nex_ExtResponseSystem_VersionHandled;
string _Nex_ExtResponseSystem_UpdateTo;
float _Nex_ExtResponseSystem_RetryTime;
float _Nex_ExtResponseSystem_RetryTime_LastDelay;

void() Item_Nex_ExtResponseSystem_SendQuery =
{
	dprint("Sending extended response requests...\n");
	localcmd(strcat("packet update.alientrap.org:27950 \"getExtResponse checkUpdates nexuiz ", cvar_string("g_nexuizversion"), "\"\n"));
	_Nex_ExtResponseSystem_RequestsSent = TRUE;
	_Nex_ExtResponseSystem_RetryTime_LastDelay = _Nex_ExtResponseSystem_RetryTime_LastDelay * 2 + 1;
	_Nex_ExtResponseSystem_RetryTime = time + _Nex_ExtResponseSystem_RetryTime_LastDelay;
}

void(float argc) Item_Nex_ExtResponseSystem_Parse =
{
	dprint("Received extended response packet from ", argv(0), "\n");
	if(!_Nex_ExtResponseSystem_RequestsSent)
	{
		dprint("  But I haven't sent a request yet! Ignoring.\n");
		return;
	}
	if(argv(1) == "noUpdateAvailable")
	{
		if(_Nex_ExtResponseSystem_VersionHandled)
		{
			dprint("  duplicated update notice, ignored\n");
			return;
		}
		_Nex_ExtResponseSystem_VersionHandled = 1;
	}
	else if(argv(1) == "updateAvailable")
	{
		if(_Nex_ExtResponseSystem_VersionHandled)
		{
			dprint("  duplicated update notice, ignored\n");
			return;
		}
		_Nex_ExtResponseSystem_VersionHandled = 1;
		_Nex_ExtResponseSystem_UpdateTo = strzone(argv(2)); // note: only one packet can be handled, so this can't be a leak
	}
	else
		dprint("  UNKNOWN RESPONSE TYPE: ", argv(1), "\n");
}

void() Item_Nex_ExtResponseSystem_CheckForResponse =
{
	local string s;
	local float argc;
	while(strlen((s = getextresponse())))
	{
		argc = tokenize(s);
		Item_Nex_ExtResponseSystem_Parse(argc);
	}
}

// END OF EXTRESPONSE SYSTEM /////////////////////////////////////////////////

float nMenuInitDots;
float preMenuInit()
{
	string s;
	float i, w, sz;

	MapInfo_Cache_Create();
	MapInfo_Enumerate();
	if(!MapInfo_FilterGametype(MAPINFO_TYPE_ALL, 0, 1))
	{
		nMenuInitDots = nMenuInitDots + 1;
		s = "Generating mapinfo..";
		for(i = 0; i < nMenuInitDots; ++i)
			s = strcat(s, ".");
		draw_reset();

		w = draw_TextWidth(s, 0);
		sz = min(0.025, 1 / w);
		draw_CenterText(eX * 0.5 + eY * 0.5, s, eX * sz + eY * sz * (draw_scale_x / draw_scale_y), '1 1 1', 1, 0);

		return FALSE;
	}
	return TRUE;
}

string campaign_name_previous;
float campaign_won_previous;
void postMenuDraw()
{
}
void preMenuDraw()
{
	vector fs, sz, line, mid;
	Item_Nex_ExtResponseSystem_CheckForResponse();
	if(!_Nex_ExtResponseSystem_VersionHandled)
		if(time > _Nex_ExtResponseSystem_RetryTime)
			Item_Nex_ExtResponseSystem_SendQuery();

	if(_Nex_ExtResponseSystem_UpdateTo != "")
	{
		fs = ((1/draw_scale_x) * eX + (1/draw_scale_y) * eY) * 12;
		line = eY * fs_y;
		sz_x = draw_TextWidth("  http://www.nexuiz.com/  ", 0) * fs_x;
		sz_y = 3 * fs_y;

		draw_alpha = sin(time * 0.112 - 0.3) * 0.7;
		mid = eX * (0.5 + 0.5 * (1 - sz_x) * cos(time * 0.071))
		    + eY * (0.5 + 0.5 * (1 - sz_y) * sin(time * 0.071));

		draw_Fill(mid - 0.5 * sz, sz, '1 1 0', 1);
		draw_CenterText(mid - 1 * line, strcat("Update to ", _Nex_ExtResponseSystem_UpdateTo, " now!"), fs, '1 0 0', 1, 0);
		draw_CenterText(mid - 0 * line, "http://www.nexuiz.com/", fs, '0 0 1', 1, 0);
	}
	if not(campaign_name_previous)
		campaign_name_previous = strzone(strcat(campaign_name, "x")); // force unequal
	if(campaign_name == campaign_name_previous)
	{
		if(cvar(strcat("g_campaign", campaign_name, "_won")))
		{
			if(!campaign_won_previous)
			{
				m_display();
				DialogOpenButton_Click_withCoords(NULL, main.winnerDialog, '0 0 0', eX * conwidth + eY * conheight);
			}
			campaign_won_previous = 1;
		}
		else
			campaign_won_previous = 0;
	}
	else
	{
		strunzone(campaign_name_previous);
		campaign_name_previous = strzone(campaign_name);
		campaign_won_previous = cvar(strcat("g_campaign", campaign_name, "_won"));
	}
}
