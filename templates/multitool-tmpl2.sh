#!/bin/sh
#
# $ multitool-tmpl2.sh -- "working" template: drop/mangle unneeded lines... $
#
# SPDX-License-Identifier: Unlicense

case ${BASH_VERSION-} in *.*) set -o posix; shopt -s xpg_echo; esac
case ${ZSH_VERSION-} in *.*) emulate ksh; esac

set -euf  # hint: (z|ba|da|'')sh -x thisfile [args] to trace execution

# LANG=C.UTF-8 LC_ALL=C.UTF-8; export LANG LC_ALL; unset LANGUAGE
# PATH='/sbin:/usr/sbin:/bin:/usr/bin'; export PATH

saved_IFS=$IFS; readonly saved_IFS

warn () { printf '%s\n' "$@"; } >&2
die () { printf '%s\n' '' "$@" ''; exit 1; } >&2

x () { printf '+ %s\n' "$*" >&2; "$@"; }
x_bg () { printf '+ %s\n' "$*" >&2; "$@" & }
x_env () { printf '+ %s\n' "$*" >&2; env "$@"; }
x_eval () { printf '+ %s\n' "$*" >&2; eval "$*"; }
x_exec () { printf '+ %s\n' "$*" >&2; exec "$@"; die "exec '$*' failed"; }

#test $# -gt 0 || die "Usage: ${0##*/} ..."

test $# = 0 && { exec >&2; echo
	echo "Usage: ${0##*/} command [args]"
	echo
	echo Commands:
	exec awk -v c="${0##*/}" '/^case .cmd/ {
		sub(".* in ", "");sub("^[^)]*[|]", "")
		sub(")", ""); printf "  %-9s %s\n", $0, pl; next }
	 { sub("# ", ""); sub("%0", c); pl = $0 }
	 END { print "\nSome '\'command\''s may be abbreviated.\n" }' "$0"
	exit not reached
}

cmd=$1; shift;

usage () { die "Usage: ${0##*/} $cmd $*"; }


# dd with if/of as first 2 args, block size 65536 and status=progress
case $cmd in dd)
	test $# -ge 2 || usage 'ifile(or empty) ofile(or empty) ...'
	if=$1 of=$2; shift 2
	x_exec dd ${if:+if="$if"} ${of:+of="$of"} bs=65536 status=progress "$@"
	exit not reached
esac


# clear screen, stty sane
case $cmd in cls)
	printf '\033c'
	exec stty sane
	exit not reached
esac


# fusermount -u ...
case $cmd in fuum|fuumo|fuumou|fuumoun|fuumount)
	test $# = 1 || usage "'mountpoint' ;: to umount"
	x_exec fusermount -u "$1"
	exit not reached
esac


# shrink png image
case $cmd in pngsh|pngshr|pngshri|pngshrin|pngshrink)
	test $# = 2 || usage "origpng shrinkedpng"

	command -v optipng >/dev/null  || die "'optipng': no such command"
	#command -v pngquant >/dev/null || die "'pngquant': no such command"

	test -f "$1" || die "'$1' input file missing"
	test -e "$2" && die "'$2' output file exists"
	ifile=$1 ofile=$2 #; shift 2

	trap 'x rm -f "$ofile.wip"' 0
	#x pngquant -f -o "$ofile.wip" "$ifile"
	cp $ifile $ofile.wip
	x optipng --strip all -o9 "$ofile.wip"
	s1=`stat -c %s "$ifile"`
	s2=`stat -c %s "$ofile.wip"`
	test $s2 -ge $s1 && exit 0
	# traps don't run after exec so trap - 0 not here
	x_exec mv "$ofile.wip" "$ofile"
	exit not reached
esac


# view source of given '%0' command
case $cmd in sou|sour|sourc|source)
	test "${1-}" || usage 'cmd-"regexpy"'
	case $1 in *[!a-z0-9._-]*) die "some unsupported chars in '$1': "; esac
	exec sed -n "/^case .cmd in .*$1/,/^esac/p" "$0"
	exit not reached
esac


die "'$cmd': no such command"

# Local variables:
# mode: shell-script
# sh-basic-offset: 8
# tab-width: 8
# End:
# vi: set sw=8 ts=8
