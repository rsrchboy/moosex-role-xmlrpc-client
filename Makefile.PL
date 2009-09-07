use inc::Module::Install;

name     'MooseX-Role-XMLRPC-Client';
all_from 'lib/MooseX/Role/XMLRPC/Client.pm';
author   'Chris Weyl <cweyl@alumni.drew.edu>';
license  'perl';

requires 'namespace::clean';

#requires 'Moose::Role';
requires 'MooseX::Role::Parameterized' => 0.02;
requires 'MooseX::Types';
requires 'MooseX::Types::URI';
requires 'MooseX::Types::Path::Class';

requires 'HTTP::Cookies';
requires 'RPC::XML::Client';

test_requires 'Test::More';

extra_tests;

auto_install;

WriteAll;

