use strict;
use warnings;

use AnyEvent;
use Amazon::SQS::Simple;
use Amazon::SQS::Simple::AnyEvent;
use Data::Dumper;

#--------------------------------------------------------------------
# This example shows how to receive 10 message batches in parallel.
# When each batch is received, the messages will be dumped to STDOUT
# and then deleted asynchronously.
#--------------------------------------------------------------------

my $sqs   = Amazon::SQS::Simple->new("ACCESS_KEY", "SECRET_KEY");
my $queue = $sqs->GetQueue("QUEUE_NAME");

#--------------------------------------------------------------------

my $cv = AnyEvent->condvar;

for (1..10) {
    
    $cv->begin;

    my $cb = sub {
        my @messages = @_; # Each will be an Amazon::SQS::Simple::Message
        print Dumper \@messages;
        $queue->DeleteMessageBatch(\@messages, sub {});
        $cv->end;
    };

    $queue->ReceiveMessageBatch($cb);
}

# Blocks until all batches are processed
$cv->recv;
