=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package Model::Log;
use Moose;
use namespace::autoclean;
use POSIX qw/strftime/;

use Model::Event;
use Model::Status;
use Model::Agent;

has 'ip'                => ( isa => 'Str', is => 'ro', required => 1);
has 'timestamp'         => ( isa => 'Int', is => 'ro', required => 1); # expected to be an epoch in seconds
has 'bytes'             => ( isa => 'Int', is => 'ro', required => 1);
has 'code'              => ( isa => 'Int', is => 'ro', required => 1);
has 'user_agent'        => ( isa => 'Str', is => 'ro', required => 1);
has 'url'               => ( isa => 'Str', is => 'ro', required => 1);
has 'method'            => ( isa => 'Str', is => 'ro', required => 1);
has 'string_timestamp'  => ( isa => 'Str', is => 'ro', lazy => 1, default => sub {
  my ($self) = @_;
  return strftime("%Y-%m-%dT%H:%M:%S",localtime($self->timestamp()));
});

# Start of the dimensions
has 'event' => ( isa => 'Model::Event', is => 'ro', lazy => 1, default => sub {
  my ($self) = @_;
  return Model::Event->new(log => $self);
});

has 'status' => ( isa => 'Model::Status', is => 'ro', lazy => 1, default => sub {
  my ($self) = @_;
  return Model::Status->new(log => $self);
});

has 'agent' => ( isa => 'Model::Agent', is => 'ro', lazy => 1, default => sub {
  my ($self) = @_;
  return Model::Agent->new(log => $self);
});

__PACKAGE__->meta->make_immutable;

1;