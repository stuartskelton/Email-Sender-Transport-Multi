use Test::Most;

use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::Test ;

# add some test only classes
use FindBin;
use lib "$FindBin::RealBin/lib";
use FailTransport;
use TestUtil;

use_ok('Email::Sender::Transport::Multi');

# lets build some emails
my @emails;

for (1..4){
    push @emails, TestUtil::build_fake_email()
};

my $multi_transport = Email::Sender::Transport::Multi->new();


dies_ok(
    sub {
        sendmail(
            $emails[0], { transport => $multi_transport }
        )
    },
    'Should fail as there are no transports configured.'
);


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
