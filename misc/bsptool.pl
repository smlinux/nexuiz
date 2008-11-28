#!/usr/bin/perl

use strict;
use warnings;
use Image::Magick;
use POSIX qw/floor ceil/;

my @lumpname = qw/entities textures planes nodes leafs leaffaces leafbrushes models brushes brushsides vertices triangles effects faces lightmaps lightgrid pvs advertisements/;
my %lumpid = map { $lumpname[$_] => $_ } 0..@lumpname-1;
my $msg = "";
my @bsp;

# READ THE BSP

my $fn = shift @ARGV;
$fn =~ /(.*)\.bsp$/
	or die "invalid input file name (must be a .bsp): $fn";
my $basename = $1;
open my $fh, "<", $fn
	or die "$fn: $!";

read $fh, my $header, 8;

die "Invalid BSP format"
	if $header ne "IBSP\x2e\x00\x00\x00";

for(0..16)
{
	read $fh, my $lump, 8;
	my ($offset, $length) = unpack "VV", $lump;

	print STDERR "BSP lump $_ ($lumpname[$_]): offset $offset length $length\n";
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

close $fh;

# STRUCT DECODING

sub DecodeLump($@)
{
	my ($lump, @fields) = @_;
	my @decoded;

	my $spec = "";
	my @decoders;

	my $item;
	my @data;
	my $idx;

	for(@fields)
	{
		if(/^(\w*)=(.*?)(\d*)$/)
		{
			$spec .= "$2$3 ";
			my $f = $1;
			my $n = $3;
			if($n eq '')
			{
				push @decoders, sub { $item->{$f} = $data[$idx++]; };
			}
			else
			{
				push @decoders, sub { $item->{$f} = [ map { $data[$idx++] } 1..$n ]; };
			}
		}
	}

	my $itemlen = length pack $spec, ();
	my $len = length $lump;

	die "Invalid lump size: $len not divisible by $itemlen"
		if $len % $itemlen;

	my $items = $len / $itemlen;
	for(0..$items - 1)
	{
		@data = unpack $spec, substr $lump, $_ * $itemlen, $itemlen;
		$item = {};
		$idx = 0;
		$_->() for @decoders;
		push @decoded, $item;
	}
	@decoded;
}

# OPTIONS

for(@ARGV)
{
	if(/^-d(.+)$/) # delete a lump
	{
		my $id = $lumpid{$1};
		die "invalid lump $1 to remove"
			unless defined $id;
		$bsp[$id]->[2] = "";
	}
	elsif(/^-m(.*)$/) # change the message
	{
		$msg = $1;
	}
	elsif(/^-l(jpg|png|tga)(\d+)?$/) # externalize lightmaps (deleting the internal ones)
	{
		my $ext = $1;
		my $quality = $2;
		my %lightmaps = ();
		my $faces = $bsp[$lumpid{faces}]->[2];
		my $lightmaps = $bsp[$lumpid{lightmaps}]->[2];
		my @values = DecodeLump $faces,
			qw/texture=V effect=V type=V vertex=V n_vertexes=V meshvert=V n_meshverts=V lm_index=V lm_start=f2 lm_size=f2 lm_origin=f3 lm_vec_0=f3 lm_vec_1=f3 normal=f3 size=V2/;
		my $oddfound = 0;
		for(@values)
		{
			my $l = $_->{lm_index};
			next if $l >= 2**31; # signed
			$oddfound = 1
				if $l % 2;
			++$lightmaps{$l};
		}
		if(!$oddfound)
		{
			$lightmaps{$_+1} = $lightmaps{$_} for keys %lightmaps;
		}
		for(sort { $a <=> $b } keys %lightmaps)
		{
			print STDERR "Lightmap $_ was used $lightmaps{$_} times\n";

			# export that lightmap
			my $lmsize = 128 * 128 * 3;
			next if length $lightmaps < ($_ + 1) * $lmsize;
			my $lmdata = substr $lightmaps, $_ * $lmsize, $lmsize;
			my $img = Image::Magick->new(size => '128x128', depth => 8, magick => 'RGB');
			$img->BlobToImage($lmdata);
			my $outfn = sprintf "%s/lm_%04d.$ext", $basename, $_;
			mkdir $basename;
			$img->Set(quality => $quality)
				if defined $quality;
			my $err = $img->Write($outfn);
			die $err
				if $err;
			print STDERR "Wrote $outfn\n";
		}

		# nullify the lightmap lump
		$bsp[$lumpid{lightmaps}]->[2] = "";
	}
	elsif(/^-g$/) # decimate light grid
	{
		my @models = DecodeLump $bsp[$lumpid{models}]->[2],
			qw/mins=f3 maxs=f3 face=V n_faces=V brush=V n_brushes=V/;
		my $entities = $bsp[$lumpid{entities}]->[2];
		my @entitylines = split /\r?\n/, $entities;
		my $gridsize = "64 64 128";
		for(@entitylines)
		{
			last if $_ eq '}';
			/^\s*"gridsize"\s+"(.*)"$/
				and $gridsize = $1;
		}
		my @scale = map { 1 / $_ } split / /, $gridsize;
		my @imins = map { ceil($models[0]{mins}[$_] * $scale[$_]) } 0..2;
		my @imaxs = map { floor($models[0]{maxs}[$_] * $scale[$_]) } 0..2;
		my @isize = map { $imaxs[$_] - $imins[$_] + 1 } 0..2;
		my $isize = $isize[0] * $isize[1] * $isize[2];
		my @gridcells = DecodeLump $bsp[$lumpid{lightgrid}]->[2],
			qw/ambient=C3 directional=C3 dir=C2/;
		die "Cannot decode light grid"
			unless $isize == @gridcells;

		# TODO now decimate it and reinsert the lump (and the changed entity lump for the new size)
	}
	elsif(/^-x(.+)$/) # extract lump to stdout
	{
		my $id = $lumpid{$1};
		die "invalid lump $1 to extract"
			unless defined $id;
		print $bsp[$id]->[2];
	}
	elsif(/^-o(.+)?$/) # write the final BSP file
	{
		my $outfile = $1;
		$outfile = $fn
			if not defined $outfile;
		open my $fh, ">", $outfile
			or die "$outfile: $!";
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
		close $fh;
		print STDERR "Wrote $outfile\n";
	}
	else
	{
		die "Invalid option: $_";
	}
}

# TODO:
#   features like:
#     decimate light grid
#     edit lightmaps/grid
