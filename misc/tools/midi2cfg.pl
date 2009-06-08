#!/usr/bin/perl

# converter from Type 1 MIDI files to CFG files that control bots with the Tuba and other weapons for percussion (requires g_weaponarena all)
# usage:
#   perl midi2cfg.pl filename.mid basenote walktime "x y z" "x y z" "x y z" ... "/" "x y z" "x y z" ... > filename.cfg

use strict;
use warnings;
use MIDI;
use MIDI::Opus;

my ($filename, $transpose, $walktime, @coords) = @ARGV;
my @coords_percussion = ();
my @coords_tuba = ();
my $l = \@coords_tuba;
for(@coords)
{
	if($_ eq '/')
	{
		$l = \@coords_percussion;
	}
	else
	{
		push @$l, [split /\s+/, $_];
	}
}

my $opus = MIDI::Opus->new({from_file => $filename});
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
        push @tempi, [$_->[1], $_->[2] * 0.000001 / $ticksperquarter];
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





my @busybots_percussion = map { undef } @coords_percussion;
my @busybots_tuba       = map { undef } @coords_tuba;

my $notes = 0;
sub busybot_findfree($$$)
{
	my ($time, $vchannel, $note) = @_;
	my $l = ($vchannel < 16) ? \@busybots_tuba : \@busybots_percussion;
	for(0..@$l-1)
	{
		if(!$l->[$_])
		{
			my $bot = {id => $_ + 1, busy => 0, busytime => 0, channel => $vchannel, curtime => -$walktime, curbuttons => 0, noteoffset => 0};
			$l->[$_] = $bot;
			return $bot;
		}
		return $l->[$_] if
			$l->[$_]{channel} == $vchannel
			&&
			!$l->[$_]{busy}
			&&
			$time > $l->[$_]{busytime};
	}
	die "No free channel found ($notes notes active)\n";
}

sub busybot_find($$)
{
	my ($vchannel, $note) = @_;
	my $l = ($vchannel < 16) ? \@busybots_tuba : \@busybots_percussion;
	for(0..@$l-1)
	{
		return $l->[$_] if
			$l->[$_]
			&&
			$l->[$_]{busy}
			&&
			$l->[$_]{channel} == $vchannel
			&&
			defined $l->[$_]{note}
			&&
			$l->[$_]{note} == $note;
	}
	return undef;
}

sub busybot_advance($$)
{
	my ($bot, $t) = @_;
	my $t0 = $bot->{curtime};
	if($t != $t0)
	{
		#print "sv_cmd bot_cmd $bot->{id} wait @{[$t - $t0]}\n";
		print "sv_cmd bot_cmd $bot->{id} wait_until $t\n";
	}
	$bot->{curtime} = $t;
}

sub busybot_setbuttons($$)
{
	my ($bot, $b) = @_;
	my $b0 = $bot->{curbuttons};
	my $press = $b & ~$b0;
	my $release = $b0 & ~$b;
	print "sv_cmd bot_cmd $bot->{id} releasekey attack1\n" if $release & 32;
	print "sv_cmd bot_cmd $bot->{id} releasekey attack2\n" if $release & 64;
	print "sv_cmd bot_cmd $bot->{id} releasekey forward\n" if $release & 1;
	print "sv_cmd bot_cmd $bot->{id} releasekey backward\n" if $release & 2;
	print "sv_cmd bot_cmd $bot->{id} releasekey left\n" if $release & 4;
	print "sv_cmd bot_cmd $bot->{id} releasekey right\n" if $release & 8;
	print "sv_cmd bot_cmd $bot->{id} releasekey crouch\n" if $release & 16;
	print "sv_cmd bot_cmd $bot->{id} releasekey jump\n" if $release & 128;
	print "sv_cmd bot_cmd $bot->{id} presskey forward\n" if $press & 1;
	print "sv_cmd bot_cmd $bot->{id} presskey backward\n" if $press & 2;
	print "sv_cmd bot_cmd $bot->{id} presskey left\n" if $press & 4;
	print "sv_cmd bot_cmd $bot->{id} presskey right\n" if $press & 8;
	print "sv_cmd bot_cmd $bot->{id} presskey crouch\n" if $press & 16;
	print "sv_cmd bot_cmd $bot->{id} presskey jump\n" if $press & 128;
	print "sv_cmd bot_cmd $bot->{id} presskey attack1\n" if $press & 32;
	print "sv_cmd bot_cmd $bot->{id} presskey attack2\n" if $press & 64;
	$bot->{curbuttons} = $b;
}

