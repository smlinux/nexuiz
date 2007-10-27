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
	entity dlg, n, i, b, c, mc, t1, t2, t3, cb;

	n = spawnNexposee();
	me.addItem(me, n, '0 0 0', '1 1 0', 1);

	dlg = spawnInputContainer();
		cb = spawnButton();
		cb.configureButton(cb, "", 12, "qcsrc/menu-div0test/baseclosebutton");
		cb.onClick = DialogCloseButton_Click; cb.onClickEntity = dlg;
		cb.srcMulti = 0;

		i = spawnBorderImage();
		i.configureBorderImage(i, "I told you...", 18, '0.5 0.5 1', "qcsrc/menu-div0test/baseborder", 1.5);
		i.closeButton = cb;
		dlg.addItem(dlg, i, '0 0 0', '1 1 0', 1);

		i = spawnLabel();
		i.configureLabel(i, "Swim swim hungry, swim swim hungry...", 10, 0.5);
		dlg.addItem(dlg, i, '0 0.3 0', '1 0.1 0', 1);

		i = spawnRadioButton();
		i.configureRadioButton(i, "RadioButton1", 12, "qcsrc/menu-div0test/baseradiobutton", 1, 0);
		dlg.addItem(dlg, i, '0.1 0.4 0', '0.4 0.1 0', 1);

		i = spawnRadioButton();
		i.configureRadioButton(i, "RadioButton2", 12, "qcsrc/menu-div0test/baseradiobutton", 1, 1);
		dlg.addItem(dlg, i, '0.5 0.4 0', '0.8 0.1 0', 1);

		i = spawnSlider();
		i.configureSliderVisuals(i, "", " fps", 12, 0.2, "qcsrc/menu-div0test/baseslider");
		i.configureSliderValues(i, 1, 50, 200, 1, 1, 20);
		dlg.addItem(dlg, i, '0.1 0.5 0', '0.8 0.1 0', 1);

		i = spawnCheckBox();
		i.configureCheckBox(i, "Do not show this dialog again", 12, "qcsrc/menu-div0test/basecheckbox");
		i.checked = 1;
		dlg.addItem(dlg, i, '0.1 0.6 0', '0.8 0.1 0', 1);

		i = spawnButton();
		i.configureButton(i, "Close", 12, "qcsrc/menu-div0test/basebutton");
		i.onClick = DialogCloseButton_Click; i.onClickEntity = dlg;
		dlg.addItem(dlg, i, '0.3 0.7 0', '0.4 0.2 0', 1);

		dlg.addItem(dlg, cb, '0.3 0.7 0', '0.4 0.2 0', 1);
	me.addItem(me, dlg, '0.2 0.3 0', '0.6 0.4 0', 1);
	
	i = spawnTeamSelectDialog();
	i.configureDialog(i);
	me.addItem(me, i, ('1 1 0' - i.intendedWidth * eX - i.intendedHeight * eY) * 0.5, i.intendedWidth * eX + i.intendedHeight * eY, 1);

	i = spawnImage();
	i.configureImage(i, "gfx/0.tga");
	n.addItem(n, i, '0.4 0.45 0', '0.2 0.1 0', 1);
	n.setNexposee(n, i, '0.5 0.5 0', 0.2, 0.5);
	
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
	n.setNexposee(n, c, '0.1 0.2 0', 0.2, 0.5);
	
	i = spawnImage();
	i.configureImage(i, "gfx/2.tga");
	n.addItem(n, i, '0.04 0.01 0', '0.9 0.9 0', 1);
	n.setNexposee(n, i, '0.95 0.8 0', 0.2, 0.5);
	
	i = spawnImage();
	i.configureImage(i, "gfx/3.tga");
	n.addItem(n, i, '0.02 0.03 0', '0.9 0.9 0', 1);
	n.setNexposee(n, i, '0.99 0.1 0', 0.2, 0.5);
	
	i = spawnImage();
	i.configureImage(i, "gfx/4.tga");
	n.addItem(n, i, '0.01 0.09 0', '0.9 0.9 0', 1);
	n.setNexposee(n, i, '0.1 0.9 0', 0.2, 0.5);

	me.initializeDialog(me, n);

}
#endif

// click. The C-word so you can grep for it.
