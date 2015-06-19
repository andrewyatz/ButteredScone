use strict;
use warnings;
use Test::More;
use IO::Scalar;

my $input = q{127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"}x20;
my $output = q{};

use Parser::Apache;
use Writer::Pool;

open my $in_fh, '<', \$input;

my $writer = Writer::Pool->new(flush_rate => 1);
{
my $apache = Parser::Apache->new(handle => $in_fh, writer => $writer);
$apache->process();
}
diag explain $writer->log_stack;

done_testing();