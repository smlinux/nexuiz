#ifdef INTERFACE
CLASS(NexuizNetworkSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizNetworkSettingsTab, fill, void(entity))
	ATTRIB(NexuizNetworkSettingsTab, title, string, "Network")
	ATTRIB(NexuizNetworkSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizNetworkSettingsTab, rows, float, 17)
	ATTRIB(NexuizNetworkSettingsTab, columns, float, 6.5)
ENDCLASS(NexuizNetworkSettingsTab)
entity makeNexuizNetworkSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizNetworkSettingsTab()
{
	entity me;
	me = spawnNexuizNetworkSettingsTab();
	me.configureDialog(me);
	return me;
}

void fillNexuizNetworkSettingsTab(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "cl_movement", "Client-side movement prediction"));
	me.TR(me);
		//me.TD(me, 1, 3, e = makeNexuizCheckBox(1, "cl_nolerp", "Network update smoothing"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "shownetgraph", "Show netgraph"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Network speed:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("_cl_rate"));
			e.addValue(e, "56k", "4000");
			e.addValue(e, "ISDN", "7000");
			e.addValue(e, "Slow ADSL", "15000");
			e.addValue(e, "Fast ADSL", "20000");
			e.addValue(e, "Broadband", "66666");
			e.configureNexuizTextSliderValues(e);
    me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Input packets/s:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(20, 100, 1, "cl_netfps"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizTextLabel(0, "HTTP downloads:"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Downloads:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(1, 5, 1, "cl_curl_maxdownloads"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Speed (kB/s):"));
		me.TD(me, 1, 2, e = makeNexuizSlider(10, 1500, 10, "cl_curl_maxspeed"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Client UDP port:"));
		me.TD(me, 1, 0.64, e = makeNexuizInputBox(0, "cl_port"));
}
#endif
