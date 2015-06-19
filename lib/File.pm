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

package File;

use Moose::Role;
use Scalar::Util qw/openhandle/;
use PerlIO::gzip;

has 'file' => ( isa => 'Str', is => 'ro' );
has 'mode' => ( isa => 'Str', is => 'ro', default => '<' ); # by default we open for reading

# Build a handle if one doesn't exist
has 'handle' => ( isa => 'FileHandle', is => 'ro', lazy => 1, default => sub {
  my ($self) = @_;
  my $handle;
  my $file = $self->file();
  confess 'No file given but expected one since I was not constructed with a handle' unless $file;
  my $mode = $self->mode();
  if($file =~ /\.gz$/) {
    open $handle, $mode.':gzip', $file or confess "Cannot open '${file}' with gzip: $!";
  }
  else {
    open $handle, $mode, $file or confess "Cannot open '${file}': $!";
  }
  return $handle;
});

has 'can_close_handle' => ( isa => 'Bool', is => 'ro', default => 1 );

sub close_handle {
  my ($self) = @_;
  if($self->can_close_handle() && defined $self->{handle} && openhandle($self->{handle})) {
    $self->issue_close();
  }
}

sub issue_close {
  my ($self) = @_;
  close $self->{handle};
  return;
}

# close the file handle if we're allowed to, if it's there and if it was open
sub DEMOLISH {
  my ($self) = @_;
  $self->close_handle();
}

1;