my %notes = (
	-18 => '1lbc',
	-17 => '1bc',
	-16 => '1brc',
	-13 => '1frc',
	-12 => '1c',
	-11 => '2lbc',
	-10 => '1rc',
	-9 => '1flc',
	-8 => '1fc',
	-7 => '1lc',
	-6 => '1lb',
	-5 => '1b',
	-4 => '1br',
	-3 => '2rc',
	-2 => '2flc',
	-1 => '1fl',
	0 => '1',
	1 => '2lb',
	2 => '1r',
	3 => '1fl',
	4 => '1f',
	5 => '1l',
	6 => '2fr',
	7 => '2',
	8 => '1brj',
	9 => '2r',
	10 => '2fl',
	11 => '2f',
	12 => '2l',
	13 => '2lbj',
	14 => '1rj',
	15 => '1flj',
	16 => '1fj',
	17 => '1lj',
	18 => '2frj',
	19 => '2j',
	21 => '2rj',
	22 => '2flj',
	23 => '2fj',
	24 => '2lj'
);

my $note_min = +99;
my $note_max = -99;
sub getnote($$)
{
	my ($bot, $note) = @_;
	$note_max = $note if $note_max < $note;
	$note_min = $note if $note_min > $note;
	$note -= $transpose;
	$note -= $bot->{noteoffset};
	my $s = $notes{$note};
	return $s;
}

sub busybot_playnote($$)
{
	my ($bot, $note) = @_;
	my $s = getnote $bot => $note;
	return (warn("note $note not found"), 0)
		unless defined $s;
	my $buttons = 0;
	$buttons |= 1 if $s =~ /f/;
	$buttons |= 2 if $s =~ /b/;
	$buttons |= 4 if $s =~ /l/;
	$buttons |= 8 if $s =~ /r/;
	$buttons |= 16 if $s =~ /c/;
	$buttons |= 32 if $s =~ /1/;
	$buttons |= 64 if $s =~ /2/;
	$buttons |= 128 if $s =~ /j/;
	busybot_setbuttons $bot => $buttons;
	return 1;
}

sub busybot_stopnote($$)
{
	my ($bot, $note) = @_;
	my $s = getnote $bot => $note;
	return 0
		unless defined $s;
	my $buttons = $bot->{curbuttons};
	$buttons &= ~(32 | 64);
	#$buttons = 0;
	busybot_setbuttons $bot => $buttons;
	return 1;
}

sub note_on($$$)
{
	my ($t, $channel, $note) = @_;
	if(busybot_find($channel, $note))
	{
		note_off($t, $channel, $note); # MIDI allows redoing a note-on for the same note
	}
	++$notes;
	if($channel == 10)
	{
		$channel = 16 + $note; # percussion
	}
	my $bot = busybot_findfree($t, $channel, $note);
	if($channel < 16)
	{
		busybot_advance $bot => $t if getnote $bot => $note;
		if(busybot_playnote $bot => $note)
		{
			$bot->{busy} = 1;
			$bot->{note} = $note;
			$bot->{busytime} = $t + 0.25;
			busybot_stopnote $bot => $note;
		}
	}
	if($channel >= 16)
	{
		print "sv_cmd bot_cmd $bot->{id} presskey attack1\n";
		print "sv_cmd bot_cmd $bot->{id} releasekey attack1\n";
		$bot->{busy} = 1;
		$bot->{note} = $note;
		$bot->{busytime} = $t + 1.5;
	}
}

sub note_off($$$)
{
	my ($t, $channel, $note) = @_;
	--$notes;
	if($channel == 10)
	{
		$channel = 16 + $note; # percussion
	}
	my $bot = busybot_find($channel, $note)
		or return;
	$bot->{busy} = 0;
	if($channel < 16)
	{
		busybot_advance $bot => $t;
		busybot_stopnote $bot => $note;
		$bot->{busytime} = $t + 0.25;
	}
}

for(@allmidievents)
{
	my $t = tick2sec $_->[1];
	my $track = $_->[3];
	if($_->[0] eq 'note_on')
	{
		my $chan = $_->[4];
		note_on($t, $chan, $_->[5]);
	}
	elsif($_->[0] eq 'note_off')
	{
		my $chan = $_->[4];
		note_off($t, $chan, $_->[5]);
	}
}

print STDERR "Range of notes: $note_min .. $note_max\n";
print STDERR "Safe transpose range: @{[$note_max - 19]} .. @{[$note_min + 13]}\n";
print STDERR "Unsafe transpose range: @{[$note_max - 24]} .. @{[$note_min + 18]}\n";
printf STDERR "%d bots allocated for tuba, %d for percussion\n", int scalar grep { defined $_ } @busybots_tuba, int scalar grep { defined $_ } @busybots_percussion;

my $n = 0;
for(@busybots_percussion, @busybots_tuba)
{
	++$n if $_ && $_->{busy};
}
if($n)
{
	die "$n channels blocked ($notes MIDI notes)";
}
