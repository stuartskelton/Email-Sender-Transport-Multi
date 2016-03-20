use Test::Most;

use DDP;
use Data::Fake qw/Core Names Text Dates Internet/;
use Data::Fake::Core qw/_transform/;
use Encode;
use MIME::Entity;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::Test ;

# add some test only classes
use FindBin;
use lib "$FindBin::RealBin/lib";
use FailTransport;

use_ok('Email::Sender::Transport::Multi');

# lets build some emails
my @emails;
my @emails;
for (1..4){
    push @emails, build_fake_email()
};

my $multi_transport = Email::Sender::Transport::Multi->new();

# lets add some transports
$multi_transport->add_transport(
   Email::Sender::Transport::Test->new(),
   Email::Sender::Transport::Test->new()
);

# send some emails
foreach my $email (@emails){
    is(
        ref(sendmail(
                $email, { transport => $multi_transport }
        )
    ),
    'Email::Sender::Success',
    'Successful sends should return a Email::Sender::Success');
}

# check to see if the emails send via two Email::Sender::Transport::Test are the
# same.

is_deeply(
    [$multi_transport->transports->[0]->deliveries],
    [$multi_transport->transports->[1]->deliveries],
    'Both transports have the same email'
);

#
# Add a failing transport to the multi_transport
#

$multi_transport->add_transport(
   FailTransport->new()
);

# send some emails
foreach my $email (@emails){
    dies_ok( sub {
            sendmail(
                $email, { transport => $multi_transport }
            )
        },
        'Should throw an error as FailTransport was used'
    );
}


done_testing();

sub build_fake_email {
    my ($thing) = @_;
    my $email_generator = fake_hash(
        {
            'Content-Type' => 'text/plain ;charset=UTF-8',
            Date => fake_array( 1, fake_past_datetime("%a, %e %b %Y %H:%M:%S %z") ),
            From => mimeq_encode(fake_email()),
            To => mimeq_encode(fake_email()),
            Subject => mimeq_encode(fake_words(fake_int(2, 5))),
            Data => fake_array( fake_int(1, 5), mimeq_encode(fake_paragraphs(1)) ),
        }
    );

    return MIME::Entity->build(%{_transform($email_generator)});
}

#  this is useful function to wrap Data::Fake in a Mime-Q
sub mimeq_encode {
    my ($thing) = @_;
    return sub { Encode::encode('MIME-Q', _transform($thing) ) };
}