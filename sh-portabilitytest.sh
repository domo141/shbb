#!/bin/sh
# -*- mode: shell-script; sh-basic-offset: 8; tab-width: 8 -*-
# $ sh-portabilitytest.sh $
#
# Author: Tomi Ollila -- too ät iki piste fi
#
#	Copyright (c) 2014 Tomi Ollila
#	    All rights reserved
#
# Created: Sun 18 May 2014 19:42:28 EEST too
# Last modified: Mon 19 May 2014 23:08:57 +0300 too

set -eu
#set -x

PATH=; export PATH

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

withpath () { PATH=/bin:/usr/bin; export PATH; "$@"; PATH=; export PATH; }

saved_IFS=$IFS; readonly saved_IFS

# the above was written into `common.sh`, now set PATH for this script.
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin; export PATH

wd=portabilitytest; rm -rf $wd; mkdir $wd

# write common.sh & separate file for each test.

sed -n '/^set -eu/,/^saved_IFS=/p; /^PATH=\//q' "$0" > $wd/common.sh
echo 'set -x' >> $wd/common.sh

# as hash(1) not supported everywhere, let's make sure we have which(1)
#which=`exec env which which`
# dropped exec's -- FreeBSD 7.1 sh will exit...
which=`env which which`

# check whether we have nawk...
# hash in subshell so heirloom sh can be used here...
#(hash "$sh" 2>/dev/null) || return 0 ...but FreeBSD does not have hash
if awk=`$which nawk 2>/dev/null`
then
	# Solaris 10 /usr/bin/which exits always with exitcode 0
	case $awk in /*) ;; *) awk=awk ;; esac
else
	awk=awk
fi

$awk 'BEGIN { file="foobar"; fn=""; cnt=0; wd="'"$wd"'" }
	/^}/ { print $0, "\n.",wd "/common.sh\n" fn >> file; file="/dev/null" }
	/^test_/ { cnt++; fn=$1; file=sprintf("%s/%02d_%s",wd,cnt,$1);
		   print "#!/bin/sh" >> file }
	{ print >> file }' "$0"
# add perl(1) code in case the above fails...

shells=
findshell ()
{
  case $sh in */*)
	test -x $sh || return 0
	shfp=$sh
  ;; *)
	# hash in subshell so heirloom sh can be used here...
	#(hash "$sh" 2>/dev/null) || return 0 ...but FreeBSD does not have hash
	shfp=`$which $sh 2>/dev/null` || return 0
	# Solaris 10 /usr/bin/which exits always with exitcode 0
	case $shfp in /*) ;; *) return 0 ;; esac
  esac
  shells="${shells:+$shells|}$sh:$shfp"
  echo $sh >> $wd/shells
}

for sh in sh ksh bash zsh ash dash mksh lksh
do
	findshell $sh
done

# special-case search for busybox shell
# Solaris 10 sh yells 'busybox: not found' unless stderr pre-redirected.
case `exec 2>/dev/null; busybox sh -c 'echo hello' || :` in hello)
	busybox=`$which busybox`
	shells="$shells|busybox sh:$busybox sh"
	echo busybox sh >> $wd/shells

esac

# do this `case $# in 0` check as `for sh`, `for sh in "$@"` and
# `for sh in ${1+"$@"}` (or any subset) is not supported everywhere.
case $# in 0) ;; *)
	for sh # in ${1+"$@"}
	do
		findshell $sh
	done
esac

# in case shell provides $COLUMNS and ${#param} works split shell info lines...
IFS='|'
#columns=`stty -a | sed -n 's/.*columns \([^ ;]*\).*/\1/p'`
case ${COLUMNS-} in [1-9]|[1-9][0-9]|[1-9][0-9][0-9])
	if ( : ${#COLUMNS} ) 2>/dev/null # is ${#param} expansion supported
	then
		# it is expected that $((...)) works if ${#param} works...
		cl=13
		printf '\nShells:'
		for f in $shells
		do
			# eval so that Sol10 sh does not fail parsing...
			eval 'cl=$((cl + ${#f} + 1))' # ... not run there.
			# cl reset for following lines may not be accurate...
			test $cl -lt $COLUMNS || {
				echo; eval 'cl=$((${#f} + 1))'; } # again...
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
IFS=$saved_IFS
####exit 0
set +e
TC_YELLOW=
[ -t 1 ] &&
# http://en.wikipedia.org/wiki/Tput
TC_RESET=`tput sgr0 2>/dev/null` && TC_RED=`tput setaf 1 2>/dev/null` &&
TC_GREEN=`tput setaf 2 2>/dev/null` && TC_YELLOW=`tput setaf 3 2>/dev/null`
set -e
case $TC_YELLOW in '')
	TC_RESET= TC_RED= TC_GREEN=
esac

pass () { printf ' %s: %sPASS%s' "$1" "${TC_GREEN}"  "${TC_RESET}"; }
fail () { printf ' %s: %sFAIL%s' "$1" "${TC_RED}"    "${TC_RESET}"; }

: > $wd/tstrun

print_tn () {
	# Solaris 10 will print spaces instead of '_'s. too bad...
	IFS=_/; set x $1; shift 3; printf %-15s "$*" #; IFS=$saved_IFS
}
shx () {
	IFS=':'
	set x $1
	sh=$3
	IFS='./' set x $2; shift; name=$@
	#echo $name; IFS='|'; return 0
	of="$tst.$name.out"
	IFS=' '
	if $sh $tst > "$of" 2>&1
	then
		rm "$of"
		pass "$name"
	else
		echo $of >> $wd/tstrun
		fail "$name"
	fi
	IFS='|'
}
for tst in $wd/[0-9][0-9]_*
do
	echo $tst >> $wd/tstrun
	print_tn $tst
	IFS='|'
	for shell in $shells
	do
		shx $shell
	done
	echo
done

exit

test_command () # builtin or system, not function or alias
{
	# one could argue whether command should include builtins...
	alias echo='exit 1' || :
	echo () { exit 1; }
	command echo >/dev/null
}

test_command_v () # the -v option
{
	# first check that there is builtin 'command'
	command echo >/dev/null || return 1
	# expect cat reside in /bin, to make this run not fail
	PATH=/bin; export PATH
	case `command -v cat` in *cat) ;; *) return 1; esac
}

