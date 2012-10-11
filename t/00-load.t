#!perl -T

use Test::More;

BEGIN {
    use_ok( 'HTML::DataForm' ) || print "Bail out!\n";
    use_ok( 'HTML::DataForm::CGI' ) || print "Bail out!\n";
    use_ok( 'HTML::DataForm::DBI' ) || print "Bail out!\n";
}

done_testing();
