package HTML::DataForm::Field::DBI::Selectable;
use base HTML::DataForm::Field::CGI::Selectable;

sub get_options {
	my $me = shift;

	# Overloads parent to get list of options from a table
	if ( $me->{table} ) {
		my @names;
		my $id = $me->{key_column} || $me->{column} || 'id';
		my $name = $me->{name_column} || 'name';
		my $order = $me->{order_by} || $name;
		$order = "lower( $order )" unless $me->{order_numeric};

		my $sql = "select $id, $name from $me->{table}";
		$sql .= " where $me->{where}" if $me->{where};
		$sql .= " order by $order";
		my $query = $me->{dbh}->prepare($sql);
		$query->execute;
		while ( my ($id, $name) = $query->fetchrow ) { push @names, $name, $id }
		return @names;
	} else {
		$me->SUPER::get_options();
}	}

1;