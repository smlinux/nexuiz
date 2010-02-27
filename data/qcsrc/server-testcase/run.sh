#!/bin/sh

if [ "$#" -lt 3 ]; then
	echo "Usage: $0 'float test() { if(fail) return 0; else if(good) return 1; else return -1; }' ./darkplaces-dedicated basement +sv_cheats 1"
	exit 125
fi

case "$0" in
	*/*)
		dir=${0%/*}
		;;
	*)
		dir=`pwd`
		;;
esac
testcase=$1; shift
engine=$1; shift
map=$1; shift
echo "$testcase" > "$dir/testcase.qc"
if ( cd $dir && fteqcc ); then
	r=`"$engine" -nexuiz -basedir "$dir/../../.." +sv_progs progs-testcase.dat "$@" +map "$map" | tee /dev/stderr`
	case "$r" in
		*"TESTCASE: PASS"*)
			echo "PASS detected"
			exit 0
			;;
		*"TESTCASE: FAIL"*)
			echo "FAIL detected"
			exit 1
			;;
		*"TESTCASE: INVALID"*)
			echo "INVALID detected"
			exit 125
			;;
		*)
			echo "Running failed"
			exit 125
			;;
	esac
else
	echo "Compilation failed"
	exit 125
fi
