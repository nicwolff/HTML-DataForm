package HTML::DataForm::Field::DBI::MultiplySelectable;
use base qw(
	HTML::DataForm::Field::DBI::Selectable
	HTML::DataForm::Field::CGI::MultiplySelectable
);

sub set_value_from_DB_datum {
	my ($me, $data) = @_;

	my @values = split "\n", $data;
	@{ $me->{value} }{ @values } = @values;

}

sub set_value_from_join_table {
	my ($me, %key_values) = @_;

	if ( %key_values ) {

		my $foreign_col = $me->{foreign_col} || $me->{key_column};

		my $where = join ' and ', map "$_ = ?", keys %key_values;

		( my $query = $me->{dbh}->prepare( << "" ) )->execute( values %key_values );
			SELECT $foreign_col FROM $me->{join_table} WHERE $me->{local_col} = ?

		while ( my $foreign_ID = $query->fetchrow ) { $me->{value}->{$foreign_ID}++ }

	}
}

sub update_join_table {
	my ($me, %key_values) = @_;

	my @options = $me->get_options;

	$me->{foreign_col} ||= $me->{key_column} || 'id';

	my $keys = join ', ', $me->{foreign_col}, keys %key_values, keys %{$me->{flags}};
	my $placeholders = join ', ', '?', map '?', values %key_values, values %{$me->{flags}};

	my (%joined, $insert, $delete);

	if ( %key_values ) {
		my $select = $me->{dbh}->prepare(
			"SELECT $me->{foreign_col} FROM $me->{join_table} WHERE " .
				join ' and ', map "$_ = ?", keys %key_values
		);
		$select->execute( values %key_values );
		while ( my ($foreign_key) = $select->fetchrow ) {
			$joined{ $foreign_key } = 'yes';
		}
	}

	if ( $me->{value} ) {

		while ( my ($name, $id) = splice @options, 0, 2 ) {

			if ( $me->{value}->{$id} ) {

				next if $joined{ $id };

				$insert ||= $me->{dbh}->prepare(
					"INSERT INTO $me->{join_table} ( $keys ) VALUES ( $placeholders )"
				);
				$insert->execute( $id, values %key_values, values %{$me->{flags}} );

			} elsif ( %key_values ) {

				$delete ||= $me->{dbh}->prepare(
					"DELETE FROM $me->{join_table} WHERE " .
						join ' AND ', map "$_ = ?", $me->{foreign_col}, keys %key_values
				);
				$delete->execute( $id, values %key_values );

			}

		}

	} elsif ( %key_values ) {

		$me->{dbh}->prepare(
			"DELETE FROM $me->{join_table} WHERE " .
				join ' AND ', map "$_ = ?", keys %key_values
		)->execute( values %key_values );

	}

}

1;
