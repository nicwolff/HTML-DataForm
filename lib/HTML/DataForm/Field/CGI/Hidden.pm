package HTML::DataForm::Field::CGI::Hidden;
use base 'HTML::DataForm::Field::CGI::Base';

use Angel::XHTML;

sub align_with { 1 }
sub label { }
sub space { }

sub controls {
	my $me = shift;

	xhtml( [ input => { name => $me->{name}, id => $me->{id} || $me->{name}, type => 'hidden', value => $me->{value} } ] );
}

1;
