package ELTracker::App::add;
use MooseX::App::Command;

extends qw(ELTracker::App);

command_short_description "Add earned leave";
command_long_description  "Add earned leave";

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

option 'earned' => (
    is            => 'rw',
    isa           => 'Int',
    default       => 0,
    documentation => 'Minutes earned. Calculated from start and stop if not set',
);

option 'comment' => (
    is            => 'rw',
    isa           => 'Str',
    required      => 1,
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

    my $new_time = $self->_schema->resultset('Time')->new({});

    $new_time->start("$start_dt");
    $new_time->stop("$stop_dt");
    $new_time->comment($self->comment);

    if ($self->earned != 0) {
	$new_time->earned($self->earned);
    }
    else {
	my $earned_dur = $stop_dt - $start_dt;
	if ($self->debug) {
	    print STDERR "Hours:\t", $earned_dur->in_units('minutes'), "\n";
	}
	$new_time->earned($earned_dur->in_units('minutes'));
    }

    $new_time->insert;
}

1;
