package Bread::Board::Container::FromParameterized;
BEGIN {
  $Bread::Board::Container::FromParameterized::AUTHORITY = 'cpan:STEVAN';
}
$Bread::Board::Container::FromParameterized::VERSION = '0.32';
use Moose;

extends 'Bread::Board::Container';

has '+parent' => (
    weak_ref => 0,
);

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Container::FromParameterized

=head1 VERSION

version 0.32

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
