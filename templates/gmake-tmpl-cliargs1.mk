
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

# compared to *-cliargs0 one can execute some "phony targets" first,
# and if any left then first as command and rest args for it

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

# utf-8 middle dot (\u00b7)
override P := ·
#override P := ?
rcip ?=
override FOTS :=

override define cmd_and_args =
override rcip := $P$(strip $1)$P
.PHONY: $1 $(rcip)
endef

override define phony_target =
override rcip := $P$(strip $1)$P
.PHONY: $1 $(rcip)
override FOTS += $1
endef
# define for phonyless target useless...

# for recipes (note: immediate)
override define sh :=
#set -x
die () { printf '%s\n' '' "$$@" ''; exit 1; } >&2
x () { printf '+ %s\n' "$$*" >&2; "$$@"; }
x_eval () { printf '+ %s\n' "$$*" >&2; eval "$$*"; }
x_exec () { printf '+ %s\n' "$$*" >&2; exec "$$@"; }
endef

# a few simple sample functions

$(eval $(call phony_target, help ))
$(rcip):
	echo Commands:
#	#set -x
	awk '$$1 == "$$(eval" { C = $$4 }
		/^\$$\(rcip.*#/ { sub(".*#",""); printf "  %-6s %s\n",C,$$0 }'\
	$(MAKEFILE)
	printf %s\\n '' 'Note: recipes may "eval" code in args...' ''

# note: if these kept, e.g. `make source build` will also make `build`.
#       such things could be handled like gmake-tmpl-cliargs0.mk do...
build:
	set -x
	mkdir $@

build/true: | build
	$(sh)
	x_eval ':> $@'
	x chmod 755 $@

$(eval $(call cmd_and_args, b ))
$(rcip): build/true
$(rcip): # build build/true ("touch")
	echo all done for $@

$(eval $(call phony_target, clean ))
$(rcip):
	set -x
	rm -rf build

$(eval $(call cmd_and_args, rb ))
$(rcip):    $Pclean$P $Pb$P ## rebuild build/true

$(eval $(call cmd_and_args, mkwt ))
$(rcip): # make worktree from commit (for temporary use, execute in repo root)
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

$(eval $(call cmd_and_args, prwt ))
$(rcip): # prune worktrees (created by mkwt)
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

# hidden, due to no # in rcip line, shows in source if one knows to give it
$(eval $(call phony_target, vars. ))
$(rcip):
	$(foreach v,$(.VARIABLES),$(info $(origin $v) $(flavor $v) $v = $($v)))

$(eval $(call cmd_and_args, source ))
$(rcip): # show code of any of the commands listed here
	echo
	e=
	for a in $(ARGS)
	do e=$$e"/eval.*, $$a/,"'/^$$/p;'
	done
	exec sed -n "$$e" '$(MAKEFILE)'

# -----

.PHONY: .cmdone.
.cmdone.: ; $(eval override FOTS :=)

override define cmdone =
ifneq ($(FOTS),)
$$(error '$(subst $P,,$1)': command/target not found)
endif
endef

#DEFAULT: ; $(info $(call cmdone,$@))
.DEFAULT: ; $(eval $(call cmdone,$@))

# recursively set args after cmd, fyi: $(info $(call ... used to figure out $$s
override define setargs =
ifeq ($(CMD),$(firstword $1))
ARGS := $$(wordlist 2, 9999, $1)
else
$(eval $(firstword $1): $P$(firstword $1)$P)
$$(eval $$(call setargs, $(wordlist 2, 9999, $1)))
endif
endef

override CMD := $(firstword $(filter-out $(FOTS), $(MAKECMDGOALS)))
ifdef CMD
#(info $(call setargs, $(MAKECMDGOALS)))
$(eval $(call setargs, $(MAKECMDGOALS)))
.PHONY: $(CMD)
$(CMD): $P$(CMD)$P .cmdone.
else
$(foreach var, $(FOTS), $(eval $(var): $P$(var)$P))
endif

# Local variables:
# mode: makefile
# End:
