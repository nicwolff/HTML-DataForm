package HTML::DataForm::Field::DBI::Password;
use base qw( HTML::DataForm::Field::DBI::Base HTML::DataForm::Field::CGI::Password );

use Digest::MD5 qw( md5_base64 );

sub set_value_from_DB_datum {	return undef }

sub get_values_for_DB {
	my $me = shift;
	
	return undef unless $me->{value};

	return ( 
		$me->{column} => 
		md5_base64( $me->{lowercase} ? lc $me->{value} : $me->{value} ) 
	);
}

1;