test_builtin () # builtin command
{
	echo () { return 1; }
	builtin echo >/dev/null
}

test_local () # local variable
{
	lt () {
		local var=ilval
		case $var in ilval) ;; *) exit 1 ;; esac
	}
	local var=lval
	lt
	case $var in lval) ;; *) exit 1 ;; esac
}

test_typeset () # local variable using plain typeset (typeset/declare without opts)
{
	# declare: same as typeset (in bash, zsh, ...)
	lt () {
		typeset var=ilval
		case $var in ilval) ;; *) exit 1 ;; esac
	}
	typeset var=lval
	lt
	case $var in lval) ;; *) exit 1 ;; esac
}

test_global () # test whether variable is global always
{
	gt () {
		var=local
	}
	var=global
	gt
	case $var in local) exit 0 ;; *) exit 1 ;; esac
}


test_function () # function keyword
{
	function inner { :; }
	inner
}

test_function2 () # function keyword, with ()
{
	function inner () { :; }
	inner
}


test_exclmark () # whether '!' as 'not' works (and is builtin)
{
	# fails in heirloom sh
	! /bin/false
}

test_test () # builtin test command
{
	test string
}

test_test_e () # test -e file (well, current directory)
{
	if test -e "$0"; then exit 0; else exit 1; fi
}

test_test_ef () # test file1 -ef file2
{
	td=`withpath mktemp -d /tmp/tmp.XXXXXX`; ev=1
	trap '/bin/rm -rf $td; exit $ev' 0
	: > $td/file1
	/bin/ln $td/file1 $td/file2
	if test $td/file1 -ef $td/file2; then ev=0; fi
}

test_test_nt () # test file1 -nt file2 (presumed -ot is also supported if -nt is)
{
	td=`withpath mktemp -d /tmp/tmp.XXXXXX`; ev=1
	#trap '/bin/rm -rf $td; exit $ev' 0
	# XXX expects system time & fs times to work as usual
	: > $td/newfile
	if test $td/newfile -nt "$0"; then ev=0; fi
}

test_testexcl () # '!' in test
{
	if test '!' string; then exit 1; else exit 0; fi
}

