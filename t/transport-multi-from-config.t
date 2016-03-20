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

my $config = {
    transports => [
        {class => 'Email::Sender::Transport::Test', config => {foo => 'meep'} },
        {class => 'Email::Sender::Transport::Test', config => {} },
        {class => 'Email::Sender::Transport::Test' },
    ]
};


my $multi_transport = Email::Sender::Transport::Multi->new_from_config($config);


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

is_deeply(
    [$multi_transport->transports->[1]->deliveries],
    [$multi_transport->transports->[2]->deliveries],
    'Both transports have the same email'
);


# now build a config wiht a failing transport

$config = {
    transports => [
        {class => 'Email::Sender::Transport::Test', config => {foo => 'meep'} },
        {class => 'FailTransport' },
    ]
};

$multi_transport = Email::Sender::Transport::Multi->new_from_config($config);


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

