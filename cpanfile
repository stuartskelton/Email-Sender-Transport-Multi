requires 'Class::Load';
requires 'Email::Sender';
requires 'Moo'';
requires 'MooX::HandlesVia';
requires 'Try::Tiny';
requires 'Types::Standard';

on 'test' => sub {
    requires 'Data::Fake',   '>= 0';
    requires 'Encode',       '>= 0';
    requires 'MIME::Entity', '>= 0';
    requires 'Test::Most',   '>= 0';
    requires 'Test::More',   '>= 0';
};
