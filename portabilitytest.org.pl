#!/usr/bin/perl
# -*- mode: cperl; cperl-indent-level: 4 -*-
# $ results.org.pl $
#
# Author: Tomi Ollila -- too ät iki piste fi
#
#	Copyright (c) 2014 Tomi Ollila
#	    All rights reserved
#
# Created: Sun 18 May 2014 22:07:23 EEST too
# Last modified: Sun 18 May 2014 23:29:16 +0300 too

use 5.8.1;
use strict;
use warnings;

die "Usage: $0 dir\n" unless @ARGV == 1;

my $wd = $ARGV[0];
die "$!" unless -d $wd;

my @shells;
open I, '<', "$wd/shells" or die "$!";
while (<I>) {
    chomp;
    tr|/| |;
    push @shells, $_;
}

print "\n", '* portabilitytest results', "\n\n";

open I, '<', "$wd/info" or die "$wd/info: $!\n";
while (<I>) {
    print $_;
}

print "\n", 'Shells: ', join(", ", @shells);
print "\n\n";

while (<$wd/[0-9][0-9]_*>)
{
    next if /[.]out$/;

    s|.*/||;
    print "| [[#$_][$_]] |";
    my $test = $_;
    foreach (@shells) {
	if (-f "$wd/$test.$_.out") {
	    my $s = $_; $s =~ tr/ /-/;
	    print " +[[#f-$test-$s][$_]]+ |";
	}
	else { print " *$_* |"; }
    }
    print "\n";
}
print "\n";

while (<$wd/[0-9][0-9]_*>)
{
    next if /[.]out$/;

    print "-----\n";
    open I, '<', $_ or die $!;
    s|.*/||;
    print "** $_\n\n";
    my $test = $_;
    print "#+BEGIN_SRC\n";
    while (<I>) { print $_; }
    close I;
    print "#+END_SRC\n";
    print "\n";
    my $cnt = 0;
    foreach my $sh (@shells) {
	#warn "$wd -- $test -- $sh \n";
	if (-f "$wd/$test.$sh.out") {
	    print "*** f $test $sh\n\n";
	    #print "#+BEGIN_VERSE\n";
	    print "#+BEGIN_SRC\n";
	    open I, '<', "$wd/$test.$sh.out" or die $!;
	    while (<I>) { print '', $_; }
	    close I;
	    print "#+END_SRC\n";
	    #print "#+END_VERSE\n";
	    print "\n";
	    $cnt++;
	}
    }
    if ($cnt) {
	print "$cnt of the tested shells failed to execute this test\n";
    } else {
	print "all of the tested shells executed this test successfully\n";
    }
}
