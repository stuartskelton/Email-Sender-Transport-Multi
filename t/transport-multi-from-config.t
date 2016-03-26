use strict;
use warnings;
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
my $total_number_of_emails = 4;
for (1..$total_number_of_emails){
    push @emails, TestUtil::build_fake_email()
};

my $config = {
    transports => [
        {class => 'Email::Sender::Transport::Test', config => {foo => 'meep'} },
        {class => 'Email::Sender::Transport::Test', config => {} },
        {class => 'Email::Sender::Transport::Test' },
    ],
};


my $multi_transport = Email::Sender::Transport::Multi->new_from_config($config);

is($multi_transport->hard_fail,0,'hard_fail should default to 0');

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


subtest "Hard fails"  => sub {

# now build a config wiht a failing transport
for my $hard_fail (0,1) {

    $config = {
        transports => [
            {class => 'Email::Sender::Transport::Test', config => {foo => 'meep'} },
            {class => 'FailTransport' },
            {class => 'Email::Sender::Transport::Test', config => {foo => 'meep'} },
        ],
        hard_fail => $hard_fail,
    };

    $multi_transport = Email::Sender::Transport::Multi->new_from_config($config);

    is($multi_transport->hard_fail,$hard_fail,"Is hard_fail set to $hard_fail");

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


    is(
        $multi_transport->transports->[0]->deliveries,
        $total_number_of_emails,
        "First transport should have sent $total_number_of_emails emails"
    );

    if ($multi_transport->hard_fail) {
        is(
            $multi_transport->transports->[2]->deliveries,
            0,
            "third transport should have sent 0 emails, because of the hard_fail"
        );
    }
    else {
        is(
            $multi_transport->transports->[2]->deliveries,
            $total_number_of_emails,
            "Third transport should have sent $total_number_of_emails emails."
        );
    }
}

};




done_testing();

