#!/bin/sh
# -*- mode: shell-script; sh-indentation: 8; tab-width: 8 -*-
#
# SPDX-License-Identifier: Unlicense

# This looks so old these days - I practically always use the tmpl3 in new one

case ~ in '~') echo "'~' does not expand. old /bin/sh?" >&2; exit 1; esac

case ${BASH_VERSION-} in *.*) set -o posix; shopt -s xpg_echo; esac
case ${ZSH_VERSION-} in *.*) emulate ksh; esac

set -u  # expanding unset variable makes non-interactive shell exit immediately
set -e  # exit on error -- know potential false negatives and positives !
set -f  # disable pathname expansion by default
#et -x  # s/#/s/ may help debugging  (or run /bin/sh -x ... on command line)

# LANG=C LC_ALL=C; export LANG LC_ALL
PATH='/sbin:/usr/sbin:/bin:/usr/bin'; export PATH

saved_IFS=$IFS
readonly saved_IFS

warn () { printf %s\\n "$*"; } >&2
die () { printf %s\\n "$@"; exit 1; } >&2

x () { printf '+ %s\n' "$*" >&2; "$@"; }
x_env () { printf '+ %s\n' "$*" >&2; env "$@"; }
x_eval () { printf '+ %s\n' "$*" >&2; eval "$*"; }
x_exec () { printf '+ %s\n' "$*" >&2; exec "$@"; die "exec '$*' failed"; }

usage () { printf \\n%s\\n "Usage: $0 $cmd $*"; exit 1; } >&2

case ${1-} in -x) setx=true; shift ;; *) setx=false ;; esac

# -- "uid 0" block -- remove in scripts where not needed --

u0_chroot ()
{
	die () { exit 1; }
	set -x
	: "Spezial command expected to be run as user id 0 (root);" :
	: "take extra care writing these, for e.g sudo NOPASSWD usage" :
	: $# -all unused- args: "$@"
	id
	exec chroot "$@"
}

u0_another () { : unused so far... :
}

case ${1-} in u0_*)
	case ' u0_chroot u0_another ' in *" $1 "*)
		u0=$1; readonly $u0; shift
		$setx && { unset setx; set -x; } || unset setx
		$u0 "$@"
		exit
	esac
	exit 1
esac

# -- end of "uid 0" block --

cmd_test1 () # simple test (or it originally was)
{
	# foo -> 'foo' --  a'b -> 'a'\''b' ...
	for arg
	do	case $arg in *"'"*)
			arg=$(printf %s "$arg" | sed "s/'/'\\\\''/g")
		esac
		shift; set -- "$@" "'$arg'"
	done
	printf 'cmd: %s, args (%d):' $cmd $#; printf " %s" "$@"; echo
	printf 'cmd: %s, args (%d): %s' $cmd $# "$*"; echo
	x id
	x uptime
}

cmd_chroot2 () # demo wrapped sudo execution
{
	x sudo /bin/sh "$0" u0_chroot "$@"
	:
}

cmd_sample3 () # exec me in almost empty env, and print that env
{
	{ case $- in *x*) x=-x ;; *) x= ;; esac; } 2>/dev/null
	test "${CLEAN_ENV-}" = //true// ||
		exec env -i CLEAN_ENV=//true// HOME="$HOME" USER="$USER" \
			/bin/sh "$0" $x cmd_$cmd "$@"
	unset CLEAN_ENV
	{ set -x; } 2>/dev/null
	id
	umask
	ulimit -a
	pwd
	env
	times
	exit
}


cmd_source () # view source of given '$0' command
{
	set +x
	case ${1-} in '') die $0 $cmd cmd-prefix ;; esac
	echo
	case $1 in ??*_*)
		exec sed -n "/^\(cmd_\)\?$1.*(/,/^}/p" "$0"
	esac;	exec sed -n "/^cmd_$1.*(/,/^}/p" "$0"
	exit not reached
}

case ${1-} in cmd_*)
	cmd=${1#cmd_}; readonly cmd; shift
	$setx && { unset setx; set -x; } || unset setx
	cmd_"$cmd" "$@"
	exit
esac

# ---

case ${1-} in '')
	echo
	echo Usage: $0 '{command} [args]'
	echo
	echo $0 commands available:
	echo
	sed -n '/^cmd_[a-z0-9_]/ { s/cmd_/ /; s/ () [ #]*/                   /
		s/$0/'"${0##*/}"'/g; s/\(.\{13\}\) */\1/p; }' "$0"
	echo
	echo Command can be abbreviated to any unambiguous prefix.
	echo
	exit 0
esac

cm=$1; shift

# override shortcuts...
# case $cm in
# 	d) cm=diff ;;
# esac

cc= cp=
for m in `LC_ALL=C exec sed -n 's/^cmd_\([a-z0-9_]*\) (.*/\1/p' "$0"`
do
	case $m in $cm) cp= cc=t cmd=$cm; break
		;; $cm*) cp=$cc; cc="$m $cc"; cmd=$m
	esac
done

case $cc in '') echo $0: $cm -- command not found.; exit 1
esac
case $cp in '') ;; *) echo $0: $cm -- ambiguous command: matches $cc; exit 1
esac
unset cc cp cm
readonly cmd
$setx && { unset setx; set -x; } || unset setx
cmd_$cmd "$@"
