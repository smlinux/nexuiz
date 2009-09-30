#!/bin/bash

width=512
height=64

sprwidth=512
sprheight=64

pngsprite()
{
	local name text color bgcolor
	name=$1
	color=$2
	bgcolor=$3
	text=$4
	svgwidth=1024
	svgheight=128

	cat <<EOF >$name.svg
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://web.resource.org/cc/"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="1024"
   height="128"
   id="svg2"
   sodipodi:version="0.32"
   inkscape:version="0.45"
   version="1.0"
   inkscape:export-filename="bluebase.tga"
   inkscape:export-xdpi="90"
   inkscape:export-ydpi="90"
   sodipodi:docname="template.svg"
   sodipodi:docbase="/home/rpolzer/software/games/nexuiz/data/models/sprites"
   inkscape:output_extension="org.inkscape.output.svg.inkscape"
   sodipodi:modified="true">
  <defs
     id="defs4" />
  <sodipodi:namedview
     id="base"
     pagecolor="#$bgcolor"
     bordercolor="#666666"
     borderopacity="1.0"
     gridtolerance="10000"
     guidetolerance="10"
     objecttolerance="10"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="0.98994949"
     inkscape:cx="375"
     inkscape:cy="75.53288"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     width="1024px"
     height="128px"
     showgrid="true"
     gridspacingx="8px"
     gridspacingy="8px"
     gridempspacing="8"
     inkscape:grid-points="true"
     showguides="true"
     inkscape:guide-bbox="true"
     inkscape:window-width="849"
     inkscape:window-height="590"
     inkscape:window-x="198"
     inkscape:window-y="66" />
  <metadata
     id="metadata7">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1">
    <path
       style="opacity:1;fill:#$color;fill-opacity:1;stroke:#$bgcolor;stroke-width:3;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 512,124 L 536,100 L 520,100 L 520,60 L 504,60 L 504,100 L 488,100 L 512,124 z "
       id="path1872"
       sodipodi:nodetypes="cccccccc" />
    <text
       xml:space="preserve"
       style="font-size:120px;font-weight:bold;text-align:center;text-anchor:middle;opacity:1;fill:#$color;fill-opacity:1;stroke:#$bgcolor;stroke-width:3;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;font-family:xscale"
       x="512"
       y="50"
       id="text1874"><tspan
         sodipodi:role="line"
         id="tspan1876"
         x="255.49414"
         y="49.957031">$text</tspan></text>
  </g>
</svg>
EOF
	enlargex=$(($sprwidth - $width))
	enlargey=$(($sprheight - $height))

	

	inkscape -z -w $sprwidth -h $sprheight \
		-a "$((-$enlargex * $svgwidth / $width / 2)):0:$(($svgwidth + $enlargex * $svgwidth / $width / 2)):$(($svgheight + $enlargey * $svgheight / $height))" \
		-e "$name.png" "$name.svg"
}

