#!/usr/bin/perl

use Test::More tests => 1;

BEGIN {
	use_ok( 'MooseX::Role::XMLRPC::Client' );
}

diag( "Testing MooseX::Role::XMLRPC::Client $MooseX::Role::XMLRPC::Client::VERSION, Perl $], $^X" );
