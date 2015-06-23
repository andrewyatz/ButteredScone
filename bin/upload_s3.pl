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

use strict;
use warnings;

use Term::ReadKey;
use Path::Iterator::Rule;
use Amazon::S3;
use JSON::XS qw/encode_json/;
use Types::Serialiser;
use Text::CSV;
use File::Spec;
use feature qw/say/;

my ($credentials_csv, $bucket_name, $directory) = @ARGV;
$directory //= '.';

# Open a CSV of credentials. 2nd and 3rd cols are the things we need!
my $csv = Text::CSV->new;
open my $fh, '<', $credentials_csv or die "Could not open $credentials_csv: $!";
my $row = $csv->getline($fh);
$row = $csv->getline($fh);
close $fh;
my ($user, $aws_access_key_id, $aws_secret_access_key) = @{$row};

# Setup the bucket
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0; # turn this off because for some reason it barfs
my $s3 = Amazon::S3->new({
  aws_access_key_id => $aws_access_key_id, 
  aws_secret_access_key => $aws_secret_access_key, 
  secure => 1, 
  retry => 0,
  timeout => 5,
});
my $bucket = $s3->bucket($bucket_name); 
# use Data::Dumper; warn Dumper ($s3->buckets()); die;

# Find files and upload
my $rule = Path::Iterator::Rule->new;
$rule->name(q{*.csv.ext});
my $it = $rule->iter($directory);
my @entries;
while ( my $file = $it->() ) {
  my ($volume,$directories,$name) = File::Spec->splitpath($file);
  say "Uploading $name to S3 bucket $bucket_name\n";
  $bucket->add_key_filename($name, $file, {
    'content_type' => 'text/plain',
    'x-amz-storage-class' => 'REDUCED_REDUNDANCY'
  });
  push(@entries, { url => "s3://${bucket_name}/$name", mandatory => $Types::Serialiser::true});
}

# Send the manifest
say "Uploading manifest file";
my $manifest = { entries => \@entries };
my $json = encode_json($manifest)."\n";
$bucket->add_key('manifest.json', $json, {
  'content_type' => 'application/json',
  'x-amz-storage-class' => 'REDUCED_REDUNDANCY'
});

say "Done";