#!/usr/bin/perl

use strict;
use warnings;
use Digest::MD5;

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
		++$level;
	}
	elsif($line[0] eq '}')
	{
		--$level;
		if($level <= 0)
		{
			$level = 0;
			if(defined $curshader)
			{
				printf "%s  %s\n", Digest::MD5::md5_hex($shadertext), $curshader;
			}
			$curshader = undef;
		}
	}
	elsif($level == 0)
	{
		$curshader = $line[0];
		$shadertext = "";
	}
}
