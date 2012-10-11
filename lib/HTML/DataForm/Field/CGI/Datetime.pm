package HTML::DataForm::Field::CGI::Datetime;
use base 'HTML::DataForm::Field::CGI::Base';

use Angel::XHTML;
use Time::Local;
use Data::Dumper;

sub align_with { 1 }

sub parts {
	$_[0]->{seconds} ?
		qw( second minute hour day month year ) :
		qw( minute hour day month year );
}

sub set_value_to_default {
	my ($me) = @_;

	if ( lc $me->{default} eq 'now' ) {
		my %now;
		@now{ qw( second minute hour day month year ) } = localtime;
		$now{month}++;
		$now{year} += 1900;
		my @parts = $me->parts;
		@{$me->{value}}{ @parts } = @now{ @parts };
	} else {
		$me->SUPER::set_value_to_default();
	}

}

sub set_value_from_CGI_data {
	my ($me, $data) = @_;

	if ( lc delete $me->{value} eq 'now' ) {
		my %now;
		@now{ qw( second minute hour day month year ) } = localtime;
		$now{month}++;
		$now{year} += 1900;
		@{$me->{value}}{ $me->parts } = @now{ $me->parts };
	}

	for ( $me->parts ) {
		my $part_field_name = "$me->{name}_SUB_$_";
		if ( exists $data->{ $part_field_name } ) {
			$me->{value}->{$_} = delete $data->{ $part_field_name };
		}
		if ( $me->{value}->{$_} < 0 ) { delete $me->{value}->{$_} }
	}

}

sub controls {
	my $me = shift;

	join ' &nbsp; ', $me->date_controls, $me->time_controls;
}

sub date_controls {
	my $me = shift;

	my $this_year = (localtime)[5] + 1900;
	my ($start_year, $end_year);
	if ( $me->{end_year} eq 'now' ) {
		$end_year = $this_year;
		$start_year = $me->{start_year} || $end_year - 10;
	} else {
		$start_year = $me->{start_year} || $this_year;
		$end_year = $me->{end_year} || $start_year + 10;
	}

	my $blank = [ ! $me->{required} && 'option' => { value => -1 } ];

	xhtml(
		[ select => { name => "$me->{name}_SUB_month" }, $blank,
			map
				[ option =>
					{ value => $_, selected => $me->is_selected('month') },
					( qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec) )[$_ - 1]
				],
				1..12
		],
		' ',
		[ select => { name => "$me->{name}_SUB_day" }, $blank,
			map
				[ option => { value => $_, selected => $me->is_selected('day') }, $_ ],
				1..31
		],
		', ',
		[ select => { name => "$me->{name}_SUB_year" }, $blank,
			map
				[ option => { value => $_, selected => $me->is_selected('year') }, $_ ],
				$start_year..$end_year
		]
	);
}

sub time_controls {
	my $me = shift;

	my $blank = [ ! $me->{required} && 'option' => { value => -1 } ];

 	xhtml(
		[ select => { name => "$me->{name}_SUB_hour" }, $blank,
			map
				[ option => { value => $_, selected => $me->is_selected('hour') }, $_ % 12 || 12, ' ', $_ < 12 ? 'AM' : 'PM' ],
				0..23
		],
		' : ',
		[ select => { name => "$me->{name}_SUB_minute" }, $blank,
			map
				[ option => { value => $_, selected => $me->is_selected('minute') }, sprintf '%02.2d', $_ ],
				0..59
		],
		$me->{seconds} && ' : ',
		$me->{seconds} && [ select => { name => "$me->{name}_SUB_second" }, $blank,
			map
				[ option => { value => $_, selected => $me->is_selected('second') }, sprintf '%02.2d', $_ ],
				0..59
		],
	);
}

sub is_selected {
	my ($me, $part_name) = @_;

	exists $me->{value}->{$part_name} and $_ == $me->{value}->{$part_name} or undef;
}

sub display {
	my $me = shift;

	join ' &nbsp; ', $me->date_display, $me->time_display;
}

sub date_display {
	my $me = shift;

	return '' unless grep exists $me->{value}->{$_}, qw( day month year );

	join ' ',
		$me->{value}->{day},
		( qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec) )[$me->{value}->{month} - 1],
		$me->{value}->{year},
		map
			xhtml( [ input => { name => "$me->{name}_SUB_$_", type => hidden, value => $me->{value}->{$_} } ] ),
			qw( year month day );
}

sub time_display {
	my $me = shift;

	return '' unless grep exists $me->{value}->{$_}, qw( hour minute second );
	my $half = $me->{value}->{hour} < 12 ? 'AM' : 'PM';
	my $hour = $me->{value}->{hour} % 12 || 12;
	join ' ',
		join( ':', $hour, @{$me->{value}}{ $me->{seconds} ? qw( minute second ) : 'minute' } ),
		$half,
		map
			xhtml( [ input => { name => "$me->{name}_SUB_$_", type => hidden, value => $me->{value}->{$_} } ] ),
			qw( hour minute second );
}

sub test {
	my ($me, $data) = @_;

	my @parts = qw( year month day );
	if (
		grep { exists $me->{value}->{$_} } @parts and
		grep { ! exists $me->{value}->{$_} } @parts
	) {
		$me->{_error} = 'Please select month, day, and year for %s';
		return;
	}

	my ($y, $m, $d) = @{$me->{value}}{ @parts };
	if ($d == 31 and ($m == 4 or $m == 6 or $m == 9 or $m == 11)) {
		$me->{_error} = 'Illegal day of month in %s';
		return; # 31st of a month with 30 days
	} elsif ($d > 29 and $m == 2) {
		$me->{_error} = 'Illegal day of month in %s';
		return; # February 30th or 31st
	} elsif ($m == 2 and $d == 29 and not ($y % 4 == 0 and ($y % 100 != 0 or $y % 400 == 0))) {
		$me->{_error} = 'Not a leap year in %s';
		return; # February 29th outside a leap year
	} else {
		return 1; # Valid date
	}

}

sub message { $_[0]->{_error} }

1;
