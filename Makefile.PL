use inc::Module::Install;
name 'Cache-Memcached-Transparent';
all_from 'lib/Cache/Memcached/Transparent.pm';

#requires '';

test_requires 'Test::More' => '0.94';

tests 't/*.t t/*/*.t';
author_tests('xt');

auto_set_repository;

WriteAll;
