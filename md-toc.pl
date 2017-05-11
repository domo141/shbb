#!/usr/bin/perl
# -*- mode: cperl; cperl-indent-level: 4 -*-
# $ md-toc.pl $

# Output new .md content in case the TOC
# part of the input file has changed.
# In case of file does not already have
# TOC, it needs seed line beginning with
# '·' (U+00B7, 0xC2 0xB7, MIDDLE DOT).

use 5.8.1;
use strict;
use warnings;

open I, '<', $ARGV[0] or die;

my (@lh, @lt, @lr, @ln);

while (<I>) {
    chomp, push(@lt, $_), last if /^·/;
    push @lh, $_;
}

while (<I>) {
    push(@lr, $_), last unless /^·/;
    chomp;
    push @lt, $_;
}

my $p;
while (<I>) {
    push @lr, $_;
    if (/^-----/) {
	chomp $p;
	$_ = $p;
	s/\W+/-/g; s/-+$//;
	push @ln, "· [$p](#$_)";
    }
    $p = $_;
}

my $current_toc = join("\n", @lt);
my $new_toc     = join("\\\n", @ln);

#if (0) {
if ($current_toc eq $new_toc) {
    print "No changes in TOC.\n";
}
else {
    print @lh, $new_toc, "\n", @lr;
}
exit;
#}

#print @lh;
print join("\n", @lt), "\n";
print "--------\n";
print join("\\\n", @ln), "\n";
#print @lr;
