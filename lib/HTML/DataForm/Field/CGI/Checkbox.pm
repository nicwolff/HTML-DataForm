package HTML::DataForm::Field::CGI::Checkbox;
use base 'HTML::DataForm::Field::CGI::Base';

use Angel::XHTML;

sub align_with { 1 }

sub required { }

sub controls {
	my $me = shift;

	xhtml(
		[ input => { 
			type => 'checkbox', 
			name => $me->{name}, 
			id => $me->{id} || $me->{name}, 
			checked => $me->{value} || undef 
		} ]
	);
}

1;
