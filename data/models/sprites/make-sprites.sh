#!/bin/bash

width=256
height=64

sprwidth=256
sprheight=64

pngsprite()
{
	local name text color bgcolor
	name=$1
	color=$2
	bgcolor=$3
	text=$4
	svgwidth=512
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
   width="512"
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
     width="512px"
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
       style="opacity:1;fill:#$color;fill-opacity:1;stroke:#$bgcolor;stroke-width:2;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:0.75294119"
       d="M 256,126 L 280,102 L 264,102 L 264,62 L 248,62 L 248,102 L 232,102 L 256,126 z "
       id="path1872"
       sodipodi:nodetypes="cccccccc" />
    <text
       xml:space="preserve"
       style="font-size:56px;font-weight:bold;text-align:center;text-anchor:middle;opacity:1;fill:#$color;fill-opacity:1;stroke:#$bgcolor;stroke-width:2;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:0.75294118"
       x="255.49414"
       y="49.957031"
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
		args="$args -sprite ${name}_frame$frame.png $(($sprwidth / 2)) $(($sprheight - 1)) $interval"
		frame=$(($frame + 1))
	done
	./makespr32 -o "$name.sp2" -proj 5 -group $args
}

sprite bluebase           "BLUE BASE"     0000ff 000000 0.0
sprite danger             "DANGER"        ff0000 ffff00 0.0
sprite flagcarrier        "FLAG CARRIER"  ffff00 000000 0.0
sprite helpme             "HELP ME"       ffff00 ff0000 0.0
sprite here               "HERE"          00ff00 000000 0.0
sprite key-dropped        "DROPPED KEY"   00ffff 000000 0.0
sprite keycarrier-blue    "KEY CARRIER"   0000ff 000000 0.0
sprite keycarrier-finish  "RUN HERE"      00ffff 000000 0.0
sprite keycarrier-friend  "KEY CARRIER"   00ff00 000000 0.0
sprite keycarrier-pink    "KEY CARRIER"   ff00ff 000000 0.0
sprite keycarrier-red     "KEY CARRIER"   ff0000 000000 0.0
sprite keycarrier-yellow  "KEY CARRIER"   ffff00 000000 0.0
sprite redbase            "RED BASE"      ff0000 000000 0.0
sprite waypoint           "WAYPOINT"      008080 000000 0.0
sprite ons-gen-red        "GENERATOR"     ff0000 000000 0.0
sprite ons-gen-blue       "GENERATOR"     0000ff 000000 0.0
sprite ons-gen-shielded   "GENERATOR"     808080 000000 0.0
sprite ons-cp-neut        "CONTROL POINT" ffff00 000000 0.0
sprite ons-cp-red         "CONTROL POINT" ff0000 000000 0.0
sprite ons-cp-blue        "CONTROL POINT" 0000ff 000000 0.0
sprite ons-cp-atck-neut   "CONTROL POINT" ffff00 000000 0.5 000000 ffff00 0.5
sprite ons-cp-atck-red    "CONTROL POINT" ff0000 000000 0.5 ff0000 ffff00 0.5
sprite ons-cp-atck-blue   "CONTROL POINT" 0000ff 000000 0.5 0000ff ffff00 0.5
sprite ons-cp-dfnd-red    "CONTROL POINT" ff0000 000000 0.5 ff0000 ffffff 0.5
sprite ons-cp-dfnd-blue   "CONTROL POINT" 0000ff 000000 0.5 0000ff ffffff 0.5
