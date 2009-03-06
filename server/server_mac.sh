#!/bin/sh

executable="nexuiz-osx-dedicated"

cd "`dirname "${0}"`"
exec ./${executable} +serverconfig server.cfg "${@}"
