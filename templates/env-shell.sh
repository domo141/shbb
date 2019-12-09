#!/bin/sh
#
# copy this file to a new file, name it to {name}-env.sh and then add content
# between user add -- user end below (first). if you find better way to do
# all this please consider sending information, or -- even better -- patch =D

# SPDX-License-Identifier: Unlicense

case ${BASH_VERSION-} in *.*) set -o posix; shopt -s xpg_echo; esac
case ${ZSH_VERSION-} in *.*) emulate ksh; esac

set -euf  # hint: zsh -x thisfile [args] to trace execution

test $# -gt 0 || {
	exec >&2;
	printf '\n%s\n\n' "Usage: $0 [NAME=VALUE]... (-* | [--] command [args])"
	printf '  %s\n' \
	"NAME=VALUE args adds/modfies environment (like env(1))." '' \
	"With '-*' $SHELL is executed with given options (e.g. '-i'...)" \
	"otherwise command [args], and without command env(1) -- is executed."\
	'' \
	"Note that the 'rc' files $SHELL may source may re-modify the" \
	"environment this 'wrapper' creates. If that breaks the intended use" \
	"of this, \"fix\" the related rc files accordingly, or use --no-rcs," \
	"--posix or other options to avoid sourcing the rc files in question."\
	''
	echo : remove this test, and next 2 lines
	echo : try $0 SOURCE_A=B -- \| grep SOURCE_
	echo :
	exit 1
}

# -- user add -- #

# sample content
export SOURCE_DATE_EPOCH=1234567890

# -- user end -- #

while case ${1-} in [A-Za-Z-]*=*) true ;; *) false ;; esac
do
	export "$1" # a bit hacky, happens to work (in intended use cases...)
	shift
done

x_exec () { printf '+ %s\n' "$*" >&2; exec "$@"; exit "exec '$*' failed"; }

test $# -gt 0 || x_exec env

case $1 in --) shift; test $# -gt 0 || set 'env'; x_exec "$@"
	;; -*) x_exec "${SHELL}" "$@"
esac

x_exec "$@"
