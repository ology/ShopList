use strict;
use warnings;

use ShopList;
use Test::More tests => 3;
use Plack::Test;
use HTTP::Request::Common;
use Ref::Util qw<is_coderef>;

my $app = ShopList->to_app;
ok( is_coderef($app), 'Got app' );

my $test = Plack::Test->create($app);
my $res  = $test->request( GET '/' );

ok( $res->is_redirect, '[GET /] successful' );

like( $res->header('location'), qr/login/, 'location login' );
