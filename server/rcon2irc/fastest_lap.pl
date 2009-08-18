sub out($$@);
use POSIX qw(ceil floor);
	# chat: Nexuiz server -> IRC channel, fastest record in nexrun and ctf
	[ dp => q{:recordset:(\d+):(.*)} => sub {
		my ($id, $record) = @_;
		my $recordnick = $id ? $store{"playernick_byid_$id"} : "(console)";
		my $minutes = $record/60;
		my $seconds = $record%60;
		my $ms = int(($record - floor($record))*1000000);
		my $time;
		if($seconds < 1) {
			$time = "\003040:0.$ms";
		} elsif($minutes < 1) {
			$time = "\003040:$seconds.$ms";
		} else {
			$time = "\00304$minutes:$seconds.$ms";
		}
		my $mapname = $store{"map"};
		if ($mapname =~ m/^ctf_/) {
			out irc => 0, "PRIVMSG $config{irc_channel} :* \00304$recordnick\017 set the \00304all-time fastest flag capture \00304record\017 with $time ($mapname)";
		} else {
			out irc => 0, "PRIVMSG $config{irc_channel} :* \00304$recordnick\017 set the \00304all-time fastest lap \00304record\017 with $time ($mapname)";
		}
		return 0;
	} ],
