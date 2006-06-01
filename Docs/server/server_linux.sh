#!/bin/sh

executable="nexuiz-linux-686-dedicated"
executable="nexuiz-linux-x86_64-dedicated"

cd "`dirname \"${0}\"`"
exec ./${executable} "${@}" +exec server.cfg
