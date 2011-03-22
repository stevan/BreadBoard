use strict;
use warnings;
use inc::Module::Install 0.91;
use Module::Install::AuthorTests;

name 'Bread-Board';
all_from 'lib/Bread/Board.pm';
auto_set_repository;
license 'perl';

# prereqs
requires 'Moose'                    => '1.00';
requires 'Class::MOP'               => '1.00';
requires 'MooseX::Clone'            => '0.05';
requires 'MooseX::Params::Validate' => '0.14';

# things the tests need
build_requires 'Test::More'      => '0.62';
build_requires 'Test::Exception' => '0.21';

tests('t/*.t');
author_tests('t/author/*.t');

WriteAll();

