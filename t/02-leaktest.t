#!perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More;
use Text::Diff;
use Catalyst::Test 'LeakTest';

my $root = $FindBin::Bin;

my ( $stderr, $old_stderr );

BEGIN {
    no warnings 'redefine';

    *Catalyst::Test::local_request = sub {
        my ( $c, $request ) = @_;

        require HTTP::Request::AsCGI;
        my $cgi = HTTP::Request::AsCGI->new( $request, %ENV )->setup;

        $c->handle_request;
        return $cgi->restore->response;
    };
}

open(SAVEERR, ">&STDERR");
close STDERR or print "cannot close STDERR\n";
open(STDERR, ">", \$stderr) or print "Cannot open: $!\n";

run_tests();

close STDERR;
open(STDERR, ">&SAVEERR");

sub reset_stderr {
    close STDERR or print "cannot close STDERR\n";
    print "Current stderr: " . $stderr . "\n";
    $stderr = '';
    open(STDERR, ">", \$stderr) or print "Cannot open: $!\n";
}

sub run_tests {

    # test first available view
    is($stderr, undef, 'empty stderr at start');
    reset_stderr();
    {
        my $expected = 'THEINDEX';
        my $request  =
          HTTP::Request->new( GET => 'http://localhost:3000/' );

        ok( my $response = request($request), 'Request' );
        ok( $response->is_success, 'Response Successful 2xx' );
        is( $response->header( 'Content-Type' ), 'text/html; charset=utf-8', 'Content Type' );
        is( $response->code, 200, 'Response Code' );

        like($response->content, qr/$expected/, 'Content OK' );
        isnt( $stderr, '', "No stderr output");
    }

    reset_stderr();
}

done_testing();
