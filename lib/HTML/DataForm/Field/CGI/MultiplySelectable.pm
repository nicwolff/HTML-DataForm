package HTML::DataForm::Field::CGI::MultiplySelectable;
use base HTML::DataForm::Field::CGI::Selectable;

sub set_value_to_default {
	my ($me) = @_;

	if ( lc $me->{default} eq 'all' ) {
		$me->{_all_checked} = 'y';
	} else {
		$me->SUPER::set_value_to_default();
	}

}

1;
