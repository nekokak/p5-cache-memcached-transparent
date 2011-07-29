use t::Utils;
use Test::More;
use Cache::Memcached::Transparent;
use Cache::Memcached;

my $m1_port = setup_memcached();
my $m2_port = setup_memcached();
my $cache1 = Cache::Memcached->new(
    +{
        servers   => ['127.0.0.1:'.$m1_port],
        namespace => 'zigorou:'
    }
);
my $cache2 = Cache::Memcached->new(
    +{
        servers   => ['127.0.0.1:'.$m2_port],
        namespace => 'zigorou:'
    }
);

my $cache = Cache::Memcached::Transparent->new(
    parent    => $cache1,
    child     => $cache2,
    max_retry => 1,
);

subtest 'can get child' => sub {
    $cache1->delete('ueda');
    ok $cache2->set('ueda' => 'satoshi');
    is $cache->get('ueda'), 'satoshi';
};

subtest 'can get parent' => sub {
    ok $cache1->set('satoshi' => 'ueda');
    $cache2->delete('satoshi');
    is $cache->get('ueda'), 'satoshi';
};

teardown_memcached();

done_testing;
