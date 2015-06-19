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

package Writer::CSV;

use Moose;
use Text::CSV;
use POSIX qw/strftime/;

extends 'Writer';

has 'csv' => ( isa => 'Text::CSV', is => 'ro', default => sub {
  my $csv = Text::CSV->new ( { binary => 1, eol => $/ } ) or die "Cannot use CSV: ".Text::CSV->error_diag();
  return $csv;
});

sub write_entries {
  my ($self) = @_;
  my $log_stack = $self->log_stack();
  my $fh = $self->handle();
  my $csv = $self->csv();
  foreach my $log (@{$log_stack}) {
    $csv->print($fh, $self->to_cols($log));
  }
  return;
}

sub to_cols {
  my ($self, $log) = @_;
  return [
    $log->ip(),
    $log->string_timestamp(),
    $log->bytes(),
    $log->code(),
    $log->user_agent(),
    $log->url(),
    $log->method(),
  ];
}

__PACKAGE__->meta->make_immutable;

1;