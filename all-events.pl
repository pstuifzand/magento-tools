#!/usr/bin/env perl

use File::Slurp 'read_file';

for my $filename (@ARGV) {
    my $content = read_file($filename);
    my $eventPrefix;
    while (!$eventPrefix && $content =~ m/\$_eventPrefix\s+=\s+'([^']+)'/gms) {
        $eventPrefix = $1;
    }
    while ($content =~ m/dispatchEvent\(\s*\$this->_eventPrefix \. '([^']+)'/gms) {
        print "$eventPrefix$1\n";
    }
    while ($content =~ m/dispatchEvent\('([^']+)'/gms) {
        print "$1\n";
    }
}
