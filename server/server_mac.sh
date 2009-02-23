#!/bin/sh

executable="nexuiz-osx-dedicated"

cd "`dirname "${0}"`"
exec ./${executable} +exec server.cfg "${@}"
