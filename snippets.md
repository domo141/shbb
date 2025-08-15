
Snippets
========

For simplicity, echo is often used to display output. In case of
user input, use e.g. printf %s\\n ... instead.

· [last argument of a function (script)](#last-argument-of-a-function-script)\
· [drop last argument](#drop-last-argument)\
· [redefining function](#redefining-function)\
· ["dots to dashes"](#dots-to-dashes)\
· [check whitespace (IFS) characters](#check-whitespace-IFS-characters)\
· [printf multiple lines](#printf-multiple-lines)\
· [check whether directory contains just one item](#check-whether-directory-contains-just-one-item)\
· [check all args are files](#check-all-args-are-files)
· [silence set +x](#silence-set-x)\
· [create or truncate existing to empty file](#create-or-truncate-existing-to-empty-file)\
· [test whether variable is unset](#test-whether-variable-is-unset)\
· [test whether variable is null (empty)](#test-whether-variable-is-null-empty)\
· [at_exit_functions](#at_exit_functions)\
· [(exit) traps in stack](#exit-traps-in-stack)


last argument of a function (script)
------------------------------------

    eval la='${'$#'}'

test it:

    sh -c 'fn () { eval la='\''${'\''$#'\''}'\''; echo $la; }; fn 1st 2nd last'

or (effectively same eval)

    sh -c 'eval la=\$"{$#}"; echo $la' 0 1 2 3 4 5 6 7 8 9 a last


drop last argument
------------------

... from "$@", but have it set in $la as as "side effect"


    la=$1; shift; for arg; do set -- "$@" "$la"; la=$arg; shift; done

or (somewhat hairier)

    la=$1; shift; for _; do set -- "$@" "$la"; la=$1; shift; done

test it (in current shell):

    set a b c d
    la=$1; shift; for arg; do set -- "$@" "$la"; la=$arg; shift; done
    echo "$@"
    echo "$la"


dots to dashes
--------------

may one have a value with dots, e.g. `1.2.3.4`. one desires to change
those dots to dashes, e.g. to get `1-2-3-4`...

    dots_to_dashes () {
        saved_IFS=$IFS; IFS=.; set -- $1;
        IFS=-; dashed=$*; IFS=$saved_IFS; unset saved_IFS
    }
    # the version where (readonly) $saved_IFS is available
    # dots_to_dashes () { IFS=.; set -- $1; IFS=-; dashed=$*; IFS=$saved_IFS; }
    dots_to_dashes 1.2.3.4
    echo "$dashed"

works w/ any one character, be it 'dot' or 'dash' to be changed; adjust
your target var, or eval it to a var if more generic function desired


redefining function
-------------------

    demonstrate_lazy_init () {
        echo doing some initialization stuff
        demonstrate_lazy_init () {
            echo doing further stuff: args "$@"
        }
        demonstrate_lazy_init "$@"
    }

    demonstrate_lazy_init first call
    demonstrate_lazy_init second call

another:

    do_it_once () {
        echo doing this thing only once
        do_it_once () { :; }
    }
    do_it_once
    do_it_once


check whitespace (IFS) characters
---------------------------------

    case $var in *["$IFS"]*) echo "whitespace!" >&2; exit 1; esac

or '

    case $var in *"'"*) echo "apostrophe[s] (')!" >&2; exit 1; esac

both (including ")

    case $var in *["$IFS'"'"']*) echo "whitespace or [\"']!" >&2; exit 1; esac

data to test the above (note: shell will exit):

`var='x y'`, `var='x"y'` and `var="x'y"`. <!-- " -->

### Default deny - "Everything, not explicitly permitted, is forbidden":

     case $var in *[!a-zA-Z-9_,.-]*) echo "Unsupported characters!" >&2; exit 1; esac


printf multiple lines
---------------------

to 'file':

    printf > file %s\\n \
        'line 1; no $var interpolation' \
        "line 2; pwd $PWD" \
        home-in-next-line: ~

another (to stdout):

    set +f
    echo "Files in $PWD:"; printf '  %s\n' *


check whether directory contains just one item
----------------------------------------------

    case ${ZSH_VERSION-} in *.*) PATH=/ emulate ksh; esac # or setopt no_nomatch

    onefile=
    onefile () {
        test $# = 1 || return 0
        case $1 in '*' | */'*' ) return; esac # filename '*' not supported ;/
        onefile=$1
    }
    set +f
    onefile * # also onefile subdir/* would work
    test "$onefile" && echo $onefile || echo less or more than one file


check all args are files
------------------------

note: test -f '' is false (not a file), too

    for f; do test -f "$f" || { f=; break; }; done
    test "$f" && echo all args files || echo not all args files
    unset f
    echo continue to do other things...


silence set +x
--------------

    set -x
    : message when XTRACE on :
    { set +x; } 2>/dev/null
    : now quiet :


create or truncate existing to empty file
-----------------------------------------

    : > empty_file


test whether variable is unset
------------------------------

    if test "${var-u1}" = u1 && test "${var-u2}" = u2
    then
        echo "Variable 'var' is unset"
    fi


test whether variable is null (empty)
-------------------------------------

    if test "${var:-e}" = e && test "${var-e}" = ''
    then
        echo "Variable 'var' is set but empty"
    fi


at_exit_functions
-----------------

bash, zsh, ...

    declare -a _exit_functions=()

    at_exit_function () {
        _exit_functions=($1 ${_exit_functions[@]/$1})
    }

    rm_exit_function () {
        _exit_functions=(${_exit_functions[@]/$1})
    }

    trap 'for _fn in ${_exit_functions[@]}; do $_fn; done' 0

shell w/o arrays (or array syntax is a bit different)

    _exit_functions=

    at_exit_function () {
        _rm_exit_function $1
        _exit_functions=$exit_functions' '$1
    }

    rm_exit_function () {
        case $exit_functions
        in *' '$1) exit_functions=${exit_functions% $1}
        ;; *' '$1' '*) exit_functions=${exit_functions% $1 *}' '${exit_functions#* $1 }
        esac
    }

    trap 'for _fn in $_exit_functions; do $_fn; done' 0


(exit) traps in stack
---------------------

one alternative to [at_exit_functions](#at_exit_functions) above; a "stack"
of evaluable statements (separated by '; ') which can be managed by `pushtrap`
and `poptrap` functions. the top statement can be cached to `traptop` variable
with `settraptrop` function.

    traps=
    pushtrap () {
            test "$traps" || trap 'set +eu; eval $traps' 0;
            traps="$*; $traps"
    }
    poptrap () {
        case $traps in *'; '*'; '*) traps=${traps#*'; '}
                    ;; *) traps=; trap - 0
        esac
    }
    settraptop () {
            traptop=${traps%%'; '*}
    }

### some simple tests executable on shell command line

    $ ( set -x && pushtrap : 1 && pushtrap : 2 && settraptop )

    $ ( set -x && pushtrap : 1 && pushtrap : 2 && poptrap )

    $ ( set -x && pushtrap ': 1 ;: 2' && pushtrap ': a ;: b' && pushtrap : 3
        poptrap && poptrap )

    $ ( set -x && pushtrap ': 1 ;: 2' && pushtrap ': a ;: b' && pushtrap : 3
        poptrap && poptrap && poptrap )
