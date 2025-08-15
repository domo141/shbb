#!/bin/sh
#
# $ outer.sh $

# SPDX-License-Identifier: Unlicense

case ${BASH_VERSION-} in *.*) set -o posix; shopt -s xpg_echo; esac
case ${ZSH_VERSION-} in *.*) emulate ksh; esac

set -euf
# set -x

echo =
echo = '$0': $0 # concecutive spaces collapse to one here if ever there...
echo = '$@': "[$#]"
printf ':  %s\n' "$@"
echo =

# heuristic to "guess" what is the executable filename
test -x "$1" && INNER_ARG= || { INNER_ARG=$1; shift; }
SCRIPT_FILE=$1
shift

(
 # sourcing in subshell. could also have done e.g. sh $SCRIPT_FILE "$@" ...
 . "$SCRIPT_FILE"
) && ev=0 || ev=$?
echo =
echo = $0: exit/return of $SCRIPT_FILE: $ev
echo =
echo
