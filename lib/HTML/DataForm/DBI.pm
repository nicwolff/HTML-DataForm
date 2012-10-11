use strict 'vars';

package HTML::DataForm::DBI;
use base HTML::DataForm::CGI;

use DBI;

# A form object that can handle inserting and updating data in
# a generic ANSI SQL database. Subclass this to handle variant SQLs
# for specific DBMS's.

sub new {
	my ($pkg, %attribs) = @_;

	# Overloads HTML::DataForm::CGI::new to cache a DB connection
	# in the object hash if one wasn't handed in

	$attribs{dbh} ||= DBI->connect( @{ $attribs{dsn} } );
	$attribs{dbh}->trace($attribs{trace}) if exists $attribs{trace};

	# For backward compatability, copy the old key attribs into the new "key" attrib
	#	$attribs{key} ||= { $attribs{key_field} || 'id' => $attribs{key_column} || 'id' };

	my $me = $pkg->SUPER::new( %attribs );

	# If the form has a time zone set, then set the time zone of any datetime fields
	if ( $me->{time_zone} ) {
		map { $_->time_zone( $me->{time_zone} ) if $_->can('time_zone') } @{$me->{fields}};
	}

	return $me;

}

sub make_Field {
	my ($me, $field) = @_;

	# Overloads HTML::DataForm::CGI::make_Field to add a reference
	# to the DB connection for the field methods' use

	$field->{dbh} = $me->{dbh};

	$me->SUPER::make_Field( $field );

	if ( $field->{sets_time_zone} ) {
		$me->{time_zone} = $field->{value};
		$me->{tz_column} = $field->{column};
	}
}

sub key_values {
	my $me = shift;

	my %key_values;
	for ( keys %{$me->{key}} ) {
		next if not defined $me->{data}->{$_};
		$key_values{ $me->{key}->{$_} } = $me->{data}->{ $_ };
	}
	return \%key_values;
}

sub get_record {
	my $me = shift;

	$me->get_table_fields unless $me->{_tables};

	my $key_values = $me->key_values;

	# Get data from tables
	$me->get_record_recurse(
		$me->{table},
		{
			key_values => $key_values,
			sub_tables => $me->{sub_tables}
		}
	);

	# Get data for MultiplySelectable fields
	for my $field ( @{ $me->{_tables}{_join}{fields} } ) {
		$field->set_value_from_join_table( %$key_values );
	}

}

sub get_table_fields {
	my $me = shift;

	# Get columns from each table
	for my $field ( @{ $me->{fields} } ) {
		my $table = $field->{subtable} || $me->{table};
		push @{ $me->{_tables}{$table}{fields} }, $field if $field->{column};
		push @{ $me->{_tables}{_join}{fields} }, $field if $field->{join_table};
	}
}

sub get_record_recurse {
	my ($me, $table_name, $table) = @_;

	# Get columns needed from this table
	my (@fields, @columns);
	for ( @fields = @{ $me->{_tables}{$table_name}{fields} } ) {
		my $column = $_->{column};
		if ( $me->{tz_column} && $_->can('time_zone') ) {
			$column = "COALESCE( $column AT TIME ZONE $me->{tz_column}, $column )"
		}
		push @columns, $column;
	}

	# Get foreign key columns for sub-tables
	my (@join_tables, @join_columns);
	for ( keys %{ $table->{sub_tables} } ) {
		push @join_tables, $_;
		push @join_columns, $table->{sub_tables}{$_}{join_on};
	}

	# Get data
	if ( @columns || @join_columns ) {

		my $column_list = join ',', @columns, @join_columns;
		my $where = join ' and ', map "$_ = ?", keys %{$table->{key_values}};

		my $query = $me->{dbh}->prepare("select $column_list from $table_name where $where");
		$query->execute( values %{$table->{key_values}} );
		my @row_data = $query->fetchrow;
		$query->finish;

		for my $field ( @fields ) {
			$field->set_value_from_DB_datum( shift @row_data );
		}

		for my $join_table ( @join_tables ) {
			$table->{sub_tables}{$join_table}{key_values}{ shift @join_columns } = shift @row_data;
			$me->get_record_recurse( $join_table, $table->{sub_tables}{$join_table} );
		}

	}
}

