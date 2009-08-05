#!/usr/bin/perl

use strict;
use warnings;

my @cols = qw/omg low med normal high ultra ultimate/;
my %table = ();

for my $col(@cols)
{
	my $fn = "effects-$col.cfg";
	open my $fh, "<", "$fn"
		or die "<$fn: $!";
	while(<$fh>)
	{
		chomp;
		next unless /^(\S+) (.*)$/;
		$table{$1}{$col} = $2;
	}
}

my %sortkeys = ();
for my $row(keys %table)
{
	my @toggles = ();
	my $last = undef;
	my $i = 0;
	for my $col(reverse @cols)
	{
		if(defined $last && $table{$row}{$col} == $last)
		{
		}
		else
		{
			push @toggles, $i;
			$last = $table{$row}{$col};
		}
		++$i;
	}
	$sortkeys{$row} = \@toggles;
}
sub toggles_compare($$);
sub toggles_compare($$)
{
	my ($a, $b) = @_;
	return 0 if !@$a and !@$b;
	return -1 if !@$a and @$b;
	return +1 if @$a and !@$b;
	return -1 if $a->[0] < $b->[0];
	return +1 if $a->[0] > $b->[0];
	my @a = @$a;
	my @b = @$b;
	shift @a;
	shift @b;
	return toggles_compare \@a, \@b;
}
my @rows_sorted = sort { toggles_compare $sortkeys{$a}, $sortkeys{$b} or $a cmp $b } keys %table;

print <<EOF;
<html>
<title>Effects configs</title>
<h1>Effects configs</h1>
<table cellspacing=0>
<tr><th width="40%">cvar</th>
EOF

for my $col(@cols)
{
	print <<EOF;
<th width="@{[60 / @cols]}%">$col</th>
EOF
}

print <<EOF;
</tr>
EOF

for my $row(@rows_sorted)
{
	print <<EOF;
<tr><th>$row</th>
EOF
	my $last = undef;
	my $last_colspan = undef;
	my $total_colspan = 0;
	my $print_last = sub {
		if(defined $last)
		{
			my $colorspan = ($last_colspan * 0.5 + $total_colspan) / @cols;
			my $color = sprintf "#%02x%02x%02x",
				# red-yellow-green transition
				# FF0000 -> FFFF00 -> 00FF00
				($colorspan > 0.5) ? 255 * (2 - 2 * $colorspan) : 255,
				($colorspan < 0.5) ? 255 * (2 * $colorspan) : 255,
				0;
			$total_colspan += $last_colspan;
			print <<EOF;
<td colspan="$last_colspan" align="center" bgcolor="$color">$last</td>
EOF
		}
	};
	for my $col(@cols)
	{
		my $v = $table{$row}{$col};
		if(defined $last && $v == $last)
		{
			++$last_colspan;
		}
		else
		{
			$print_last->();
			$last = $v;
			$last_colspan = 1;
		}
	}
	$print_last->();
	print <<EOF;
</tr>
EOF
}

print <<EOF;
</html>
EOF
