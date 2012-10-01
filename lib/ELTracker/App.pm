package ELTracker::App;
use MooseX::App qw(Color Config ConfigHome);

use FindBin;
use DateTime::Format::Natural;
use DateTime::Format::ISO8601;

use ELTracker::Schema;

option 'debug' => (
    is            => 'rw',
    isa           => 'Bool',
    documentation => 'Turn on debugging output',
);

option 'dsn' => (
    is            => 'rw',
    isa           => 'Str',
    documentation => 'SQL DSN',
    required      => 1,
);

option 'name' => (
    is            => 'rw',
    isa           => 'Str',
    documentation => 'Real name',
    required      => 0,
    default       => '',
);

option 'username' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'DB user name',
);

option 'password' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'DB password',
);

has '_schema' => (
    is            => 'rw',
    lazy          => 1,
    builder       => '_build__schema',
);

has '_parser' => (
    is            => 'rw',
    lazy          => 1,
    builder       => '_build__parser',
);

has '_iso8601_parser' => (
    is            => 'rw',
    lazy          => 1,
    builder       => '_build__iso8601_parser',
);

sub _build__schema {
    my $self = shift;

    my $schema = ELTracker::Schema->connect(
	$self->dsn,
	$self->username,
	$self->password,
	{ AutoCommit => 1 },
    );

    return $schema;
}

sub _build__parser {
    my $self = shift;
    return $self->_new_parser;
}

sub _new_parser {
    my $self = shift;

    my %options = (
	lang          => 'en',
	format        => "mm/dd/yy",
	prefer_future => 0,
	time_zone     => 'America/Denver',
    );

    return DateTime::Format::Natural->new(%options);
}

sub _build__iso8601_parser {
    my $self = shift;
    return $self->_new_iso8601_parser;
}

sub _new_iso8601_parser {
    return DateTime::Format::ISO8601->new();
}

1;
