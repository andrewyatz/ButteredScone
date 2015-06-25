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

# This code will take a CSV with the columns "user_agent_dimension_id","user_agent","language","browser","bot"
# and will attempt to figure out what browser a user agent describes or if it is a bot. To add
# new user agents just give it an ID and the useragent string. "language" is optional but setting
# either the browser or bot field will cause the script to skip that line.
#
# Results are written to the same file
#
# Usage: ./bin/parse_apache_log.pl input.gz output.csv

use strict;
use warnings;

BEGIN {
  use Cwd;
  use File::Basename;
  use File::Spec;
  my $dirname = dirname(Cwd::realpath(__FILE__));
  my $lib = File::Spec->catdir($dirname, File::Spec->updir(), 'lib');
  if(-d $lib) {
    unshift(@INC, $lib);
  }
  else {
    die "Cannot find the lib directory in the expected location $lib";
  }
};

use Parser::CSV;
use Writer::ExtendedCSV;

my ($input, $output) = @ARGV;

my $writer = Writer::ExtendedCSV->new(file => $output);
my $parser = Parser::CSV->new(file => $input);
my $processor = Processor::Basic->new(parser => $parser, $writer => $writer);
$processor->process();
$writer->issue_close();
$parser->issue_close();
print "Done!\n";
exit(0);