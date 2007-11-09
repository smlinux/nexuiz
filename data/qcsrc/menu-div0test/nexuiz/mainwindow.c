#ifdef INTERFACE
CLASS(MainWindow) EXTENDS(ModalController)
	METHOD(MainWindow, configureMainWindow, void(entity))
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
	entity dlg, n, i, b, c, mc, t1, t2, t3;

	n = spawnNexuizNexposee();
	me.addItem(me, n, '0 0 0', '1 1 0', 1);

	i = spawnNexuizTeamSelectDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, 1);

	i = spawnImage();
	i.configureImage(i, "gfx/0.tga");
	n.addItem(n, i, '0.4 0.45 0', '0.2 0.1 0', 1);
	n.setNexposee(n, i, '0.5 0.5 0', 0.5, 0.8);

	c = spawnInputContainer();

		i = spawnImage();
		i.configureImage(i, "gfx/0.tga");
		c.addItem(c, i, '0 0 0', '1 1 0', 1);

		mc = spawnModalController();
			b = spawnButton();
			b.configureButton(b, "1!", 12, "qcsrc/menu-div0test/basebutton");
			c.addItem(c, b, '0 0 0', '0.2 0.2 0', 1);
			i = spawnButton();
			i.configureButton(i, "Do not press this button!", 12, "qcsrc/menu-div0test/basebutton"); // click n gently with a chainsaw
				i.onClick = DemoButton_Click; i.onClickEntity = dlg;
			mc.addTab(mc, i, b);
			t1 = i;

			b = spawnButton();
			b.configureButton(b, "2!", 12, "qcsrc/menu-div0test/basebutton");
			c.addItem(c, b, '0.2 0 0', '0.2 0.2 0', 1);
			i = spawnButton();
			i.configureButton(i, "Close", 12, "qcsrc/menu-div0test/basebutton"); // click n plenty
				i.onClick = ExposeeCloseButton_Click; i.onClickEntity = n;
			mc.addTab(mc, i, b);
			t2 = i;

			b = spawnButton();
			b.configureButton(b, "3!", 12, "qcsrc/menu-div0test/basebutton");
			c.addItem(c, b, '0.4 0 0', '0.2 0.2 0', 1);
			i = spawnButton();
			i.configureButton(i, "Close", 12, "qcsrc/menu-div0test/basebutton"); // click n plenty
				i.onClick = ExposeeCloseButton_Click; i.onClickEntity = n;
			mc.addTab(mc, i, b);
			t3 = i;
		c.addItem(c, mc, '0 0.2 0', '1 0.8 0', 1);

	n.addItem(n, c, '0.03 0.06 0', '0.9 0.9 0', 0.5);
	n.setNexposee(n, c, '0.1 0.2 0', 0.5, 0.8);

	i = spawnNexuizSettingsDialog();
	i.configureDialog(i);
	n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, 1);
	n.setNexposee(n, i, '0.95 0.8 0', 0.5, 0.8);

	i = spawnNexuizMultiplayerDialog();
	i.configureDialog(i);
	n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, 1);
	n.setNexposee(n, i, '0.99 0.1 0', 0.5, 0.8);

	i = spawnImage();
	i.configureImage(i, "gfx/4.tga");
	n.addItem(n, i, '0.01 0.09 0', '0.9 0.9 0', 1);
	n.setNexposee(n, i, '0.1 0.9 0', 0.5, 0.8);

	me.initializeDialog(me, n);

}
#endif

// click. The C-word so you can grep for it.
