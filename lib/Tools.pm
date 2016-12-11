package Tools;
use strict;
use Template;
use File::Slurp 'read_file';

sub tt {
    my ($dir) = @_;
    return Template->new(ABSOLUTE => 1, INCLUDE_PATH => $dir);
}

sub file_theme {
    my ($filename) = @_;
    if ($filename =~ m{^app/design/(?:frontend|adminhtml)/(\w+/\w+)/}) {
        return $1;
    }
    return;
}

sub parse_filename {
    my ($filename) = @_;

    my %info;

    if ($filename =~ m{^app/code/(core|community|local)/((\w+/\w+)/(Model|Block|Helper)/(.*))\.php$}) {
        $info{filename} = $filename;

        $info{codepool} = $1;
        $info{file_part} = $2;
        $info{module} = $3;
        $info{type} = $4;
        $info{name} = $5;

        $info{class_name} = $info{file_part};
        $info{class_name} =~ s{/}{_}g;

        $info{module} =~ s{/}{_}g;
        $info{name} =~ s{/}{_}g;

        $info{uri_module} = lc($info{module});
        $info{uri_name} = lc($info{name});

        if ($info{type} eq 'Helper' && $info{name} eq 'Data') {
            $info{uri} = lc($info{module});
        }
        else {
            $info{uri} = join "/", lc($info{module}), lc($info{name});
        }

        my $content = read_file($filename);

        if ($content =~ m/class\s+$info{class_name}/) {
            $info{class_found} = 1;
        } else {
            $info{class_found} = 0;
        }
    }

    return \%info;
}

sub git_root {
    my $root = `git rev-parse --show-toplevel`;
    chomp $root;
    return $root;
}

1;

