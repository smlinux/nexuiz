#!/usr/bin/perl

use strict;
use warnings;

# particlefont.txt generator for DarkPlaces

# this is eval'ed to not fail if Image::Magick is not installed
my $magick =
eval q{
	use Image::Magick;
	Image::Magick->new();
}
	or warn "Image::Magick not installed, not generating a TGA\n";

sub checkmagick($)
{
	my ($e) = @_;
	die $e if $e;
	return $e;
}

my ($pixw, $pixh, $cols, $beamoffset, $beams) = @ARGV;
defined $beams
	or die "Usage: $0 pixw pixh columns beamoffset beams\n";

if($magick)
{
	checkmagick $magick->Set(size => "${pixw}x${pixh}");
	checkmagick $magick->ReadImage("xc:white");
}

my $square = 1.0 / $cols;
my $rows = $cols - $beams;

my $dx = 1 / $pixw;
my $dy = 1 / $pixh;

my $i = 0;
for my $row(0..$rows-1)
{
	for my $col(0..$cols-1)
	{
		my $s0 = $col * $square + $dx;
		my $s1 = ($col+1) * $square - $dx;
		my $t0 = $row * $square + $dy;
		my $t1 = ($row+1) * $square - $dy;
		print "$i $s0 $t0 $s1 $t1\n";
		if($magick)
		{
			checkmagick $magick->Draw(
				fill => (($row + $col)%2 ? 'green' : 'white'),
				primitive => 'rectangle',
				points => sprintf "%d,%d %d,%d", $s0 * $pixw, $t0 * $pixh, $s1 * $pixw, $t1 * $pixh
			);
			checkmagick $magick->Annotate(
				x => $s0 * $pixw,
				y => $t1 * $pixh,
				text => $i
			);
		}
		++$i;
	}
}

$i = $beamoffset if $i < $beamoffset;
for my $beam(0..$beams-1)
{
	my $s0 = 0;
	my $s1 = 1;
	my $row = $beam + $rows;
	my $t0 = $row * $square + $dy;
	my $t1 = ($row+1) * $square - $dy;
	print "$i $s0 $t0 $s1 $t1\n";
	if($magick)
	{
		checkmagick $magick->Draw(
			fill => (($beam)%2 ? 'yellow' : 'red'),
			primitive => 'rectangle',
			points => sprintf "%d,%d %d,%d", $s0 * $pixw, $t0 * $pixh, $s1 * $pixw, $t1 * $pixh
		);
		checkmagick $magick->Annotate(
			x => $s0 * $pixw,
			y => $t1 * $pixh,
			text => $i
		);
	}
	++$i;
}

if($magick)
{
	$magick->Write("particlefont-template.png");
}
