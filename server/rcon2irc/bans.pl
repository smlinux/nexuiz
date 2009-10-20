# Nexuiz rcon2irc plugin by Merlijn Hofstra licensed under GPL - bans.pl
# Place this file inside the same directory as rcon2irc.pl and add the full filename to the plugins.

$store{plugin_bans}->{interval} = 300; #interval to displays bans

sub out ($$@);
sub schedule($$);

schedule sub {
	my ($timer) = @_;
	if ($store{plugin_bans}->{attempts}) {
		foreach (sort keys %{ $store{plugin_bans}->{attempts} }) {
			out irc => 0, "PRIVMSG $config{irc_channel} :\00305* banned client\017 \00304$_\017 was refused to connect \00304" .
				$store{plugin_bans}->{attempts}->{$_} . "\017 times";
		}
		$store{plugin_bans}->{attempts} = undef;
	}
	schedule $timer => $store{plugin_bans}->{interval};;
} => 1;

[ dp => q{(?:\^\d)?NOTE:(?:\^\d)? banned client (\d+\.\d+\.\d+\.\d+) just tried to enter} => sub {
	my ($ip) = @_;
	$store{plugin_bans}->{attempts}->{$ip} += 1;
	return 0;
} ],

[ dp => q{(?:\^\d)?NOTE:(?:\^\d)? banned client (.*) has to go} => sub {
	my ($name) = @_;
	$name = color_dp2irc $name;
	out irc => 0, "PRIVMSG $config{irc_channel} :\00305* banned client\017 $name\017 was removed from the server";
	return 0;
} ],
