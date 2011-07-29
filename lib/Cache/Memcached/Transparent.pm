package Cache::Memcached::Transparent;
use strict;
use warnings;
our $VERSION = '0.01';
use Sub::Args;
use Sub::Retry;

sub new {
    my $class = shift;
    my $args = args(
        {
            parent    => 1,
            child     => 1,
            max_retry => 1,
            delay     => 0,
        }, @_
    );
    bless {
        delay => 0.1,
        %$args,
    }, $class;
}

sub set {
    my $self = shift;
    my ($key, $val, $ttl) = args_pos(1,1,0);

    my $res = retry $self->{max_retry}, $self->{delay}, sub {
        $self->{parent}->set($key, $val, $ttl);
    };
    return unless $res;

    retry $self->{max_retry}, $self->{delay}, sub {
        $self->{child}->set($key, $val, $ttl);
    };
    $res;
}

sub get {
    my $self = shift;
    my ($key, ) = args_pos(1);

    my $res = retry $self->{max_retry}, $self->{delay}, sub {
        $self->{child}->get($key);
    };
    return $res if $res;

    retry $self->{max_retry}, $self->{delay}, sub {
        $self->{parent}->get($key);
    };
}

1;
__END__

=head1 NAME

Cache::Memcached::Transparent -

=head1 SYNOPSIS

  use Cache::Memcached::Transparent;

=head1 DESCRIPTION

Cache::Memcached::Transparent is

=head1 AUTHOR

Atsushi Kobayashi E<lt>nekokak _at_ gmail _dot_ comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
