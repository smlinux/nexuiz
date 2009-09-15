# Nexuiz rcon2irc plugin by Merlijn Hofstra licensed under GPL - echo-rcon.pl
# Place this file inside the same directory as rcon2irc.pl and add the full filename to the plugins.

sub out($$@);

[ dp => q{server received rcon command from (.*):  (.*)} => sub {
	my ($origin, $cmd) = @_;
	return 0 if ($origin eq $config{dp_listen}); #do not relay rcon2irc commands
	my $origin = color_dp2irc $origin;
	out irc => 0, "PRIVMSG $config{irc_channel} :\00302* admin\017 command recieved from $origin: \00304$cmd\017";
	return 0;
} ],
