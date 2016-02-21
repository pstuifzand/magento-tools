#!/usr/bin/env perl

use strict;
use feature "say";
use Data::Dumper;
use File::Slurp 'read_file';

my %events;
my %extends;

my %later;

my @files = `find /var/www/html/magento/app/code -type f -name '*.php'`;

my @events;

for my $filename (@files) {
    chomp $filename;
    next if $filename =~ m/^\s*$/;
    next if $filename =~ m/install|upgrade/;
    my $content = read_file($filename);

    $filename =~ s{.*(?=app/code)}{};
    my ($class, undef, $extends, undef, $implements) =
        $content =~ m/class\s+(\w+)(\s+extends\s+(\w+))?(\s+implements\s+(\w+))?/msx;

    $events{$class} = {
        class => $class,
        extends => $extends,
        implements => $implements,
    };

    if ($class && $extends) {
        push @{$extends{$extends}}, $class;
    }

    if (!$class) {
        #warn "$filename has no class";
        next;
    }

    my $eventPrefix;
    while (!$eventPrefix && $content =~ m/\$_eventPrefix\s+=\s+'([^']+)'/gms) {
        $eventPrefix = $1;
        $events{$class}{event_prefix} = $eventPrefix;
    }
    while ($content =~ m/dispatchEvent\(\s*\$this->_eventPrefix\s*\.\s*'([^']+)'/gms) {
        push @{$later{$class}}, $1;
        if ($eventPrefix) {
            push @{$events{$class}{events}}, "$eventPrefix$1";
        }
    }
    while ($content =~ m/dispatchEvent\('([^']+)'/gms) {
        push @{$events{$class}{events}}, "$1";
    }
}

for my $class (keys %later) {
    my @parts = @{$later{$class}};
    for my $p (@parts) {
        my @classes;
        my @t = @{$extends{$class}||[]};

        while (@t) {
            my @u;
            for (@t) {
                if (@{$extends{$_}||[]}) {
                    push @u, @{$extends{$_}};
                }
            }
            push @classes, @t;
            @t = @u;
            @u = ();
        }
        if (@t) {
            push @classes, @t;
        }

        for my $sub_class (@classes) {
            my $x = $events{$sub_class};
            if ($x->{event_prefix}) {
                push @events, $x->{event_prefix} . $p;
            }
        }
    }
}

for my $class (keys %events) {
    for my $event (@{$events{$class}{events}}) {
        push @events, $event;
    }
}

my %uniq = map { $_ => 1 } @events;
say for sort keys %uniq;


