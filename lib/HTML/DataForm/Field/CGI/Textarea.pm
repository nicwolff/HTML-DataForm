package HTML::DataForm::Field::CGI::Textarea;
use base 'HTML::DataForm::Field::CGI::Base';

use Angel::XHTML;

sub valign { 'top' }

sub align_with { 'textareas' }

sub controls {
	my $me = shift;

	xhtml(
		[ textarea => { 
				name => $me->{name}, 
				id => $me->{id} || $me->{name},
				cols => $me->{cols} || $me->{width} || 40,
				rows => $me->{rows} || 5 
			},
			$me->{value}
		]
	);
}

1;
