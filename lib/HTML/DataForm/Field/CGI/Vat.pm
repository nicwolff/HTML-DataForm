package HTML::DataForm::Field::CGI::Vat;
use base 'HTML::DataForm::Field::CGI::Base';

use HTML::FromArrayref;

sub align_with { return 1 }

sub set_value_from_CGI_data {
	my ($me, $cgi_data) = @_;

	$me->{value} = join '', $cgi_data->{ $me->{name} . '_COUNTRY_CODE' }, $cgi_data->{ $me->{name} . '_NUMBER' };
}

sub controls {
	my $me = shift;

	$me->{value} =~ /^([A-Z][A-Z])([A-Za-z0-9]{2,})/;

	HTML( 
		[ input => { name => $me->{name} . '_COUNTRY_CODE', type => 'text', size => 2, maxlength => 2, value => $1 } ],
		[[ '&nbsp;' ]],
		[ input => { name => $me->{name} . '_NUMBER', type => 'text', size => 12, maxlength => 12, value => $2 } ]
	);
}

sub test {
	my ($me, $data) = @_;

	$me->{value} =~ /^[A-Z]{2}[A-Za-z0-9]{2,}/;
}

sub message {
	my ($me, $data) = @_;
	
	qq(The first part of the "$me->{label}" field must be two letters, and the second part must be at least two letters or numbers.);
}

1;
