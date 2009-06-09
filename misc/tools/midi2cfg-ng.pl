#!/usr/bin/perl

# converter from Type 1 MIDI files to CFG files that control bots with the Tuba and other weapons for percussion (requires g_weaponarena all)
# usage:
#   perl midi2cfg.pl filename.mid basenote walktime "x y z" "x y z" "x y z" ... "/" "x y z" "x y z" ... > filename.cfg

use strict;
use warnings;
use MIDI;
use MIDI::Opus;
use Storable;

use constant MIDI_FIRST_NONCHANNEL => 17;
use constant MIDI_DRUMS_CHANNEL => 10;

my ($filename, $transpose, $timeoffset) = @ARGV;

my $opus = MIDI::Opus->new({from_file => $filename});
#$opus->write_to_file("/tmp/y.mid");
my $ticksperquarter = $opus->ticks();
my $tracks = $opus->tracks_r();
my @tempi = (); # list of start tick, time per tick pairs (calculated as seconds per quarter / ticks per quarter)
my $tick;

$tick = 0;
for($tracks->[0]->events())
{   
    $tick += $_->[1];
    if($_->[0] eq 'set_tempo')
    {   
        push @tempi, [$tick, $_->[2] * 0.000001 / $ticksperquarter];
    }
}
sub tick2sec($)
{
    my ($tick) = @_;
    my $sec = 0;
    my $curtempo = [0, 0.5 / $ticksperquarter];
    for(@tempi)
    {
        if($_->[0] < $tick)
        {
			# this event is in the past
			# we add the full time since the last one then
			$sec += ($_->[0] - $curtempo->[0]) * $curtempo->[1];
        }   
        else
        {
			# if this event is in the future, we break
			last;
        }
		$curtempo = $_;
    }
	$sec += ($tick - $curtempo->[0]) * $curtempo->[1];
	return $sec;
}

# merge all to a single track
my @allmidievents = ();
my $sequence = 0;
for my $track(0..@$tracks-1)
{
	$tick = 0;
	for($tracks->[$track]->events())
	{
		my ($command, $delta, @data) = @$_;
		$tick += $delta;
		push @allmidievents, [$command, $tick, $sequence++, $track, @data];
	}
}
@allmidievents = sort { $a->[1] <=> $b->[1] or $a->[2] <=> $b->[2] } @allmidievents;






