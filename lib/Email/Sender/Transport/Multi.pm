# ABSTRACT: Allows for multiple transports objects to be used
use strict;
use warnings;
package Email::Sender::Transport::Multi;
use Moo;
use Class::Load;
use MooX::HandlesVia;
use Types::Standard -all;
use Try::Tiny;

with ('Email::Sender::Transport');

has transports => (
    is => 'ro',
    isa => ArrayRef[ConsumerOf['Email::Sender::Transport']],
    default => sub{[]},
    handles_via => 'Array',
    handles => {
        add_transport  => 'push',
        num_transports => 'count',
    }
);

has hard_fail => (
    is => 'ro',
    isa => Bool,
    default => sub{ 0 }
);


sub send_email {
    my ($self,$email,$env) = @_;

    Email::Sender::Failure->throw('No transports have been configured.')
        if 0 == $self->num_transports;

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


sub new_from_config {
    my $class = shift;
    my $config = shift;
    die "You must specify a config."
        unless ($config);

    die "You must specify an array of transports."
        unless exists $config->{transports} &&
            'ARRAY' eq ref($config->{transports});

    my $object = {};

    foreach my $tansport_class ( @{$config->{transports}} ) {
        my $transport_classname = $tansport_class->{class};
        die 'There was an empty transport class name in your config' unless $transport_classname;

        Class::Load::load_class($transport_classname);
        my $transport_config = delete $tansport_class->{cofig};
        $transport_config //= {};
        push @{$object->{transports}},
            $tansport_class->{class}->new( %{$transport_config} )
    }
    return $class->new( $object );
}

1;
