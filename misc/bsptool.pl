#!/usr/bin/perl

use strict;
use warnings;

my $msg = "";

my $fn = shift @ARGV;
open my $fh, "<", $fn
	or die "$fn: $!";

read $fh, my $header, 8;

die "Invalid BSP format"
	if $header ne "IBSP\x2e\x00\x00\x00";

my @lumpname = qw/entities textures planes nodes leafs leaffaces leafbrushes models brushes brushsides vertices triangles effects faces lightmaps lightgrid pvs advertisements/;
my %lumpid = map { $lumpname[$_] => $_ } 0..@lumpname-1;

my @bsp;

for(0..16)
{
	read $fh, my $lump, 8;
	my ($offset, $length) = unpack "VV", $lump;

	print "BSP lump $_ ($lumpname[$_]): offset $offset length $length\n";
	push @bsp, [$offset, $length, undef];
}

for(@bsp)
{
	my ($offset, $length, $data) = @$_;
	seek $fh, $offset, 0;
	read $fh, $data, $length;
	length $data == $length
		or die "Incomplete BSP lump at $offset\n";
	$_->[2] = $data;
}

for(@ARGV)
{
	if(/^-x(.*)$/)
	{
		my $id = $lumpid{$1};
		die "invalid lump $1 to remove"
			unless defined $id;
		$bsp[$id]->[2] = "";
	}
	elsif(/^-m(.*)$/)
	{
		$msg = $1;
	}
	elsif(/^-e(.*)$/) # extract lump
	{
		my $id = $lumpid{$1};
		die "invalid lump $1 to extract"
			unless defined $id;
		print $bsp[$id]->[2];
	}
	elsif(/^-o(.*)$/)
	{
		open my $fh, ">", $1
			or die "$1: $!";
		print $fh $header;
		my $pos = 17 * 8 + tell($fh) + length $msg;
		for(@bsp)
		{
			$_->[0] = $pos;
			$_->[1] = length $_->[2];
			$pos += $_->[1];
			print $fh pack "VV", $_->[0], $_->[1];
		}
		print $fh $msg;
		for(@bsp)
		{
			print $fh $_->[2];
		}
	}
}

# TODO:
#   features like:
#     externalize lightmaps
#     decimate light grid
#     edit lightmaps/grid
