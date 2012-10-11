package HTML::DataForm::Field::CGI::Time;
use base 'HTML::DataForm::Field::CGI::Datetime';

sub align_with { return 1 }

sub parts { qw( sec min hour ) }

sub controls {
	my $me = shift;

	$me->time_controls;
}

1;