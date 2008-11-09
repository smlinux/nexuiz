#ifdef INTERFACE
CLASS(NexuizMutatorsDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizMutatorsDialog, toString, string(entity))
	METHOD(NexuizMutatorsDialog, fill, void(entity))
	METHOD(NexuizMutatorsDialog, showNotify, void(entity))
	METHOD(NexuizMutatorsDialog, close, void(entity))
	ATTRIB(NexuizMutatorsDialog, title, string, "Mutators")
	ATTRIB(NexuizMutatorsDialog, color, vector, SKINCOLOR_DIALOG_MUTATORS)
	ATTRIB(NexuizMutatorsDialog, intendedWidth, float, 0.8)
	ATTRIB(NexuizMutatorsDialog, rows, float, 15)
	ATTRIB(NexuizMutatorsDialog, columns, float, 6)
	ATTRIB(NexuizMutatorsDialog, refilterEntity, entity, NULL)
ENDCLASS(NexuizMutatorsDialog)
#endif

#ifdef IMPLEMENTATION
void showNotifyNexuizMutatorsDialog(entity me)
{
	loadAllCvars(me);
}

string weaponarenastring;
string weaponarenastring_cvar;
string WeaponArenaString()
{
	string s;
	float n, i, j;
	entity e;
	s = cvar_string("g_weaponarena");
	if(s == "0")
		return "";
	if(s == "all")
		return "All Weapons Arena";
	if(s == "most")
		return "Most Weapons Arena";
	if(s == weaponarenastring_cvar)
		return weaponarenastring;
	if(weaponarenastring)
		strunzone(weaponarenastring);
	if(weaponarenastring_cvar)
		strunzone(weaponarenastring_cvar);

	weaponarenastring_cvar = strzone(s);

	n = tokenize_sane(s);
	s = "";
	for(i = 0; i < n; ++i)
	{
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if(argv(i) == e.netname)
				s = strcat(s, " & ", e.message);
		}
	}
	s = strcat(substring(s, 3, strlen(s) - 3), " Arena");
	
	weaponarenastring = strzone(s);

	return weaponarenastring;
}

string toStringNexuizMutatorsDialog(entity me)
{
	string s;
	s = "";
	if(cvar("g_minstagib"))
		s = strcat(s, ", MinstaGib");
	if(cvar("g_nixnex"))
		s = strcat(s, ", NixNex");
	if(cvar_string("g_weaponarena") != "0")
		s = strcat(s, ", ", WeaponArenaString());
	if(cvar("sv_gravity") < 800)
		s = strcat(s, ", Low gravity");
	if(cvar("g_cloaked"))
		s = strcat(s, ", Cloaked");
	if(cvar("g_footsteps"))
		s = strcat(s, ", Steps");
	if(cvar("g_grappling_hook"))
		s = strcat(s, ", Hook");
	if(cvar("g_laserguided_missile"))
		s = strcat(s, ", LG missiles");
	if(cvar("g_midair"))
		s = strcat(s, ", Midair");
	if(cvar("g_vampire"))
		s = strcat(s, ", Vampire");
	if(s == "")
		return "None";
	else
		return substring(s, 2, strlen(s) - 2);
}
void fillNexuizMutatorsDialog(entity me)
{
	entity e, s, w;
	float i, j;
	string str, hstr;
	me.TR(me);
		me.TD(me, 1, 2, makeNexuizTextLabel(0, "Game mutators:"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_cloaked", "Cloaked"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_footsteps", "Footsteps"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_grappling_hook", "Grappling hook"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_laserguided_missile", "Laser guided missiles"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_midair", "Midair"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_vampire", "Vampire"));
	me.TR(me);
		s = makeNexuizSlider(80, 400, 8, "sv_gravity");
			s.valueDigits = 0;
			s.valueDisplayMultiplier = 0.125; // show gravity in percent
		me.TD(me, 1, 2, e = makeNexuizSliderCheckBox(800, 1, s, "Low gravity"));
			e.savedValue = 200; // good on silvercity
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, s);

	me.gotoRC(me, 0, 2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 4, makeNexuizTextLabel(0, "Weapon arenas:"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeNexuizRadioButton(1, string_null, string_null, "Regular (no arena)"));
	for(i = WEP_FIRST, j = 0; i <= WEP_LAST; ++i, ++j)
	{
		w = get_weaponinfo(i);
		if(j & 1 == 0)
			me.TR(me);
		str = w.netname;
		hstr = w.message;
		if not(w.spawnflags & WEPSPAWNFLAG_CANCLIMB)
		{
			str = strcat(str, " laser");
			hstr = strcat(hstr, " & Laser");
		}
		me.TD(me, 1, 2, e = makeNexuizRadioButton(1, "g_weaponarena", strzone(str), strzone(hstr)));
			e.cvarOffValue = "0";
	}
	me.TR(me);
		me.TD(me, 1, 4, makeNexuizTextLabel(0, "Special arenas:"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeNexuizRadioButton(1, "g_minstagib", string_null, "MinstaGib"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeNexuizRadioButton(1, "g_nixnex", string_null, "NixNex"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeNexuizCheckBox(1, "g_nixnex_with_laser", "with laser"));
			setDependent(e, "g_nixnex", 1, 1);
	me.TR(me);
		me.TD(me, 1, 4, e = makeNexuizRadioButton(1, "g_weaponarena", "all", "All weapons"));
			e.cvarOffValue = "0";

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNexuizButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void closeNexuizMutatorsDialog(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	closeDialog(me);
}
#endif
