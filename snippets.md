
Snippets
========

For simplicity, echo is often used to display output. In case of
user input, use e.g. printf %s\\n ... instead.


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
         demonstrate_lazy_init
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

