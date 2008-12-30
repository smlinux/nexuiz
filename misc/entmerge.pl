#!/usr/bin/perl

use strict;
use warnings;

# ent file managing tool
# usage:
#
#   map -> ent:
#     perl entmerge.pl $scalefactor             < mapname.map > mapname.ent
#
#   ent -> map:
#     perl entmerge.pl $scalefactor mapname.ent < mapname.map > mapname-merged.map
#
#   bsp -> ent:
#     perl bsptool.pl mapname.bsp -xentities                  > mapname.ent
#                                                          
#   ent -> bsp:                                            
#     perl bsptool.pl mapname.bsp -rentities                  < mapname.ent

sub BrushOrigin($)
{
	warn "Origin brushes not supported yet";
	return undef;
}

sub ParseEntity($)
{
	my ($fh) = @_;

	my %ent = ( );
	my @brushes = ( );

	while(<$fh>)
	{
		chomp; s/\r//g; s/\0//g; s/\/\/.*$//; s/^\s+//; s/\s+$//; next if /^$/;

		if(/^\{$/)
		{
			# entity starts
			while(<$fh>)
			{
				chomp; s/\r//g; s/\0//g; s/\/\/.*$//; s/^\s+//; s/\s+$//; next if /^$/;

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
						chomp; s/\r//g; s/\0//g; s/\/\/.*$//; s/^\s+//; s/\s+$//; next if /^$/;

						if(/^\{$/)
						{
							# patch?
							push @$brush, $_;

							while(<$fh>)
							{
								chomp; s/\r//g; s/\0//g; s/\/\/.*$//; s/^\s+//; s/\s+$//; next if /^$/;

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
			die "Unexpected line in top level: >>$_<<";
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

my ($scale, $in_ent) = @ARGV;

$scale = 1
	if not defined $scale;

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
		delete $ent->{_keeplights};
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

		if(grep { $_ eq $ent->{classname} } qw/group_info func_group misc_model _decal _skybox/)
		{
			push @entities_skipped, [$ent, $brushes];
			next;
		}

		if(!$keeplights && $ent->{classname} =~ /^light/)
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

if($first)
{
	push @entities, { classname => "worldspawn" };
	@submodels = ([]);
}

if(defined $in_ent)
{
	# translate map using ent to map
	open my $fh, "<", $in_ent
		or die "$in_ent: $!";

	# THIS part is always an .ent file now
	my @entities_entfile = ();
	$first = 1;
	for(;;)
	{
		my ($ent, $brushes) = ParseEntity $fh;

		defined $ent
			or last;
		
		if($first && $ent->{classname} eq 'worldspawn')
		{
		}
		else
		{
			if($first)
			{
				push @entities_entfile, { classname => "worldspawn" };
			}

			if($ent->{classname} eq 'worldspawn')
			{
				$ent->{classname} = "worldspawn_renamed";
			}
		}

		push @entities_entfile, $ent;
		$first = 0;
	}
	close $fh;

	if($first)
	{
		push @entities_entfile, { classname => "worldspawn" };
	}

	$first = 1;
	for(@entities_entfile)
	{
		my %e = %$_;
		my $submodel = undef;

		$e{gridsize} = "64 64 128" if not exists $e{gridsize};
		$e{lip} /= $scale if exists $e{lip};
		$e{origin} = join ' ', map { $_ / $scale } split /\s+/, $e{origin} if exists $e{origin};
		$e{gridsize} = join ' ', map { $_ / $scale } split /\s+/, $e{gridsize} if exists $e{gridsize} and $first;

		if($first)
		{
			$submodel = $submodels[0];
			$e{_keeplights} = 1
				if $keeplights;
		}
		elsif(defined $e{model} and $e{model} =~ /^\*(\d+)$/)
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
		my %e = %$_;

		if(defined $e{model} and $e{model} =~ /^\*(\d+)$/)
		{
			my $org = BrushOrigin $submodels{$e{origin}};
			$e{origin} = $org
				if defined $org;
		}

		$e{gridsize} = "64 64 128" if not exists $e{gridsize};
		$e{lip} *= $scale if exists $e{lip};
		$e{origin} = join ' ', map { $_ * $scale } split /\s+/, $e{origin} if exists $e{origin};
		$e{gridsize} = join ' ', map { $_ * $scale } split /\s+/, $e{gridsize} if exists $e{gridsize} and $first;

		print UnparseEntity \%e, undef;
		$first = 0;
	}
}
