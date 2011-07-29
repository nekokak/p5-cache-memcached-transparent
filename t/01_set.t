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

subtest 'can set parent and child' => sub {
    ok $cache->set('ueda' => 'satoshi');
    is $cache1->get('ueda'), 'satoshi';
    is $cache2->get('ueda'), 'satoshi';
};

subtest 'can set only parent' => sub {
    teardown_memcached($m2_port);
    ok $cache->set('satoshi' => 'ueda');
    is $cache1->get('satoshi'), 'ueda';
    ok not $cache2->get('satoshi');
};

teardown_memcached();

done_testing;
