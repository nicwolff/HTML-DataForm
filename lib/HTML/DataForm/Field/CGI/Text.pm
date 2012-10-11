package HTML::DataForm::Field::CGI::Text;
use base 'HTML::DataForm::Field::CGI::Base';

use Angel::XHTML;

sub align_with { return 1 }

sub controls {
	my $me = shift;

	xhtml(
		[ input => {
			name => $me->{name},
			id => $me->{id} || $me->{name},
			type => $me->type,
			size => $me->{size},
			maxlength => $me->{maxlength} || $me->{size},
			value => $me->{value},
			class => $me->{class},
			onClick => $me->{onClick},
			onChange => $me->{onChange},
			onEnter => $me->{onEnter},
		} ]
	);
}

sub type { 'text' }

1;
