package HTML::DataForm::Field::CGI::Date;
use base 'HTML::DataForm::Field::CGI::Datetime';

sub align_with { return 1 }

sub parts { qw( day month year ) }

sub controls {
	my $me = shift;

	$me->date_controls;
}

sub display {
	my $me = shift;

	$me->date_display;
}

1;