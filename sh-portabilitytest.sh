#!/bin/sh
# -*- mode: shell-script; sh-basic-offset: 8; tab-width: 8 -*-
# $ sh-portabilitytest.sh $
#
# Author: Tomi Ollila -- too ät iki piste fi
#
# Created: Tue 27 Aug 2013 19:07:01 EEST too
# Last modified: Sat 17 May 2014 21:33:49 +0300 too
#
# This script has been placed in the public domain.
#

# fail on error (-e), require referenced variables be defined (-u)
set -eu
#set -x

# This is ever-evolving shell script portability testing tool.
# This will always lack to test some shell script specifics and the
# test coverage with all (Bourne"-compatible") shells in all possible
# systems will never be complete.
# Nevertheless the contents should provide good insight what kind
# of differences one can expect when writing shell scripts.


#case $SHELL in *heirloom*) set -x; esac

case ${BASH_VERSION-} in *.*)
	# Make echo builtin in bash expands backslash-escape sequences by
	# default. Without this bash would be less portable compared to
	# most other shells...
	shopt -s xpg_echo
	# make sure pipefail is not set (bash-only feature)...
	set +o pipefail
	#list_functions () { set; }
esac

case ${ZSH_VERSION-} in *.*)
	setopt shwordsplit
	setopt posix_builtins # for test_command()
	unsetopt equals # for [ 1 == 1 ] (nonstandard usage...)
	#setopt equals # make [ 1 == 1 ] fail for sure...
	unsetopt function_argzero # $0 being the name of this script always
	#list_functions () { functions; }
esac

warn () { echo "$@" >&2; }
die () { echo "$@" >&2; exit 1; }

need_path () { PATH='/sbin:/usr/sbin:/bin:/usr/bin'; export PATH; }

ffalse () { return 1; } #  false is not builtin in all shells...

iwhich () # internal which... for test_ functions to use ...
{
	case $1 in *'[^a-zA-Z0-9_]'*) return 1; esac
	# case $1 in *[.,-]*) set x `echo "$1" | tr ,.- ___`; shift; esac
	for d in /bin /usr/bin /sbin /usr/sbin
	do test '!' -x "$d/$1" || { eval "$1='$d/$1'"; return 0; }
	done
	return 1
}

#not () { if "$@"; then return 1; else return 0; fi; } # see exclmark

e () {
	echo $SHELL $test: "$@"
	case ${PT_VERBOSE_FD-} in [3456789])
		echo $SHELL $test: "$@" >&$PT_VERBOSE_FD
	esac
}

test_command ()
{
	e builtin or system, not function or alias.
	# one could argue whether command should include builtins...
	alias echo=/bin/false || :
	echo () { return 1; }
	command echo >/dev/null
}

test_command_v ()
{
	e the -v option
	# first check that there is builtin 'command'
	command echo >/dev/null || return 1
	# expect cat reside in /bin, to make this run not fail
	PATH=/bin; export PATH
	case `command -v cat` in *cat) ;; *) return 1; esac
}

test_builtin ()
{
	e builtin command
	echo () { return 1; }
	builtin echo >/dev/null
}

test_local ()
{
	e 'local variable'
	lt () {
		local var=ilval
		case $var in ilval) ;; *) exit 1 ;; esac
	}
	local var=lval
	lt
	case $var in lval) ;; *) exit 1 ;; esac
}

test_typeset ()
{
	e 'local variable using plain typeset (typeset/declare without opts)'
	# declare: same as typeset (in bash, zsh, ...)
	lt () {
		typeset var=ilval
		case $var in ilval) ;; *) exit 1 ;; esac
	}
	typeset var=lval
	lt
	case $var in lval) ;; *) exit 1 ;; esac
}


test_function ()
{
	e 'function keyword'
	# without eval some shells exit to syntax error while parsing
	eval 'function inner { :; }'
	inner
}

test_function2 ()
{
	e 'function keyword, with ()'
	# without eval some shells exit to syntax error while parsing
	eval 'function inner () { :; }'
	inner
}


test_exclmark ()
{
	e "whether '!' as 'not' works (and is builtin)"
	# fails in heirloom sh
	! /bin/false
}

test_test ()
{
	e 'builtin test command'
	test string
}

test_test_e ()
{
	e "test -e file"
	if test -e "$0"; then exit 0; else exit 1; fi
}

test_test_ef ()
{
	e "test file1 -ef file2"
	iwhich mktemp; td=`exec $mktemp -d`; ev=1
	trap '/bin/rm -rf $td; exit $ev' 0
	: > $td/file1
	/bin/ln $td/file1 $td/file2
	if test $td/file1 -ef $td/file2; then ev=0; fi
}

test_test_nt ()
{
	e "test file1 -nt file2 (presumed -ot is also supported if -nt is)"
	iwhich mktemp; td=`exec $mktemp -d`; ev=1
	#trap '/bin/rm -rf $td; exit $ev' 0
	# XXX expects system time & fs times to work as usual
	: > $td/newfile
	if test $td/newfile -nt "$0"; then ev=0; fi
}

