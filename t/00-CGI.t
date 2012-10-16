#!perl -T

use Test::More;

BEGIN {
    use_ok( 'HTML::DataForm::CGI' ) || print "Could not load HTML::DataForm::CGI\n";
}

ok( my $form = HTML::DataForm::CGI->new, 'new' );

my %fields = (
	fields => [
		{
			name => 'A checkbox',
			type => 'checkbox',
			html => '<input name="xe76bc1fd" type="checkbox" id="xe76bc1fd">'
		},
		{
			name => 'Multiple checkboxes',
			type => 'checkboxes',
			list => [ 'First', 'Second', 'Third' ],
			html => '<table cellpadding="2" class="form_items"><tr><td><input ID="xbc924c98_SUB_First" name="xbc924c98_SUB_First" type="checkbox"></td><td class="form_label"><label for="xbc924c98_SUB_First">First</label></td></tr><tr><td><input ID="xbc924c98_SUB_Second" name="xbc924c98_SUB_Second" type="checkbox"></td><td class="form_label"><label for="xbc924c98_SUB_Second">Second</label></td></tr><tr><td><input ID="xbc924c98_SUB_Third" name="xbc924c98_SUB_Third" type="checkbox"></td><td class="form_label"><label for="xbc924c98_SUB_Third">Third</label></td></tr></table>'
		},
		{
			name => 'Date field',
			type => 'date',
			html => '<select name="x1c928694_SUB_month"><option value="-1"></option><option value="1">Jan</option><option value="2">Feb</option><option value="3">Mar</option><option value="4">Apr</option><option value="5">May</option><option value="6">Jun</option><option value="7">Jul</option><option value="8">Aug</option><option value="9">Sep</option><option value="10">Oct</option><option value="11">Nov</option><option value="12">Dec</option></select> <select name="x1c928694_SUB_day"><option value="-1"></option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option></select>, <select name="x1c928694_SUB_year"><option value="-1"></option><option value="2012">2012</option><option value="2013">2013</option><option value="2014">2014</option><option value="2015">2015</option><option value="2016">2016</option><option value="2017">2017</option><option value="2018">2018</option><option value="2019">2019</option><option value="2020">2020</option><option value="2021">2021</option><option value="2022">2022</option></select>'
		},
		{
			name => 'File field',
			type => 'file',
			html => '<input name="x53b9e9d5" onChange="this.form.x53b9e9d5_RADIOS[2].checked=true" type="file" id="x53b9e9d5">'
		},
		{
			name => 'Hidden field',
			type => 'hidden',
			value => '123secret',
			html => '<input value="123secret" name="xb85cded3" id="xb85cded3" type="hidden">'
		},
	]
);

ok( my $form2 = HTML::DataForm::CGI->new( %fields ), 'new with fields' );
$form2->{_checksum_secret} = '___TESTING___';

for my $field ( @{$form2->{fields}} ) {
	is( $field->controls, $field->{html}, ref $field );
}

is( $form2->html, join('', <DATA>), 'form HTML is OK' );

done_testing();

__DATA__
<form enctype="multipart/form-data" name="form" accept-charset="UTF-8" action="00-CGI.t" id="form" method="POST"><input name="_new_record" id="_new_record" type="hidden"><input name="_referer" id="_referer" type="hidden"><input value="c345fc4e890488bc2ba4b085464deb0c" name="_HFchecksum" id="_HFchecksum" type="hidden"><table border="0" cellspacing="0" cellpadding="2"></table><table border="0" cellspacing="0" cellpadding="2"><tr><td align="left" colspan="3"><label for="xe76bc1fd" class="form_label">A checkbox</label></td><td colspan="2"><input name="xe76bc1fd" type="checkbox" id="xe76bc1fd"></td></tr></table><table border="0" cellspacing="0" cellpadding="2"><tr valign="top"><td align="left" colspan="3"><label for="xbc924c98" class="form_label">Multiple checkboxes</label></td><td colspan="2"><table cellpadding="2" class="form_items"><tr><td><input ID="xbc924c98_SUB_First" name="xbc924c98_SUB_First" type="checkbox"></td><td class="form_label"><label for="xbc924c98_SUB_First">First</label></td></tr><tr><td><input ID="xbc924c98_SUB_Second" name="xbc924c98_SUB_Second" type="checkbox"></td><td class="form_label"><label for="xbc924c98_SUB_Second">Second</label></td></tr><tr><td><input ID="xbc924c98_SUB_Third" name="xbc924c98_SUB_Third" type="checkbox"></td><td class="form_label"><label for="xbc924c98_SUB_Third">Third</label></td></tr></table></td></tr></table><table border="0" cellspacing="0" cellpadding="2"><tr><td align="left" colspan="3"><label for="x1c928694" class="form_label">Date field</label></td><td colspan="2"><select name="x1c928694_SUB_month"><option value="-1"></option><option value="1">Jan</option><option value="2">Feb</option><option value="3">Mar</option><option value="4">Apr</option><option value="5">May</option><option value="6">Jun</option><option value="7">Jul</option><option value="8">Aug</option><option value="9">Sep</option><option value="10">Oct</option><option value="11">Nov</option><option value="12">Dec</option></select> <select name="x1c928694_SUB_day"><option value="-1"></option><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option><option value="31">31</option></select>, <select name="x1c928694_SUB_year"><option value="-1"></option><option value="2012">2012</option><option value="2013">2013</option><option value="2014">2014</option><option value="2015">2015</option><option value="2016">2016</option><option value="2017">2017</option><option value="2018">2018</option><option value="2019">2019</option><option value="2020">2020</option><option value="2021">2021</option><option value="2022">2022</option></select></td></tr><tr valign="top"><td align="left" colspan="3"><label for="x53b9e9d5" class="form_label">File field</label></td><td colspan="2"><input name="x53b9e9d5" onChange="this.form.x53b9e9d5_RADIOS[2].checked=true" type="file" id="x53b9e9d5"></td></tr><tr><td colspan="2"><input value="123secret" name="xb85cded3" id="xb85cded3" type="hidden"></td></tr></table></form>