sub get_new_id {
	my ($me, $table_name, $table) = @_;

	# Generic method to get ID for new record;
	# meant to work with any ANSI SQL.

	my $query = $me->{dbh}->prepare("select max($table->{key_column}) from $table_name");
	$query->execute;
	my $id = $query->fetchrow;
	$query->finish;
	return ++$id;
}

sub test_unique {
  my ($me, $field) = @_;

  return unless $field->{column};

	my $where = "$field->{column} = ?";
	$where = "lower($field->{column}) = lower(?)" if $me->{case_insensitive_unique};
	my @values = ( $field->{value} );

	if ( ! $me->{data}->{_new_record} ) {
		$where .= join ' and ', '', map "$_ <> ?", values %{$me->{key}};
		push @values, @{$me->{data}}{ keys %{$me->{key}} };
	}

  my $sth = $me->{dbh}->prepare( "select null from $me->{table} where $where" );

  $sth->execute( @values );

  if ( my @d = $sth->fetchrow ) {
    $sth->finish;
    return undef;
  } else {
    $sth->finish;
    return 1;
  }
}

sub process_save {
	my $me = shift;

	# Get the data from the form's fields and either insert it in the database as
	# a new record or update the record that was modified.

	$me->get_table_fields unless $me->{_tables};

	my $key_values = $me->key_values;

	$me->{dbh}->commit unless $me->{dbh}->{AutoCommit};
	$me->{dbh}->{RaiseError} = 1;
	$me->{dbh}->{AutoCommit} = 1;
	$me->{dbh}->begin_work;

	eval {

		if ( $me->{data}->{_new_record} ) {

			$me->insert_recurse(
				$me->{table},
				{
					key_values => $key_values,
					sequence => $me->{sequence},
					auto_increment => $me->{auto_increment},
					sub_tables => $me->{sub_tables}
				}
			);

		} else {

			$me->update_recurse(
				$me->{table},
				{
					key_values => $key_values,
					sub_tables => $me->{sub_tables}
				}
			);

		}

		# Update join tables
		for my $field ( @{ $me->{_tables}{_join}{fields} } ) {
			$field->update_join_table( %$key_values );
		}

		$me->{dbh}->commit;

	};

	if ( $@ ) {

		$me->{dbh}->rollback;

		$me->{error} = "Update or insert failed: $@";

	} else {

		# Processing functions return the success page or undef to go to referer
		# which we pass back to print_result()
		return $me->{_processing}->{success};

	}
}

sub insert_recurse {
	my ($me, $table_name, $table) = @_;

	my (@join_tables, @join_columns, @join_values, %foreign_keys);

	# Get foreign key columns for sub-tables
	for ( keys %{ $table->{sub_tables} } ) {
		push @join_tables, $_;
		push @join_columns, $table->{sub_tables}{$_}{join_on};
	}

	# Insert into sub-tables
#	for my $join_table ( @join_tables ) {
#		push @join_values, $foreign_keys{$table->{sub_tables}{$join_table}{join_on}} =
#			$me->insert_recurse( $join_table, $table->{sub_tables}{$join_table} );
#	}

#	for ( $me->key_fields_with_no_CGI_data ) {
#		next if $table->{auto_increment};
#		my $key_column = $table->{key}->{$_};
#		push @join_columns, $key_column;
#		push @join_values, $table->{key_values}->{$key_column} = $me->get_new_id( $table_name, $table );
#	}

	# Get the new ID, unless it's been supplied or it's auto-incrementing
#	unless (
#		$table->{key_value} = $foreign_keys{$table->{key_column}} or
#		$table->{auto_increment}
#		or $me->{data}->{ $me->{key_field} }
#	) {
#		push @join_columns, $table->{key_column};
#		push @join_values, $table->{key_value} = $me->get_new_id( $table_name, $table );
#	}

	# Insert the record
	if ( my %values = $me->get_values( $me->{_tables}{$table_name}{fields} ) ) {

		for ( keys %{$table->{key_values}} ) {
			$values{ $_ } ||= $table->{key_values}->{$_} if $table->{key_values}->{$_};
		}

		my $names = join ', ', keys %values, @join_columns;
		my $placeholders = join ', ', map '?', values %values, @join_values;
		my $sth = $me->{dbh}->prepare( "insert into $table_name ( $names ) values ( $placeholders )" );
		$sth->execute( values %values, @join_values );

	}

#	return $table->{key_value} || $table->{auto_increment} || $me->get_last_id( $table_name, $table );
}

