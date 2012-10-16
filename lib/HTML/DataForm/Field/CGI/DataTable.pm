package HTML::DataForm::Field::CGI::DataTable;
use base 'HTML::DataForm::Field::CGI::Base';

use HTML::FromArrayref;
use HTML::DataTable;

sub align_with { return 1 }

sub valign { 'top' }

sub controls {
	my $me = shift;

	my $table = new HTML::DataTable { %$me };
	$table->html;
}

1;
