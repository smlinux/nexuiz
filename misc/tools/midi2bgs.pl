#!/usr/bin/perl

# converter from Type 1 MIDI files to BGS files that control particle effects on maps
# usage:
#   perl midi2bgs.pl filename.mid tracknumber channelnumber offset prefix > filename.bgs
# track and channel numbers -1 include all events
# example:
#   perl midi2bgs.pl filename.mid -1 10 0.3 note_ > filename.bgs

use strict;
use warnings;
use MIDI;
use MIDI::Opus;

my ($filename, $trackno, $channelno, $offset, $noteprefix) = @ARGV;
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
	return $sec + $offset;
}

my @notes = ('c', 'c#', 'd', 'd#', 'e', 'f', 'f#', 'g', 'g#', 'a', 'a#', 'b');
my @notenames = ();
for my $octave (0..11)
{
	for(@notes)
	{
		if($octave <= 3)
		{
			push @notenames, uc($_) . ',' x (3 - $octave);
		}
		else
		{
			push @notenames, lc($_) . "'" x ($octave - 4);
		}
	}
}

my @outevents = (); # format: name, time in seconds, velocity
$tick = 0;
for my $thistrackno($trackno >= 0 ? $trackno : (0..@$tracks - 1))
{
	for($tracks->[$thistrackno]->events())
	{
		$tick += $_->[1];
		my $t = tick2sec $tick;
		if($_->[0] eq 'note_on')
		{
			my $chan = $_->[2];
			my $note = $notenames[$_->[3]];
			my $velocity = $_->[4] / 127.0;
			push @outevents, [$note, $t, $velocity]
				if($channelno < 0 || $channelno == $chan);
		}
		elsif($_->[0] eq 'note_off')
		{
			my $chan = $_->[2];
			my $note = $notenames[$_->[3]];
			my $velocity = $_->[4] / 127.0;
			push @outevents, [$note, $t, 0]
				if($channelno < 0 || $channelno == $chan);
		}
	}   
}
for(sort { $a->[0] cmp $b->[0] or $a->[1] <=> $b->[1] } @outevents)
{
    printf "%s%s %f %f\n", $noteprefix, @$_;
}
