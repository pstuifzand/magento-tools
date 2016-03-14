#!/usr/bin/env perl
use feature "say";
use FindBin '$Bin';
use lib $Bin.'/../lib';
use Data::Dumper;
use Set::Scalar;
use Tools;

my $codepool = 'community';

my $tags = Set::Scalar->new;

my @args;

for (@ARGV) {
    if (m/^--simple$/) {
        $tags->insert('simple');
    } elsif (m/^--/) {
        # unknown option
    } else {
        push @args, $_;
    }
}

my $module_name = shift @args or die "No module_name";
my $helper_name  = shift @args or die "No helper_name";

my $module_filename = $module_name;
$module_filename =~ s{_}{/}g;

my $helper_filename = $helper_name;
$helper_filename =~ s{_}{/}g;

my $basedir = "app/code/$codepool";

my $uri = lc($module_name) . '/' . lc($helper_name);

my @parts = (
    {
        class_name => "${module_name}_Helper_${helper_name}",
        template   => $Bin.'/../tt/helper-helper.tt',
        helper_uri  => $uri,
        filename   => $basedir . "/${module_filename}/Helper/${helper_filename}.php",
        tags       => Set::Scalar->new(),
    },
);

my $tt = Tools::tt();

for my $part (@parts) {
    print Dumper($part);
    if (!-e $part->{filename}) {
        if (!$tags->intersection($part->{tags})->is_equal($part->{tags})) {
            next;
        }
        say $part->{filename};
        $tt->process($part->{template}, $part, $part->{filename}) or die $tt->error;
    } else {
        say $part->{filename};
    }
}


