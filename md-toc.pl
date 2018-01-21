#!/usr/bin/perl
# -*- mode: cperl; cperl-indent-level: 4 -*-
# $ md-toc.pl $

# Write new .md content in case the TOC
# part of the input file has changed.
# In case of file does not already have
# TOC, it needs seed line beginning with
# '·' (U+00B7, 0xC2 0xB7, MIDDLE DOT).

use 5.8.1;
use strict;
use warnings;

die "Usage: $0 filename\n" unless @ARGV;

my $fn = $ARGV[0];

die "$fn.bak exists" if -e "$fn.bak";

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
	s/^\W+//; s/\W+$//; s/\W+/-/g;
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
    print "Renaming to '$fn.bak'\n";
    die "Could not rename\n"
      unless rename "$fn", "$fn.bak";
    open O, '>', "$fn" or die;
    print O @lh, $new_toc, "\n", @lr;
    close O;
    print "Wrote '$fn'\n";
}
exit;
#}

#print @lh;
print join("\n", @lt), "\n";
print "--------\n";
print join("\\\n", @ln), "\n";
#print @lr;
