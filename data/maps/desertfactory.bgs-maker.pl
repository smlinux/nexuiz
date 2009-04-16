#!/usr/bin/perl

use strict;
use warnings;

my $dt = 0.5;
my $pattern = '';
my $time = 0;
my $staccato = 0.25;
my @script = ();

while(<DATA>)
{
	chomp;
	my (@arg) = split /\s+/, $_;
	if($arg[0] eq 'time')
	{
		$time = $arg[1];
	}
	elsif($arg[0] eq 'bpm')
	{
		$dt = 60.0 / $arg[1];
	}
	elsif($arg[0] eq 'pattern')
	{
		$pattern = $arg[1];
	}
	elsif($arg[0] eq 'range')
	{
		my ($begin, $end) = ($arg[1], $arg[2]);
		my $n = $end - $begin;
		for(0..($n - 1))
		{
			my $char = substr $pattern, ($_ % length $pattern), 1;
			push @script, [$char, $time, 1], [$char, $time + $dt * (1 - $staccato), 0]
				unless $char eq '_';
			$time += $dt;
		}
	}
}

for(sort { $a->[0] cmp $b->[0] or $a->[1] <=> $b->[1] } @script)
{
	printf "%s %f %d\n", @$_;
}

__DATA__
time           0.200
bpm            254
pattern        aaa_____aaa_____
range          0 32
pattern        aaa_b__caaa_bccc
range          32 160
pattern        aaa_b__caaa_b__c
range          160 272
pattern        aaa_b__caaa_b_bb
range          272 288
pattern        abc_c_c_c_c_c_c_
range          288 352
pattern        aaa_b__caaa_bccc
range          352 480
pattern        aaa_b__caaa_b__c
range          480 592
pattern        aaa_b__caaa_b_bb
range          592 608
pattern        aaa_b__caaa_b__c
range          608 656
pattern        aaa_b__caaa_b_bb
range          656 672
pattern        aaa_b__caaa_b__c
range          672 720
pattern        aaa_b__caaa_b_bb
range          720 736
pattern        aaa_b__caaa_b__c
range          736 864
pattern        a_______________
range          864 865
