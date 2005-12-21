Title		: NavNodeEdit
Filename	: ...
Version		: ?
Date		: ?
Author		: Marko "Urre" Permanto
Email		: imunreal A to the T gmail D to the O to the T com
Website		: http://urre.quakedev.com/
Credits		: LordHavoc for teaching me a lot about QuakeC
		  Ender for scratch tutorials
		  id Software for various good things
		  Stribbs for inspiration to improve this editor

Type of Mod
-----------
Quake C		: aye!
Sound		: no
MDL		: Yes
Level		: no
Gfx		: no

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
mb1 = No effect (feel free to suggest what this button could do)
mb2 = lock/unlock selection (unlocking will delete all clip points)
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
	Solution: re-aim slightly and try again.
2) Resizing sometimes doesn't go all the way.
	Cause: Unknown.
	Solution: Re-resize with same parameters until it reaches the desired
	size.

Legal
-----
Authors MAY use this Quake modification as a basis for other publicly
available work, as long as I am credited. Please send me any modifications
you make.

You may distribute this Quake modification in any electronic format as long
as this description file remains intact and unmodified and is retained along
with all of the files in the archive.

You are not allowed to sell this Quake modification for money without my
permission.

Quake is copyrighted and trademarked, owned by id Software.