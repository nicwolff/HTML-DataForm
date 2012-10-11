package HTML::DataForm::Field::DBI::Base;

sub get_values_for_DB {
	my $me = shift;

	my $value = $me->{value};
	return ( $me->{column} => $value );
}

sub set_value_from_DB_datum {
	my ($me, $data) = @_;

	$me->{value} = $data;
}

1;