#!/usr/bin/perl
use feature 'say';
use Data::Dumper;
use XML::Simple;
use Path::Tiny;

my %helpers;
my %models;

for my $section (qw/core community local/) {
    my $basedir = '/var/www/html/magento/app/code/' . $section;
    my $dir = path($basedir);
    my $it = $dir->iterator({recurse => 1});
    while (my $path = $it->()) {
        my $relpath = $path->relative($basedir);
        if ($relpath =~ m{/etc/config\.xml$}) {
            my $in = XMLin($path->filehandle);
            if (ref($in->{global}) eq 'HASH') {
                my %h = %{$in->{global}{helpers}};
                %helpers = (%helpers, %h);
                %h = %{$in->{global}{models}};
                %models = (%models, %h);
            } elsif (ref($in->{global}) eq 'ARRAY') {
                for (@{$in->{global}}) {
                    if (exists $_->{helpers}) {
                        my %h = %{$_->{helpers}};
                        %helpers = (%helpers, %h);
                    }
                    if (exists $_->{models}) {
                        my %h = %{$_->{models}};
                        %models = (%models, %h);
                    }
                }
            }
        }
    }
}

print Dumper(\%helpers);
say Mage::helper('tax');
#say Mage::getModel('catalog/product');

package Mage;

sub getModel {
    my ($name) = @_;
    my ($model,$class) = split '/', $name;
    if ($models{$model}) {
        return $models{$model}{class} . '_' . ucfirst($class);
    }
    return;
}

sub helper {
    my ($name) = @_;
    if ($helpers{$name}) {
        return $helpers{$name}{class} . '_Data';
    }
    return;
}
