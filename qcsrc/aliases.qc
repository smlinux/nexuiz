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

    self.hasaliases = TRUE;
};
