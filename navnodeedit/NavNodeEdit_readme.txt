Title		: NavNodeEdit
Version		: 0.9
Date		: 20060129
Author		: Marko "Urre" Permanto
Email		: imunreal A to the T gmail D to the O to the T com
Website		: http://urre.quakedev.com/
Credits		: LordHavoc for teaching me a lot about QuakeC
		  Ender for scratch tutorials
		  Chris Voss for the menu system
		  id Software for various good things
		  Stribbs for inspiration to improve this editor

Type of Mod
-----------
Quake C		: aye!
Sound		: no
MDL		: Yes
Level		: no
Gfx		: Uh-huh

Format of QuakeC (if a Quake C Mod)
-----------------------------------
unified diff  : no
context diff  : no
.qc files     : yes
progs.dat     : yes

Description of the Modification
-------------------------------
Previously called WayBoxEdit, this mod has evolved into something I like to
call NavNodeEdit, this because it is no longer restricted to arbitrary boxes,
nor touching links. It now supports planes to shape the boxes into different
shapes, and supports remote links ala waypoints. Not as cool as building all
the info out of planes, like MrElusives navigation systems do (Omicron bot,
Gladiator bot, and Q3A bots). I might do that once I figure out BSP trees,
which is when it would be even remotely plausible, for performance reasons.
This system should still cover most needs.

I recommend the DarkPlaces engine, FTE might be supported in the future.

A word of *WARNING* to anyone interested in checking out the sourcecode:
This is the only project I've written merely to get it done ASAP, I did not
plan the code *at all*, so it's probably the messiest and hardest to
maintain/update code I've ever written. You have been warned.

Controls and Impulses
--------
WARNING: These instructions are *not* pedagogical!

+button3 and +button4 in combination with other buttons are used for various
types of control. For example, if you hold down +button3, aim at a wall and
press +button0, the current navnode will resize on the current axis to where
you aimed.

+button3 = resizing navnodes.
+button4 = movement of navnodes and clip points.
+button3 and +button4 = plane control.

The effect that +button0 and/or +button2 has depends on which of these
"help-buttons" are held down, if at all. Impulse 101 and impulse 102 are
special in the way that they also have different effects depending on this.
By default, +button0 is bound to mousebutton1, +button2 is bound to
mousebutton2, impulse 101 to scrollwheel-up, impulse 102 to scrollwheel-down,
+button3 to shift, +button4 is to ctrl.

Here follows a list of actions, assuming the default binds (mb1 and mb2 are
mousebuttons):
	(no help-button)
mb1 = Teleport yourself to aimed location
mb2 = lock/unlock selection (*NOTE*: unlocking will delete all clip points)
scroll-wheel = change gridsize
	SHIFT
mb1 = resize to aimed geometry on current axis
mb2 = resize to self.origin on all axis
scroll-wheel = resize on current axis
	CTRL
mb1 = move on all axis to aim
mb2 = move on all axis to self
scroll-wheel = move on current axis
	SHIFT+CTRL
mb1 = spawn/delete plane (if no clip points are present, will make plane on
      aimed geometry. deletion only happens if new plane matches with old)
mb2 = spawn clip point (requires selection lock, up to 3 allowed and required)
scroll-wheel = switch selected clip point if available, else switch selected
	       plane

The say command is used for various things that require extra parameters. Here
follow the possible commands (say them without the quotation marks):

"origin [vector]" = will move the navnode to the desired origin, unaffected by
		    the grid.
"resize [worldspace on current axis]" = will resize a navnode's edge to the
					issued worldspace parameter, unaffected
					by the grid.
"save" = Saves the navnode list (future versions will provide possibility to
	 issue filename).
"load" = Loads navnode list (future versions will provide possibility to
	 issue filename).
"teleport" = gives the Special flag S_TELEPORT to the current navnode.
"door" = gives the Special flag S_DOOR to the current navnode.
"nolink [optional number]" = will give the Link flag FL_NOLINK to the current
			     navnode. If no number is issued, it will look for
			     your secondary-selected navnode, check if it is a
			     valid link, and issue the number automaticly.
"nowalk [optional number]" = will give the Link flag FL_NOWALK to the current
			     navnode. If no number is issued, it will look for
			     your secondary-selected navnode, check if it is a
			     valid link, and issue the number automaticly.
"bad [optional number]" = will give the Link flag FL_BAD to the current
			  navnode. If no number is issued, it will look for your
			  secondary-selected navnode, check if it is a valid
			  link, and issue the number automaticly.
"bigdrop [optional number]" = will give the Link flag FL_BIGDROP to the current
			      navnode. If no number is issued, it will look for
			      your secondary-selected navnode, check if it is a
			      valid link, and issue the number automaticly.
"remote" = will give the Link flag FL_REMOTE to the current navnode. Secondary-
	   selected navnode is required.

There are a number of impulses as well, which are important. The default bind
is listed next to the impulse number:

Impulse	Bind		Effect
1-9	1-9		Menu selection
101	wheelup		Described above
102	wheeldown	Described above
110	N		Spawn new navnode (requires selection to be unlocked)
111	R		Delete current navnode
112	P		Delete current plane
120	O		Switches selected navnode when in overlap-selection-mode
121	M		Switches selection mode between closest, and overlap
122	TAB		Cycles current axis
123	X		Switches to X axis
124	Y		Switches to Y axis
125	Z		Switches to Z axis

Good Luck!

Known Bugs
----------
1) Sometimes when doing something against aimed geometry, the aim goes through
	the wall.
	Cause: The DarkPlaces engine has collision issues in q3bsp, thus
	nothing I can affect.
	Workaround: re-aim slightly and try again until it works.
2) Resizing (most often down-sizing) sometimes doesn't go all the way.
	Cause: Unknown.
	Workaround: Re-resize with same parameters until it reaches the desired
	size.
3) Link flags mess up after saving and loading the navnode file
	Cause: Unknown. (I do have a clue though)
	Workaround: save the navnode file, restart the map, load the navnode
	file, and without making other changes, fix the flags and save again.
	If you make flag-unrelated changes, it's likely to mess up flags on
	closeby navnodes, at which point you need to repeat the steps. I'd
	recommend making flag related stuff after you've made everything else.

Legal
-----
This is a special version of the NavNodeEditor, donated to the Nexuiz team,
thus it is released under the same license as Nexuiz. See relevant documents
for more information.