use strict;
use warnings;

my @colors = (
	'cccccc',
	'996600',
	'00ff80',
	'00ff00',
	'ff0000',
	'00a8ff', # was: 0080ff, green increased
	'00ffff',
	'80ff00',
	'8000ff',
	'ff00ff',
	'ff0080',
	'999999',
	'ffff00',
	'0050ff', # was: 0000ff, green increased so the color is perceptively just as bright as red (for teamplay)
	'ff8000',
	'000000'
);

my $value_min = 0x0F;
my $value_max = 0xFF;

my $i = 0;
for(@colors)
{
	/^(..)(..)(..)$/ or die "invalid color spec: $_";
	my $r = hex $1;
	my $g = hex $2;
	my $b = hex $3;
	printf "%c%c%c", map { int(0.5 + $value_min + ($_ * 1.0 / 0xFF) * ($value_max - $value_min)) } $r, $g, $b;
	printf STDERR "\t\tcase %2d: return '%f %f %f';\n", $i, $r / 0xFF, $g / 0xFF, $b / 0xFF;
	++$i;
}
