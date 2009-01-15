This subdirectory contains scripts and a config file that can be used
to start a dedicated Nexuiz (default) or Nexuiz Havoc server (differs
in movement and weapon settings) on linux, mac or windows systems and
also some tools that help with maintaining your server.

You will need to copy the right script into your Nexuiz main
directory, where the normal binaries are.  There are two scrips for
each sytems, one to start a normal Nexuiz server and one to start a
Nexuiz 'Havoc' server.  You then need to copy and ADJUST the config
file which is called server.cfg.  You can copy it either into the
Nexuiz/data directory where the big data*.pk3 file is or when running
on linux or mac you can as well copy it into a special directory
called ~/.nexuiz/data

After you have setup everything and have adjusted the config file you
can start the server by running the server script.  The options in the
config file are only the most interesting and important ones.

Please make sure your server is always uptodate!  Just signup the
Nexuiz release mailinglist to get informed about new releases.
https://lists.sourceforge.net/lists/listinfo/nexuiz-releases

An important thing is to make sure that your firewall does allow
players to connect to your server.  This typicly means you will have
to open or forward the port (see the line that sets the variable port
in your config.cfg for the right port number, default is 26000) to the
computer running your server.  How to do this does depend on your
computer and network setup.

If you plan to install custom maps on your server you should read the
file Docs/mapdownload.txt to learn how to setup automatic map
download.

You can find more information about setting up a dedicated server in
the Nexuiz Wiki:
http://alientrap.org/wiki/pmwiki.php?n=Main.DedicatedServer

Some more info about the available variables and commands:
http://alientrap.org/wiki/pmwiki.php?n=Main.GameTweaks
http://alientrap.org/wiki/pmwiki.php?n=Main.ConsoleCommands

rcon2irc is a Nexuiz server to irc gateway.  It allows you to watch
and communicate with active players on your server via irc.  Read its
rcon2irc.txt to learn how to setup and use it!

rcon.pl is a perl script that implements rcon which can be used to
remotely control your server.

help.cfg is a nexuiz config file proving a simple help message system.
It prints all the messages from a list, one after the other with an
configureable delay between them.  Great to provide beginners with
some hints.
