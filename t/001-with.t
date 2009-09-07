#!/usr/bin/perl
#############################################################################
#
# Author:  Chris Weyl (cpan:RSRCHBOY), <cweyl@alumni.drew.edu>
# Company: No company, personal work
# Created: 01/11/2009 01:07:44 PM PST
#
# Copyright (c) 2009 Chris Weyl <cweyl@alumni.drew.edu>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
#############################################################################

=head1 NAME

001-with.t - test the role 

=head1 DESCRIPTION 

This test exercises...

=head1 TESTS

This module defines the following tests.

=cut

use Test::More tests => 15;

=head2 Named role without login info

Check to make sure the methods are constructed in the expected fashion

=cut 

do {
    package NamedNoLoginInfo;

    use Moose;

    with 'MooseX::Role::XMLRPC::Client' => { 
        name => 'bugzilla',
        uri  => 'https://bugzilla.redhat.com/xmlrpc.cgi',
        login_info => 0,
    }
};

my $a = NamedNoLoginInfo->new;

ok  $a->can('bugzilla_uri'),        'can uri';
ok !$a->can('bugzilla_userid'),     'cannot userid';
ok  $a->can('_build_bugzilla_rpc'), 'can build rpc';
ok  $a->can('_build_bugzilla_uri'), 'can build uri';

isa_ok $a->bugzilla_rpc => 'RPC::XML::Client';

isa_ok $a->bugzilla_uri => 'URI'; 
is     $a->bugzilla_uri => 'https://bugzilla.redhat.com/xmlrpc.cgi', 'uri ok';

=head2 Named role, no login info, basic BZ live test

=cut

SKIP: {
    skip 'No network tests allowed', 1 if $ENV{NO_NET_TESTS};

    my $ver = $a->bugzilla_rpc->simple_request('Bugzilla.version')->{version};
    ok $ver, 'queried RH bugzilla version successfully';
}

=head2 Named role with login info

=cut

do {
    package Named;

    use Moose;

    with 'MooseX::Role::XMLRPC::Client' => {
        name => 'foo',
        uri  => 'http://foo.org/a/b/c',
    };

    sub _build_foo_userid { __LINE__ }
    sub _build_foo_passwd { __LINE__ }
    
    sub foo_login  { __LINE__ }
    sub foo_logout { __LINE__ }
};

my $b = Named->new;

ok  $b->can('foo_uri'),        'can uri';
ok  $b->can('foo_userid'),     'cannot userid';
ok  $b->can('_build_foo_rpc'), 'can build rpc';
ok  $b->can('_build_foo_uri'), 'can build uri';

isa_ok $b->foo_rpc => 'RPC::XML::Client';

isa_ok $b->foo_uri => 'URI'; 
is     $b->foo_uri => 'http://foo.org/a/b/c', 'uri ok';

__END__

=head1 CONFIGURATION AND ENVIRONMENT

This test does not require network connectivity; it tests to make sure the
role behaves as expected when included in a class.

=head1 SEE ALSO

L<MooseX::Role::XMLRPC::Client>, L<RPC::XML::Client>

=head1 AUTHOR

Chris Weyl  <cweyl@alumni.drew.edu>


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 Chris Weyl <cweyl@alumni.drew.edu>

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the 

    Free Software Foundation, Inc.
    59 Temple Place, Suite 330
    Boston, MA  02111-1307  USA

=cut



