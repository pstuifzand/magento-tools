#!/usr/bin/env perl
use strict;
use feature "say";

open my $in, '-|', "find /var/www/html/magento/app/code -name 'config.xml' | xargs /home/peter/work/magento-tools/mh"
    or die "Can't open input process";

my %helpers;
my %models;
my %blocks;

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

    if (($uri, $func) = m{get(?:Model|Singleton)\('([\w/]+)'\)(?:->(\w+))?}) {
        $type = 'model';
        ($h, $c) = split '/', $uri;
        ($class, $pool) = @{$models{$h}};
    }
    elsif (($uri) = m{getBlock\('([\w/]+)'\)}) {
        $type = 'block';
        ($h, $c) = split '/', $uri;
        ($class, $pool) = @{$blocks{$h}};
    }
    elsif (($uri, $func) = m{helper\('([\w/]+)'\)(?:->(\w+))?}) {
        $type = 'helper';
        ($h, $c) = split '/', $uri;
        ($class, $pool) = @{$helpers{$h}};
        $c //= 'data';
    }
    else {
        last;
    }

    my $fh = $class;

    if (!$fh) {
        $fh = 'Mage_' . ucfirst($h) . '_' . ucfirst($type);
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
