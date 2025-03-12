#!/bin/sh

# how $#, $0 and $@ show up when sourcing...

# probably no -u but anyway...
if test "${SOURCEME_PFX-}"
then
        echo $SOURCEME_PFX: $# : $0 : "$@"
        return 0
        exit 1
fi

# the non-sourced shell script part
case $- in *i*) echo "Execute, do not 'source' this file."; return 0; esac

set -uf #-e

echo
echo exec: $# : $0 : "$@"

case $0 in */*) f=$0 ;; *) f=./$0 ;; esac

for sh in /bin/sh /bin/dash /bin/bash /bin/zsh /bin/ksh
do
        test -x $sh || continue
        echo
        SOURCEME_PFX=$sh $sh -c ". '$f'"
        SOURCEME_PFX=$sh $sh -c ". '$f' 1 2 3 sauna"
done
echo
