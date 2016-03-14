#!/usr/bin/env perl
use strict;
use feature "say";

use FindBin '$Bin';
use lib $Bin . '/../lib';

use File::Basename 'dirname';
use Tools;

my $filename = shift @ARGV;
if (!$filename) {
    die "No filename argument";
}

if (!-e $filename) {
    die "File doesn't exist";
}

my $BASE = $Bin;

my $new_theme =`$BASE/themes.sh | fzf --header="Select Theme"`;
chomp $new_theme;

my $theme = Tools::file_theme($filename);

if ($theme && $new_theme) {
    my $new_file = $filename;
    $new_file =~ s/$theme/$new_theme/;
    say "cp $filename $new_file";
    system('mkdir', '-p', dirname($new_file));
    system('cp', $filename, $new_file);
}

