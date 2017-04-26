
alias c: simple command line calculator
=======================================

This provides command line alias `c`, which gives the following expressions
for perl(1) to compute.

output is in float, hexadecimal, octal and binary formats (fractional parts
only in float numbers).

This works pretty well in most common cases; e.g:

seconds per year (average)

    $ c 86400 * 365.25
    31557600  0x1e187e0  0170303740  1111000011000011111100000

gigasecond (approximate)

    $ c 1e9 / 86400 / 365.25
    31.688087814029  0x1f  037  11111

ditto, in binary

    $ c 2**30 / 86400 / 365.25
    34.0248252085076  0x22  042  100010

simple hex

    $ c 0x66
    102  0x66  0146  1100110

something that needs quotes

    $ c '102 & 0x0f'
    6  0x6  06  110

ditto

    $ c '1 << 8'
    256  0x100  0400  100000000


The zsh part is simple, the `noglob` prefix disables pathname expansion for
the rest of the command line. In bash we had to do some tricks...


zsh
---

### simple command-line calculator

    alias c='LC_ALL=C noglob perl -e '\''shift; $x = eval qq(@ARGV); print $x; printf "  0x%x  0%o  %b\n", $x, $x, $x'\'' _'


bash
----

### reset_expansion copied from stack overflow (with minor edits)

    reset_expansion () { local cmd="$1"; shift; "$cmd" "$@"; set +f; }

### note: clobbers `$__` and resets `set -f` if set

### simple command-line calculator

    alias c='case $- in *f*) __x= ;; *) __=reset_expansion; set -f ;; esac; LC_ALL=C $__ perl -e '\''shift; $x = eval qq(@ARGV); printf "%s  0x%x  0%o  %b\n", $x, $x, $x, $x'\'' _'
