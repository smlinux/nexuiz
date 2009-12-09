#!/usr/bin/perl

use strict;
use warnings;
use POSIX qw/ceil floor/;

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

my ($pixw, $pixh, $cols, $rows, $beamoffset, $beams) = @ARGV;
defined $beams
	or die "Usage: $0 pixw pixh columns rows beamoffset beams\n";

if($magick)
{
	checkmagick $magick->Set(size => "${pixw}x${pixh}");
	checkmagick $magick->ReadImage("xc:white");
}

my $square_x = 1.0 / $cols;
my $square_y = 1.0 / $rows;
$rows -= $beams;

my $dx = 1.0 / $pixw;
my $dy = 1.0 / $pixh;

my $i = 0;
for my $row(0..$rows-1)
{
	for my $col(0..$cols-1)
	{
		my $s0 = $col * $square_x + $dx;
		my $s1 = ($col+1) * $square_x - $dx;
		my $t0 = $row * $square_y + $dy;
		my $t1 = ($row+1) * $square_y - $dy;
		print "$i $s0 $t0 $s1 $t1\n";
		if($magick)
		{
			checkmagick $magick->Draw(
				fill => (($row + $col)%2 ? 'green' : 'cyan'),
				primitive => 'rectangle',
				points => sprintf "%d,%d %d,%d", ceil($s0 * $pixw), ceil($t0 * $pixh), floor($s1 * $pixw)-1, floor($t1 * $pixh)-1
			);
			checkmagick $magick->Annotate(
				x => $s0 * $pixw + 2,
				y => $t1 * $pixh - 2,
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
	my $t0 = $row * $square_y + $dy;
	my $t1 = ($row+1) * $square_y - $dy;
	print "$i $s0 $t0 $s1 $t1\n";
	if($magick)
	{
		checkmagick $magick->Draw(
			fill => (($beam)%2 ? 'yellow' : 'red'),
			primitive => 'rectangle',
			points => sprintf "%d,%d %d,%d", ceil($s0 * $pixw), ceil($t0 * $pixh), floor($s1 * $pixw)-1, floor($t1 * $pixh)-1
		);
		checkmagick $magick->Annotate(
			x => $s0 * $pixw + 2,
			y => $t1 * $pixh - 2,
			text => $i
		);
	}
	++$i;
}

if($magick)
{
	$magick->Write("particlefont-template.png");
}
