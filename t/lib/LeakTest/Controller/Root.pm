package LeakTest::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

LeakTest::Controller::Root - Root Controller for LeakTest

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
   my ( $self, $c ) = @_;
   if ( $c->req->params->{nosubinclude} ) {
      $c->stash( current_view => 'BareTT' );
   } else {
      $c->stash( current_view => 'TT' );
   }
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub render : ActionClass('RenderView') { }

sub end : Private {
  my ( $self, $c ) = @_;
  $c->forward('render');

  use Scalar::Util 'weaken';
  use Devel::Cycle 'find_cycle';
  my @leaks;
  my $weak_ctx = $c;
  weaken $weak_ctx;

  find_cycle( $c, sub {
      my ($path) = @_;
      push @leaks, $path
          if $path->[0]->[2] == $weak_ctx;
  } );
  return unless @leaks;
  my $msg = "Circular reference detected";
  $c->res->status(500);
  $c->res->body($msg);
}

=head1 AUTHOR

zdk

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
