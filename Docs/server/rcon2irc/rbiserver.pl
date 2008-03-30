sub out($$@);

sub markmap($$$$;$)
{
	my ($state, $map, $pro, $total, $who) = @_;
	open my $fh, '>>', "$ENV{HOME}/.nexuiz/__votelog.$config{irc_nick}.txt"
		or die "votelog open: $!";
	print $fh "@{[time()]} $config{irc_nick} $state $map $pro $total" . (defined $who ? " $who" : "") . "\n";
	close $fh;
}

# call the log analyzer at the end of a match
[ dp => q{:end} => sub {
	system(q{
		for X in ~/Nexuiz/home/.nexuiz/extramaps/data/*.log; do
			if [ x"`tail -n 1 "$X"`" = x":gameover" ]; then
				ssh hector 'l=$HOME/.nexuiz/server-remote-$RANDOM.log; cat >"$l"; ~/.nexuiz/logspam/addlogs-processonly.sh "$l"' < "$X"
				rm -f "$X"
			fi
		done
	});
	return 0;
} ],

# the AOL calendar
[ dp => q{\001(.*?)\^7: d} => sub {
	my $aoltime = time() - 746748000;
	my $day = int($aoltime / 86400);
	my $wday = [qw[Tue Wed Thu Fri Sat Sun Mon]]->[$day % 7];
	my $hour = int($aoltime / 3600) % 24;
	my $minute = int($aoltime / 60) % 60;
	my $second = int($aoltime / 1) % 60;
	out dp => 0, sprintf 'rcon2irc_say_as "AOL service" "The time is %3s Sep %2d %02d:%02d:%02d 1993"',
		$wday, $day, $hour, $minute, $second;
	return 1;
} ],

# map vote logging
[ dp => q{:vote:suggestion_accepted:(.*)} => sub {
	my ($map) = @_;
	markmap suggestion_accepted => $map, $store{rbi_winvotes}, $store{rbi_totalvotes};
	return 0;
} ],
[ dp => q{:vote:suggested:(.*?):\d+:(.*)} => sub {
	my ($map, $who) = @_;
	markmap suggested => $map, 1, 1, $who;
	return 0;
} ],
[ dp => q{\001\^2\* .*'s vote for \^1gotomap (.*)\^2 was accepted} => sub {
	my ($map) = @_;
	markmap voted => $map, 1, 1;
	return 0;
} ],
[ dp => q{\001\^2\* .*'s vote for \^1timelimit -1\^2 was accepted} => sub {
	markmap cancelled => $store{map}, 1, 1;
	return 0;
} ],
[ dp => q{:vote:(keeptwo|finished):(.*)} => sub {
	my ($status, $result) = @_;
	my @result = split /:/, $result;
	my $totalvotes = 0;
	my $cutoff = -1;
	my @allmaps = map
	{
		$cutoff = $_ if $result[2*$_] eq '';
		$totalvotes += int($result[2*$_+1] || 0);
		[$result[2*$_], int($result[2*$_+1] || 0)]
	} 0..((@result-1)/2);
	die "Invalid vote result: $result" unless $cutoff >= 0;
	my @winners = @allmaps[0..($cutoff-1)];
	my @losers = @allmaps[($cutoff+1)..(@allmaps-1)];
	my $winvotes = 0;
	$winvotes += $_->[1] for @winners;
	if($status eq 'keeptwo')
	{
		markmap irrelevant_relative => $_->[0], $winvotes, $totalvotes
			for @losers;
	}
	elsif($status eq 'finished')
	{
		markmap((@losers == 1 ? 'duel_winner' : 'winner_absolute') => $_->[0], $_->[1], $totalvotes)
			for @winners;
		markmap((@losers == 1 ? 'duel_loser' : 'irrelevant_absolute') => $_->[0], $winvotes, $totalvotes)
			for @losers;
	}
	$store{rbi_winvotes} = $winvotes;
	$store{rbi_totalvotes} = $totalvotes;
	return 0;
} ],

# retrieve system load data
[ dp => q{timing:   (([0-9.]*)% CPU, ([0-9.]*)% lost, offset avg ([0-9.]*)ms, max ([0-9.]*)ms, sdev ([0-9.]*)ms)} => sub {
	my ($all, $cpu, $lost, $avg, $max, $sdev) = @_;
	return 0 # don't complain when just on the voting screen
		if !$store{playing};
	return 0 # don't complain if it was less than 0.5%
		if $lost < 0.5;
	return 0 # don't complain if nobody is looking
		if $store{slots_active} == 0;
	return 0 # don't complain in the first two minutes
		if time() - $store{map_starttime} < 120;
	return 0 # don't complain if it was already at least half as bad in this round
		if $store{map_starttime} == $store{timingerror_map_starttime} and $lost <= 2 * $store{timingerror_lost};
	$store{timingerror_map_starttime} = $store{map_starttime};
	$store{timingerror_lost} = $lost;
	out dp => 0, 'rcon2irc_say_as server "There are currently some severe system load problems. A log file has been written."';
	#my $subj = "slow $lost% on $store{slots_active}p $store{map} @{[int(time() - $store{map_starttime})]}s on $config{dp_server}";
	#system "{ echo '$subj'; echo '$cpu% CPU, $lost% lost, offset ms: $avg max $max sdev $sdev'; top -b -n 1; } | mail -s 'Nexuiz: $subj' divVerent\@alientrap.org";
	out irc => 1, "PRIVMSG $config{irc_channel} :\001ACTION has big trouble on $store{map} after @{[int(time() - $store{map_starttime})]}s: $all\001";
	out irc => 1, "PRIVMSG OpBaI :\001ACTION has big trouble on $store{map} after @{[int(time() - $store{map_starttime})]}s: $all\001";
	return 0;
} ],
