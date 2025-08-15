#!./outer.sh
#
# $ inner-no-args.sh $

# SPDX-License-Identifier: Unlicense

echo - line 7 of inner-w-args.sh but \$0: $0

echo - SCRIPT_FILE: $SCRIPT_FILE
echo - INNER_ARG: $INNER_ARG

echo -
echo - '$0': $0
echo - '$@:' "[$#]"
test $# = 0 ||
printf '·  %s\n' "$@"
echo -

unset unset_var
echo - $unset_var - expect fail w/o seeing this
echo ! not reached !
