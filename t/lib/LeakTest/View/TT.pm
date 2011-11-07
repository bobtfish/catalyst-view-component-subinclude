package LeakTest::View::TT;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';
with 'Catalyst::View::Component::SubInclude';

__PACKAGE__->config(
    INCLUDE_PATH => [
       LeakTest->path_to( 'root' ),
    ],
    TEMPLATE_EXTENSION => '.tt',
    WRAPPER => 'wrapper.tt',
    ENCODING => 'utf-8',
);

=head1 NAME

LeakTest::View::TT - Catalyst View

=head1 DESCRIPTION

Catalyst View.

=head1 AUTHOR

zdk

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
