#!/bin/sh

prev=omg
for cfg in low med normal high ultra ultimate; do
	echo "$prev.cfg -> $cfg.cfg:"
	diff "$prev.cfg" "$cfg.cfg" | grep ^\>
	echo
	prev=$cfg
done
