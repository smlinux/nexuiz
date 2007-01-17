#!/bin/sh
set -ex

base=`pwd`

case "$version" in
	[0-9]*)
		versiontag=
		ext=_v$version
		version=$version
		;;
	*)
		version=
		;;
esac
case "$versiontag" in
	'')
		;;
	*)
		version='$1'$versiontag
		versiontag=$versiontag
		;;
esac

basepk3=$base/data20060905.pk3
nexdir=$base/nexuiz
dpdir=$base/darkplaces
tmpdir=/tmp/NEX
zipdir=/home/polzer/UT/distfiles/nex/
buildfiles=$base/buildfiles
mingwdlls=$buildfiles/w32
osxapps=$buildfiles/osx
copystrip=$buildfiles/copystrip
fteqcc="fteqcc.bin -O2"
mingw=/home/polzer/mingw32
ia32=/chroot/fc6-i386
osxhost=macmini_osx
osxtemp=/Users/rpolzer/Darkplaces.build
osxsave=/tmp/Nexuiz.osx

if [ -n "$1" ]; then
	osxhost="$1"
fi

: ${date:=`date +%Y%m%d`}
: ${versiontag:=}
echo "date stamp: $date"

buildosx()
{
	rsync --exclude "*.o" --exclude "*.d" --exclude "nexuiz-*" --delete-excluded --delete -zvaSHP . $copystrip "$osxhost:$osxtemp"
	ssh "$osxhost" ". ~/.profile && cd $osxtemp && PATH=$osxtemp/copystrip:\$PATH make CC=\"gcc -g -arch i386 -arch ppc -isysroot /Developer/SDKs/MacOSX10.4u.sdk\" clean $*"
	if [ -d "$osxsave" ]; then
		cp "$osxsave"/* .
	fi
	rsync --exclude "*.o" --exclude "*.d" --delete-excluded --delete -zvaSHP "$osxhost:$osxtemp/." .
	mkdir -p "$osxsave"
	cp nexuiz-* "$osxsave"/
}

build64()
{
	PATH=$copystrip:$PATH make CC="/opt/gcc-4.1.1/bin/gcc -g" "$@"
}

build32()
{
	PATH=$copystrip:$PATH make CC="/opt/gcc-4.1.1/bin/gcc -g -I$ia32/usr/include -I$ia32/usr/X11R6/include -L$ia32/usr/lib -L$ia32/usr/X11R6/lib -m32" DP_MACHINE=i686 "$@"
}

buildwin()
{
	PATH=$copystrip:$mingw/bin:$PATH make CC="gcc -g" DP_MAKE_TARGET=mingw "$@"
}

rm -rf "$tmpdir"
mkdir -p "$tmpdir"
cd "$dpdir"

cp -r "$osxapps"/*.app "$tmpdir"
mkdir "$tmpdir/debuginfo"
rm -f *.exe nexuiz-* *-withdebug

make clean
buildosx sdl-nexuiz cl-nexuiz sv-nexuiz
cp nexuiz-agl "$tmpdir/Nexuiz.app/Contents/MacOS/nexuiz-osx-ppc-agl-bin"
cp nexuiz-dedicated "$tmpdir/nexuiz-osx-ppc-dedicated"
cp nexuiz-sdl "$tmpdir/Nexuiz-SDL.app/Contents/MacOS/nexuiz-osx-ppc-sdl-bin"
cp nexuiz-agl-withdebug "$tmpdir/debuginfo/nexuiz-osx-ppc-agl-bin"
cp nexuiz-dedicated-withdebug "$tmpdir/debuginfo/nexuiz-osx-ppc-dedicated-bin"
cp nexuiz-sdl-withdebug "$tmpdir/debuginfo/nexuiz-osx-ppc-sdl-bin"

make clean
buildwin nexuiz
for x in -dedicated -sdl ''; do
	cp nexuiz$x.exe "$tmpdir/nexuiz$x.exe"
	cp nexuiz$x.exe-withdebug "$tmpdir/debuginfo/nexuiz$x.exe"
done

make clean
build32 nexuiz
for x in dedicated sdl glx; do
	cp nexuiz-$x "$tmpdir/nexuiz-linux-686-$x"
	cp nexuiz-$x-withdebug "$tmpdir/debuginfo/nexuiz-linux-686-$x"
done

make clean
build64 nexuiz
for x in dedicated sdl glx; do
	cp nexuiz-$x "$tmpdir/nexuiz-linux-x86_64-$x"
	cp nexuiz-$x-withdebug "$tmpdir/debuginfo/nexuiz-linux-x86_64-$x"
done

cp "$nexdir/"nexuiz-*.{sh,bat} "$tmpdir/"
cp "$nexdir/gpl.txt" "$tmpdir/"

make clean
rm -f *.exe nexuiz-* *-withdebug '.#'*

cd "$nexdir/data"
svn export . "$tmpdir/data"

cd "$nexdir/Docs"
svn export . "$tmpdir/Docs"

cd "$tmpdir/data"
mkdir -p "$tmpdir/sources"
#zip -9r ../sources/gamesource$date.zip qcsrc
7za a -mx=9 -tzip ../sources/gamesource$date.zip qcsrc

cd "$dpdir"
rm -f ChangeLog*
cvs2cl.pl

cd "$dpdir/.."
#zip -9r "$tmpdir/sources/enginesource$date.zip" "${dpdir##*/}"
7za a -mx=9 -tzip "$tmpdir/sources/enginesource$date.zip" "${dpdir##*/}"

