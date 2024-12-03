#!/bin/sh
#
# multitool-tmpl3.sh -- perhaps the best of these in multitool-tmpl series
#
# SPDX-License-Identifier: Unlicense
#

case ${BASH_VERSION-} in *.*) set -o posix; shopt -s xpg_echo; esac
case ${ZSH_VERSION-} in *.*) emulate ksh; esac

set -euf  # hint: (z|ba|da|'')sh -x thisfile [args] to trace execution

die () { printf '%s\n' '' "$@" ''; exit 1; } >&2

x () { printf '+ %s\n' "$*" >&2; "$@"; }
x_bg () { printf '+ %s\n' "$*" >&2; "$@" & }
x_env () { printf '+ %s\n' "$*" >&2; env "$@"; }
x_eval () { printf '+ %s\n' "$*" >&2; eval "$*"; }
x_exec () { printf '+ %s\n' "$*" >&2; exec "$@"; exit not reached; }

bn0=${0##*/}

usage () { die "Usage: $bn0 $cmd $@"; }

cmds=

cmds=$cmds'
cmd_addcmd  add or copy multitool cmd to a file (add stub or copy from other)'
cmd_addcmd ()
{
	case $# in 2)	case $2 in *[!a-z0-9_]*)
			die "Unsuitable characters in '$2'"
			esac
		;; 3)	test -f "$3" || die "'$3': no such file"
		;; *) usage 'to-file cmd [src-file]'
	esac
	test -f "$1" || die "'$1': no such file"
	exec perl -e 'use strict; use warnings;
my (@ofp1, $ofp2);
my $of = $ARGV[0];
my $fn = $ARGV[1]; $fn =~ s/^cmd_//;
open I, q"<", $of || die $!;
while (<I>) {
  die "'\''cmd_$fn'\'' exists in '\''$of'\'' line $.: $_" if /^cmd_$fn/;
  $ofp2 = $_, last if /^# ---/;
  push @ofp1, $_
''}
read I, $ofp2, 65536, length $ofp2;
close I;
my @fnl;
if (@ARGV == 3) {
  open I, "<", $ARGV[2] || die $!;
  while (<I>) {
     push(@fnl, $_), last if /^cmd_$fn/;
  }
  die "Cannot find '\''cmd_$fn'\'' in '\''$ARGV[0]'\''\n" unless @fnl;
  while (<I>) {
     push @fnl, $_;
     last if /^}/;
  }
''}
else { @fnl = ("cmd_$fn  dox'\''\ncmd_$fn ()\n{\n\t:\n}\n") }
close I;
open O, q">", $of or die $!; select O;
print @ofp1, "cmds=\$cmds'\''\n", @fnl, "\n", $ofp2;
close O;
chmod 0755, $of' "$@"
	exit not reached
}

cmds=$cmds'
cmd_dd  dd with if/of as first 2 args, block size 65536 and status=progress'
cmd_dd ()
{
	test $# -ge 2 || usage "ifile(or '') ofile(or '') [more dd(1) args...]"
	if=$1 of=$2; shift 2
	x_exec dd ${if:+if="$if"} ${of:+of="$of"} bs=65536 status=progress "$@"
	exit not reached
}

cmds=$cmds'
cmd_pngshrink shrink png image'
cmd_pngshrink ()
{
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
}

cmds=$cmds'
cmd_git1sum  sha1-checksum of a file like git blob has it'
cmd_git1sum ()
{
	test $# = 1 && {
	   set -- `{ stat --printf='blob %s\0' "$1"; cat "$1"; } | sha1sum`
	   echo $1
	   exit
	}
	for arg
	do set -- `{ stat --printf='blob %s\0' "$arg"; cat "$arg"; } | sha1sum`
	   printf "%s  %s\n" $1 "$arg"
	done
}

cmds=$cmds'
cmd_cls  clear screen, stty sane'
cmd_cls ()
{
	printf '\033c'
	exec stty sane
}

cmds=$cmds'
cmd_cwds cwds of running processes'
cmd_cwds ()
{
	test $# = 0 && d= || {
		case $* in .) d=.*`printf %s "$PWD"\$ | tr / .`
			;; */*) d=.*`printf %s "$*" | tr / .`
			;; *) d=".*$*"
		esac
	}
	cd /proc/self
	set +f
	ls -o /proc/[1-9]*/cwd 2>/dev/null | awk "/ -. $d/"' {
		pwd=$10; pid=gensub("/proc/([0-9]+)/.*", "\\1", 1, $8)
		getline cmd < ("/proc/" pid "/cmdline"); sub("\0.*", "", cmd)
		print pid "\t" $10 "\t" cmd }'
}

