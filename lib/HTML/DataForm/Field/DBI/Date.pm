package HTML::DataForm::Field::DBI::Date;
use base qw( 
	HTML::DataForm::Field::DBI::Date 
	HTML::DataForm::Field::CGI::Date 
	HTML::DataForm::Field::DBI::Datetime
);

sub parts { qw( year month day ) }

1;
