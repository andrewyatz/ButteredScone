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

# Drivers are ways of producing the schema ButteredScone will write to. They work
# with SQL::Translator to create the schema and DBIx::Simple and custom code
# to do the batch loading commands. Everything goes via DBI so there's no
# reason to do anything bar install the DBI driver for the DB you care about.

package Driver;

use Moose;
use namespace::autoclean;
use DBIx::Simple;
use DBI;
use SQL::Translator;

has 'dsn'   => ( isa => 'Str', is => 'ro', required => 1 );
has 'user'  => ( isa => 'Str', is => 'ro' );
has 'pass'  => ( isa => 'Str', is => 'ro' );
has 'args'  => ( isa => 'HashRef', is => 'ro', default => sub {{ RaiseError => 1 }});
has 'dbh'   => ( isa => 'DBIx::Simple', is => 'ro', lazy => 1, default => sub {
  my ($self) = @_;
  my ($dsn, $user, $pass) = ($self->dsn, $self->user, $self->pass); 
  my $dbh = DBIx::Simple->connect($dsn, $user, $pass, $self->args);
  confess "Cannot connect to '${dsn}' with user '${user}'. Error: $DBI::errstr" if ! $dbh;
  return $dbh;
});

has 'schema_type' => ( isa => 'Str', is => 'ro', default => '');
has 'schema_translator' => ( isa => 'SQL::Translator', is => 'ro', lazy => 1, builder => 'build_schema_translator');

sub build_schema_translator {
  my ($self) = @_;
  return SQL::Translator->new(quote_identifiers => 1, no_comments => 1, from => 'XML', to => $self->schema_type());
}

# Takes a filename (as a scalar) or data to parse (as a scalar ref) and returns a ref of DDL statements
sub generate_schema {
  my ($self, $filename) = @_;
  my $t = $self->schema_translator();
  my @schema = $t->translate($filename);
  return \@schema;
}

# Calls generate_schema and then loads the data
sub load_schema {
  my ($self, $filename) = @_;
  my $dbh = $self->dbh();
  my $ddl_commands = $self->generate_schema($filename);
  foreach my $ddl (@{$ddl_commands}) {
    $dbh->dbh->do($ddl);
  }
  return;
}

sub fetch_dimension {
  my ($self, $table) = @_;
  my $sql = "select * from ${table}";
  my $result = $self->dbh->query($sql);
  my @objects;
  while(my $row = $result->hash()) {
    my %data = %{$row};
    $data{id} = $data{"${table}_id"};
    delete $data{"${table}_id"};
    push(@objects, \%data);
  }
  return \@objects;
}

# Give it a table and an array ref of hashes like [{col => 'data'}] ready to insert
sub insert_dimension {
  my ($self, $table, $data, $insert_ignore) = @_;
  my ($sql, $bind_params) = $self->_generate_insert($table, $data, $insert_ignore);
  my $res = $self->dbh->query($sql, @{$bind_params});
  if($res->rows() > 0) {
    return $self->dbh->last_insert_id(undef, undef, $§);
  }
  return -1;
}

sub _generate_insert {
  my ($self, $table, $data, $insert_ignore) = @_;
  $insert_ignore //= 0;
  my @keys = keys %{$data};
  my $length = scalar(@keys);
  my $cols = join(',', map {"`$_`"} @keys);
  my $placeholders = join(',', ('?')x$length);
  my $insert = 'INSERT ';
  $insert .= 'IGNORE ' if $insert_ignore;
  $insert .= "INTO ${table} (${cols}) VALUES (${placeholders})";
  my $bind_params = [ map { $data->{$_} } @keys ];
  return ($insert, $bind_params);
}

__PACKAGE__->meta->make_immutable;

1;