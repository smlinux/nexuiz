void AddAlias(entity client, string alias, string command) {
    stuffcmd(client, "alias ");
    stuffcmd(client, alias);
    stuffcmd(client, " \"");
    stuffcmd(client, command);
    stuffcmd(client, "\"\n");
};

void AddImpulse(entity client, string alias, float imp) {
    stuffcmd(client, "alias ");
    stuffcmd(client, alias);
    stuffcmd(client, " \"impulse ");
    stuffcmd(client, ftos(imp));
    stuffcmd(client, "\"\n");
};

void DoAliases() {
    if (self.hasaliases)
	return;

    AddImpulse(self, "+crouch", 37);
    AddImpulse(self, "-crouch", 38);
    AddImpulse(self, "bot_add", 100);
    AddImpulse(self, "bot_add2", 101);
    AddImpulse(self, "bot_kick", 102);
    AddImpulse(self, "bot_cam", 102);
    AddImpulse(self, "bot_wayedit", 102);

    self.hasaliases = TRUE;
};
