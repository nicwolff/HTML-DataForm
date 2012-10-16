package HTML::DataForm::Field::CGI::Hidden;
use base 'HTML::DataForm::Field::CGI::Base';

use HTML::FromArrayref;

sub align_with { 1 }
sub label { }
sub space { }

sub controls {
	my $me = shift;

	HTML( [ input => { name => $me->{name}, id => $me->{id} || $me->{name}, type => 'hidden', value => $me->{value} } ] );
}

1;
