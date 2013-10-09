package Bread::Board::Service;
use v5.16;
use warnings;
use mop;

role WithClass with Bread::Board::Service {
    has $!class_name is ro;

    method class ($c) {
        $!class_name = $c if $c;
        $!class_name;
    }

    method has_class { defined $!class_name }

    method get_class {
        Module::Runtime::use_package_optimistically( $!class_name )
            if $self->has_class;
    }
}

no mop;
__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<class>

=item B<get>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
