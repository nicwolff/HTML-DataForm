use strict;

package HTML::DataForm::Field::DBI::Save; 
use base HTML::DataForm::Field::CGI::Submit;

use DBI;

sub process {
	my ($me, $form) = @_;

	# Get the data from the form's fields and either insert it in the database as
	# a new record or update the record that was modified.

	$form->get_table_fields unless $form->{_tables};

	my $key_values = $form->key_values;

	$me->{dbh}->commit;
	$me->{dbh}->{RaiseError} = 1;
	$me->{dbh}->{AutoCommit} = 1;
	$me->{dbh}->begin_work;

	eval {

		if ( $form->{data}->{_new_record} ) {
	
			$me->insert_recurse(
				$form,
				$form->{table}, 
				{
					key_values => $key_values,
					sequence => $form->{sequence},
					auto_increment => $form->{auto_increment},
					sub_tables => $form->{sub_tables}
				}
			);
	
		} else {

			$me->update_recurse( 
				$form,
				$form->{table}, 
				{
					key_values => $key_values,
					sub_tables => $form->{sub_tables}
				}
			);
	
		}

		# Update join tables
		for my $field ( @{ $form->{_tables}{_join}{fields} } ) {
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
		return $me->{success};

	}
}

sub insert_recurse {
	my ($me, $form, $table_name, $table) = @_;

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
	my %values = $form->get_values( $form->{_tables}{$table_name}{fields} );

	for ( keys %{$table->{key_values}} ) {
		$values{ $_ } ||= $table->{key_values}->{$_} if $table->{key_values}->{$_};
	}

	my $names = join ', ', keys %values, @join_columns;
	my $placeholders = join ', ', map '?', values %values, @join_values;
	my $sth = $me->{dbh}->prepare( "insert into $table_name ( $names ) values ( $placeholders )" );
	$sth->execute( values %values, @join_values );

#	return $table->{key_value} || $table->{auto_increment} || $me->get_last_id( $table_name, $table );
}

sub update_recurse {
	my ($me, $form, $table_name, $table) = @_;

	# Update the record
	my %values = $form->get_values( $form->{_tables}{$table_name}{fields} );
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

1;
