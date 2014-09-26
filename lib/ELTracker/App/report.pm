package ELTracker::App::report;
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

option 'format' => (
    is            => 'rw',
    isa           => 'Str',
    required      => 1,
    documentation => 'Format output: txt, org',
    default       => 'txt',
    );

sub run {
    my $self = shift;

    my $start_dt = $self->_parser->parse_datetime($self->start);
    my $stop_dt  = $self->_parser->parse_datetime($self->stop);

    my $p_totals = $self->_schema->resultset('Time')->search(
	{
	    start  => { '<' => "$start_dt"  }
	},
	{ order_by => 'start' }
    );
    my $p_earned = $p_totals->get_column('earned')->sum || 0;
    my $p_used   = $p_totals->get_column('used')->sum   || 0;

    if ($self->format eq 'txt') {
	$self->format_txt(
	    $start_dt, $stop_dt,
	    $p_totals, $p_earned, $p_used
	    );
    } elsif ($self->format eq 'org') {
	$self->format_org(
	    $start_dt, $stop_dt,
	    $p_totals, $p_earned, $p_used
	    );
    }

}

sub format_txt {
    my $self     = shift;

    my $start_dt = shift;
    my $stop_dt  = shift;
    my $p_totals = shift;
    my $p_earned = shift;
    my $p_used   = shift;

    print "Earned leave for ", $self->name;
    print " (", $self->start, " - ", $self->stop, ")\n";
    print "-"x65, "\n";
    printf("%16s   %16s % 6s % 5s\n",
	   '', '', 'Hours', 'Mins'
       );
    print "-"x65, "\n";
    printf("%16s   %16s % 6.2f % 5d\n",
	   "",
	   "Previous",
	   ($p_earned - $p_used) / 60,
	   ($p_earned - $p_used),
       );
    print "-"x65, "\n";

    my $records = $self->_schema->resultset('Time')->search(
	{
	    start => { '>=' => "$start_dt" },
	    stop  => { '<=' => "$stop_dt"  }
	},
	{ order_by => 'start' }
    );

    my $cldr_format = "MM-dd-yyyy HH:mm";
    while (my $rec = $records->next) {
	my $time = 0;

	if ($rec->earned) {
	    $time = $rec->earned;
	}
	elsif ($rec->used) {
	    $time = $rec->used * -1;
	}

	#use Data::Dumper; print STDERR Dumper $rec->start; print "\n";
	my $rec_start = $self->_iso8601_parser->parse_datetime($rec->start);
	my $rec_stop  = $self->_iso8601_parser->parse_datetime($rec->stop);
	printf("%16s - %16s % 6.2f % 5d %s\n",
	       $rec_start->format_cldr($cldr_format),
	       $rec_stop->format_cldr($cldr_format),
	       #$rec->start,
	       #$rec->stop,
	       $time / 60,
	       $time,
	       $rec->comment || "",
	   );
    }

    my $total = 0;
    my $totals = $self->_schema->resultset('Time')->search(
	{
	    stop  => { '<=' => "$stop_dt"  }
	},
	{ order_by => 'start' }
    );
    my $earned = $totals->get_column('earned')->sum || 0;
    my $used   = $totals->get_column('used')->sum   || 0;
    $total = $earned - $used;

    print "-"x65, "\n";
    printf("%16s   %16s % 6.2f % 5d\n",
	   "",
	   "Total",
	   $total / 60,
	   $total
       );
}

# Format for emacs org-mode
sub format_org {
    my $self     = shift;

    my $start_dt = shift;
    my $stop_dt  = shift;
    my $p_totals = shift;
    my $p_earned = shift;
    my $p_used   = shift;

    my $hline = "|-|-|-|\n";

    # TODO: Why doesn't printing a caption work?
    #print "#+CAPTION: Earned leave for ",$self->start, ' - ', $self->stop, "\n";
    print "| Start | Stop | Hours | Comments |\n";

    print $hline;

    printf("| | Previous | % 6.2f | |\n",
	   ($p_earned - $p_used) / 60);

    print $hline;

    my $records = $self->_schema->resultset('Time')->search(
	{
	    start => { '>=' => "$start_dt" },
	    stop  => { '<=' => "$stop_dt"  }
	},
	{ order_by => 'start' }
    );

    my $cldr_format = "MM-dd-yyyy HH:mm";
    while (my $rec = $records->next) {
	my $time = 0;

	if ($rec->earned) {
	    $time = $rec->earned;
	}
	elsif ($rec->used) {
	    $time = $rec->used * -1;
	}

	#use Data::Dumper; print STDERR Dumper $rec->start; print "\n";
	my $rec_start = $self->_iso8601_parser->parse_datetime($rec->start);
	my $rec_stop  = $self->_iso8601_parser->parse_datetime($rec->stop);
	printf("| %16s | %16s | % 6.2f | %s |\n",
	       $rec_start->format_cldr($cldr_format),
	       $rec_stop->format_cldr($cldr_format),
	       #$rec->start,
	       #$rec->stop,
	       $time / 60,
	       #$time,
	       $rec->comment || "",
	   );
    }
    print $hline;

    my $total = 0;
    my $totals = $self->_schema->resultset('Time')->search(
	{
	    stop  => { '<=' => "$stop_dt"  }
	},
	{ order_by => 'start' }
    );
    my $earned = $totals->get_column('earned')->sum || 0;
    my $used   = $totals->get_column('used')->sum   || 0;
    $total = $earned - $used;

    printf("| | Total | % 6.2f | |\n",
	   $total / 60);
    
}

1;
