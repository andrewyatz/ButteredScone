package Parser::Apache;

use Moose;
use namespace::autoclean;
extends 'Parser';

use Apache::Log::Parser;
use Model::Log;
use Date::Parse qw/str2time/;

has 'parser' => ( isa => 'Apache::Log::Parser', is => 'ro', default => sub {
  my ($self) = @_;
  return Apache::Log::Parser->new(fast => 1);
});

sub process {
  my ($self) = @_;
  my $fh = $self->handle();
  my $p = $self->parser();
  my $w = $self->writer();
  while(my $line = <$fh>) {
    my $r = $p->parse($line);
    next unless defined $r;
    $r->{timestamp} = str2time($r->{datetime});
    my $log = Model::Log->new(
      ip => $r->{rhost}, 
      timestamp => $r->{timestamp},
      bytes => $r->{bytes}, 
      code => $r->{status}, 
      user_agent => $r->{agent}, 
      url => $r->{path}, 
      method => $r->{method}
    );
    $w->log($log);
  }
  return;
}

__PACKAGE__->meta->make_immutable;

1;