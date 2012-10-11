package HTML::DataForm::Field::DBI::Datetime;
use base qw(
	HTML::DataForm::Field::DBI::Base
	HTML::DataForm::Field::CGI::Datetime
);

sub time_zone {
	my ($me, $tz) = @_;
	$me->{time_zone} = $tz;
}

sub set_value_from_DB_datum {
	my ($me, $datum) = @_;

	return delete $me->{value} if not defined $datum;

	my %date;
	@date{ qw( year month day hour minute second ) } = (split /[^\d]/, $datum)[0..5];
	$me->{value} = \%date;
}

sub get_values_for_DB {
	my $me = shift;

	my @parts = $me->parts;

	if ( ! grep( $me->{value}->{$_}, @parts ) ) {
		return ( $me->{column} => undef );
	}

	return (
		$me->{column} =>
		join ' ', grep $_,
			sprintf( '%02d-%02d-%d', @{$me->{value}}{ qw( month day year ) } ),
			sprintf( '%02d:%02d:%02d', @{$me->{value}}{ qw( hour minute second ) } ),
			$me->{time_zone}
	);
}

1;
