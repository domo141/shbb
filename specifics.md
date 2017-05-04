
Things not working in all modern shells
=======================================

Most often the common denominator is dash(1) (or e.g. bsd equivalents
-- so let's start with such) examples:


dollar-single
-------------

e.g. `var=$'line 1\nline 2 with\ttab'`

(notice `"'` quote switch before ${#var} in lines below
 -- as an attempt to simplify presentation)

    $ dash -c "var=\$'\n'; printf '%s %s\n' "' ${#var} $var'
    3 $\n

    $ bash -c "var=\$'\n'; printf '%s %s\n' "' ${#var} $var'
    1

    $ zsh -c "var=\$'\n'; printf '%s %s\n' "' ${#var} $var'
    1
     

By default zsh does not use `$IFS` to split (and to drop $IFS characters on)
unquoted $variables, so there is one "extra" newline above in zsh output.

[[ ]]
-----

Not in dash, present in bash, zsh & ksh (might have sligthly different
behaviour, to be tested).

todo: examples


test "$var1" == "$var2"
-----------------------

To test (string) equality, the comparison operator is single `=`. Use it!
(also as `[ "$var1" = "$var2" ]) `The test 16 (`test_eqeq`) in
[portabilitytest](portabilitytest/portabilitytest-2014-05-21-linux.org#16_test_testeqeq)
shows that in (linux) shells, `dash(1)` does not support double equals sign.


function keyword
----------------

`function` keyword when defining functions is not supported in dash, and
is optional in rest of the shells (where supported). Better not use it.


using ^ to negate in case pattern
---------------------------------

Does not work in dash (may even not be defined in any standard). there
is no need to use it, `[!...]` works in all modern shells. See
["Default deny" in snippets](snippets.md#default-deny---everything-not-explicitly-permitted-is-forbidden)
for an example.


stdout & stderr redirection
---------------------------

While convenient in `bash` and `zsh` interactive usage, `&>`
should not be used in shell scripts, use

    sh -c '(echo to-out; echo to-err >&2) >/dev/null 2>&1'

instead (play by removing redirections).


$(< file)
---------

Many shells have internal `cat` command substitution that replaces
e.g. `var=$(cat file)`. The replacement syntax `var=$(cat file)`
sure is faster, so in scripts that does not need to be portable to
all modern shells it can be used. Those are easy to recognize and
get replaced if need arises (sed 's/$(< */$(cat /g' seems to work).



something not working in bash
-----------------------------

Single command shell function:

    $ dash -c 'pl () printf %s\\n "$@"; pl einz deux kol'
    einz
    deux
    kol

    $ bash -c 'pl () printf %s\\n "$@"; pl einz deux kol'
    bash: -c: line 0: syntax error near unexpected token `printf'
    bash: -c: line 0: `pl () printf %s\\n "$@"; pl einz deux kol'

    $ zsh -c 'pl () printf %s\\n "$@"; pl einz deux kol'
    einz
    deux
    kol

    $ ksh -c 'pl () printf %s\\n "$@"; pl einz deux kol'
    einz
    deux
    kol
