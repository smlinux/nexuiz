#!/bin/sh

set -ex
gcc -Wall -Wextra ttf2conchars.c `sdl-config --cflags --libs` -lSDL_ttf -lSDL_image -ggdb3
#./a.out source.tga /home/rpolzer/.nexuiz/data/gfx/vera-sans.tga /usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf /usr/share/fonts/truetype/ttf-bitstream-vera/VeraSeBd.ttf /usr/share/fonts/truetype/ttf-bitstream-vera/VeraBI.ttf 0.05 0.004 0.000000000000001
#./a.out source.tga 0 56 /home/rpolzer/.nexuiz/data/gfx/vera-sans.tga /usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf "" "" 0.05 0.004 0.000000000000001
./a.out ~/software/games/nexuiz/data/gfx/conchars.tga 0 56 64 /home/rpolzer/.nexuiz/data/gfx/vera-sans.tga /usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf "" "" 0.05 0.004 0.000000000000001
#./a.out source.tga /home/rpolzer/.nexuiz/data/gfx/conchars.tga /usr/share/fonts/truetype/ttf-bitstream-vera/VeraMoBd.ttf /usr/share/fonts/truetype/ttf-bitstream-vera/VeraSeBd.ttf /usr/share/fonts/truetype/ttf-bitstream-vera/VeraBI.ttf 0.05 0.004 0.000000000000001
display /home/rpolzer/.nexuiz/data/gfx/vera-sans.tga
