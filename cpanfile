requires 'Email::Sender';





on 'test' => sub {
    requires 'Test::More',   '>= 0';
    requires 'Test::Most',   '>= 0';
    requires 'Encode',       '>= 0';
    requires 'Data::Fake',   '>= 0';
    requires 'MIME::Entity', '>= 0';
};
