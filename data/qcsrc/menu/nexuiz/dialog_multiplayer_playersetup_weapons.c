#ifdef INTERFACE
CLASS(NexuizWeaponsDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizWeaponsDialog, toString, string(entity))
	METHOD(NexuizWeaponsDialog, fill, void(entity))
	METHOD(NexuizWeaponsDialog, showNotify, void(entity))
	ATTRIB(NexuizWeaponsDialog, title, string, "Weapon settings")
	ATTRIB(NexuizWeaponsDialog, color, vector, SKINCOLOR_DIALOG_WEAPONS)
	ATTRIB(NexuizWeaponsDialog, intendedWidth, float, 0.5)
	ATTRIB(NexuizWeaponsDialog, rows, float, 17)
	ATTRIB(NexuizWeaponsDialog, columns, float, 4)
	ATTRIB(NexuizWeaponsDialog, weaponsList, entity, NULL)
ENDCLASS(NexuizWeaponsDialog)
#endif

#ifdef IMPLEMENTATION
void showNotifyNexuizWeaponsDialog(entity me)
{
        loadAllCvars(me);
}
string toStringNexuizWeaponsDialog(entity me)
{
	return me.weaponsList.toString(me.weaponsList);
}
void fillNexuizWeaponsDialog(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 4, makeNexuizTextLabel(0, "Weapon priority list:"));
	me.TR(me);
		me.TD(me, 9, 4, e = me.weaponsList = makeNexuizWeaponsList());
	me.gotoRC(me, 10, 0);
		me.TDempty(me, 1);
		me.TD(me, 1, 1, e = makeNexuizButton("Up", '0 0 0'));
			e.onClick = WeaponsList_MoveUp_Click;
			e.onClickEntity = me.weaponsList;
		me.TD(me, 1, 1, e = makeNexuizButton("Down", '0 0 0'));
			e.onClick = WeaponsList_MoveDown_Click;
			e.onClickEntity = me.weaponsList;
	me.gotoRC(me, 11, 0);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "cl_weaponpriority_useforcycling", "Use priority list for weapon cycling"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "cl_autoswitch", "Auto switch weapons on pickup"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "r_drawviewmodel", "Draw 1st person weapon model"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_gunalign", "4", "Left align"));
			setDependent(e, "r_drawviewmodel", 1, 1);
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_gunalign", "3", "Right align"));
			setDependent(e, "r_drawviewmodel", 1, 1);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "v_flipped", "Flip view horizontally"));
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNexuizButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
