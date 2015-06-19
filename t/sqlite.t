use strict;
use warnings;
use Test::More;

use Driver::SQLite;
use Driver::MySQL;
use Data::Dumper;
use Model::Agent;

our $DATA_DIR;
BEGIN {
  use Cwd;
  use File::Basename;
  use File::Spec;
  my $dirname = dirname(Cwd::realpath(__FILE__));
  $DATA_DIR = File::Spec->catdir($dirname, File::Spec->updir(), 'data');
};

my $driver = Driver::SQLite->new(dsn => 'dbi:SQLite:dbname=:memory:');
$driver->load_schema("$DATA_DIR/schema.1.xml");
# my $driver = Driver::MySQL->new(dsn => 'dbi:MySQL:database=tmp');
# my $ddl = $driver->generate_schema("$DATA_DIR/schema.1.xml");
# print $_.";\n" for @{$ddl};

warn 'before insert 1';
warn Dumper($driver->fetch_dimension('user_agent_dimension'));
warn 'before insert 2';
$driver->dbh->dbh->do('insert into user_agent_dimension (user_agent, browser, bot, language) values ("ua", "chrome", 0, "web")');
warn 'after insert 3';
warn Dumper($driver->fetch_dimension('user_agent_dimension'));
warn 'after insert 4';

done_testing();