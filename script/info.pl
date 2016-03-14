#!/usr/bin/env perl
use strict;
use feature "say";

use FindBin '$Bin';
use lib $Bin . '/../lib';

use Tools;
use Data::Dumper;

for my $filename (@ARGV) {
    print Dumper(Tools::parse_filename($filename));
}

