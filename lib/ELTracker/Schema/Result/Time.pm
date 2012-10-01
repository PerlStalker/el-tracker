package ELTracker::Schema::Result::Time;
use warnings;
use strict;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('times');
__PACKAGE__->add_columns(qw/id start stop earned comment used/);
__PACKAGE__->set_primary_key('start');

1;
