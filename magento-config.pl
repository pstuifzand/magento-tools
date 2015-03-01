#!/usr/bin/env perl
use feature "say";

open my $check_fh, '|-', '/home/peter/work/magento-tools/magento-config `find . -type f -name \'system.xml\'`'
    or die "Can't open: $!";

while (<ARGV>) {
    chomp;
    if (m/getStoreConfig(?:Flag)?\('([^']+)'\)/) {
        print {$check_fh} "$1\n";
    }
}

close $check_fh;

