
# Enter `make` on command line to get help.

# GNUmakefile template where one maybe able to run make cmd [args]
# Note: make eats (and uses!) some options (e.g. -l ("'-l'"))
# But, there are quite a few simple cases this is useful...
# Replace /bin/dash with something else if desired...
# Note: any var (e.g SHELL=/bin/zsh) can be set, those of which are
# not overridden below, and one can add more, too...
# All targets here .PHONY; One can add non-phony (internal) targets,
# but if any of those are added on command line after first goal,
# those will be .phonified (and (re)made if no errors before...).

# first target in command line "made". rest cli args as args for it,
# and after that rest targets made no-ops (early exit 0 shell exit)

# strace hints:
## strace make ... s ... 2>&1 | grep stat
## strace -ff -omsl make ... s ...
## grep execve msl.*

.ONESHELL: # gnu make >= 3.82 feature
SHELL = /bin/dash
.SHELLFLAGS = -eufc
#.SHELLFLAGS = -xeufc
.NOTPARALLEL:
.SILENT:
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules --no-builtin-variables
MAKEFLAGS += --warn-undefined-variables
unexport MAKEFLAGS

override MAKEFILE := $(MAKEFILE_LIST)# hint: make -pn -f /dev/null
# fyi: more .PHONYs, less *stat(2)s
.PHONY: $(MAKEFILE)

#$(error $(MAKECMDGOALS))
override CMD := $(firstword $(MAKECMDGOALS))
ifdef CMD
override ARGS := $(wordlist 2, 9999, $(MAKECMDGOALS))
ifdef ARGS
.PHONY: $(filter-out $(CMD), $(ARGS))
$(filter-out $(CMD), $(ARGS)): prexit0
endif
endif

.DEFAULT_GOAL = help
.PHONY: prexit0
prexit0: ; $(eval override .VARIABLES :=)
# using .VARIABLES is hack to "disable" vars.

# for recipes (note: deferred)
override define sh =
test '$(.VARIABLES)' || exit 0
#set -x
die () { printf '%s\n' '' "$$@" ''; exit 1; } >&2
x () { printf '+ %s\n' "$$*" >&2; "$$@"; }
x_eval () { printf '+ %s\n' "$$*" >&2; eval "$$*"; }
x_exec () { printf '+ %s\n' "$$*" >&2; exec "$$@"; }
endef

# a few simple sample functions

.PHONY: help
help:   # helep
	$(sh)
	echo Commands:
#	#set -x
	sed -n '/^[a-z][^ ]*:/ { s/^/  /; s/#//p; }' '$(MAKEFILE)'
	printf %s\\n '' 'Note: recipes may "eval" code in args...' ''

.PHONY: echo
echo:   # echo args
	$(sh)
	test '$(ARGS)' || die 'No args'
	set -- $(ARGS) # example; could have used this in place of $$@ below
	echo $$# - "$$@"

.PHONY: mkwt
mkwt:   # make worktree from commit (for temporary use, execute in repo root)
	$(sh)
	test -d .git || die "$$PWD/.git: no such directory"
	test -h .git && die "$$PWD/.git: is a symbolic link"
	test '$(ARGS)' || die "Usage: make mkwt {cref}  (e.g. @{u})"
	cref='$(firstword $(ARGS))'
	IFS=' -:'
	set -- `git log -1 --abbrev=7 --format='%ci %h' "$$cref"`
	IFS=' '
	dir=wt-"$$1"$$2"$$3"-"$$4"$$5"$$6"-g"$$8"
	test -d $$dir && die "'$$dir' exists. remove for rebuild"
	x git worktree add $$dir "$$cref"

.PHONY: prwt
prwt:   # prune worktrees (created by mkwt)
	$(sh)
	test -d .git || die "$$PWD/.git: no such directory"
	test -h .git && die "$$PWD/.git: is a symbolic link"
	test '$(ARGS)' || die "Usage: make prwt {wt-dir...}"
	for d in $(ARGS)
	do case $$d in wt-2*) ;; *) die "'$$d' does not start with 'wt-2'";esac
	   test -e "$$d/.git" || die "'$$d/.git' does not exist"
	done
	x rm -rf $(ARGS)
	x_exec git worktree prune -v

.PHONY: ls
ls:     # list filez (not very useful) (fyi: e.g. "'-l'" gets thru as '-l')
	$(sh)
	set -x
	exec ls $(ARGS)

.PHONY: vars.
vars.:  # list make .VARIABLES
	$(foreach v,$(.VARIABLES),$(info $(origin $v) $(flavor $v) $v = $($v)))

.PHONY: source
source: # show code of any of the commands listed here
	$(sh)
	echo
	e=
	for a in $(ARGS)
	do e=$$e"/^$$a"':/,/^$$/p;'
	done
	exec sed -n "$$e" '$(MAKEFILE)'

# Local variables:
# mode: makefile
# End:
