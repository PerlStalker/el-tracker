package ELTracker::App::use;
use MooseX::App::Command;

extends qw(ELTracker::App);

command_short_description "Use earned leave";
command_long_description  "Use earned leave";

use DateTime;
use DateTime::Format::Natural;

option 'start' => (
    is            => 'rw',
    isa           => 'Str',
    required      => 1,
    documentation => 'Start time',
);

option 'stop' => (
    is            => 'rw',
    isa           => 'Str',
    required      => 1,
    documentation => 'Stop time',
);

option 'used' => (
    is            => 'rw',
    isa           => 'Int',
    default       => 0,
    documentation => 'Minutes used. Calculated from start and stop if not set',
);

option 'comment' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'Comment',
);

sub run {
    my $self = shift;

    my $start_dt = $self->_parser->parse_datetime($self->start);
    my $stop_dt  = $self->_parser->parse_datetime($self->stop);

    if ($self->debug) {
	print STDERR "Start:\t", $self->start, " ", $start_dt,
	    "\nStop:\t", $self->stop, " ", $stop_dt,"\n";
    }

    my $new_time = $self->_schema->resultset('Time')->new({
	start   => "$start_dt",
	stop    => "$stop_dt",
	comment => $self->comment
    });

    if ($self->used != 0) {
	$new_time->used($self->used);
    }
    else {
	my $used_dur = $stop_dt - $start_dt;
	$new_time->used($used_dur->in_units('minutes'));
    }

    $new_time->insert;

    $self->_schema->txn_do(sub { $new_time->update });
}

1;
