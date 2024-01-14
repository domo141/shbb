
# GNUMakefile template where one can run make cmd [args]
# note: make eats some options (e.g. -l ("'--l'"))
# but, there are quite a few simple cases this is useful...
# replace /bin/dash with something else if desired...
# note: any var (e.g SHELL=/bin/zsh) can be set, which are
# not overridden, and one can add more, too...

# simple helper tool, not to be used in security-sensitive
# environments; it is pretty easy to make this fail...

.ONESHELL: # gnu make >= 3.82 feature
SHELL = /bin/dash
.SHELLFLAGS = -euc
#.SHELLFLAGS = -xeuc
.NOTPARALLEL:
.SILENT:

override MAKEFILE := $(MAKEFILE_LIST)  # hint: make -pn -f /dev/null

# utf-8 middle dot (\u00b7)
override P := ·
#override P := ?
.DEFAULT_GOAL: $Phelp$P

override CMD := $(firstword $(MAKECMDGOALS))
ifdef CMD
override ARGS := $(wordlist 2, 9999, $(MAKECMDGOALS))
.PHONY: $(ARGS)
endif

# fyi: more .PHONYs, less *stat(2)s
.PHONY: $(CMD) $P$(CMD)$P
$(CMD): $P$(CMD)$P

override define sh :=
#set -x
die () { printf '%s\n' '' "$$@" ''; exit 1; } >&2
x () { printf '+ %s\n' "$$*" >&2; "$$@"; }
x_exec () { printf '+ %s\n' "$$*" >&2; exec "$$@"; }
endef

# a few simple sample functions

$Phelp$P:   # helep
	echo Commands:
#	#set -x
	exec sed -n '/^\$$P/ { s/\$$P//g; s/^/  /; s/#//p }' $(MAKEFILE)


$Pecho$P:   # echo args
	$(sh) # all these 4 files like this for demonstration purpose
	test '$(ARGS)' || die 'No args'
	set -- $(ARGS) # example; could have used this in place of $$@ below
	echo $$# - $$@


$Pls$P:     # list filez (not very useful) (fyi: e.g. "'-l'" gets thru)
	set -x
	exec ls $(ARGS)

$Psource$P: # show code of any of the commands listed here
	e=
	for a in $(ARGS)
	do e=$$e"/^.P$$a"'.P/,/^$$/ { s/^$$P//; s/$$P:/:/; p };'
	done
	exec sed -n "$$e" $(MAKEFILE)
	exit not reached


.SUFFIXES:
MAKEFLAGS += --no-builtin-rules --no-builtin-variables
MAKEFLAGS += --warn-undefined-variables
unexport MAKEFLAGS

# Local variables:
# mode: makefile
# End:
