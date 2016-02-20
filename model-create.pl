#!/usr/bin/env perl
use feature "say";
use Template;
use FindBin '$Bin';
use Data::Dumper;
use Set::Scalar;

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
my $model_name  = shift @args or die "No model_name";

my $module_filename = $module_name;
$module_filename =~ s{_}{/}g;

my $model_filename = $model_name;
$model_filename =~ s{_}{/}g;

my $basedir = "app/code/$codepool";

my $uri = lc($module_name) . '/' . lc($model_name);

my @parts = (
    {
        class_name => "${module_name}_Model_${model_name}",
        template   => $Bin.'/tt/model-model-simple.tt',
        model_uri  => $uri,
        filename   => $basedir . "/${module_filename}/Model/${model_filename}.php",
        tags       => Set::Scalar->new('simple'),
    },
    {
        class_name => "${module_name}_Model_${model_name}",
        template   => $Bin.'/tt/model-model.tt',
        model_uri  => $uri,
        filename   => $basedir . "/${module_filename}/Model/${model_filename}.php",
        tags       => Set::Scalar->new('db'),
    },
    {
        class_name => "${module_name}_Model_Resource_${model_name}",
        template   => $Bin.'/tt/model-resource.tt',
        model_uri  => $uri,
        filename   => $basedir . "/${module_filename}/Model/Resource/${model_filename}.php",
        tags       => Set::Scalar->new('db'),
    },
    {
        class_name => "${module_name}_Model_Resource_${model_name}_Collection",
        template   => $Bin.'/tt/model-collection.tt',
        model_uri  => $uri,
        filename   => $basedir . "/${module_filename}/Model/Resource/${model_filename}/Collection.php",
        tags       => Set::Scalar->new('db'),
    }
);

my $tt = Template->new(ABSOLUTE=>1);

for my $part (@parts) {
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

