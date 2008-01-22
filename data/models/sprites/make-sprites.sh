width=256
height=64

sprwidth=256
sprheight=64

sprite()
{
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
	./makespr32 -o "$name.sp2" -proj 5 "$name.png" $(($sprwidth / 2)) $(($sprheight - 1)) 0
}

sprite bluebase           0000ff 000000 "BLUE BASE"
sprite danger             ff0000 ffff00 "DANGER"
sprite flagcarrier        ffff00 000000 "FLAG CARRIER"
sprite helpme             ffff00 ff0000 "HELP ME"
sprite here               00ff00 000000 "HERE"
sprite key-dropped        00ffff 000000 "DROPPED KEY"
sprite keycarrier-blue    0000ff 000000 "KEY CARRIER"
sprite keycarrier-finish  00ffff 000000 "RUN HERE"
sprite keycarrier-friend  00ff00 000000 "KEY CARRIER"
sprite keycarrier-pink    ff00ff 000000 "KEY CARRIER"
sprite keycarrier-red     ff0000 000000 "KEY CARRIER"
sprite keycarrier-yellow  ffff00 000000 "KEY CARRIER"
sprite redbase            ff0000 000000 "RED BASE"
sprite waypoint           008080 000000 "WAYPOINT"
sprite ons-gen-red        ff0000 000000 "GENERATOR"
sprite ons-gen-blue       0000ff 000000 "GENERATOR"
sprite ons-gen-shielded   808080 000000 "GENERATOR"
sprite ons-cp-neut        ffff00 000000 "CONTROL POINT"
sprite ons-cp-red         ff0000 000000 "CONTROL POINT"
sprite ons-cp-blue        0000ff 000000 "CONTROL POINT"
