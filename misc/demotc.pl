#!/usr/bin/perl

# Fake demo "cutting" tool
# works by looking for time codes in the demo
# and injecting playback speed commands

# usage:
#   ./demotc.pl infile outfile tc0 tc1 - cuts the demo file for playback
#   ./demotc.pl infile outfile tc0 tc1 --capture - cuts the demo file for video capture (it will automatically write a dpvideo001.avi file of the selected time range when playing)
#   ./demotc.pl infile pattern - looks for a pattern, prints parentheses matches

use strict;
use warnings;

sub sanitize($)
{
	my ($str) = @_;
	$str =~ y/\000-\037//d;
	return $str;
}

# opening the files

die "Usage: $0 infile outfile tc_start tc_end [--capture], or $0 infile pattern"
	if @ARGV != 2 && @ARGV != 4 && @ARGV != 5;
my ($in, $out, $tc0, $tc1, $capture) = (@ARGV, undef, undef, undef);

$in ne $out
	or die "Input and output file may not be the same!";

open my $infh, "<", $in
	or die "open $in: $!";
binmode $infh;

my $outfh;
if(defined $tc0) # cutting
{
	open $outfh, ">", $out
		or die "open $out: $!";
	binmode $outfh;
}

# 1. CD track

$/ = "\012";
my $cdtrack = <$infh>;
print $outfh $cdtrack if $outfh;

# 2. packets

my $tc = 0;

my $first = 1;
my $demo_started = 0;
my $demo_stopped = 0;
my $inject_buffer = "";

for(;;)
{
	last
		unless 4 == read $infh, my $length, 4;
	$length = unpack("V", $length);
	die "Invalid demo packet"
		unless 12 == read $infh, my $angles, 12;
	die "Invalid demo packet"
		unless $length == read $infh, my($data), $length;
	
	if(substr($data, 0, 1) eq "\007") # svc_time
	{
		$tc = unpack "f", substr $data, 1, 4;
	}

	if(defined $tc0)
	{
		if($first)
		{
			$inject_buffer = "\011\nslowmo 100\n\000";
			$first = 0;
		}
		if($demo_started < 1 && $tc > $tc0 - 50)
		{
			$inject_buffer = "\011\nslowmo 10\n\000";
			$demo_started = 1;
		}
		if($demo_started < 2 && $tc > $tc0 - 5)
		{
			$inject_buffer = "\011\nslowmo 1\n\000";
			$demo_started = 2;
		}
		if($demo_started < 3 && $tc > $tc0)
		{
			if($capture)
			{
				$inject_buffer = "\011\ncl_capturevideo 1\n\000";
			}
			else
			{
				$inject_buffer = "\011\nslowmo 0; defer 1 \"slowmo 1\"\n\000";
			}
			$demo_started = 3;
		}
		if(!$demo_stopped && $tc > $tc1)
		{
			if($capture)
			{
				$inject_buffer = "\011\ncl_capturevideo 0; defer 0.5 \"disconnect\"\n\000";
			}
			else
			{
				$inject_buffer = "\011\ndefer 0.5 \"disconnect\"\n\000";
			}
			$demo_stopped = 1;
		}
	}
	else
	{
		if(my @l = ($data =~ /$out/))
		{
			print "$tc:";
			for(@l)
			{
				print " \"", sanitize($_), "\"";
			}
			print "\n";
		}
	}
	
	next unless $outfh;
	if(length($data . $inject_buffer) < 65536)
	{
		$data .= $inject_buffer;
		$inject_buffer = "";
	}
	print $outfh pack("V", length $data);
	print $outfh $angles;
	print $outfh $data;
}

close $outfh if $outfh;
close $infh;
