#!/bin/sh

executable="nexuiz-osx-dedicated"

cd "`dirname "${0}"`"
exec ./${executable} -game havoc +serverconfig server.cfg "${@}"
