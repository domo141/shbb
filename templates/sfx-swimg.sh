#!/bin/sh

# --8<--
# swimg.sh -- for cases simple enough can be used in place of "AppImage"
# Public Domain (this template)
# SPDX-License-Identifier: Unlicense

# Create that "supportive tar archive" mentioned below, copy this template
# to another file and edit to match the need. Then cat(1) it and the
# created tar archive to make the final "swimg" shell executable.
# -->8--

# This shell script contains supportive tar archive with (binary) data to
# be used during script execution. The archive content is extracted to a
# temporary directory which is removed at the end of execution.
# Be sure that tail(1) can handle binary c o n t e n t and long lines in
# your target platform (at least when using +num -option).

case $- in *i*) echo "Execute, do not 'source' this file."; return 0; esac

case ${BASH_VERSION-} in *.*) set -o posix; shopt -s xpg_echo; esac
case ${ZSH_VERSION-} in *.*) emulate ksh; esac

set -euf

LC_ALL=C LANG=C
export LC_ALL LANG

die () { printf %s\\n '' "$@" ''; exit 1; } >&2

x () { printf '+ %s\n' "$*" >&2; "$@"; }
x_exec () { printf '+ %s\n' "$*" >&2; exec "$@"; exit not reached; }

if test $# = 0
then
	die "Usage: ${0##*/} options... (try --) (or ifile ofile)" '' \
	    "(drop/update this sample check to match usage)"
fi

# more sample checks...
case $1 in -*) ;; *)
	test $# = 2 || die "Arg count '$#' not '2'"
	case $1 in *["$IFS"]*) die "Whitespace in '$1'"
		;; *.txt|*.sh)
		;; *) die "'$1' does not end with '.txt' nor '.sh'"
	esac
	case $2 in *["$IFS"]*) die "Whitespace in '$2'"
		;; *.zst) ;; *) die "'$2' does not end with '.zst'"
	esac
	test -f "$1" || die "'$1': no such file"
	test -f "$2" && die "'$2': output file exists"
esac

# Find  c o n t e n t  separator
SKIP=`awk '/^con[t]ent[.]tar[.][a-z]*$/ { print NR + 1, $0; exit 0; }' "$0"`

test "$SKIP" ||
	die "Cannot find con"t"ent separator line 'con"t"ent.tar.?z' in $0"

case $SKIP in *.gz)  zx=gzip
	   ;; *.xz)  zx=xz
	   ;; *.zst) zx=zstd
esac
SKIP=${SKIP% *}

# Absolute path to $0 -- so one may `cd` elsewhere before extraction...
case $0 in /*) this=$0 ;; *) this=$PWD/$0 ;; esac

mk_tmpdir () {
	tmpdir=`mktemp -d ${1-}`
	trap "rm -rf $tmpdir" 0
}

case ${1-}
in -s-)  test $# = 1 || die "No args for '-s'"
	exec head -n $((SKIP - 1)) "$this"
	exit not reached

;; -l-)  test $# = 1 || die "No args for '-l'"
	tail -n +$SKIP "$this" | $zx -dc | tar -tf -
	exit
;; -v-)  test $# = 1 || die "No args for '-v'"
	tail -n +$SKIP "$this" | $zx -dc | tar -tvf -
	exit
;; -c-)  test $# = 1 || die "No args for '-c'"
	test -t 1 && die "stdout is a terminal, aborting"
	exec tail -n +$SKIP "$this"
	exit not reached
;; -x-)  mk_tmpdir _sfxa.XXXXXX
	shift
	tail -n +$SKIP "$this" | $zx -dc | tar -C "$tmpdir" -xvvf - "$@"
	onefile=
	onefile () {
		test $# = 1 || return 0
		case $1 in '*' | */'*' ) return; esac
		onefile=$1
	}
	set +f
	onefile $tmpdir/*
	if test -n "$onefile"
	then onefile=${onefile#*/}
	     test -e "$onefile" || {
		mv $tmpdir/"$onefile" ./"$onefile"
		rmdir $tmpdir
		tmpdir=$onefile
	    }
	fi
	echo "Extracted to '$tmpdir'"
	trap - 0
	exit
;; -*)
	echo
	echo Options for SFX reUsage: "$0 -(s|l|v|c|x)-"
	echo
	bn0=${0##*/}
	echo '  -s-: show the .sfx script in' $bn0
	echo '  -l-: list the archive con't'ent in ^'
	echo '  -v-: list the archive con't'ent in ^^'
	echo '  -c-: "cat" the archive con't'ent in ^^^'
	echo '  -x-: extract the archive con't'ent in ^^^^'
	echo
	exit 1
esac

# Continue here when no sfx hints/opts (in sample case above) to be done...

mk_tmpdir
tail -n +$SKIP "$this" | $zx -dc | tar -C $tmpdir -xf -

# Code to execute after tmp support archive has been extracted (REPLACE)!
# '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

test -x $tmpdir/zstd && zstd=$tmpdir/zstd || zstd=zstd

# sample export, alternative is to use patchelf --set-rpath '$ORIGIN' ...
export LD_LIBRARY_PATH=$tmpdir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

x $zstd -o "$2" "$1"

ls -l "$1" "$2"

# have exit if there is more traps than just rm -rf $tmpdif
exit
# otherwise outcomment/remove exit to give up one fork w/ exec below
exec rm -rf $tmpdir  # with exec, exit trap is not executed

exit (not reached)

# -v- this was older "advice", even harder to comprehend/get right -v-
# the following 2 lines show case where $tmpdir can be removed before
# executing (last) command with exec -- in that case trap does not run
# these lines are not reached as exit is executed above
rm -rf $tmpdir

x_exec md5sum "$1" "$2"

exit
# .zst is kinda "dumb" suffix in this particular case as $zstd used above.
# content.tar.gz or content.tar.xz are also possible.
# make sure there is just one \n after the .gz, .xz or .zst suffix before EOF
content.tar.zst
