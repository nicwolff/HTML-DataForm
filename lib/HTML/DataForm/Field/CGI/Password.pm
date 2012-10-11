package HTML::DataForm::Field::CGI::Password;
use base 'HTML::DataForm::Field::CGI::Base';

use Angel::XHTML;

sub align_with { return 1 }

sub set_value_from_CGI_data {
	my ($me, $cgi_data) = @_;

	$me->{_verify} = delete $cgi_data->{ $me->{name} . '_VERIFY' };
	$me->SUPER::set_value_from_CGI_data( $cgi_data );
}

sub controls {
	my $me = shift;

	xhtml( 
		[ input => {
			name => $me->{name}, 
			type => 'password', 
			size => $me->{size}, 
			maxlength => $me->{maxlength} || $me->{size}, 
		} ],
		' Re-enter ',
		[ input => {
			name => $me->{name} . '_VERIFY', 
			type => 'password', 
			size => $me->{size}, 
			maxlength => $me->{maxlength} || $me->{size}, 
		} ]
	);
}

sub test {
	my ($me, $data) = @_;

	$me->{value} eq $me->{_verify};
}

sub message {
	my ($me, $data) = @_;
	
	qq(The two values entered in the "$me->{label}" field do not match);
}

1;
