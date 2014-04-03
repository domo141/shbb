#!/bin/sh
# -*- mode: shell-script; sh-basic-offset: 8; tab-width: 8 -*-

set -eu
#set -x

die () { echo "$@" >&2; exit 1; }

hash urxvt 2>/dev/null || die need urxvt '(rxvt-unicode)'
hash zsh 2>/dev/null || die need zsh

test -x ./sh-portabilitytest.sh ||
	die "'./sh-portabilitytest.sh' does not exist."

case $# in 0 | 1 | 2 )
	die "Usage: $0 width height title [more shells]"
esac

w=$1 h=$2 t=$3
shift 3

fg=black
bg=grey70

set -x
exec urxvt -b 6 -bl +sb -hold -fg $fg -bg $bg -bd $bg -g ${w}x${h} -e \
	zsh -c "printf '%s  \\033[38;5;3m%s\\033[38;5;0m\\n' '$t' '(${w}x${h})'
		set x $*; shift; . ./sh-portabilitytest.sh"
