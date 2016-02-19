#!/usr/bin/env perl
use strict;
use feature "say";

use FindBin '$Bin';

open my $in, '-|', "find ./app/code -name 'config.xml' | xargs $FindBin::Bin/magento-helper"
    or die "Can't open input process";

my %helpers;
my %models;
my %blocks;

my $find;
if (($find) = $ARGV[0] =~ m/^--(\w+)$/) {
    shift @ARGV;
}

while (<$in>) {
    chomp;
    my ($type, $name, $class, $pool) = m/^(\w+): \s+ (\w+) \s+ => \s+ (\w+) \s+ \((community|core|local)\)$/x;

    if ($type eq 'Helper') {
        $helpers{$name} = [ $class, $pool ];
    } elsif ($type eq 'Block') {
        $blocks{$name} = [ $class, $pool ];
    } elsif ($type eq 'Model') {
        $models{$name} = [ $class, $pool ];
    }
}

while (<>) {
    chomp;
    my ($uri, $func, $type);
    my ($class, $pool);
    my ($h, $c);

    if ((undef, $uri, $func) = m{get(?:Model|Singleton)\((["'])([^"']+)\1\)(?:->(\w+))?}) {
        $type = 'model';
        ($h, $c) = split '/', $uri;
        ($class, $pool) = @{$models{$h}||[]};
    }
    elsif ((undef,$uri) = m{getBlock\((["'])([^"']+)\1}) {
        $type = 'block';
        ($h, $c) = split '/', $uri;
        ($class, $pool) = @{$blocks{$h}||[]};
    }
    elsif (m{<block\s+} && do { (undef, $uri) = m{type=(["'])([^"']+)\1}}) {
        $type = 'block';
        ($h, $c) = split '/', $uri;
        ($class, $pool) = @{$blocks{$h}||[]};
    }
    elsif (($uri, $func) = m{helper\('([\w/]+)'\)(?:->(\w+))?}) {
        $type = 'helper';
        ($h, $c) = split '/', $uri;
        ($class, $pool) = @{$helpers{$h}||[]};
        $c //= 'data';
    }
    elsif ($find) {
        $type = $find;
        ($h, $c) = split '/';
        ($class, $pool) = @{$helpers{$h}||[]};
    }
    else {
        last;
    }

    my $fh = $class;

    if (!$fh) {
        $fh = 'Mage_' . ucfirst($h) . '_' . ucfirst($type);
        $pool = 'core';
    }

    $c =~ s/_([a-z])/_\u$1/g;
    my $helper_class = $fh . '_' . ucfirst($c);

    if ($func) {
        say 'function\\s\\+'. $func;
    } else {
        say 'class\\s\\+' . $helper_class;
    }

    $helper_class =~ s{_}{/}g;
    say 'app/code/'.$pool.'/' . $helper_class . '.php';
}
