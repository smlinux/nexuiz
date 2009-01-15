#!/usr/bin/perl

# usage:
#   ./demosplit.pl demo.dem
# splits the demo into separate demos for each map played and writes them
# to demo-0000.dem, demo-0001.dem ...

use strict;
use warnings;

# constants
my $svc_signon = "\001";

# opening the files

die "Usage: $0 infile"
	if @ARGV != 1;
my ($in) = @ARGV;

my $demoname = [$in =~ /^(.*)\.dem$/]->[0];
$demoname = "out"
	if not defined $demoname;

open my $infh, "<", $in
	or die "open $in: $!";
binmode $infh;

# 1. CD track

$/ = "\012";
my $cdtrack = <$infh>;

# 2. packets

my $outfh;
my $outnum = 0;

for(;;)
{
	last
		unless 4 == read $infh, my $length, 4;
	$length = unpack("V", $length);
	die "Invalid demo packet"
		unless 12 == read $infh, my $angles, 12;
	die "Invalid demo packet"
		unless $length == read $infh, my($data), $length;

	if($data =~ m{
		^
		$svc_signon
		$
	}sx)
	{
		close $outfh
			if $outfh;
		my $outname = sprintf("%s-%04d.dem", $demoname, $outnum++);
		open $outfh, ">", $outname
			or die "open $outname: $!";
		binmode $outfh;
		print $outfh $cdtrack;
		print "Writing to $outname...\n";
	}

	die "No signon received"
		unless $outfh;
	print $outfh pack("V", length $data);
	print $outfh $angles;
	print $outfh $data;
}

close $outfh;
close $infh;
