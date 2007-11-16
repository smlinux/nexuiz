#ifdef INTERFACE
CLASS(NexuizMutatorsDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizMutatorsDialog, fill, void(entity))
	METHOD(NexuizMutatorsDialog, showNotify, void(entity))
	ATTRIB(NexuizMutatorsDialog, title, string, "Mutators")
	ATTRIB(NexuizMutatorsDialog, color, vector, SKINCOLOR_DIALOG_MUTATORS)
	ATTRIB(NexuizMutatorsDialog, intendedWidth, float, 0.6)
	ATTRIB(NexuizMutatorsDialog, rows, float, 8)
	ATTRIB(NexuizMutatorsDialog, columns, float, 4)
ENDCLASS(NexuizMutatorsDialog)
#endif

#ifdef IMPLEMENTATION
void showNotifyNexuizMutatorsDialog(entity me)
{
        loadAllCvars(me);
}
void fillNexuizMutatorsDialog(entity me)
{
	entity e;
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

	me.gotoXY(me, 0, 2); me.setFirstColumn(me, me.currentColumn);
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

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNexuizButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