sub update_recurse {
	my ($me, $table_name, $table) = @_;

	# Update the record
	my %values = $me->get_values( $me->{_tables}{$table_name}{fields} );
	my $assignments = join ', ', map "$_ = ?", keys %values;
	if ( $assignments ) {
		my $where = join ' and ', map "$_ = ?", keys %{$table->{key_values}};
		my $sth = $me->{dbh}->prepare( "update $table_name set $assignments where $where" );
		$sth->execute( values %values, values %{$table->{key_values}} );
	}

	my (@join_tables, @join_columns);

	# Get foreign key columns for sub-tables
	for ( keys %{ $table->{sub_tables} } ) {
		push @join_tables, $_;
		push @join_columns, $table->{sub_tables}{$_}{join_on};
	}

	# Update sub-tables
	if ( @join_columns ) {
		my $column_list = join ',', @join_columns;
		my $query = $me->{dbh}->prepare( "select $column_list from $table_name where $me->{key_column} = ?" );
		$query->execute( $table->{key_value} );
		my @row_data = $query->fetchrow;
		$query->finish;
		for my $join_table ( @join_tables ) {
			$table->{sub_tables}{$join_table}{key_values}{ shift @join_columns } = shift @row_data;
			$me->update_recurse( $join_table, $table->{sub_tables}{$join_table} );
		}
	}
}

sub get_values {
	my ($me, $fields) = @_;
	# Get the values entered in the form's fields.

	my %values;
	for my $field ( @$fields ) {
		# Ask each field with a DB column to get and format its value.
		if ( $field->can('get_values_for_DB') and $field->{column} and ! $field->{display} ) {
			my %field_values = $field->get_values_for_DB;
			while ( my ($column, $value) = each %field_values ) {
				$values{ $column } = $value if $column;
			}
		}
	}
	return %values;
}

sub process_delete {
	my $me = shift;

	if ( $me->{_processing}->{verify} ) {
		unless ( $me->{data}->{verify_delete} ) {
			return "Content-type: text/plain\nStatus: 204 No result\n\n";
		}
	}

	$me->get_table_fields unless $me->{_tables};

	my $key_values = $me->key_values;

	$me->{dbh}->commit unless $me->{dbh}->{AutoCommit};
	$me->{dbh}->{RaiseError} = 1;
	$me->{dbh}->{AutoCommit} = 1;
	$me->{dbh}->begin_work;

	eval {

		$me->delete_recurse(
			$me->{table},
			{
				key_values => $key_values,
				sub_tables => $me->{sub_tables}
			}
	 );

		$me->{dbh}->commit;

	};

	if ( $@ ) {
		$me->{dbh}->rollback;
		return "Content-type: text/plain\n\nDelete failed: $@";
	} else {
		$me->{_processing}->{success};
	}
}

sub delete_recurse {
	my ($me, $table_name, $table) = @_;

	# Get foreign key columns for sub-tables
	my (@join_tables, @join_columns);
	for ( keys %{ $table->{sub_tables} } ) {
		push @join_tables, $_;
		push @join_columns, $table->{sub_tables}{$_}{join_on};
	}

	# Delete records
	if ( @join_columns ) {
		my $column_list = join ',', @join_columns;
		my $query = $me->{dbh}->prepare("select $column_list from $table_name where $table->{key_column} = ?");
		$query->execute( $table->{key_value} );
		my @row_data = $query->fetchrow;
		$query->finish;
		for my $join_table ( @join_tables ) {
			$table->{sub_tables}{$join_table}{key_value} = shift @row_data;
			$me->delete_recurse( $join_table, $table->{sub_tables}{$join_table} );
		}
	}

	my $where = join ' and ', map "$_ = ?", keys %{$table->{key_values}};
	my $query = $me->{dbh}->prepare("delete from $table_name where $where");
	$query->execute( values %{$table->{key_values}} );
}

sub DESTROY {
	my $me = shift;

	$me->{dbh}->disconnect if $me->{dbh};
}

sub w { warn join ', ', @_; return @_; }

1;