cd "$tmpdir/data/qcsrc/menu"
$fteqcc

cd "$tmpdir/data/qcsrc/server"
$fteqcc

rm -rf "$tmpdir/data/qcsrc"

cd "$tmpdir/Docs"
perl -pi -e '/^#---SET nexversion=([0-9.]*)$/ and $_ = "#---SET nexversion='$version'\n"' FAQ.aft
perl -pi -e '/^\s*Version ([0-9.]*)<\/div>$/ and $_ = "Version '$version'</div>\n"' Readme.htm
aft FAQ.aft
aft FAQ.aft
rm FAQ.aft-TOC

cd "$tmpdir/data"
mv common-spog.pk3 ..
perl -pi -e '/^set g_nexuizversion "([0-9.]*)[^"]*"/ and $_ = "set g_nexuizversion \"'$version'\"\n"' default.cfg
if [ -n "$versiontag" ]; then
	perl -pi -e '/^set g_nexuizversion/ and $_ = "showbrand 1\n$_"' default.cfg
	cp "$buildfiles/brand/$versiontag.tga" gfx/brand.tga
fi
7za a -mx=7 -tzip ../data.pk3 .

cd "$tmpdir"
rm -rf data
mkdir data
mv data.pk3 data/data$date.pk3
mv common-spog.pk3 data/

cp -r "$mingwdlls"/* .
# fix up permissions
chmod 644 *.dll *.exe

mkdir Nexuiz
mv * Nexuiz/ || true

find . -name .svn -exec rm -rf {} \; -prune

rm -f "$zipdir/nexuiz$date$ext.zip"
zip -9yr "$zipdir/nexuiz$date$ext.zip"           Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll Nexuiz/sources Nexuiz/Docs Nexuiz/data/data$date.pk3 Nexuiz/data/common-spog.pk3
rm -f "$zipdir/nexuizengineonly$date$ext.zip"
zip -9yr "$zipdir/nexuizengineonly$date$ext.zip" Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll
rm -f "$zipdir/nexuizsource$date$ext.zip"
zip -9yr "$zipdir/nexuizsource$date$ext.zip"     Nexuiz/gpl.txt                                            Nexuiz/sources

zipdiff -o "Nexuiz/data/datapatch$date.pk3" -f "$basepk3" -t Nexuiz/data/data$date.pk3
mkdir -p gfx
if unzip "Nexuiz/data/data$date.pk3" gfx/brand.tga; then
	zip -9r "Nexuiz/data/datapatch$date.pk3" gfx/brand.tga
	rm -rf gfx
fi

rm -f "$zipdir/nexuizpatch$date$ext.zip"
zip -9yr "$zipdir/nexuizpatch$date$ext.zip"      Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll Nexuiz/sources Nexuiz/Docs Nexuiz/data/datapatch$date.pk3

rm -f "$zipdir/nexuizdebug$date$ext.zip"
zip -9yr "$zipdir/nexuizdebug$date$ext.zip"      Nexuiz/gpl.txt Nexuiz/debuginfo/*
