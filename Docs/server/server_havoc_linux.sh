#!/bin/sh

case "$(uname -m)" in
  x86_64)	executable="nexuiz-linux-x86_64-dedicated" ;;
  *)		executable="nexuiz-linux-686-dedicated" ;;
esac

cd `dirname "${0}"`
exec ./${executable} -game havoc +exec server.cfg "${@}"
