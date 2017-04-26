
Blocks for interactive shells
=============================


dot-sh-eternalhistory
---------------------

How to manage a list of good commands one has ever executed. The hardest
part is to decide which is good and which is not.

An alternative to that is just record all commands ever executed, and
then have means to search (grep) through (all) that content

It would be pretty unmanageable to have all this history in one file;
the used alternative here is to have each shell write its own history
file (this also prevents overwrites) -- history files are named
``$HOME/.shhistories/YYYYMM/YYYYMMDD-HHMMSS.PID``.

With this, a command (shell function, that is) ``gh`` (grep history) is
provided. It takes (optional) ``daysback`` argument (default 7 days), and
then string to grep for. I.e. default one weeks content is searched.

An another shell function, ``h`` prints history. In bash, it prints
time of execution and history number; in zsh: history number,
time of execution and execution time.

See files dot-bash-eternalhistory__ and dot-zsh-eternalhistory__.

__ dot-bash-eternalhistory
__ dot-zsh-eternalhistory

I've personally used zsh since 1995, and have had some form of this
in use since early 2000s -- bash code is separate sourcable component;
zsh code I had to strip from my configuration files...


bash printexitvalue
-------------------

Zsh and tcsh have shell option which, after executing a command, prints
a message if the return value is nonzero. With this oneliner one can
add such a feature to bash (mimics zsh behaviour):

    trap 'echo -n bash: exit $? \ \ ; fc -nl -1 -1' ERR

(``setopt printexitvalue`` in zsh)


simple command line calculator
------------------------------

zsh version
'''''''''''

    alias c='LC_ALL=C noglob perl -e '\''shift; $x = eval qq(@ARGV); print $x; printf "  0x%x  0%o  %b\n", $x, $x, $x'\'' _'


bash version
''''''''''''

I did have something somewhere...
