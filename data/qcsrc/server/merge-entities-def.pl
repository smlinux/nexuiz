#!/usr/bin/perl

use strict;
use warnings;

my %spawnfuncs;
my %entitiesdef;

-f "qc.asm"
	or (system 'fteqcc -Fwasm'
		and die "fteqcc died");
open my $fh, '<', 'qc.asm'
	or die "qc.asm: $!";
while(<$fh>)
{
	chomp;
	/^void \(\) spawnfunc_(.*);$/
		and $spawnfuncs{$1} = 1;
}
close $fh;

open $fh, '+<', '../../entities.def'
	or die "entities.def: $!";
my $s = do { undef local $/; <$fh>; };
while($s =~ s/\n\/\*QUAKED (\S+) (.*?)\*\//\n/s)
{
	$entitiesdef{$1} = $2;
}

use Data::Dumper;
print Dumper \%entitiesdef;

I KNOW THIS WON'T COMPILE, I WILL FINISH IT LATER
example description
"(0 .5 0) (-8 -8 -8) (8 8 8)
Aiming target for entities like light, misc_portal_camera and trigger_push (jump pads) in particular.
-------- KEYS --------
targetname : the entity that requires an aiming direction points to this.
notfree : when set to 1, entity will not spawn in "Free for all" and "Tournament" modes.
notteam : when set to 1, entity will not spawn in "Teamplay" and "CTF" modes.
notsingle : when set to 1, entity will not spawn in Single Player mode (bot play mode).
-------- NOTES --------
To make a jump pad, place this entity at the highest point of the jump and target it with a trigger_push entity."
