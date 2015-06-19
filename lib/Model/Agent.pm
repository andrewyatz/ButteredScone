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

package Model::Agent;
use Moose;
use namespace::autoclean;

with 'Model::Dimension';
has '+data' => (default => sub {
  my ($self) = @_;
  #manually filled in afterwards so we don't represent all keys
  return { user_agent => $self->log()->user_agent(), bot => 0 };
});

sub generate_key {
  my ($self, $data) = @_;
  return $data->{user_agent};
}

__PACKAGE__->meta->make_immutable;

1;