package Tools;
use strict;
use Template;

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

1;