test_testeqeq () # nonstandard '[ 1 == 1 ]' ('[ 1 = 1 ]' would be standard one)
{
	# this can be made to pass in zsh by using '==' or w/ unsetopt equals
	[ 1 == 1 ]
}

test_testtest () # whether [[ ]] is supported (with 1 == 1)
{
	[[ 1 == 1 ]]
}

test_tildexp () # tilde expansion
{
	case ~ in /*) ;; *) exit 1; esac
}

test_pwdvar () # '$PWD' variable expansion
{
	cd /tmp
	PWD=/usr
	echo \$PWD: $PWD
	cd .
	echo \$PWD: $PWD
	case $PWD in /tmp) ;; *) exit 1; esac
}

test_pwdcmd () # pwd builtin command
{
	pwd
}


test_true () # true builtin command (cannot test false...)
{
	true
}

test_colon () # colon (:) builtin command
{
	:
}

test_export1 () # export VAR=val -- not bourne compatible
{
	export VAR=val
	case $VAR in val) ;; *) exit 1; esac
}

test_readonly2 () # VAR=val; readonly VAR -- then attempt to change VAR
{
	VAR=val; readonly VAR
	# running in subshell as this makes shell exit.
	( VAR=changed || : ) && exit 1 || :
}


test_case_pxcl () # case where both '*' and '[!a-z0-9_]' unquoted
{
	case test/echo1 in *[!a-z0-9_]*) ;; *) exit 1; esac
	case test_echo1 in *[!a-z0-9_]*) exit 1; esac
}


test_case_pxcf () # case where both '*' and '[^a-z0-9_]' unquoted
{
	# dash & heirloom sh expected to "fail" here.
	case test/echo1 in *[^a-z0-9_]*) ;; *) exit 1; esac
	case test_echo1 in *[^a-z0-9_]*) exit 1; esac
}

disabled_test_case1x () # like previous but '[^a-z0-9_]' quoted...
{
	case test/echo1 in *'[^a-z0-9_]'*) ;; *) exit 1; esac
	case test_echo1 in *'[^a-z0-9_]'*) exit 1; esac
}


test_at0 () # "$@" expansion when $# 0
{
	case $# in 0) ;; *) die "arg count 0 required for this test" ;; esac
	: "$@"
}

test_at1 () # ${1+"$@"} expansion when $# 0
{
	case $# in 0) ;; *) die "arg count 0 required for this test" ;; esac
	: ${1+"$@"}
}

test_at0for () # implicit "$@" in for loop
{
	case $# in 0) ;; *) die "arg count 0 required for this test" ;; esac
	# FreeBSD 7.1 /bin/sh will complain something like $@ not defined
	for var; do :; done
}

test_echoE () # expect backslash-escapes to be escapes by default
{
	case `echo '\n' | withpath wc` in *2*0*2) ;; *) exit 1; esac
}

test_echoc () # expect '\c' to stop producing more output
{
	case `echo '\c---'` in '') ;; *) exit 1; esac
}

test_echon () # whether 'echo -n' works
{
	echo -n
	case `echo -n` in '') ;; *) exit 1; esac
}

test_bi_printf () # builtin printf
{
	case `printf '%s' tstr` in tstr) ;; *) exit 1; esac
}

test_dollar_sq () # dollar-single expansion
{
	x=$'\n'
	case $x in ?) ;; *) exit 1; esac
}

test_hash_fatl () # some shells (heirloom sh) exits when hash fails
{
	if hash xxx_no_such_prog 2>/dev/null
	then :
	fi
}

test_hash_btin () # if there is builtin hash
{
	hash /bin/sh || hash sh=/bin/sh # latter for zsh
}

test_iexpr () # $((a + b))
{
	a=1 b=2
	c=$((a + b))
	case $c in 3) ;; *) exit 1; esac
}

test_tfft () # true && false && false || true
{
	_false () { return 1; }
	: && _false && _false || :
}

test_icat () # whether there is $(< file)
{
	d=$(< "$0")
	case $d in '') exit 1; esac
}

#test_false_x () # this should be ovbious from some of the previous tests
#{
#	e continuation of the above... this should not cause exit
#	_false || :
#}
