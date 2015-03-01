#!/usr/bin/env perl
use feature "say";
use IPC::Open3;
use Data::Dumper;

my @files = `find . -type f -name \'system.xml\'`;
for (@files) { chomp; }
my @cmd = ('/home/peter/work/magento-tools/magento-config', @files);

my ($in, $out, $err);
my $pid = open3($in, $out, $err, @cmd);

my $show_filename = 1;
sub check {
    my ($in, $out, $filename, $key) = @_;
    print {$in} "$1\n";
    my $output = <$out>;
    if ($output =~ m/^not found/) {
        if ($show_filename) {
            say "$filename";
            $show_filename = 0;
        }
        print $output;
    }
}

for my $filename (@ARGV) {
    open my $fh, '<', $filename or die "Can't open $filename: $!";
    $show_filename = 1;
    while (<$fh>) {
        chomp;
        if (m/const\s+XML_PATH_[A-Z_]+\s+=\s+'([^']+)';/) {
            check($in, $out, $filename, $1);
        } elsif (m/getStoreConfig(?:Flag)?\('([^']+)'\)/) {
            check($in, $out, $filename, $1);
        } elsif (m/getStoreConfig(?:Flag)?\("([^"]+)"\)/) {
            check($in, $out, $filename, $1);
        }
    }
}
close $in;
close $out;

waitpid $pid, 0;
