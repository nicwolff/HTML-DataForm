package HTML::DataForm::Field::DBI::File;
use base qw( HTML::DataForm::Field::DBI::Base HTML::DataForm::Field::CGI::File );

sub get_values_for_DB {
	my $me = shift;

	if ( $me->{value} eq '_DELETE' ) {

		return (
			$me->{column} => undef,
			$me->{binary_column} => undef,
		);

	} elsif ( $me->{value} ) {

		my $filename = ( split '[\\\\/]', $me->{value} )[-1];

		my $file;
		my $filehandle = $me->{upload}->fh;
		while ( <$filehandle> ) {
			# New encoding for UTF-8 BYTEA
			s/([\x00-\x1f'\\\x7f-\xff])/'\\' . sprintf("%03o", ord($1))/eg;
			# Old encoding for SQL_ASCII
	#		s{\\}{\\134}g;
	#		s{\0}{\\000}g;
	#		s{'}{\\047}g;
			$file .= $_;
		}

		return (
			$me->{column} => $filename,
			$me->{binary_column} => $file,
		);

	} else {

		return;

	}
}

1;
