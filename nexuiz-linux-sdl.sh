#!/bin/sh

path="`dirname \"${0}\"`"
link="`readlink \"${0}\"`"

[ -n "${link}" ] && path="`dirname \"${link}\"`"
cd "${path}"

case "$(uname -m)" in
  x86_64)	nexuiz="nexuiz-linux-x86_64-sdl" ;;
  *)		nexuiz="nexuiz-linux-686-sdl" ;;
esac

set -- ./${nexuiz} "${@}"

xserver=
xlayout=

# now how do we execute it?
if [ -r ~/.nexuiz/data/config.cfg ]; then
	while read -r CMD KEY VALUE; do
		VALUE=${VALUE#\"}
		VALUE=${VALUE%\"}
		case "$CMD:$KEY" in
			seta:vid_x11_display)
				case "$VALUE" in
					:*)
						;;
					*)
						VALUE=:$VALUE
						;;
				esac
				VALUE="$VALUE "
				xserver="${VALUE%% *}"
				xserver=${xserver#:}
				xlayout=${VALUE#* }
				xlayout=${xlayout% }
				;;
		esac
	done < ~/.nexuiz/data/config.cfg
fi

case "$xserver" in
	'')
		;;
	*[!0-9]*)
		echo "Not using display ':$xserver': evil characters"
		;;
	*)
		msg=
		lf='
'
		prefix=

		# check for a listening X server on that socket
		if netstat -nl | grep -F " /tmp/.X11-unix/X$xserver" >/dev/null; then
			# X server already exists
			export DISPLAY=:$xserver
			prefix="DISPLAY=:$xserver "
			msg=$msg$lf"- Running Nexuiz on already existing display :$xserver"
		else
			set -- startx "$@" -fullscreen -- ":$xserver"
			msg=$msg$lf"- Running Nexuiz on a newly created X server :$xserver."
			case "$xlayout" in
				'')
					;;
				*[!A-Za-z0-9]*)
					echo >&2 "Not using layout '$xlayout': evil characters"
					xlayout=
					;;
				*)
					set -- "$@" -layout "$xlayout"
					msg=$msg$lf"- Using the ServerLayout section named $xlayout."
					;;
			esac
		fi

		echo "X SERVER OVERRIDES IN EFFECT:$msg"
		echo
		echo "Resulting command line:"
		echo "  $prefix$*"
		echo
		echo "To undo these overrides, edit ~/.nexuiz/data/config.cfg and remove the line"
		echo "starting with 'seta vid_x11_display'."
		echo
		echo
		;;
esac

exec "$@"
