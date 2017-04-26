#!/bin/sh

# a shell script with perl program at the end.

set -eufx

# do stuff

echo `perl -x "$0" --jep-- "$@" 2>&1`

exit

#!perl
#line 10
#---- 10

use 5.8.1;
use strict;
use warnings;

warn "Heya there: ", "@ARGV";
