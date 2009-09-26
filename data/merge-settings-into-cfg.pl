#!/usr/bin/perl

use strict;
use warnings;

my ($in, $out) = @ARGV;

my %changes = ();
while(<STDIN>)
{
	chomp;
	/^(?:seta?\s)?\s*(\S+)\s+(.*)/
		or next;
	$changes{$1} = $2;
}

my %changes_unapplied = %changes;
my $result = "";
open my $fh, "<", $in
	or die "<$in: $!";
while(<$fh>)
{
	chomp;
	/^(seta?\s?\s*)(\S+)(\s+)(.*)/
		or do { $result .= "$_\n"; next; };
	my $v = exists($changes{$2}) ? $changes{$2} : $4;
	$result .= "$1$2$3$v\n";
	delete $changes_unapplied{$2};
}
close $fh;
open $fh, ">", $out
	or die ">$out: $!";
print $fh $result;
print $fh "set $_ $changes_unapplied{$_}\n" for keys %changes_unapplied;
close $fh;
