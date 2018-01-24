#!/bin/bash

# numbered multi-subcommand interface
# run this and you'll get the point..

# (Ø) public domain, like https://creativecommons.org/publicdomain/zero/1.0/

set -euf
# to debug, enter bash -x thisfile ...

case ${BASH_VERSION-} in '') echo 'Not BASH!' >&2; exit 1; esac

# bash settings
set -o posix
shopt -s xpg_echo

saved_IFS=$IFS; readonly saved_IFS

warn () { printf '%s\n' "$*"; } >&2
die () { printf '%s\n' "$*"; exit 1; } >&2

x () { printf '+ %s\n' "$*" >&2; "$@"; }
x_env () { printf '+ %s\n' "$*" >&2; env "$@"; }
x_eval () { printf '+ %s\n' "$*" >&2; eval "$*"; }
x_exec () { printf '+ %s\n' "$*" >&2; exec "$@"; die "exec '$*' failed"; }

case ${1-}
in '')
   echo; echo Commands available:; echo
   cmd_num=0
   declare -A cmds=()
   add_cmd () {
        printf '%3d: %-21s' "$1" "$2"; echo $3
        cmd_num=$((cmd_num + 1))
        test $cmd_num = $1 || die $cmd_num != $1 # internal consistency
        test -z "${cmds[$2]-}" || die "'$2' already defined"
        cmds[$2]=t
   }
   run_cmd () { echo; echo "Usage: ${0##*/} (#nr|name) [args]"; echo; exit; }
;; [0-9]*)
   cmd_num=0
   add_cmd () {
        cmd_num=$((cmd_num + 1))
        readonly -f cmd_$2
        # since 'readonly' 'eval' not needed (set -u not in effect, though)
        readonly cmd_$1=$2
   }
   run_cmd () {
        test $1 -le $cmd_num || die "'$1': unknown command (max $cmd_num)"
        cmd=$1; shift
        eval cmd_'$'cmd_$cmd '"$@"'
   }
;; *)
   add_cmd () { :; }
   run_cmd () { cmd=$1; shift; cmd_$cmd "$@"; }
esac

cmd_list_files ()
{
        x_exec ls "$@"
}
add_cmd 1 list_files 'simple wrapper for `ls`'


cmd_process_list ()
{
        x_exec ps "$@"
}
add_cmd 2 process_list 'simple wrapper for `ps`'


cmd_disk_space_usage ()
{
        x_exec df "$@"
}
add_cmd 3 disk_space_usage 'simple wrapper for `df`'

cmd_estimate_disk_usage ()
{
        x_exec du "$@"
}
add_cmd 4 estimate_disk_usage 'simple wrapper for `du`'


cmd_argtest ()
{
        printf 'argN: %s\n' "$@"
}
add_cmd 5 argtest 'test parameter expansion'



run_cmd "$@"
