#!/usr/bin/env perl

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

package Parser::CSV;

use Moose;
use namespace::autoclean;
extends 'Parser';

use Model::Log;
use Text::CSV;
use Date::Parse qw/str2time/;

has 'parser' => ( isa => 'Text::CSV', is => 'ro', default => sub {
  my $csv = Text::CSV->new ( { binary => 1, eol => $/ } ) or die "Cannot use CSV: ".Text::CSV->error_diag();
  return $csv;
});

sub process {
  my ($self, $callback) = @_;
  confess('No callback given') unless $callback;
  my $fh = $self->handle();
  my $p = $self->parser();
  my $w = $self->writer();
  while(my $line = <$fh>) {
    my $r = $p->parse($line);
    next unless defined $r;
    my $fields = [$p->fields()];
    my $log = $self->array_to_log($fields);
    $callback->($log);
  }
  return;
}

sub array_to_log {
  my ($self, $array) = @_;
  my $log = Model::Log->new(
    ip => $array->[0],
    timestamp => str2time($array->[1]),
    bytes => $array->[2],
    code => $array->[3],
    user_agent => $array->[4],
    url => $array->[5],
    method => $array->[6],
  );
  return $log;
}

__PACKAGE__->meta->make_immutable;

1;