#if 0 /* -*- mode: c; c-file-style: "stroustrup"; tab-width: 8; -*-
 set -euf; trg=${0##*''/}; trg=${trg%.c}; test ! -e "$trg" || rm "$trg"
 WARN="-Wall -Wstrict-prototypes -Winit-self -Wformat=2" # -pedantic
 WARN="$WARN -Wcast-align -Wpointer-arith " # -Wfloat-equal #-Werror
 WARN="$WARN -Wextra -Wwrite-strings -Wcast-qual -Wshadow" # -Wconversion
 WARN="$WARN -Wmissing-include-dirs -Wundef -Wbad-function-cast -Wlogical-op"
 WARN="$WARN -Waggregate-return -Wold-style-definition"
 WARN="$WARN -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls"
 WARN="$WARN -Wnested-externs -Winline -Wvla -Woverlength-strings -Wpadded"
 case ${1-} in '') set x -O2; shift; esac
 #case ${1-} in '') set x -ggdb; shift; esac
 set -x; exec ${CC:-gcc} -std=c99 $WARN "$@" -o "$trg" "$0"
 exit $?
 */
#endif

// compile this as sh thisfile.c

// a template for single file c project. warning options match gcc 4+
// (and possibly clang) edit to suit your needs
// (pragmas tbd, in another template)

//#include <unistd.h>
//#include <stdio.h>
//#include <string.h>
//#include <stdlib.h>
//#include <stdbool.h>
//#include <fcntl.h>
//#include <sys/types.h>
//#include <.h>


int main(void)
//int main(int argc, char * argv[])
{
    return 0;
}
