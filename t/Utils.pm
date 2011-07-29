package t::Utils;
use strict;
use warnings;
use Test::TCP qw(empty_port wait_port);
use File::Which qw(which);
use Proc::Guard;

sub import {
    my $caller = caller(0);

    for my $func (qw/setup_memcached teardown_memcached/) {
        no strict 'refs'; ## no critic.
        *{$caller.'::'.$func} = \&$func;
    }

    strict->import;
    warnings->import;
}

my %_memcached;

sub setup_memcached {
    my $port = shift || empty_port;
    my $proc = proc_guard( scalar which('memcached'), '-p', $port, '-U', 0 );
    wait_port( $port );
    $_memcached{$port} = $proc;
    $port;
}

sub teardown_memcached {
    my $port = shift;
    if ($port) {
        delete $_memcached{$port};
    } else {
        delete $_memcached{$_} for keys %_memcached;
    }
}

1;