test_testexcl ()
{
	e "'!' in test"
	if test '!' string; then exit 1; else exit 0; fi
}

test_testeqeq ()
{
	e "nonstandard '[ 1 == 1 ]' ('[ 1 = 1 ]' would be standard one)"
	# this can be made to pass in zsh by using '==' or w/ unsetopt equals
	[ 1 == 1 ]
}

test_testtest ()
{
	e "whether [[ ]] is supported (with 1 == 1)"
	[[ 1 == 1 ]]
}

test_tildexp ()
{
	e 'tilde expansion'
	case ~ in /*) ;; *) exit 1; esac
}

test_pwdvar ()
{
	e "'$PWD' variable expansion"
	cd /tmp
	PWD=/usr
	echo \$PWD: $PWD
	cd .
	echo \$PWD: $PWD
	case $PWD in /tmp) ;; *) exit 1; esac
}

test_pwdcmd ()
{
	e "pwd builtin command"
	pwd
}


test_true ()
{
	e "true builtin command (cannot test false...)"
	true
}

test_colon ()
{
	e "colon (:) builtin command"
	:
}

test_export1 ()
{
	e 'export VAR=val -- not bourne compatible'
	export VAR=val
	case $VAR in val) ;; *) exit 1; esac
}

test_readonly2 ()
{
	e 'VAR=val; readonly VAR -- then attempt to change VAR'
	VAR=val; readonly VAR
	# running in subshell as this makes shell exit.
	( VAR=changed || : ) && exit 1 || :
}


test_case_pxcl ()
{
	e "case where both '*' and '[!a-z0-9_]' unquoted"
	case test/echo1 in *[!a-z0-9_]*) ;; *) exit 1; esac
	case test_echo1 in *[!a-z0-9_]*) exit 1; esac
}


test_case_pxcf ()
{
	e "case where both '*' and '[^a-z0-9_]' unquoted"
	# dash & heirloom sh expected to "fail" here.
	# without eval heirloom sh fails in syntax error while parsing
	eval 'case test/echo1 in *[^a-z0-9_]*) ;; *) exit 1; esac'
	eval 'case test_echo1 in *[^a-z0-9_]*) exit 1; esac'
}

disabled_test_case1x ()
{
	e "like previous but '[^a-z0-9_]' quoted..."
	case test/echo1 in *'[^a-z0-9_]'*) ;; *) exit 1; esac
	case test_echo1 in *'[^a-z0-9_]'*) exit 1; esac
}


test_at0 ()
{
	e '"$@" expansion when $# 0'
	case $# in 0) ;; *) die "arg count 0 required for this test" ;; esac
	: "$@"
}

test_at1 ()
{
	e '${1+"$@"} expansion when $# 0'
	case $# in 0) ;; *) die "arg count 0 required for this test" ;; esac
	: ${1+"$@"}
}

test_at0for ()
{
	e 'implicit "$@" in for loop'
	case $# in 0) ;; *) die "arg count 0 required for this test" ;; esac
	# FreeBSD 7.1 /bin/sh will complain something like $@ not defined
	eval 'for var; do :; done' # Solaris 10 /bin/sh gives parse error...
}


test_echoE ()
{
	e 'expect backslash-escapes to be excapes by default'
	iwhich wc
	#echo `echo '\n' | wc` || :
	case `echo '\n' | $wc` in *2*0*2) ;; *) exit 1; esac
}

test_echoc ()
{
	e "expect '\\\\c' to stop producing more output"
	case `echo '\c---'` in '') ;; *) exit 1; esac
}

test_echon ()
{
	e "whether 'echo -n' works"
	echo -n
	case `echo -n` in '') ;; *) exit 1; esac
}

test_bi_printf ()
{
	e 'builtin printf'
	case `printf '%s' tstr` in tstr) ;; *) exit 1; esac
}

test_dollar_sq ()
{
	e 'dollar-single expansion'
	x=$'\n'
	case $x in ?) ;; *) exit 1; esac
}

test_hash_fatl ()
{
	e 'some shells (heirloom sh) exits when hash fails'
	if hash xxx_no_such_prog 2>/dev/null
	then :
	fi
}

test_hash_btin ()
{
	e 'if there is builtin hash'
	hash /bin/sh || hash sh=/bin/sh # latter for zsh
}

test_iexpr ()
{
	e '$((a + b))'
	a=1 b=2
	eval 'c=$((a + b))' # eval for heirloom sh to continue parsing...
	case $c in 3) ;; *) exit 1; esac
}

test_tfft ()
{
	e 'true && false && false || true'
	: && ffalse && ffalse || :
}

test_icat ()
{
	e 'whether there is $(< file)'
	eval 'd=$(< "$0")' # eval for heirloom sh to continue parsing...
	case $d in '') exit 1; esac
}

#test_false_x () # this should be ovbious from some of the previous tests
#{
#	e continuation of the above... this should not cause exit
#	ffalse || :
#}

set_env ()
{
	PATH=
	export PATH
}

run_test ()
{
	case $PATH in '') ;; *) set_env ;; esac
	test=$1
	"$test"
	exit
}

# just execute function if $1 starts with 'test_' and is all a-z, 0-9 & _
case ${1-} in *'[^a-z0-9_]'*) # echo "xxx '$1' xxx"
 ;;	test_*) run_test "$1"
esac
# ... else continue here

# --8<----8<----8<----8<----8<----8<----8<----8<----8<----8<----8<----8<--

case ${TEST_LOOP-} in '') ;; *) die "$SHELL: Looping!"
esac
TEST_LOOP=1; export TEST_LOOP

which=`exec env which which`

shells=
findshell ()
{
  case $sh in */*)
	test -x $sh || return 0
	shfp=$sh
  ;; *)
	# hash in subshell so heirloom sh can be used as a driver...
	#(hash "$sh" 2>/dev/null) || return 0 ...but FreeBSD does not have hash
	shfp=`exec $which $sh 2>/dev/null` || return 0
	# Solaris 10 /usr/bin/which exits always with exitcode 0
	case $shfp in /*) ;; *) return 0 ;; esac
  esac
  shells="${shells:+$shells|}$sh:$shfp"
}

for sh in sh ksh bash zsh ash dash mksh lksh
do
	findshell $sh
done

# special-case search for busybox shell
# Solaris 10 sh yells 'busybox: not found' unless stderr pre-redirected.
case `exec 2>/dev/null; busybox sh -c 'echo foo' || :` in foo)
	busybox=`exec $which busybox`
	shells="$shells|busybox sh:$busybox sh"
esac

case $# in 0) ;; *)
for sh # in ${1+"$@"}
do
	findshell $sh
done
esac

DFL_IFS=$IFS; readonly DFL_IFS

# [ -t 1 ] &&
# # http://en.wikipedia.org/wiki/Tput
# TC_RESET=`tput sgr0 2>/dev/null` &&
# TC_RED=`tput setaf 1 2>/dev/null` &&
# TC_GREEN=`tput setaf 2 2>/dev/null` &&
# TC_YELLOW=`tput setaf 3 2>/dev/null` ||
# TC_RESET= TC_RED= TC_GREEN= TC_YELLOW=

# Above did not work in Solaris 10 /bin/sh -- after
# after tput setaf 1 failed, script exited instead
# of taking || branch.

# Solaris 10 /bin/sh does not survice to 'echo foo' in
# sh -c 'set -xeu; z=`false` || :; echo foo'
# ... and we want to know the return value there...

TC_YELLOW=
set +e
[ -t 1 ] &&
# http://en.wikipedia.org/wiki/Tput
TC_RESET=`tput sgr0 2>/dev/null` && TC_RED=`tput setaf 1 2>/dev/null` &&
TC_GREEN=`tput setaf 2 2>/dev/null` && TC_YELLOW=`tput setaf 3 2>/dev/null`
set -e
case $TC_YELLOW in '')
	TC_RESET= TC_RED= TC_GREEN=
esac

IFS='|'
#columns=`stty -a | sed -n 's/.*columns \([^ ;]*\).*/\1/p'`
case ${COLUMNS-} in [1-9]|[1-9][0-9]|[1-9][0-9][0-9])
	if ( : ${#COLUMNS} ) 2>/dev/null # is ${#param} expansion supported
	then
		# it is expected that $((...)) works if ${#param} works...
		cl=13
		printf '\nFound shells:'
		for f in $shells
		do
			cl=$((cl + ${#f} + 1))
			# cl reset for following lines may not be accurate...
			test $cl -lt $COLUMNS || { echo; cl=$((${#f} + 1)); }
			printf ' '%s $f
		done
		echo
	else
		echo
		echo Found shells: $shells
		echo
	fi
;;	*)	echo
		echo Found shells: $shells
		echo
esac
LANG=C LC_ALL=C; export LANG LC_ALL
need_path

pass () {
	printf ' %sPASS%s'  "${TC_GREEN}"  "${TC_RESET}"
	echo ' `-PASS' >> $logfile
}
fail () {
	printf ' %sFAIL%s'  "${TC_RED}"    "${TC_RESET}"
	echo ' `-FAIL' >> $logfile
}

lprefix=portabilitytest
logfile=`exec date +$lprefix-%Y%d%m-%H%M%S.log`

shx ()
{
	sh=$1; shfp=$2
	IFS=' '
	case $shfp in *busybox' 'sh) shfp="$busybox sh"; esac
	printf '  %s:' "$sh"
	#date "+%d/%H:%M:%S: Executing $shfp $test" >> $logfile
	( SHELL=$shfp; export SHELL
	  set_env
	  $shfp "$0" $test >> $logfile 2>&1 ) && pass || fail
}

exec 8>&2 # for temp test testing...

WC=`exec which wc`
export WC

IFS=$DFL_IFS
for test in `exec sed -n '/^test_/ s/ .*//p' "$0"`
do
	printf '%-14s' $test
	IFS='|'
	for shp in $shells
	do
		IFS=':'
		shx $shp
	done
	echo
done

latest=$lprefix-latest.log
rm -f $lprefix-latest.log
ln -s $logfile $latest
echo
echo Logfile $logfile
echo Latest link: $latest
echo
