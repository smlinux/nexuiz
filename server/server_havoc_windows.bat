@echo off

setlocal
set executable=nexuiz -dedicated

%~d0
cd "%~p0"
.\%executable% -game havoc +serverconfig server.cfg %*
