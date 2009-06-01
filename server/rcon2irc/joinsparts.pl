# Nexuiz rcon2irc plugin by Merlijn Hofstra licensed under GPL - joinsparts.pl
# Place this file inside the same directory as rcon2irc.pl and add the full filename to the plugins.
# Don't forget to edit the options below to suit your needs.

my %pj = (
	irc_announce_joins => 1,
	irc_announce_parts => 1,
	irc_show_playerip => 0,
	irc_show_mapname => 0,
	irc_show_amount_of_players => 0
);

$store{plugin_joinsparts} = \%pj;

sub out($$@);

sub get_player_count
{
	my $count = 0;
	for (1 .. $store{slots_max}) {
		my $id = $store{"playerid_byslot_$_"};
		$count++ if (defined $id && $store{"playerip_byid_$id"} ne 'bot');
	}
	return $count;
}

# chat: Nexuiz server -> IRC channel, nick set
[ dp => q{:join:(\d+):(\d+):([^:]*):(.*)} => sub {
	my ($id, $slot, $ip, $nick) = @_;
	my $pj = $store{plugin_joinsparts};
	$store{"playernickraw_byid_$id"} = $nick;
	$nick = color_dp2irc $nick;
	if ($pj->{irc_announce_joins} && !$store{"playerid_byslot_$slot"} && $ip ne 'bot') {
		out irc => 0, "PRIVMSG $config{irc_channel} :\00309+ join\017: $nick\017" . 
			($pj->{irc_show_playerip} ? " (\00304$ip\017)" : '') .
			($pj->{irc_show_mapname} ? " playing on \00304$store{map}\017" : '') .
			($pj->{irc_show_amount_of_players} ? " players: \00304" . (get_player_count()+1) . "\017/$store{slots_max}" : '');
	}
	return 0;
} ],
# Record parts so the info in $store is always up to date
[ dp => q{:part:(\d+)} => sub {
	my ($id) = @_;
	my $pj = $store{plugin_joinsparts};
	if ($pj->{irc_announce_parts} && defined $store{"playernick_byid_$id"} && $store{"playerip_byid_$id"} ne 'bot') {
		out irc => 0, "PRIVMSG $config{irc_channel} :\00304- part\017: " . $store{"playernick_byid_$id"} . "\017" . 
			($pj->{irc_show_playerip} ? " (\00304" . $store{"playerip_byid_$id"} . "\017)" : '') .
			($pj->{irc_show_mapname} ? " playing on \00304$store{map}\017" : '') .
			($pj->{irc_show_amount_of_players} ? " players: \00304" . (get_player_count()-1) . "\017/$store{slots_max}" : '');
	}
	my $slot = $store{"playerslot_byid_$id"};
	$store{"playernickraw_byid_$id"} = undef;
	$store{"playernick_byid_$id"} = undef;
	$store{"playerip_byid_$id"} = undef;
	$store{"playerslot_byid_$id"} = undef;
	$store{"playerid_byslot_$slot"} = undef;
	return 0;
} ],
