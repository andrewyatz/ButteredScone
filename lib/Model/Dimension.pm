package Model::Dimension;

use Moose::Role;

has 'log'   => ( isa => 'Model::Log', is => 'ro');
has 'data'  => ( isa => 'HashRef', is => 'ro', lazy => 1, default => sub {{}});
has 'key'   => ( isa => 'Str', is => 'ro', lazy => 1, default => sub {
  my ($self) = @_;
  return $self->generate_key($self->data());
});

requires 'generate_key';

1;