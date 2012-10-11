package HTML::DataForm::Field::CGI::File;
use base 'HTML::DataForm::Field::CGI::Text';

use HTML::FromArrayref;

sub valign { 'top' }

sub align_with { return 1 }

sub type { 'file' }

sub enctype { 'multipart/form-data' }

sub controls {
	my $me = shift;

	$me->{onChange} = "this.form.$me->{name}_RADIOS[2].checked=true";

	join ' ', grep $_,
		$me->{value} && HTML(
			[ input => { name => "$me->{name}_RADIOS", type => 'radio', value => 'KEEP', checked => 'y' } ],
			$me->{value},
			['br'],
			[ input => { name => "$me->{name}_RADIOS", type => 'radio', value => 'DELETE' } ],
			'None',
			['br'],
			[ input => { name => "$me->{name}_RADIOS", type => 'radio', value => 'REPLACE' } ],
			'Replace with ',
		),
		$me->SUPER::controls;
}

sub set_value_from_CGI_data {
	my ($me, $cgi_data) = @_;

	$me->{value} = delete $cgi_data->{ $me->{name} } if exists $cgi_data->{ $me->{name} };
	$me->{value} = '_DELETE' if $cgi_data->{ "$me->{name}_RADIOS" } eq 'DELETE';
}

1;