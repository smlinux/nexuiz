Q3MAP2="q3map2 -v -game quake3 -fs_basepath ../../ -fs_game data"
MAP=bloodprisonctf.map
$Q3MAP2 -meta -samplesize 8 -mv 1000000 -mi 6000000 $MAP
$Q3MAP2 -scale 1.2 $MAP
$Q3MAP2 -vis $MAP
$Q3MAP2 -light -deluxe -fast -filter -deluxe -patchshadows -samples 3 $MAP

# nexuiz-map-compiler bloodprisonctf -scale 1.2 -bsp -samplesize 8 -light -deluxe -fast -filter -deluxe -patchshadows -samples 3
