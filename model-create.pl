#!/usr/bin/env perl
use Template;

my $codepool = 'community';
my $module_name = shift or die "No module_name";
my $model_name  = shift or die "No model_name";

my $module_filename = $module_name;
$module_filename =~ s{_}{/}g;

my $model_filename = $model_name;
$model_filename =~ s{_}{/}g;

my $basedir = "xml/test/app/code/$codepool";

my $uri = lc($module_name) . '/' . lc($model_name);

my @parts = (
    {
        class_name => "${module_name}_Model_${model_name}",
        template   => 'tt/model-model.tt',
        model_uri  => $uri,
        filename   => $basedir . "/${module_filename}/Model/${model_filename}.php",
    },
    {
        class_name => "${module_name}_Model_Resource_${model_name}",
        template   => 'tt/model-resource.tt',
        model_uri  => $uri,
        filename   => $basedir . "/${module_filename}/Model/Resource/${model_filename}.php",
    },
    {
        class_name => "${module_name}_Model_Resource_${model_name}_Collection",
        template   => 'tt/model-collection.tt',
        model_uri  => $uri,
        filename   => $basedir . "/${module_filename}/Model/Resource/${model_filename}/Collection.php",
    }
);

my $tt = Template->new();

for my $part (@parts) {
    $tt->process($part->{template}, $part, $part->{filename}) or die $tt->error;
}

