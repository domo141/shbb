#!/bin/sh
#
# Created: Wed 30 Apr 2003 11:41:13 EET too
# Last Modified: Fri 17 Nov 2023 21:34:13 +0200 too
# Public Domain (this template)

# This is self-extracting archive. You can use this to create new
# self-extracting archives (cp to *.sfx and modify to suit your needs).
# Be sure that tail(1) can handle binary content and long lines in your
# target platform (at least when using +num -option).

# If you edit this script after you've catenated your archive, there is risk
# that editor modifies the "binary". If editor adds (final) newline, you'll
# get warning when extracting. You're more unfortunate if some changes are
# made to it. Therefore I suggest do editing before archive is catenated.

# The suffix in the last line, be it .gz (default), .xz or .zst is used to
# choose the decompressor, gzip(1), xz(1) or zstd(1), respectively.

# Some effort to keep this template traditional-shell compatible has been put.
# E.g. $PWD usually works, but if not, replace use of it with `pwd`.

case ${BASH_VERSION-} in *.*) set -o posix; shopt -s xpg_echo; esac
case ${ZSH_VERSION-} in *.*) emulate ksh; esac

set -euf  # hint: (z|ba|da|'')sh -x thisfile [args] to trace execution

LC_ALL=C LANG=C; export LC_ALL LANG; unset LANGUAGE

die () { echo "$@"; exit 1; } >&2

# Find  c o n t e n t  separator
SKIP=`grep -anm1 '^con't'ent.tar.' "$0"` ||
	die "Cannot find con"t"ent separator line 'con"t"ent.tar...' in '$0'"
case $SKIP
	in *.gz)  uz=gzip
	;; *.xz)  uz=xz
	;; *.zst) uz=zstd
	;; *) die "'Unknown con"t"ent separator line in '$0'"
esac
SKIP=${SKIP%:*}
SKIP=$((SKIP + 1))

# Absolute path to $0 -- so one may `cd` elsewhere before extraction...
case $0 in /*) this=$0 ;; *) this=$PWD/$0 ;; esac

mk_tmpdir () {
	tmpdir=`mktemp -d ${1:+$1/}_sfxa.XXXXXX`
	trap "rm -rf $tmpdir" 0
}

# Add commands to do before extracting archive here (if any)
# ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

# This template asks more options...

case ${1-} in -i) # fall through to installation part

;; -l)	test $# = 1 || die "'-l' takes no arguments"
	head -n +$SKIP "$this"
	exit

;; -v)	test $# = 1 || die "'-v' takes no arguments"
	tail -n +$SKIP "$this" | $uz -dc | tar -tvf -
	exit

;; -x)	test $# = 1 || die "'-x' takes no arguments"
	mk_tmpdir
	tail -n +$SKIP "$this" | $uz -dc | tar -C "$tmpdir" -xvvf -
	onefile=
	onefile () {
		test $# = 1 || return 0
		case $1 in '*' | */'*' ) return; esac
		onefile=$1
	}
	set +f
	onefile $tmpdir/*
	if test "$onefile"
	then onefile=${onefile#*/}
		# use "test -e" below if this is run only on modern shells
		#test -d "$onefile" || test -f "$onefile" || {
		if test ! -d "$onefile" && test ! -f "$onefile"
		then	mv $tmpdir/"$onefile" ./"$onefile"
			rmdir $tmpdir
			tmpdir=$onefile
		fi
	fi
	echo "Extracted to '$tmpdir'"
	trap - 0
	exit
;; *)
	echo
	echo Usage: "$0 ( -l | -v | -x | -i )"
	echo
	echo ' ' -l: '' list the leading program part of $0
	echo ' ' -v: '' view archive content appended in $0
	echo ' ' -x: '' extract archive content embedded in $0
	echo '    ' and
	echo ' ' -i: '"install"' i.e. also do pre and post extraction commands
	echo
	exit
esac

# Here in case of -i were given on command line -- extract archive
mk_tmpdir
tail -n +$SKIP "$this" | $uz -dc | tar -C "$tmpdir" -xf -

# Add commands to do after archive has been extracted here
# ''''''''''''''''''''''''''''''''''''''''''''''''''''''''

trap - 0

exit
content.tar.gz
