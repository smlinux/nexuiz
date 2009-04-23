#!/usr/bin/perl

use strict;
use warnings;

my $out = "";
my %found;

open my $fh, '<', 'effectinfo.txt';
while(<$fh>)
{
	chomp;

	next if /^\/\/ used in /;
	next if /^\/\/ used nowhere in code$/;

	if(/^effect\s+([^\s\/]+)\s*(?:\/\/.*)?$/i)
	{
		if(!$found{$1})
		{
			print STDERR "Handling $1...\n";
			$found{$1} = 1;
			my $search = $1;
			my $search2 =
				$1 eq 'TR_BLOOD' ? 'MF_GIB' :
				$1 eq 'TR_SLIGHTBLOOD' ? 'MF_ZOMGIB' :
				$1 eq 'TR_WIZSPIKE' ? 'MF_TRACER' :
				$1 eq 'TR_KNIGHTSPIKE' ? 'MF_TRACER2' :
				$1 eq 'TR_ROCKET' ? 'MF_ROCKET' :
				$1 eq 'TR_GRENADE' ? 'MF_GRENADE' :
				$1 eq 'TR_VORESPIKE' ? 'MF_TRACER3' :
				$1;
			local $ENV{effectre} =
				$search eq lc $search
					? "\"$search\"|\"$search2\""
					: "\"$search\"|\\<" . lc($search) . "\\>|\\<" . $search . "\\>|"
					. "\"$search2\"|\\<" . lc($search2) . "\\>|\\<" . $search2 . "\\>";
			print "$ENV{effectre}\n";
			my $occurrences = `grep -E "\$effectre" qcsrc/server/*.qc qcsrc/client/*.qc`;
			$occurrences =~ s/\r/\n/g;
			$occurrences =~ s/;//g;
			my $found = 0;
			for(split /\n/, $occurrences)
			{
				next if $_ eq '';
				next if /^qcsrc\/server\/gamecommand\.qc:/; # list of quake effects is there
				next if /^qcsrc\/client\/csqc_builtins\.qc:/; # list of quake effects is there
				next if /^qcsrc\/client\/csqc_constants\.qc:/; # list of quake effects is there
				$out .= "// used in $_\n";
				$found = 1;
			}
			if(!$found)
			{
				$out .= "// used nowhere in code\n";
			}
		}
	}

	$out .= "$_\n";
}
close $fh;

open $fh, '>', 'effectinfo.txt';
print $fh $out;
close $fh;
