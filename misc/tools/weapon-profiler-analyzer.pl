#!/usr/bin/perl

# no warranty for this script
# and no documentation
# take it or leave it

use strict;
use warnings;
use FindBin; use lib $FindBin::Bin;
use WeaponEncounterProfile;

my ($statsfile) = @ARGV;
my $stats;

sub LoadData()
{
	$stats = WeaponEncounterProfile->new($statsfile);
}

sub LinSolve($$)
{
	my ($m, $v) = @_;
	my $n = @$m;

	my @out = ();

	my @bigmatrix = map { [ @{$m->[$_]}, $v->[$_] ] } 0..$n-1;

	# 1. Triangulate
	for my $i(0..$n-1)
	{
		# first: bring the highest value to the top
		my $best = -1;
		my $bestval = 0;
		for my $j($i..$n-1)
		{
			my $v = $bigmatrix[$j]->[$i];
			if($v*$v > $bestval*$bestval)
			{
				$best = $j;
				$bestval = $v;
			}
		}
		die "lindep" if $best == -1;

		# swap
		($bigmatrix[$i], $bigmatrix[$best]) = ($bigmatrix[$best], $bigmatrix[$i]);

		# then: eliminate
		for my $j($i+1..$n-1)
		{
			my $r = $bigmatrix[$j]->[$i];
			for my $k(0..$n)
			{
				$bigmatrix[$j]->[$k] -= $bigmatrix[$i]->[$k] * $r / $bestval;
			}
		}
	}

	# 2. Diagonalize
	for my $i(reverse 0..$n-1)
	{
		my $bestval = $bigmatrix[$i]->[$i];
		for my $j(0..$i-1)
		{
			my $r = $bigmatrix[$j]->[$i];
			for my $k(0..$n)
			{
				$bigmatrix[$j]->[$k] -= $bigmatrix[$i]->[$k] * $r / $bestval;
			}
		}
	}

	# 3. Read off solutions
	return map { $bigmatrix[$_]->[$n] / $bigmatrix[$_]->[$_] } 0..($n-1);
}

sub SolveBestSquares($$)
{
	my ($d, $w) = @_;

	my $n = @$d;

	if($ENV{stupid})
	{
		my @result = ();
		for my $i(0..$n-1)
		{
			my $num = 0;
			my $denom = 0;
			for my $j(0..$n-1)
			{
				my $weight = $w->[$i]->[$j];
				$num += $weight * $d->[$i]->[$j];
				$denom += $weight;
			}
			push @result, $num / $denom;
		}
		return @result;
	}

	# build linear equation system

	my @matrix = map { [ map { 0 } 1..$n ] } 1..$n;
	my @vector = map { 0 } 1..$n;

	for my $i(0..$n-1)
	{
		$matrix[0][$i] += 1;
	}
	$vector[0] += 0;
	for my $z(1..$n-1)
	{
		for my $i(0..$n-1)
		{
			$matrix[$z][$i] += $w->[$i]->[$z];
			$matrix[$z][$z] -= $w->[$i]->[$z];
			$vector[$z] += $w->[$i]->[$z] * $d->[$i]->[$z];
		}
	}

	return LinSolve(\@matrix, \@vector);
}

sub Evaluate($)
{
	my ($matrix) = @_;
	my %allweps;
	for(keys %$matrix)
	{
		++$allweps{$_};
		for(keys %{$matrix->{$_}})
		{
			++$allweps{$_};
		}
	}
	delete $allweps{"@!#%'n Tuba"};
	delete $allweps{"Port-O-Launch"};
	my @allweps = keys %allweps;
	my %values;

	my @dmatrix = map { [ map { 0 } @allweps ] } @allweps;
	my @wmatrix = map { [ map { 0 } @allweps ] } @allweps;

	for my $i(0..@allweps - 1)
	{
		my $attackweapon = $allweps[$i];
		my $v = 0;
		my $d = 0;
		for my $j(0..@allweps - 1)
		{
			my $defendweapon = $allweps[$j];
			next if $attackweapon eq $defendweapon;
			my $win = ($matrix->{$attackweapon}{$defendweapon} || 0);
			my $lose = ($matrix->{$defendweapon}{$attackweapon} || 0);
			my $c = ($win + $lose);
			next if $c == 0;
			my $p = $win / $c;
			my $w = 1 - 1/($c * 0.1 + 1);

			$dmatrix[$i][$j] = $p - (1 - $p); # antisymmetric
			$wmatrix[$i][$j] = $w;            # symmetric
		}
	}

	my @val;
	eval
	{
		@val = SolveBestSquares(\@dmatrix, \@wmatrix);
		1;
	}
	or do
	{
		@val = map { undef } @allweps;
	};

	for my $i(0..@allweps - 1)
	{
		my $attackweapon = $allweps[$i];
		$values{$attackweapon} = $val[$i];
	}
	return \%values;
}

LoadData();
$stats->allstats(sub
{
	my ($addr, $map, $data) = @_;
	print "For server @{[$addr || 'any']} map @{[$map || 'any']}:\n";
	my $values = Evaluate $data;
	my $valid = defined [values %$values]->[0];
	my @weapons_sorted = sort { $valid ? $values->{$b} <=> $values->{$a} : $a cmp $b } keys %$values;
	my $min = undef;
	for my $row(@weapons_sorted)
	{
		printf "  %-30s %8s |", $row, $valid ? sprintf("%8.5f", $values->{$row}) : "N/A";
		for my $col(@weapons_sorted)
		{
			my $win = ($data->{$row}{$col} || 0);
			my $lose = ($data->{$col}{$row} || 0);
			$min = $win + $lose
				if $row ne $col and (not defined $min or $min > $win + $lose);
			if(($row eq $col) || ($win + $lose == 0))
			{
				print "   .   ";
			}
			elsif($win == $lose)
			{
				printf " %6.3f", 0;
			}
			else
			{
				my $p = 2 * ($win / ($win + $lose) - 0.5);
				printf " %+6.3f", $p;
			}
		}
		print "\n";
	}
	$min ||= 0;
	print "  Relevance: $min\n";
});
