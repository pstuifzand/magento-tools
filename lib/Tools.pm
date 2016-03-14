package Tools;
use strict;
use Template;

sub tt {
    my ($dir) = @_;
    return Template->new(ABSOLUTE => 1, INCLUDE_PATH => $dir);
}

1;
