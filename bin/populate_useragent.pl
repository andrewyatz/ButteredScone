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
# Usage: ./bin/populate_useragent.pl ./data/user_agent_dimension.csv

use strict;
use warnings;
use Tie::File;
use Text::CSV;
use Regexp::Assemble;
use HTTP::UA::Parser;

tie my @array, 'Tie::File', $ARGV[0] or die "Cannot tie file from ARGS";

my $csv = Text::CSV->new ( { binary => 1 } ) or die "Cannot use CSV: ".Text::CSV->error_diag ();
my $len = scalar(@array);
my $bot_regex = make_bot_regex();
my $r = HTTP::UA::Parser->new();
for(my $i = 1; $i < $len; $i++) {
  my $line = $array[$i];
  $csv->parse($line);
  my @columns = $csv->fields();
  my ($id, $user_agent, $language, $browser, $bot) = @columns;
  # Skip if we've already assigned it to something
  next if $browser || $bot;
  next if $language ne 'webbrowser' && $language ne 'unknown';
  
  #Now process. If it hits BOT then deal as such
  if($user_agent =~ $bot_regex) {
    $bot = 1;
  }
  # Otherwise detect the web broswer
  else {
    $r->parse($user_agent);
    $browser = $r->ua->family();
  }
  $csv->combine($id, $user_agent, $language, $browser, $bot);
  $array[$i] = $csv->string();
}

sub make_bot_regex {
  my $ra = Regexp::Assemble->new;
  while (<DATA>) {
    chomp;
    $ra->add( '\b' . quotemeta( $_ ) . '\b' );
  }
  return $ra->re;
}

__DATA__
Baiduspider
Googlebot
YandexBot
AdsBot-Google
AdsBot-Google-Mobile
bingbot
facebookexternalhit
libwww-perl
aiHitBot
Baiduspider+
aiHitBot
aiHitBot-BP
NetcraftSurveyAgent
Google-Site-Verification
W3C_Validator
ia_archiver
Nessus
UnwindFetchor
Butterfly
Netcraft Web Server Survey
Twitterbot
PaperLiBot
Add Catalog
1PasswordThumbs
MJ12bot
SmartLinksAddon
YahooCacheSystem
TweetmemeBot
CJNetworkQuality
YandexImages
StatusNet
Untiny
Feedfetcher-Google
DCPbot
AppEngine-Google