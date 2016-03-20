package FailTransport;
use Moo;
use Email::Sender::Failure;
with 'Email::Sender::Transport';
use Email::Sender::Failure;

sub send_email {
    Email::Sender::Failure->throw('send_email fail Email::Sender::Failure');
    return;
}

no Moo;
1;
