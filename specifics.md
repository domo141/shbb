
Things not working on all modern shells
=======================================

Most often the common denominator is dash(1) (or e.g bsd equivalents
-- so let's start with such) examples:

dollar-single
-------------

(notice `"'` quote switch before ${#var} in lines below.)

    $ dash -c "var=\$'\n'; printf '%s %s\n' "' ${#var} $var'
    3 $\n

    $ bash -c "var=\$'\n'; printf '%s %s\n' "' ${#var} $var'
    1

    $ zsh -c "var=\$'\n'; printf '%s %s\n' "' ${#var} $var'
    1
     

By default zsh does not use `$IFS` to split (and to drop $IFS on)
unquoted $variables, so there is one "extra" newline above in
zsh output.

[[ ]]
-----

Not in dash, present in bash, zsh & ksh (might have sligthly different
behaviour, have to test).

todo: examples


using ^ to negate in case pattern
---------------------------------

Does not work in dash (may even not be defined in any standard). there
is no need to use it, `[!...]` works in all modern shells. See
["Default deny" in snippets](snippets.md#default-deny---everything-not-explicitly-permitted-is-forbidden)
for an example.
