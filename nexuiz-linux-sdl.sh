#!/bin/sh

path="`dirname \"${0}\"`"
link="`readlink \"${0}\"`"

[ -n "${link}" ] && path="`dirname \"${link}\"`"
cd "${path}"

case "$(uname -m)" in
  x86_64)	nexuiz="nexuiz-linux-x86_64-sdl" ;;
  *)		nexuiz="nexuiz-linux-686-sdl" ;;
esac

exec ./${nexuiz} "${@}"
