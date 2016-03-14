#!/usr/bin/env perl
use strict;
use feature "say";

use FindBin '$Bin';
use IPC::Run3;
use lib $Bin . '/../lib';

use Tools;
use Data::Dumper;
use File::Slurp 'write_file';

open my $in, '-|', "find ./app/code -name 'config.xml' | xargs $FindBin::Bin/../bin/magento-helper"
    or die "Can't open input process";

my %helpers;
my %models;
my %blocks;
my @class_prefix;
my %class_info;

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

    push @class_prefix, $class;
    $class_info{$class} = { name => $name, pool => $pool, class => $class, type => $type };
}

my $info = Tools::parse_filename($ARGV[0]);

my $class_name = $info->{class_name};
my $cinfo;

if ($class_name =~ m/^Mage_Core_(Model|Block|Helper)/) {
    $info->{uri_module} = 'core';
    $info->{type} = $1;
}
else {
    for my $prefix (@class_prefix) {
        if ($class_name =~ m/^$prefix/) {
            # $class_name is part of $prefix
            $cinfo = $class_info{$prefix};
            $info->{uri_module} = $cinfo->{name};
            $info->{type} = $cinfo->{type};
            last;
        }
    }
}

# what is current module?
my $module = `modules.sh | fzf`;
chomp $module;

my ($codepool, $module_dir) = split m{/}, $module, 2;

# Crazy to find name of file, class and dir
my $rewritten_module = $info->{uri_module};
$rewritten_module =~ s{_}{/}g;
$rewritten_module =~ s{((^|/)[a-z])}{uc($1)}ge;
my $rewritten_name = $info->{uri_name};
$rewritten_name =~ s{_}{/}g;
$rewritten_name =~ s{((^|/)[a-z])}{uc($1)}ge;
my $type = $info->{type};
my $module_filename = "$module_dir/$type/Rewrite/$rewritten_module/$rewritten_name.php";
my $module_class_name=$module_filename;
$module_class_name =~ s/\.php$//;
$module_class_name =~ s{/}{_}g;
my $full_filename = "app/code/$codepool/$module_filename";
say $full_filename;

# config.xml aanpassen
my $uri_module = $info->{uri_module};
my $uri_name = $info->{uri_name};

my $xslt_filename = $Bin . '/../xml/'.lc($type).'_rewrite.xslt';
my $config_filename = "app/code/$codepool/$module_dir/etc/config.xml";

system('cp', $config_filename, '/tmp/output.tmp.xml');

my @cmd = ('xmlstarlet', 'tr', '--inplace', $xslt_filename,
    '-s', qq{rewrite_package=$uri_module},
    '-s', qq{rewrite_class=$uri_name},
    '-s', qq{class_name=$module_class_name},
    $config_filename);

my ($in,$out,$err);
run3(\@cmd,\undef,\$out,\$err);

@cmd = ('xmlstarlet','fo','-s','4','-');
my $newout;
run3(\@cmd,\$out,\$newout,\$err);
write_file($config_filename, $newout);

# create new file
my $tt = Tools::tt();

my $extra = '';
if ($type eq 'Model') {
    $extra = '-simple';
}

my $template = $Bin.'/../tt/'.lc($type).'-'.lc($type).$extra.'.tt';
$tt->process($template, {
    class_name   => $module_class_name,
    extends_name => $class_name,
}, $full_filename) or $tt->error;

