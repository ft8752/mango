#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test;

    eval 'require DBD::SQLite';
    if($@) {
        plan skip_all => 'DBD::SQLite not installed';
    } else {
        plan tests => 2;
    };

    use_ok('Mango::Provider::Carts');
};

my $schema = Mango::Test->init_schema;
my $provider = Mango::Provider::Carts->new({
    connection_info => [$schema->dsn]
});
isa_ok($provider, 'Mango::Provider::Carts');