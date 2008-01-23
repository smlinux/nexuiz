#ifdef INTERFACE
CLASS(NexuizMutatorsDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizMutatorsDialog, toString, string(entity))
	METHOD(NexuizMutatorsDialog, fill, void(entity))
	METHOD(NexuizMutatorsDialog, showNotify, void(entity))
	METHOD(NexuizMutatorsDialog, close, void(entity))
	ATTRIB(NexuizMutatorsDialog, title, string, "Mutators")
	ATTRIB(NexuizMutatorsDialog, color, vector, SKINCOLOR_DIALOG_MUTATORS)
	ATTRIB(NexuizMutatorsDialog, intendedWidth, float, 0.6)
	ATTRIB(NexuizMutatorsDialog, rows, float, 9)
	ATTRIB(NexuizMutatorsDialog, columns, float, 4)
	ATTRIB(NexuizMutatorsDialog, refilterEntity, entity, NULL)
ENDCLASS(NexuizMutatorsDialog)
#endif

#ifdef IMPLEMENTATION
void showNotifyNexuizMutatorsDialog(entity me)
{
        loadAllCvars(me);
}
string toStringNexuizMutatorsDialog(entity me)
{
	string s;
	s = "";
	if(cvar("g_instagib"))
		s = strcat(s, ", InstaGib");
	if(cvar("g_minstagib"))
		s = strcat(s, ", MinstaGib");
	if(cvar("g_nixnex"))
		s = strcat(s, ", NixNex");
	if(cvar("g_rocketarena"))
		s = strcat(s, ", RL arena");
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
		s = strcat(s, ", Mid-air");
	if(cvar("g_vampire"))
		s = strcat(s, ", Vampire");
	if(s == "")
		return "None";
	else
		return substring(s, 2, strlen(s) - 2);
}
void fillNexuizMutatorsDialog(entity me)
{
	entity e, s;
	me.TR(me);
		me.TD(me, 1, 2, makeNexuizTextLabel(0, "Game mutators:"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_cloaked", "Cloaked"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_footsteps", "Foot steps"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_grappling_hook", "Grappling hook"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_laserguided_missile", "Laser guided missiles"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_midair", "Mid-air"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "g_vampire", "Vampire"));

	me.gotoRC(me, 0, 2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 2, makeNexuizTextLabel(0, "Arena mutators:"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizRadioButton(1, string_null, string_null, "Regular"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizRadioButton(1, "g_instagib", string_null, "InstaGib"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizRadioButton(1, "g_minstagib", string_null, "MinstaGib"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizRadioButton(1, "g_nixnex", string_null, "NixNex"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeNexuizCheckBox(1, "g_nixnex_with_laser", "with laser"));
			setDependent(e, "g_nixnex", 1, 1);
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizRadioButton(1, "g_rocketarena", string_null, "Rocket launcher arena"));

	me.gotoRC(me, me.rows - 2, 0);
		s = makeNexuizSlider(80, 400, 8, "sv_gravity");
			s.valueDigits = 0;
			s.valueDisplayMultiplier = 0.125; // show gravity in percent
		me.TD(me, 1, 1, e = makeNexuizSliderCheckBox(800, 1, s, "Low gravity"));
			e.savedValue = 200; // good on silvercity
		me.TD(me, 1, 3, s);

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