sub botconfig_read($)
{
	my ($fn) = @_;
	my %bots = ();
	open my $fh, "<", $fn
		or die "<$fn: $!";
	
	my $currentbot = undef;
	my $appendref = undef;
	my $super = undef;
	while(<$fh>)
	{
		chomp;
		s/\s*#.*//;
		next if /^$/;
		if(s/^\t\t//)
		{
			my @cmd = split /\s+/, $_;
			if($cmd[0] eq 'super')
			{
				push @$appendref, @$super;
			}
			else
			{
				push @$appendref, \@cmd;
			}
		}
		elsif(s/^\t//)
		{
			if(/^include (.*)/)
			{
				my $base = $bots{$1};
				for(keys %$base)
				{
					if(ref $base->{$_})
					{
						$currentbot->{$_} = Storable::dclone $base->{$_}; # copy array items as new array
					}
					else
					{
						$currentbot->{$_} = $base->{$_};
					}
				}
				# better: do some merging TODO
			}
			elsif(/^count (\d+)/)
			{
				$currentbot->{count} = $1;
			}
			elsif(/^transpose (\d+)/)
			{
				$currentbot->{transpose} += $1;
			}
			elsif(/^channels (.*)/)
			{
				$currentbot->{channels} = { map { $_ => 1 } split /\s+/, $1 };
			}
			elsif(/^init$/)
			{
				$super = $currentbot->{init};
				$currentbot->{init} = $appendref = [];
			}
			elsif(/^note on (-?\d+)/)
			{
				$super = $currentbot->{notes_on}->{$1};
				$currentbot->{notes_on}->{$1} = $appendref = [];
			}
			elsif(/^note off (-?\d+)/)
			{
				$super = $currentbot->{notes_off}->{$1};
				$currentbot->{notes_off}->{$1} = $appendref = [];
			}
			elsif(/^percussion (\d+)/)
			{
				$super = $currentbot->{percussion}->{$1};
				$currentbot->{percussion}->{$1} = $appendref = [];
			}
			else
			{
				print "unknown command: $_\n";
			}
		}
		elsif(/^bot (.*)/)
		{
			$currentbot = ($bots{$1} ||= {});
		}
		else
		{
			print "unknown command: $_\n";
		}
	}

	my $lowesttimeoffset = 0;
	for(values %bots)
	{
		my $l = $_->{init};
		next unless defined $l;
		next unless $l->[0]->[0] eq 'time';
		my $t = $l->[0]->[1];
		$lowesttimeoffset = $t
			if $t < $lowesttimeoffset;
	}
	print STDERR "Using a time adjustment of $lowesttimeoffset\n";
	$timeoffset -= $lowesttimeoffset;

	return \%bots;
}

sub busybot_cmd_bot_test($$@)
{
	my ($bot, $time, @commands) = @_;

	my $bottime = defined $bot->{timer} ? $bot->{timer} : -$timeoffset-1;
	my $botbusytime = defined $bot->{busytimer} ? $bot->{busytimer} : -$timeoffset-1;

	return 0
		if $time < $botbusytime;
	
	my $mintime = (@commands && ($commands[0]->[0] eq 'time')) ? $commands[0]->[1] : 0;

	return 0
		if $time + $mintime < $bottime;
	
	return 1;
}

sub busybot_cmd_bot_execute($$@)
{
	my ($bot, $time, @commands) = @_;

	for(@commands)
	{
		if($_->[0] eq 'time')
		{
			printf "w %d %f\n", $bot->{id}, $time + $_->[1] + $timeoffset;
			$bot->{timer} = $time + $_->[1];
		}
		elsif($_->[0] eq 'busy')
		{
			$bot->{busytimer} = $time + $_->[1];
		}
		elsif($_->[0] eq 'buttons')
		{
			my %buttons_release = %{$bot->{buttons} ||= {}};
			for(@{$_}[1..@$_-1])
			{
				/(.*)\??/ or next;
				delete $buttons_release{$1};
			}
			for(keys %buttons_release)
			{
				printf "r %d %s\n", $bot->{id}, $_;
				delete $bot->{buttons}->{$_};
			}
			for(@{$_}[1..@$_-1])
			{
				/(.*)(\?)?/ or next;
				defined $2 and next;
				printf "p %d %s\n", $bot->{id}, $_;
				$bot->{buttons}->{$_} = 1;
			}
		}
		elsif($_->[0] eq 'cmd')
		{
			printf "sv_cmd bot_cmd %d %s\n", $bot->{id}, join " ", @{$_}[1..@$_-1];
		}
	}

	return 1;
}

sub busybot_note_off_bot($$$$)
{
	my ($bot, $time, $channel, $note) = @_;
	my $cmds = $bot->{notes_off}->{$note - $bot->{transpose} - $transpose};
	return 1
		if not defined $cmds; # note off cannot fail
	busybot_cmd_bot_execute $bot, $time, @$cmds; 
	return 1;
}

sub busybot_note_on_bot($$$$$)
{
	my ($bot, $time, $channel, $note, $init) = @_;
	return -1 # I won't play on this channel
		if defined $bot->{channels} and not grep { $_ == $channel } $bot->{channels};
	my $cmds = $bot->{notes_on}->{$note - $bot->{transpose} - $transpose};
	if(not defined $cmds)
	{
		$cmds = $bot->{percussion}->{$note};
		return -1 # I won't play this note
			if not defined $cmds;
	}
	if($init && $bot->{init})
	{
		return 0
			if not busybot_cmd_bot_test $bot, 0, @{$bot->{init}};
		return 0
			if not busybot_cmd_bot_test $bot, $time, @$cmds; 
		busybot_cmd_bot_execute $bot, 0, @{$bot->{init}};
		busybot_cmd_bot_execute $bot, $time, @$cmds; 
	}
	else
	{
		return 0
			if not busybot_cmd_bot_test $bot, $time, @$cmds; 
		busybot_cmd_bot_execute $bot, $time, @$cmds; 
	}
	return 1;
}

my $busybots = botconfig_read "midi2cfg-ng.conf";
my @busybots_allocated;
my %notechannelbots;

sub busybot_note_off($$$)
{
	my ($time, $channel, $note) = @_;

	if(my $bot = $notechannelbots{$channel}{$note})
	{
		busybot_note_off_bot $bot, $time, $channel, $note;
		delete $notechannelbots{$channel}{$note};
		return 1;
	}

	return 0;
}

sub busybot_note_on($$$)
{
	my ($time, $channel, $note) = @_;

	if($notechannelbots{$channel}{$note})
	{
		busybot_note_off $time, $channel, $note;
	}

	my $overflow = 0;

	for(@busybots_allocated)
	{
		my $canplay = busybot_note_on_bot $_, $time, $channel, $note, 0;
		if($canplay > 0)
		{
			$notechannelbots{$channel}{$note} = $_;
			return 1;
		}
		$overflow = 1
			if $canplay == 0;
		# wrong
	}

	for(map { $_->[0] } sort { $a->[1] <=> $b->[1] } map { [$_, rand] } keys %$busybots)
	{
		next if $busybots->{$_}->{count} <= 0;
		my $bot = Storable::dclone $busybots->{$_};
		$bot->{id} = @busybots_allocated + 1;
		$bot->{classname} = $_;
		my $canplay = busybot_note_on_bot $bot, $time, $channel, $note, 1;
		if($canplay > 0)
		{
			--$busybots->{$_}->{count};
			$notechannelbots{$channel}{$note} = $bot;
			push @busybots_allocated, $bot;
			return 1;
		}
		$overflow = 1
			if $canplay == 0;
	}

	if($overflow)
	{
		warn "Not enough bots to play this";
		use Data::Dumper;
		print STDERR Dumper \@busybots_allocated;
	}
	else
	{
		warn "Note $channel:$note cannot be played by any bot"
	}

	return 0;
}

print 'alias p "sv_cmd bot_cmd $1 presskey $2"' . "\n";
print 'alias r "sv_cmd bot_cmd $1 releasekey $2"' . "\n";
print 'alias w "sv_cmd bot_cmd $1 wait_until $2"' . "\n";
print 'alias m "sv_cmd bot_cmd $1 moveto \"$2 $3 $4\""' . "\n";

my %midinotes = ();
my $note_min = undef;
my $note_max = undef;
my $notes_stuck = 0;
for(@allmidievents)
{
	my $t = tick2sec $_->[1];
	my $track = $_->[3];
	if($_->[0] eq 'note_on')
	{
		my $chan = $_->[4] + 1;
		$note_min = $_->[5]
			if not defined $note_min or $_->[5] < $note_min;
		$note_max = $_->[5]
			if not defined $note_max or $_->[5] > $note_max;
		if($midinotes{$chan}{$_->[5]})
		{
			--$notes_stuck;
			busybot_note_off($t, $chan, $_->[5]);
		}
		busybot_note_on($t, $chan, $_->[5]);
		++$notes_stuck;
		$midinotes{$chan}{$_->[5]} = 1;
	}
	elsif($_->[0] eq 'note_off')
	{
		my $chan = $_->[4] + 1;
		if($midinotes{$chan}{$_->[5]})
		{
			--$notes_stuck;
			busybot_note_off($t, $chan, $_->[5]);
		}
		$midinotes{$chan}{$_->[5]} = 0;
	}
}

print STDERR "Range of notes: $note_min .. $note_max\n";
print STDERR "Safe transpose range: @{[$note_max - 19]} .. @{[$note_min + 13]}\n";
print STDERR "Unsafe transpose range: @{[$note_max - 27]} .. @{[$note_min + 18]}\n";
print STDERR "Stuck notes: $notes_stuck\n";
print STDERR "Bots allocated:\n";
for(@busybots_allocated)
{
	print STDERR "$_->{id} is a $_->{classname}\n";
}
