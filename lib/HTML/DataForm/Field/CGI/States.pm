package HTML::DataForm::Field::CGI::States;
use base 'HTML::DataForm::Field::CGI::Select';

my @US_states = ( 
'Alaska' => 'AK',
'Alabama' => 'AL',
'Arkansas' => 'AR',
'Arizona' => 'AZ',
'California' => 'CA',
'Colorado' => 'CO',
'Connecticut' => 'CT',
'District of Columbia' => 'DC',
'Delaware' => 'DE',
'Florida' => 'FL',
'Georgia' => 'GA',
'Hawaii' => 'HI',
'Iowa' => 'IA',
'Idaho' => 'ID',
'Illinois' => 'IL',
'Indiana' => 'IN',
'Kansas' => 'KS',
'Kentucky' => 'KY',
'Louisiana' => 'LA',
'Massachusetts' => 'MA',
'Maryland' => 'MD',
'Maine' => 'ME',
'Michigan' => 'MI',
'Minnesota' => 'MN',
'Missouri' => 'MO',
'Mississippi' => 'MS',
'Montana' => 'MT',
'North Carolina' => 'NC',
'North Dakota' => 'ND',
'Nebraska' => 'NE',
'New Hampshire' => 'NH',
'New Jersey' => 'NJ',
'New Mexico' => 'NM',
'Nevada' => 'NV',
'New York' => 'NY',
'Ohio' => 'OH',
'Oklahoma' => 'OK',
'Oregon' => 'OR',
'Pennsylvania' => 'PA',
'Puerto Rico' => 'PR',
'Rhode Island' => 'RI',
'South Carolina' => 'SC',
'South Dakota' => 'SD',
'Tennessee' => 'TN',
'Texas' => 'TX',
'Utah' => 'UT',
'Virginia' => 'VA',
'Vermont' => 'VT',
'Washington' => 'WA',
'Wisconsin' => 'WI',
'West Virginia' => 'WV',
'Wyoming' => 'WY',
);

my @territories = (
	'American Samoa' => 'AS',
	'Federated States of Micronesia' => 'FM',
	'Guam' => 'GU',
	'Marshall Islands' => 'MH',
	'Northern Mariana Islands' => 'MP',
	'Palau' => 'PW',
	'Virgin Islands' => 'VI',
);

sub new {
	my $class = shift;
	
	my $me = $class->SUPER::new( @_ );
	$me->{pairs} = \@US_states;
	push @{$me->{pairs}}, @territories if $me->{territories};
	return $me;
}

1;
