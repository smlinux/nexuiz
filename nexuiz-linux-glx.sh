#!/bin/sh

path="`dirname \"${0}\"`"
link="`readlink \"${0}\"`"

lsmod | grep ac97 > /dev/null 2>&1 && sndspeed="-sndspeed 48000"

[ -n "${link}" ] && path="`dirname \"${link}\"`"
cd "${path}"

case "$(uname -m)" in
  x86_64)	nexuiz="nexuiz-linux-x86_64-glx" ;;
  *)		nexuiz="nexuiz-linux-686-glx" ;;
esac

exec ./${nexuiz} "${@}" ${sndspeed}
