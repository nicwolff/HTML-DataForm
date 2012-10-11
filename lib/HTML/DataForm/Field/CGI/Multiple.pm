package HTML::DataForm::Field::CGI::Multiple;
use base qw(
	HTML::DataForm::Field::CGI::Select
	HTML::DataForm::Field::CGI::MultiplySelectable
);

sub align_with { 1 }

sub valign { 'top' }

sub multiple { 'multiple' }

sub set_value_from_CGI_data {
	my ($me, $cgi_data) = @_;

	return unless exists $cgi_data->{ $me->{name} };
	for ( @{ delete $cgi_data->{ $me->{name} } } ) {
		$me->{value}->{$_} = 'y';
	}
}

sub is_selected {
	my ($me, $value) = @_;
	
	$me->{value}->{ $value };
}

sub test {
	my ($me, $data) = @_;

	'y';
}

1;
