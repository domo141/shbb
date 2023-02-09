
Snippets larger than just a few lines
=====================================

1 - 24th letter of (ascii) alphabet
-----------------------------------

This one works also in dash(1). bash/zsh could just index the string...

0-23 -indexed. I have one usecase where I split day in a 2 letter
string, 1st per hour, 2nd per 2.5 minutes (150 seconds).

Somewhat easy to extend...

    nth_lc_letter ()
    {
        local l u; l=$1 # IIRC local did not work in ksh...
        test $l -ge 12 && u=mnopqrstuvwx l=$((l - 12)) || u=abcdefghijkl
        test $l -ge 6 && u=${u#??????} l=$((l - 6))
        test $l -ge 3 && u=${u#???} l=$((l - 3))
        test $l -ge 2 && u=${u#??} l=$((l - 2))
        test $l -ge 1 && u=${u#?} l=$((l - 1))
        l=${u#?}
        printf '%2d %s\n' $1 ${u%$l}
    }
    # test code
    x=0; while test $x -le 23; do nth_lc_letter $x; x=$((x + 1)); done

Version w/o local vars, and one var (l) where the result is

    nth_lc_letter ()
    {
        test $1 -ge 12 && { l=mnopqrstuvwx; set -- $(($1 - 12)); } ||
                            l=abcdefghijkl
        test $1 -ge 6 && { l=${l#??????}; set -- $(($1 - 6)); }
        test $1 -ge 3 && { l=${l#???}; set -- $(($1 - 3)); }
        test $1 -ge 2 && { l=${l#??}; set -- $(($1 - 2)); }
        test $1 -ge 1 && { l=${l#?}; set -- $(($1 - 1)); }
        set -- ${l#?}
        l=${l%$1}
    }
    # test code
    x=0
    while test $x -le 23; do nth_lc_letter $x; echo $x $l; x=$((x + 1)); done
