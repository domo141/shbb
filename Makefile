# -*- makefile -*-
# Not copyrighted -- provided to the public domain

SHELL = /bin/sh

.PHONY: force

instructions:
	@echo
	@echo The following targets can be run with this make:
	@echo '' heirloom-sh
	@echo


heirloom-sh-050706.tar.bz2:
	: See also: http://heirloom.sourceforge.net/sh.html
	curl -Lo $@ 'http://sourceforge.net/projects/heirloom/files/heirloom-sh/050706/heirloom-sh-050706.tar.bz2/download'

heirloom-sh: heirloom-sh-050706.tar.bz2
	sed '1,/^$@.sh:/d;/^#.#eos/q' Makefile | /bin/sh -s $<
	ln -sf heirloom-sh-050706 heirloom-sh

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

clean:
	rm -f *~

distclean: clean
	rm -rf heirloom-sh*

.SUFFIXES:
#EOF
