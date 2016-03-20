package TestUtil;
use strict;
use warnings;

use Data::Fake qw/Core Names Text Dates Internet/;
use Data::Fake::Core qw/_transform/;
use Encode;
use MIME::Entity;

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

1;
