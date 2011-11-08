use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Catalyst::Test 'LeakTest';

{
    my $expected = qq{Circular reference detected};
    my $request  = HTTP::Request->new( GET => 'http://localhost:3000/?nosubinclude=1' );
    ok( my $response = request($request), 'Request' );
    is( $response->code, 200, 'Response Code' );
    isnt( $response->content, $expected, 'No circular ref detected' );
}

# Here is to test leak
{
    my $expected = qq{Circular reference detected};
    my $request  = HTTP::Request->new( GET => 'http://localhost:3000/' );
    ok( my $response = request($request), 'Request' );
    isnt( $response->code, 500, 'Response Code' );
    isnt( $response->content, $expected, 'No circular ref detected' );
}


done_testing();