sprite()
{
	local name text color bgcolor interval frame args
	name=$1
	text=$2
	shift
	shift
	args=
	frame=0
	while [ $# -gt 0 ]; do
		color=$1
		bgcolor=$2
		interval=$3
		shift
		shift
		shift
		pngsprite "${name}_frame$frame" "$color" "$bgcolor" "$text"
		convert "${name}_frame$frame.png" "${name}_frame$frame.tga"
		rm -f "${name}_frame$frame.png"
		args="$args -sprite ${name}_frame$frame.tga $(($sprwidth / 2)) $(($sprheight - 1)) $interval"
		frame=$(($frame + 1))
	done
	#./makespr32 -o "$name.sp2" -proj 5 -group $args
}

sprite as-push            "Push"          ff8000 000000 0.0
sprite as-destroy         "Destroy"       ff8000 000000 0.0
sprite as-defend          "Defend"        0080ff 000000 0.0
sprite bluebase           "Blue Base"     0050ff 000000 0.0
sprite danger             "DANGER"        ff0000 ffff00 0.0
sprite flagcarrier        "Flag carrier"  ffff00 000000 0.0
sprite flagdropped        "Dropped flag"  00ffff 000000 0.0
sprite helpme             "Help me!"      ffff00 ff0000 0.0
sprite here               "Here"          00ff00 000000 0.0
sprite key-dropped        "Dropped key"   00ffff 000000 0.0
sprite keycarrier-blue    "Key carrier"   0050ff 000000 0.0
sprite keycarrier-finish  "Run here"      00ffff 000000 0.0
sprite keycarrier-friend  "Key carrier"   00ff00 000000 0.0
sprite keycarrier-pink    "Key carrier"   ff00ff 000000 0.0
sprite keycarrier-red     "Key carrier"   ff0000 000000 0.0
sprite keycarrier-yellow  "Key carrier"   ffff00 000000 0.0
sprite redbase            "Red base"      ff0000 000000 0.0
sprite waypoint           "Waypoint"      008080 000000 0.0
sprite ons-gen-red        "Generator"     ff0000 000000 0.0
sprite ons-gen-blue       "Generator"     0050ff 000000 0.0
sprite ons-gen-shielded   "Generator"     808080 000000 0.0
sprite ons-cp-neut        "Control point" ffff00 000000 0.0
sprite ons-cp-red         "Control point" ff0000 000000 0.0
sprite ons-cp-blue        "Control point" 0050ff 000000 0.0
sprite ons-cp-atck-neut   "Control point" ffff00 000000 0.5 000000 ffff00 0.5
sprite ons-cp-atck-red    "Control point" ff0000 000000 0.5 ff0000 ffff00 0.5
sprite ons-cp-atck-blue   "Control point" 0050ff 000000 0.5 0050ff ffff00 0.5
sprite ons-cp-dfnd-red    "Control point" ff0000 000000 0.5 ff0000 ffffff 0.5
sprite ons-cp-dfnd-blue   "Control point" 0050ff 000000 0.5 0050ff ffffff 0.5
sprite race-checkpoint    "Checkpoint"    ff8000 000000 0.0
sprite race-finish        "Finish"        ff8000 000000 0.0
sprite race-start         "Start"         ff8000 000000 0.0
sprite nb-ball            "Ball"          e8d8a0 000000 0.0

sprite wpn-laser          "Laser"         ff8080 000000 0.0 # bright red
sprite wpn-shotgun        "Shotgun"       804000 000000 0.0 # brown
sprite wpn-uzi            "Machine Gun"   ffff00 000000 0.0 # yellow
sprite wpn-gl             "Mortar"        ff0000 000000 0.0 # red
sprite wpn-electro        "Electro"       0080ff 000000 0.0 # bluish cyan
sprite wpn-crylink        "Crylink"       ff80ff 000000 0.0 # bright pink
sprite wpn-nex            "Nex"           00ffff 000000 0.0 # cyan
sprite wpn-hagar          "Hagar"         ffff80 000000 0.0 # bright yellow
sprite wpn-rl             "Rocket Launcher" ffff00 000000 0.0 # yellow
sprite wpn-porto          "Port-O-Launch" 808080 000000 0.0 # grey
sprite wpn-minstanex      "Minstanex"     80ffff 000000 0.0 # bright cyan
sprite wpn-hookgun        "Hook"          008000 000000 0.0 # dark green
sprite wpn-fireball       "Fireball"      ff8000 000000 0.0 # orange
sprite wpn-hlac           "HLAC"          00ff00 000000 0.0 # green
sprite wpn-campingrifle   "Rifle"         80ff00 000000 0.0 # orange

sprite dom-neut           "Control point" 00ffff 000000 0.0
sprite dom-red            "Control point" ff0000 000000 0.0
sprite dom-blue           "Control point" 0050ff 000000 0.0
sprite dom-yellow         "Control point" ffff00 000000 0.0
sprite dom-pink           "Control point" ff00ff 000000 0.0

sprite item-invis         "Invisibility"  0050ff 000000 0.5 0050ff ffff00 0.5
sprite item-extralife     "Extra life"    ff0000 000000 0.5 ff0000 ffff00 0.5
sprite item-speed         "Speed"         ff00ff 000000 0.5 ff00ff ffff00 0.5
sprite item-strength      "Strength"      0050ff 000000 0.5 0050ff ffff00 0.5
sprite item-shield        "Shield"        ff00ff 000000 0.5 ff00ff ffff00 0.5
sprite item-fuelregen     "Fuel regen"    ff8000 000000 0.5 ff8000 ffff00 0.5
sprite item-jetpack       "Jet Pack"      808080 000000 0.5 808080 ffff00 0.5
