package HTML::DataForm::Field::CGI::Submit;
use base 'HTML::DataForm::Field::CGI::Base';

use Angel::XHTML;

sub align_with { 2 }

sub label { undef }

sub controls {
	my $me = shift;

	$me->{onClick} ||= 'return confirm( "Are you sure you want to delete this record?" )' if $me->{process} eq 'delete';

	xhtml( 
		[ input => { 
			name => $me->{name}, 
			type => 'submit', 
			accesskey => $me->{accesskey}, 
			value => ucfirst( $me->{label} || $me->{process} ), 
			onClick => $me->{onClick} 
		} ],
		$me->{default} && [ input => { name => '_action', type => 'hidden', value => $me->{name} } ]
	);
}

sub set_value_from_CGI_data {
	my ($me, $cgi_data) = @_;

	$me->{value} = delete $cgi_data->{ $me->{name} };
}

sub skip_check {
	my $me = shift;

	$me->{skip_check} or $me->{value} =~ /delete/i;
}

1;
