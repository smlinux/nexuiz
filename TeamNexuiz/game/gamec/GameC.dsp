# Microsoft Developer Studio Project File - Name="Game code" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=Game code - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "GameC.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "GameC.mak" CFG="Game code - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Game code - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "Game code - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Game code - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Game_code___Win32_Release"
# PROP BASE Intermediate_Dir "Game_code___Win32_Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Game_code___Win32_Release"
# PROP Intermediate_Dir "Game_code___Win32_Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "GAMECODE_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "GAMECODE_EXPORTS" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x419 /d "NDEBUG"
# ADD RSC /l 0x419 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386

!ELSEIF  "$(CFG)" == "Game code - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "GAMECODE_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "GAMECODE_EXPORTS" /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x419 /d "_DEBUG"
# ADD RSC /l 0x419 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "Game code - Win32 Release"
# Name "Game code - Win32 Debug"
# Begin Group "Header Files"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\builtins.h
# End Source File
# Begin Source File

SOURCE=.\constants.h
# End Source File
# Begin Source File

SOURCE=.\defs.h
# End Source File
# Begin Source File

SOURCE=.\extensions.h
# End Source File
# Begin Source File

SOURCE=.\sys.h
# End Source File
# End Group
# Begin Group "Source Files"

# PROP Default_Filter ""
# Begin Group "client"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\cl_client.c
# End Source File
# Begin Source File

SOURCE=.\cl_impulse.c
# End Source File
# Begin Source File

SOURCE=.\cl_physics.c
# End Source File
# Begin Source File

SOURCE=.\cl_player.c
# End Source File
# Begin Source File

SOURCE=.\mauvebot.c
# End Source File
# End Group
# Begin Group "server"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\sv_main.c
# End Source File
# Begin Source File

SOURCE=.\sv_stats.c
# End Source File
# End Group
# Begin Group "map"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\t_fort.c
# End Source File
# Begin Source File

SOURCE=.\t_halflife.c
# End Source File
# Begin Source File

SOURCE=.\t_items.c
# End Source File
# Begin Source File

SOURCE=.\t_jumppads.c
# End Source File
# Begin Source File

SOURCE=.\t_plats.c
# End Source File
# Begin Source File

SOURCE=.\t_quake.c
# End Source File
# Begin Source File

SOURCE=.\t_quake3.c
# End Source File
# Begin Source File

SOURCE=.\t_teleporters.c
# End Source File
# End Group
# Begin Group "game"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\ctf.c
# End Source File
# Begin Source File

SOURCE=.\domination.c
# End Source File
# Begin Source File

SOURCE=.\g_casings.c
# End Source File
# Begin Source File

SOURCE=.\g_damage.c
# End Source File
# Begin Source File

SOURCE=.\g_decors.c
# End Source File
# Begin Source File

SOURCE=.\g_lights.c
# End Source File
# Begin Source File

SOURCE=.\g_subs.c
# End Source File
# Begin Source File

SOURCE=.\g_tetris.c
# End Source File
# Begin Source File

SOURCE=.\g_triggers.c
# End Source File
# Begin Source File

SOURCE=.\g_violence.c
# End Source File
# Begin Source File

SOURCE=.\g_world.c
# End Source File
# End Group
# Begin Group "class"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\class.c
# End Source File
# Begin Source File

SOURCE=.\engineer.c
# End Source File
# Begin Source File

SOURCE=.\medic.c
# End Source File
# Begin Source File

SOURCE=.\pyro.c
# End Source File
# Begin Source File

SOURCE=.\scout.c
# End Source File
# Begin Source File

SOURCE=.\soldier.c
# End Source File
# Begin Source File

SOURCE=.\spy.c
# End Source File
# End Group
# Begin Group "weapons"

# PROP Default_Filter ""
# Begin Group "pyro"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\w_bombletts.c
# End Source File
# Begin Source File

SOURCE=.\w_flamer.c
# End Source File
# Begin Source File

SOURCE=.\w_hotbombs.c
# End Source File
# Begin Source File

SOURCE=.\w_incendiary_r.c
# End Source File
# End Group
# Begin Group "scout"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\w_hook.c
# End Source File
# Begin Source File

SOURCE=.\w_setrope.c
# End Source File
# End Group
# Begin Group "soldier"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\w_electro.c
# End Source File
# Begin Source File

SOURCE=.\w_namek.c
# End Source File
# Begin Source File

SOURCE=.\w_rocketlauncher.c
# End Source File
# Begin Source File

SOURCE=.\w_shotgun.c
# End Source File
# End Group
# Begin Group "spy"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\tf_w_mac10.c
# End Source File
# Begin Source File

SOURCE=.\w_laser.c
# End Source File
# End Group
# Begin Group "medic"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\w_healgun.c
# End Source File
# Begin Source File

SOURCE=.\w_uzi.c
# End Source File
# End Group
# Begin Group "engineer"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\tf_w_railgun.c
# End Source File
# Begin Source File

SOURCE=.\tfsentry.c
# End Source File
# Begin Source File

SOURCE=.\tftesla.c
# End Source File
# Begin Source File

SOURCE=.\w_crylink.c
# End Source File
# End Group
# Begin Group "unused"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\cl_weaponanimations.c
# End Source File
# Begin Source File

SOURCE=.\w_grenadelauncher.c
# End Source File
# Begin Source File

SOURCE=.\w_hagar.c
# End Source File
# Begin Source File

SOURCE=.\w_nex.c
# End Source File
# End Group
# Begin Source File

SOURCE=.\cl_weapons.c
# End Source File
# Begin Source File

SOURCE=.\cl_weaponsystem.c
# End Source File
# Begin Source File

SOURCE=.\tf_w_pistol.c
# End Source File
# Begin Source File

SOURCE=.\w_common.c
# End Source File
# Begin Source File

SOURCE=.\w_grenades.c
# End Source File
# End Group
# Begin Group "TF map items"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\tfbuttons.c
# End Source File
# Begin Source File

SOURCE=.\tfdoors.c
# End Source File
# Begin Source File

SOURCE=.\tfitems.c
# End Source File
# Begin Source File

SOURCE=.\tfmapitems.c
# End Source File
# Begin Source File

SOURCE=.\tfplats.c
# End Source File
# Begin Source File

SOURCE=.\tfq3fitems.c
# End Source File
# End Group
# Begin Group "TF combat"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\tfai.c
# End Source File
# Begin Source File

SOURCE=.\tfcombat.c
# End Source File
# End Group
# Begin Group "TF Defs&Functs"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\tfdefs.c
# End Source File
# Begin Source File

SOURCE=.\tffunctions.c
# End Source File
# Begin Source File

SOURCE=.\tfmenus.c
# End Source File
# End Group
# Begin Group "TF Client"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\tfclient.c
# End Source File
# End Group
# Begin Group "TF Weaponry"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\tfgrenades.c
# End Source File
# End Group
# End Group
# Begin Source File

SOURCE=..\progs.src
# End Source File
# Begin Source File

SOURCE=..\todo.txt
# End Source File
# End Target
# End Project
