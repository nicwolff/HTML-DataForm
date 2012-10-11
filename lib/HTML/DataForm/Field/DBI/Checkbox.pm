package HTML::DataForm::Field::DBI::Checkbox;
use base qw( HTML::DataForm::Field::DBI::Base HTML::DataForm::Field::CGI::Checkbox );

sub get_values_for_DB {
	my $me = shift;

	return ( $me->{column} => $me->{value} ? 't' : 'f' );
}

1;
