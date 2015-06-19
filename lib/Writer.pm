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

package Writer;

use Moose;
use namespace::autoclean;
with 'File';

has 'log_stack' => ( isa => 'ArrayRef', is => 'ro', default => sub { [] });
has 'flush_rate'  => ( isa => 'Int', is => 'ro', default => 50000 );
has '+mode' => ( default => '>' ); # open file handles for writing to

sub log {
  my ($self, $log) = @_;
  my $stack = $self->log_stack();
  push(@{$stack}, $log);
  if(scalar(@{$stack}) >= $self->flush_rate()) {
    $self->flush();
  }
  return;
}

sub flush {
  my ($self) = @_;
  $self->write_entries();
  @{$self->log_stack()} = ();
  return;
}

sub write_entries {
  ...
}

before 'issue_close' => sub {
  my ($self) = @_;
  $self->write_entries(); # send the last ones out
  return;
};

__PACKAGE__->meta->make_immutable;

1;