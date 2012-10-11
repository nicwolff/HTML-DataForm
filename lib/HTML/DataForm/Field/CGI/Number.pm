package HTML::DataForm::Field::CGI::Number;
use base 'HTML::DataForm::Field::CGI::Text';

sub test {
	my ($me, $data) = @_;

	$data =~ /^[\.\d\s]+$/;
}

sub message { '%s must contain a number"' }

1;
