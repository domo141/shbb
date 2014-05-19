# -*- makefile -*-
# Not copyrighted -- provided to the public domain

SHELL = /bin/sh

.PHONY: force

instructions:
	@echo
	@echo The following targets can be run with this make:
	@echo '' heirloom-sh
	@echo '' pix '(to be obsoleted)'
	@echo


heirloom-sh-050706.tar.bz2:
	: See also: http://heirloom.sourceforge.net/sh.html
	curl -Lo $@ 'http://sourceforge.net/projects/heirloom/files/heirloom-sh/050706/heirloom-sh-050706.tar.bz2/download'

heirloom-sh: heirloom-sh-050706.tar.bz2
	sed '1,/^$@.sh:/d;/^#.#eos/q' Makefile | /bin/sh -s $<
	ln -sf heirloom-sh-050706 heirloom
	ln -sf heirloom-sh-050706/sh heirloom-sh

heirloom-sh.sh:
	test -n "$1" || exit 1 # internal shell script; not to be made directly
	die () { exit 1; }
	af=$1
	set -eux
	esha=25fb8409e1eb75bb5da21ca32baf2d5eebcb8b84a1288d66e65763a125809e1d
	asha=`openssl sha256 $af | sed 's/.*= *//'`
	case $esha in $asha) ;; *)
	 : : Checksum of '$af' unexpected
	 die Remove the file and try again to see whether the file is corrupted
	esac
	rm -rf heirloom-sh-050706
	tar jxf $af
	make -C heirloom-sh-050706
	set +x
	echo
	echo Enter '' man heirloom-sh-050706/sh.1.out '' -- or if this does not
	echo work, '' nroff -man heirloom-sh-050706/sh.1.out '|' less -R
	echo to read the manual page of The Heirloom Bourne Shell.
	echo To run the shell, execute ./heirloom-sh-050706/sh
	echo See also: http://heirloom.sourceforge.net/sh.html
	echo
#	#eos
	exit 1 # not reached

# example: pix W=134 H=38 T='Solaris 10...' S=heirloom-sh/sh
pix:
	case "$W" in '') false; esac # W=w H=h T=title [S=shells]
	sed '1,/^$@.sh:/d;/^#.#eos/q' Makefile | /bin/sh -s '$W' '$H' "$T" '$S'

pix.sh:
	test -n "$1" || exit 1 # internal shell script; not to be made directly
	die () { exit 1; }
	set -eux
	case $3 in '') die Usage: make pix W=w H=h T=title [S=shells] ;; esac
	hash urxvt 2>/dev/null || die need urxvt '(rxvt-unicode)'
	hash zsh 2>/dev/null || die need zsh
	fg=black
	bg=grey70
	exec urxvt -b 6 -bl +sb -hold -fg $fg -bg $bg -bd $bg -g ${1}x${2} -e \
	zsh -c "printf '\\33]4;3;#b7b7b7\\007'
		printf '%s  \\033[38;5;3m%s\\033[38;5;0m\\n' '$3' '(${1}x${2})'
		set x $4; shift; . ./sh-portabilitytest.sh"
#	#eos
	exit 1 # not reached

clean:
	rm -f *~

distclean: clean
	rm -rf heirloom*

.SUFFIXES:
#EOF
