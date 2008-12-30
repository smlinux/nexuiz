#!/usr/bin/perl

use strict;
use warnings;

# ent file managing tool
# usage:
#
#   map -> ent:
#     perl entmerge.pl             < mapname.map > mapname.ent
#
#   ent -> map:
#     perl entmerge.pl mapname.ent < mapname.map > mapname-merged.map
#
#   bsp -> ent:
#     perl bsptool.pl mapname.bsp -xentities     > mapname.ent
#
#   ent -> bsp:
#     perl bsptool.pl mapname.bsp -rentities     < mapname.ent

sub ParseEntity($)
{
	my ($fh) = @_;

	my %ent = ( );
	my @brushes = ( );

	while(<$fh>)
	{
		chomp; s/\/\/.*$//; s/^\s+//; s/\s+$//; next if /^$/;

		if(/^\{$/)
		{
			# entity starts
			while(<$fh>)
			{
				chomp; s/\/\/.*$//; s/^\s+//; s/\s+$//; next if /^$/;

				if(/^"(.*?)" "(.*)"$/)
				{
					# key-value pair
					$ent{$1} = $2;
				}
				elsif(/^\{$/)
				{
					my $brush = [];
					push @brushes, $brush;

					while(<$fh>)
					{
						chomp; s/\/\/.*$//; s/^\s+//; s/\s+$//; next if /^$/;

						if(/^\{$/)
						{
							# patch?
							push @$brush, $_;

							while(<$fh>)
							{
								chomp; s/\/\/.*$//; s/^\s+//; s/\s+$//; next if /^$/;

								if(/^\}$/)
								{
									push @$brush, $_;

									last;
								}
								else
								{
									push @$brush, $_;
								}
							}
						}
						elsif(/^\}$/)
						{
							# end of brush
							last;
						}
						else
						{
							push @$brush, $_;
						}
					}
				}
				elsif(/^\}$/)
				{
					return \%ent, \@brushes;
				}
			}
		}
		else
		{
			die "Unexpected line in top level: $_";
		}
	}

	return undef;
}

sub UnparseEntity($$)
{
	my ($ent, $brushes) = @_;
	my %ent = %$ent;

	my $s = "{\n";

	for(sort keys %ent)
	{
		$s .= "\"$_\" \"$ent{$_}\"\n";
	}

	if(defined $brushes)
	{
		for(@$brushes)
		{
			$s .= "{\n";
			$s .= "$_\n" for @$_;
			$s .= "}\n";
		}
	}

	$s .= "}\n";
	return $s;
}

my ($in_ent) = @ARGV;

my @submodels = ();
my @entities = ();
my @entities_skipped = ();

# THIS part is always a .map file
my $first = 1;
my $keeplights;
for(;;)
{
	my ($ent, $brushes) = ParseEntity \*STDIN;

	defined $ent
		or last;
	
	if($first && $ent->{classname} eq 'worldspawn')
	{
		$keeplights = $ent->{_keeplights};
		@submodels = ($brushes);
	}
	else
	{
		if($first)
		{
			push @entities, { classname => "worldspawn" };
			@submodels = ([]);
		}

		if($ent->{classname} eq 'worldspawn')
		{
			$ent->{classname} = "worldspawn_renamed";
		}

		if(grep { $_ eq $ent->{classname} } (qw/group_info func_group misc_model _decal _skybox/, ($keeplights ? qw// : qw/light/)))
		{
			push @entities_skipped, [$ent, $brushes];
			next;
		}

		if(@$brushes)
		{
			my $i = @submodels;
			push @submodels, $brushes;
			$ent->{model} = sprintf "*%d", $i;
		}
	}

	push @entities, $ent;

	$first = 0;
}

if(defined $in_ent)
{
	# translate map using ent to map
	open my $fh, "<", $in_ent
		or die "$in_ent: $!";

	# THIS part is always an .ent file now
	my @entities_entfile = ();
	$first = 1;
	while(<STDIN>)
	{
		my ($ent, $brushes) = ParseEntity $fh;
		push @entities_entfile, $ent;
		$first = 0;
	}
	close $fh;

	$first = 1;
	for(@entities)
	{
		my %e = %$_;
		my $submodel = undef;
		if($first)
		{
			$submodel = $submodels[0];
		}
		elsif($e{model} =~ /^\*(\d+)$/)
		{
			$submodel = $submodels[$1];
			delete $e{model};
		}
		print UnparseEntity \%e, $submodel;
		$first = 0;
	}
	for(@entities_skipped)
	{
		print UnparseEntity $_->[0], $_->[1];
		$first = 0;
	}
}
else
{
	# translate map to ent
	$first = 1;
	for(@entities)
	{
		print UnparseEntity $_, undef;
		$first = 0;
	}
}