# ---

ifs=$IFS; readonly ifs
IFS='
'
test $# = 0 && {
	echo
	echo Usage: $0 '{command} [args]'
	echo
	echo Commands of $bn0 "('.' to list, '.. cmd(pfx)' to view source):"
	echo
	# 2 outcommented alternatives to the fork(2)less shell implementation
	#echo "$cmds" | sed 's/ .*//; s/cmd_/  /' | column
	#perl -x "$0" cmdcols
	set -- $cmds # xx x x x x
	rows=$((($# + 4) / 5))
	cols=$((($# + ($rows - 1)) / $rows))
	#echo argc $# - rows $rows - cols $cols
	c=0; while test $c -lt $rows; do eval r$c="'  '"; c=$((c + 1)); done
	c=0; i=0
	for arg
	do arg=${arg%% *}; arg=${arg#cmd_}
	   test $i -lt $(($# - rows)) && {
	      # one ' ' less than '?'s can handle cmd that has just 1 char
	      arg=$arg'          '; arg=${arg%${arg#???????????}}; } # 10, 11
	   eval r$c='$r'$c'$arg'
	   #printf '%2d - %d  |%s|\n' $i $c $arg
	   i=$((i + 1)); c=$((i % rows))
	done
	#as $IFS is \n, no need to quote \$r$c
	c=0; while test $c -lt $rows; do eval echo \$r$c; c=$((c + 1)); done
	echo
	echo Command can be abbreviated to any unambiguous prefix.
	echo
	exit 0
}
cm=$1; shift

case $#/$cm
in 0/.)
	# in a multitool w/ just a few commands this can be above when $# = 0
	set -- $cmds
	IFS=' '
	echo
	for cmd
	do	set -- $cmd; cmd=${1#cmd_}; shift
		printf ' %-9s  %s\n' $cmd "$*"
	done
	echo
	exit
;; 1/..)
	set +x
	# $1 not sanitized but that should not be too much of a problem...
	exec sed -n "/^cmd_$1/,/^}/p; \${g;p}" "$0"
;; */.) cm=$1; shift
;; */..) cmd=..; usage cmd-prefix

#;;	d) cm=diff
esac

cc= cp=
for m in $cmds
do
	m=${m#cmd_}; m=${m%% *}
	case $m in
		$cm) cp= cc=1 cmd=$cm; break ;;
		$cm*) cp=$cc; cc="$m $cc"; cmd=$m ;;
	esac
done
IFS=$ifs

test "$cc" || die "$0: $cm -- command not found."
test "$cp" && die "$0: $cm -- ambiguous command: matches $cc"

unset cc cp cm
#set -x
cmd'_'$cmd "$@"
exit

# -v- unused but could be used -v- see #perl -x "$0" cmdcols above
#
#!perl
#line 219
#---- 219

use 5.8.1;
use strict;
use warnings;

if ($ARGV[0] eq 'cmdcols') {
	open I, '<', $0 or die $!;
	my @cmds;
	while (<I>) {
		next unless /^cmd_(\S+)\s[^(]+\w/;
		push @cmds, $1
	}
	close I;
	my @ws = (0, 0, 0, 0, 0);
	my $cc = scalar @cmds; my $c = int(($cc + 4) / 5);
	push @cmds, ""; push @cmds, ""; push @cmds, ""; push @cmds, "";
	for (my $i = 0; $i < $c; $i++) {
		my $w = length $cmds[$i];    $ws[0] = $w if $w > $ws[0];
		$w = length $cmds[$i+$c];    $ws[1] = $w if $w > $ws[1];
		$w = length $cmds[$i+$c*2];  $ws[2] = $w if $w > $ws[2];
		$w = length $cmds[$i+$c*3];  $ws[3] = $w if $w > $ws[3];
		$w = length $cmds[$i+$c*4];  $ws[4] = $w if $w > $ws[4];
	}
	for (my $i = 0; $i < $c; $i++) {
		printf  " %-$ws[0]s   %-$ws[1]s   %-$ws[2]s  " .
			" %-$ws[3]s   %-$ws[4]s\n", $cmds[$i],
			$cmds[$i+$c], $cmds[$i+$c*2],
			$cmds[$i+$c*3], $cmds[$i+$c*4]
	}
	exit
}
