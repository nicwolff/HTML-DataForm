#!perl -T

use Test::More;

BEGIN {
    use_ok( 'HTML::DataForm::DBI' ) || print "Could not load HTML::DataForm::CGI\n";
}

my $dbh = DBI->connect('dbi:Mock:', '', '');

ok( my $form = HTML::DataForm::DBI->new( dbh => $dbh, fields => \@fields ), 'new with fields' );
$form->{_checksum_secret} = '___TESTING___';

done_testing();

BEGIN {

	our %data = (
		x18b56cc9 => 'on', # Submit
	);

	our @fields = (
		{
			name => 'A checkbox',
			type => 'checkbox',
		},
		{
			name => 'Multiple checkboxes',
			type => 'checkboxes',
			list => [ 'First', 'Second', 'Third' ],
		},
		{
			name => 'Countries',
			type => 'countries',
		},
		{
			name => 'Date field',
			type => 'date',
		},
		{
			name => 'File field',
			type => 'file',
		},
		{
			name => 'Hidden field',
			type => 'hidden',
			value => '123secret',
		},
		{
			name => 'Multiple select',
			type => 'multiple',
			list => [ 'First', 'Second', 'Third' ],
		},
		{
			name => 'Number',
			type => 'number',
			value => 12345,
		},
		{
			name => 'Radios',
			type => 'radios',
			list => [ 'First', 'Second', 'Third' ],
		},
		{
			name => 'Select',
			type => 'select',
			list => [ 'First', 'Second', 'Third' ],
		},
		{
			name => 'Separator',
			type => 'separator',
		},
		{
			name => 'Spacer',
			type => 'spacer',
		},
		{
			name => 'States',
			type => 'states',
		},
		{
			name => 'Submit',
			type => 'submit',
			process => 'save',
			value => 'Submit',
		},
		{
			name => 'Text',
			type => 'text',
		},
		{
			name => 'Textarea',
			type => 'textarea',
		},
		{
			name => 'Time',
			type => 'time',
		}
	);

}

__DATA__
