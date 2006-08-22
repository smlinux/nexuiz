#!/bin/sh

path="`dirname \"${0}\"`"
link="`readlink \"${0}\"`"

[ -n "${link}" ] && path="`dirname \"${link}\"`"
cd "${path}"

case "$(uname -m)" in
  x86_64)	nexuiz="nexuiz-linux-x86_64-glx" ;;
  *)		nexuiz="nexuiz-linux-686-glx" ;;
esac

exec ./${nexuiz} "${@}"
