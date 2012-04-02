#############################################################################
#
# Provide XML-RPC methods.
#
# Author:  Chris Weyl (cpan:RSRCHBOY), <cweyl@alumni.drew.edu>
# Company: No company, personal work
# Created: 01/11/2009 12:00:39 PM PST
#
# Copyright (c) 2009 Chris Weyl <cweyl@alumni.drew.edu>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
#############################################################################

package MooseX::Role::XMLRPC::Client;

use MooseX::Role::Parameterized;

use MooseX::AttributeShortcuts;
use MooseX::Types::Moose       qw{ Str Bool };
use MooseX::Types::URI         ':all';
use MooseX::Types::Path::Class ':all';

use HTTP::Cookies;
use RPC::XML::Client;

use namespace::clean -except => 'meta';

our $VERSION = '0.05';

parameter name => (is => 'ro', isa => Str, default => 'xmlrpc' );
parameter uri  => (is => 'ro', isa => Uri, coerce => 1, predicate => 'has_uri');

parameter login_info
    => (is => 'ro', isa => Bool, predicate => 'has_login_info', default => 1);

parameter cookie_jar
    => (is => 'ro', isa => File, predicate => 'has_cookie_jar', coerce => 1);

# traits, if any, for our attributes
parameter traits => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
    handles => { all_traits => 'elements' },
);

role {
    my $p = shift @_;

    my $name = $p->name;

    my $traits = [ Shortcuts, $p->all_traits ];
    my @defaults = (traits => $traits, is => 'rw', lazy_build => 1);

    # generate our attribute & builder names... nicely sequential tho :)
    my $a = sub {             $name . '_' . shift @_ };
    my $b = sub { '_build_' . $name . '_' . shift @_ };

    if ($p->login_info) {

        has $a->('userid') => (@defaults, isa => Str);
        has $a->('passwd') => (@defaults, isa => Str);

        requires $b->('userid');
        requires $b->('passwd');

        requires $name . '_login';
        requires $name . '_logout';
    }

    has $a->('uri') => (@defaults, isa => Uri, coerce => 1);

    # if we have a uri, use it; otherwise require its builder
    if ($p->has_uri) { method $b->('uri') => sub { $p->uri } }
    else             { requires $b->('uri')                  }

    has $a->('cookie_jar') => (
        traits    => $traits,
        is        => 'ro',
        isa       => File,
        coerce    => 1,
        predicate => 1,
        ( $p->has_cookie_jar ? (default => $p->cookie_jar) : () ),
    );

    has $a->('rpc') => (@defaults, isa => 'RPC::XML::Client');

    my $uri_method = $a->('uri');

    # create our RPC::XML::Client appropriately
    method $b->('rpc') => sub {
        my $self = shift @_;

        # twice to keep warnings from complaining...
        local $RPC::XML::ENCODING;
        $RPC::XML::ENCODING = 'UTF-8';

        my $rpc = RPC::XML::Client->new($self->$uri_method);

        # error bits - FIXME - we could probably do this better...
        $rpc->error_handler(sub { confess shift         });
        $rpc->fault_handler(sub { confess shift->string });

        $rpc->useragent->cookie_jar({});

        return $rpc;
    }
};

1;

__END__

=head1 NAME

MooseX::Role::XMLRPC::Client - provide the needed bits to be a XML-RPC client

=head1 SYNOPSIS

    package MultipleWiths;
    use Moose;

    # ...

    # we don't want to keep any login information here
    with 'MooseX::Role::XMLRPC::Client' => {
        name => 'bugzilla',
        uri  => 'https://bugzilla.redhat.com/xmlrpc.cgi',
        login_info => 0,
    };

    # basic info
    with 'MooseX::Role::XMLRPC::Client' => {
        name => 'foo',
        uri  => 'http://foo.org/a/b/c',
    };

    sub _build_foo_userid { 'userid'   }
    sub _build_foo_passwd { 'passw0rd' }

    sub foo_login  { 'do login magic here..'   }
    sub foo_logout { 'do logout magic here...' }

=head1 DESCRIPTION

This is a L<Moose> role that provides methods and attributes needed to enable
a class to serve as an XML-RPC client. It is parameterized through
L<MooseX::Role::Parameterized>, so you can customize how it embeds in your
class.  You can even embed it multiple times with different paramaterization,
if it strikes your fancy :-)

=head1 ROLE PARAMETERS

This role generates methods and attributes depending on these parameters.
None of them are required.

=head2 name

This parameter defaults to "xlmrpc".  It serves as a prefix to all generated
methods and attributes.  File and URI types are coerced.

=head2 uri (URI)

=head2 login_info (Bool)

=head2 cookie_jar (File)

=head2 traits (ArrayRef[Str])

An arrayref of traits to apply to the attributes.

=head1 METHODS/ATTRIBUTES

Right now, the best documentation can be found in the tests.

=head1 SEE ALSO

L<RPC::XML::Client>, L<Moose::Role>, L<MooseX::Role::Parameterized>.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Chris Weyl <cweyl@alumni.drew.edu>, or (preferred)
to this package's RT tracker at <bug-MooseX-Role-XMLRPC-Client@rt.cpan.org>.

Patches are welcome.

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

