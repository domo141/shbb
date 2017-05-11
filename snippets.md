
Snippets
========

For simplicity, echo is often used to display output. In case of
user input, use e.g. printf %s\\n ... instead.

· [last argument of a function (script)](#last-argument-of-a-function-script)\
· [drop last argument](#drop-last-argument)\
· [redefining function](#redefining-function)\
· [check whitespace (IFS) characters](#check-whitespace-IFS-characters)\
· [printf multiple lines](#printf-multiple-lines)\
· [check whether directory contains just one item](#check-whether-directory-contains-just-one-item)


last argument of a function (script)
------------------------------------

    eval la='$'$#

test it:

    sh -c 'fn () { eval la='\''$'\''$#; echo $la; }; fn 1st 2nd last'

or

    sh -c 'eval la='\''$'\''$#; echo $la' 0th 1st 2nd last


drop last argument
------------------

    l=$1; shift; for arg; do set -- "$@" "$l"; l=$arg; shift; done

or (somewhat hairier)

    l=$1; shift; for _; do set -- "$@" "$l"; l=$1; shift; done

test it (in current shell):

    set a b c d
    l=$1; shift; for arg; do set -- "$@" "$l"; l=$arg; shift; done
    echo "$@"

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

`var='x y'`, `var='x"y'` and `var="x'y"`.


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
