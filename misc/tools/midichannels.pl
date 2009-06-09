#!/usr/bin/perl

use strict;
use warnings;
use MIDI;
use MIDI::Opus;

my ($filename) = @ARGV;
my $opus = MIDI::Opus->new({from_file => $filename});

my %chanpos = (
	note_off => 2,
	note_on => 2,
	key_after_touch => 2,
	control_change => 2,
	patch_change => 2,
	channel_after_touch => 2,
	pitch_wheel_change => 2
);

while(<STDIN>)
{
	chomp;
	my @arg = split /\s+/, $_;
	my $cmd = shift @arg;
	print "Executing: $cmd @arg\n";
	if($cmd eq 'ticks')
	{
		if(@arg)
		{
			$opus->ticks($arg[0]);
		}
		else
		{
			print "Ticks: ", $opus->ticks(), "\n";
		}
	}
	elsif($cmd eq 'tricks')
	{
		print "haha, very funny\n";
	}
	elsif($cmd eq 'tracks')
	{
		my $tracks = $opus->tracks_r();
		if(@arg)
		{
			my %taken = (0 => 1);
			my @t = ($tracks->[0]);
			for(@arg)
			{
				next if $taken{$_}++;
				push @t, $tracks->[$_];
			}
			$opus->tracks_r(\@t);
		}
		else
		{
			for(1..@$tracks-1)
			{
				print "Track $_:";
				my $name = undef;
				my %channels = ();
				my $notes = 0;
				for($tracks->[$_]->events())
				{
					my $p = $chanpos{$_->[0]};
					if(defined $p)
					{
						my $c = $_->[$p] + 1;
						++$channels{$c};
					}
					++$notes if $_->[0] eq 'note_on';
					$name = $_->[2] if $_->[0] eq 'track_name';
				}
				my $channels = join " ", sort keys %channels;
				print " $name" if defined $name;
				print " (channel $channels)" if $channels ne "";
				print " ($notes notes)" if $notes;
				print "\n";
			}
		}
	}
	elsif($cmd eq 'save')
	{
		$opus->write_to_file($arg[0]);
	}
	else
	{
		print "Unknown command, allowed commands: ticks, tricks, tracks, save\n";
	}
	print "Done with: $cmd @arg\n";
}
