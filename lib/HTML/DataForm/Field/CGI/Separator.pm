package HTML::DataForm::Field::CGI::Separator;
use base 'HTML::DataForm::Field::CGI::Base';

use Angel::XHTML;

sub align_with { 100 }

sub valign { 'top' }

sub label { undef }

sub controls { xhtml( [ hr => { class => 'form_separator' } ] ) }

1;
