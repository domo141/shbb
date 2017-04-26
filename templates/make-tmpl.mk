
# makefile template, where `any` goal executes embedded shell script

SHELL = /bin/sh

any:
	sed '1,/^$@.sh:/d;/^#.#eos/q' $(MAKEFILE) | /bin/sh -s yes

any.sh:
	test -n "$1" || exit 1 # embedded shell script; not to be made directly
	die () { exit 1; }
	set -eux
	echo code here
#	#eos
	exit 1 # not reached


.SUFFIXES:
MAKEFLAGS += --no-builtin-rules --warn-undefined-variables

# Local variables:
# mode: makefile
# End:
