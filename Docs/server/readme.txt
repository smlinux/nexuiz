In this subdirectoriy you will find scripts and a config file that can
be used to start a dedicated server on linux, mac or windows systems.
You will need to copy the right script into your Nexuiz main
directory, where the normal binaries are.  You then need to copy and
ADJUST the config file which is called server.cfg.  You can copy it
either into the Nexuiz/data directory where the big data*.pk3 file is
or when running linux or a mac you can as well copy it into a special
directory called ~/.nexuiz/data .

An important thing is to make sure that your firewall does allow to
contact your server.  This typicly means you will have to open or
forward the port (see the line <set "port" "26000"> in your config.cfg
for the right port number) to the computer running your server.  How
to do this does depend on your computer setup.

If you plan to install custom maps on your server you should read the
file Docs/mapdownload.txt to learn how to setup automatic map
download.

After you have setup everything and have adjusted the config file you
can start the server by executing the server script.  The options in
the config file are only the most interesting and important ones. You
can find more information about setting up a dedicated server in the
Nexuiz Wiki:
http://savage747.sa.funpic.de/wiki/pmwiki.php?n=Main.DedicatedServer

Some more info about the available variables and commands:
http://savage747.sa.funpic.de/wiki/pmwiki.php?n=Main.GameTweaks
http://savage747.sa.funpic.de/wiki/pmwiki.php?n=Main.ConsoleCommands
