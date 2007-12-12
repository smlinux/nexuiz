#ifdef INTERFACE
CLASS(MainWindow) EXTENDS(ModalController)
	METHOD(MainWindow, configureMainWindow, void(entity))
	ATTRIB(MainWindow, mutatorsDialog, entity, NULL)
	ATTRIB(MainWindow, mapInfoDialog, entity, NULL)
ENDCLASS(MainWindow)
#endif

#ifdef IMPLEMENTATION

void DemoButton_Click(entity me, entity other)
{
	if(me.text == "Do not press this button again!")
		DialogOpenButton_Click(me, other);
	else
		me.setText(me, "Do not press this button again!");
}

void configureMainWindowMainWindow(entity me)
{
	entity n, i;

	i = spawnNexuizTeamSelectDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, 1);

	me.mutatorsDialog = i = spawnNexuizMutatorsDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, 1);

	me.mapInfoDialog = i = spawnNexuizMapInfoDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, 1);

	n = spawnNexuizNexposee();
		if(checkextension("DP_GECKO_SUPPORT"))
		{
			i = spawnNexuizNewsDialog();
			i.configureDialog(i);
			n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, 1);
			n.setNexposee(n, i, '0.1 0.1 0', 0.5, 0.8);
		}
		
		i = spawnNexuizSettingsDialog();
		i.configureDialog(i);
		n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, 1);
		n.setNexposee(n, i, '0.1 0.9 0', 0.5, 0.8);

		i = spawnNexuizMultiplayerDialog();
		i.configureDialog(i);
		n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, 1);
		n.setNexposee(n, i, '0.9 0.5 0', 0.5, 0.8);

		i = spawnNexuizQuitDialog();
		i.configureDialog(i);
		n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, 1);
		n.setNexposee(n, i, '0.9 1.2 0', 0.5, 0.8);
	me.addItem(me, n, '0 0 0', '1 1 0', 1);
	me.moveItemAfter(me, n, NULL);

	me.initializeDialog(me, n);
}
#endif

// click. The C-word so you can grep for it.
