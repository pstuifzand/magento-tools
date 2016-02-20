#!/usr/bin/env perl
use File::Slurp 'read_file', 'write_file';

my ($method, $filename) = @ARGV;

my $template = <<"TEMPLATE";

    public function $method(\$observer)
    {
    }
TEMPLATE

my $content = read_file($filename);
$content =~ s/^}$/$template\n}/ms;
write_file($filename, $content);

