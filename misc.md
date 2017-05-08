
Misc characteristics
====================


bash forks
----------

When running external command in command substition, bash seems to
always fork at least twice. In simplest cases one would suffice.

    $ ltrace -f -e trace=clone bash -c ': `/bin/true`'
    [pid 4046] --- Called exec() ---
    [pid 4046] +++ exited (status 0) +++
    [pid 4045] +++ exited (status 0) +++
    [pid 4044] +++ exited (status 0) +++

Where dash (and zsh) outputs:

    $ ltrace -bf -e trace=fork dash -c ': `/bin/true`'
    [pid 4128] --- Called exec() ---
    [pid 4128] +++ exited (status 0) +++
    [pid 4127] +++ exited (status 0) +++

Same can be observed with strace(1):

    $ strace -qqf -e trace=clone,execve bash -c ': `/bin/true`' 2>&1 | sed s/,.*//
    execve("/bin/bash"
    clone(child_stack=NULL
    [pid  5876] clone(child_stack=NULL
    [pid  5877] execve("/bin/true"
    [pid  5876] --- SIGCHLD {si_signo=SIGCHLD
    --- SIGCHLD {si_signo=SIGCHLD

One could use `exec $command` (to drop that "extra" fork) in the scripts
(*I do, just to nitpick*), but some care has to be taken where that exec
is effective -- with builtin commands the effect is negative -- external
command is executed instead. In pipeline `exec` has no effect, and trying
to do `$(exec shell_function)` will fail.
