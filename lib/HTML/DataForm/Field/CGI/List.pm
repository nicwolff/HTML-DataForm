package HTML::DataForm::Field::CGI::List;
use base 'HTML::DataForm::Field::CGI::Base';

use Angel::XHTML;
use Angel::List;

sub align_with { return 1 }

sub valign { 'top' }

sub controls {
	my $me = shift;

	my $list = new Angel::List { %$me };
	$list->html;
}

1;
