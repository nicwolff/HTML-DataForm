package HTML::DataForm::Field::CGI::Spacer;
use base 'HTML::DataForm::Field::CGI::Base';

sub align_with { 1 }

sub valign { 'top' }

sub label { undef }

sub controls { '<br />' }

1;
