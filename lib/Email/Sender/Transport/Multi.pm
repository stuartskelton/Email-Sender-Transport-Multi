# ABSTRACT: Allows for multiple transports objects to be used
use strict;
use warnings;
package Email::Sender::Transport::Multi;
use Moo;
use MooX::HandlesVia;
use Types::Standard -all;
use Try::Tiny;

with ('Email::Sender::Transport');

has transports => (
    is => 'ro',
    isa => ArrayRef[Int],
    default => sub{[]},
    handles_via => 'Array',
    handles => {
        add_transport => 'push'
    }
);

has hard_fail => (
    is => 'ro',
    isa => Bool,
    default => sub{ 0 }
);


sub send_email {
    my ($self,$email,$env) = @_;
    my @errors;
    # loop though the transports
    foreach my $transport(@{$self->transports}) {
        try {
            $transport->send_email($email);
        } catch {
            push @errors, $_;
            last if $self->hard_fail;
        };
    }
    Email::Sender::Failure->throw(join("\n",@errors)) if @errors;
    return $self->success;
}


1;
