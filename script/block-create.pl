#!/usr/bin/env perl
use feature "say";
use Template;
use FindBin '$Bin';
use Data::Dumper;
use Set::Scalar;
use lib $Bin.'/../lib';
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
my $block_name  = shift @args or die "No block_name";

my $module_filename = $module_name;
$module_filename =~ s{_}{/}g;

my $block_filename = $block_name;
$block_filename =~ s{_}{/}g;

my $basedir = "app/code/$codepool";

my $uri = lc($module_name) . '/' . lc($block_name);

my @parts = (
    {
        class_name => "${module_name}_Block_${block_name}",
        template   => $Bin.'/../tt/block-block.tt',
        block_uri  => $uri,
        filename   => $basedir . "/${module_filename}/Block/${block_filename}.php",
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


