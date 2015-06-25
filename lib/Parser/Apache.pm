package Parser::Apache;
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

use Moose;
use namespace::autoclean;
extends 'Parser';

use Apache::Log::Parser;
use Model::Log;
use Date::Parse qw/str2time/;
use Scalar::Util qw/looks_like_number/;
use Carp;

has 'parser' => ( isa => 'Apache::Log::Parser', is => 'ro', default => sub {
  my ($self) = @_;
  return Apache::Log::Parser->new(fast => 1);
});

sub process {
  my ($self, $callback) = @_;
  confess('No callback given') unless $callback;
  my $fh = $self->handle();
  my $p = $self->parser();
  while(my $line = <$fh>) {
    my $r = $p->parse($line);
    next unless defined $r;
    $r->{timestamp} = str2time($r->{datetime});
    $r->{status} = 0 if ! looks_like_number($r->{status});
    my $log = Model::Log->new(
      ip => $r->{rhost}, 
      timestamp => $r->{timestamp},
      bytes => $r->{bytes}, 
      code => $r->{status}, 
      user_agent => $r->{agent}, 
      url => $r->{path}, 
      method => $r->{method}
    );
    $callback->($log);
  }
  return;
}

__PACKAGE__->meta->make_immutable;

1;