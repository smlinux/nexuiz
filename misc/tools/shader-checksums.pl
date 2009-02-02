#!/usr/bin/perl

use strict;
use warnings;
use Digest::MD5;

sub normalize_path($)
{
	my ($p) = @_;
	$p =~ s/\\/\//g;
	$p =~ s/(?:\.jpg|\.png|\.tga)$//gi;
	$p = lc $p;
	return $p;
}

my $find_texture_names;
$find_texture_names = grep { /^-t$/ } @ARGV;

my $shadertext = "";
my $level = 0;
my $curshader;
while(<STDIN>)
{
	s/\r//gs;
	chomp;

	s/\/\/.*//s;
	s/^\s+//;
	s/\s+$//;
	next if /^$/;

	my @line = map { s/"//g; $_; } split /\s+/, $_;

	$shadertext .= "@line\n";

	if($line[0] eq '{')
	{
		die "{ line contains other stuff"
			unless @line == 1;
		die "{ line without shader name"
			unless defined $curshader;
		die "{ line in level $level"
			if $level >= 2;
		++$level;
	}
	elsif($line[0] eq '}')
	{
		die "} line contains other stuff"
			unless @line == 1;
		die "} line without shader name"
			unless defined $curshader;
		die "{ line in level $level"
			if $level <= 0;
		--$level;
		if($level <= 0)
		{
			$level = 0;
			printf "%s  %s\n", Digest::MD5::md5_hex($shadertext), $curshader;

			if($find_texture_names)
			{
				# find out possibly loaded textures
				my @maps = ($shadertext =~ /^map ([^\$].*)$/gim);
				for($shadertext =~ /^animmap \S+ (.*)$/gim)
				{
					push @maps, split / /, $_;
				}
				for($shadertext =~ /^skyparms (.*)$/gim)
				{
					for(split / /, $_)
					{
						next if $_ eq "-";
						push @maps, "$_"."_lf";
						push @maps, "$_"."_ft";
						push @maps, "$_"."_rt";
						push @maps, "$_"."_bk";
						push @maps, "$_"."_up";
						push @maps, "$_"."_dn";
					}
				}
				@maps = ($curshader)
					if @maps == 0;
				printf "* %s  %s\n", $_, $curshader
					for map { normalize_path $_ } @maps;
			}

			$curshader = undef;
		}
	}
	elsif($level == 0)
	{
		die "shader name already set"
			if defined $curshader;
		$curshader = normalize_path $line[0];
		$shadertext = "";
	}
}

if($level != 0)
{
	die "missing } line";
}
