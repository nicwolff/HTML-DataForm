package HTML::DataForm::Field::CGI::Base;

use HTML::FromArrayref qw(HTML :TAGS);
use Data::Dumper;

sub new {
	my $class = shift;

	return bless { @_ } => $class;
}

sub valign { undef }
sub align_with { 'any' }
sub label_location { 'left' }
sub required { $_[0]->{required} }

sub set_value_to_default { $_[0]->{value} = $_[0]->{default} }

sub table_row {
	my $me = shift;

	my $html = start_tag( 'tr' => { valign => $me->valign } );

	$me->{label_colspan} = 1;

	# Print number
	if ( $me->{number} ) {
		$html .= HTML( $me->number );
	} else {
		$me->{label_colspan} += 1;
	}

	$me->{label_location} = 'above' if $me->{label_above};
	$me->{label_location} ||= $me->label_location;

	if ( $me->{label_location} eq 'left' ) {
		$html .= join '', $me->label_td, $me->controls_td;
	} elsif ( $me->{label_location} eq 'above' ) {
		$me->{label_colspan}++;
		$html .= join '', $me->label_td, end_tag('tr'), start_tag('tr'), $me->controls_td;
	} elsif ( $me->{label_location} eq 'right' ) {
		$html .= join '', $me->controls_td, $me->label_td;
	} elsif ( $me->{label_location} eq 'below' ) {
		$me->{label_colspan}++;
		$html .= join '', $me->controls_td, end_tag('tr'), start_tag('tr'), $me->label_td;
	}

	$html .= end_tag( 'tr' );

	# Print spacer row
	$html .= HTML( $me->space );

 	return $html;
}

sub label_td {
	my $me = shift;

	my $label = $me->label;
	HTML(
		$label &&
		[ td =>
			{
				colspan => $me->{label_colspan} + 1,
				align => $me->{label_align} || 'left',
				style => $me->{style}
			},
			$label
		]
	);
}

sub label {
	my $me = shift;

	[ label => { for => $me->{id} || $me->{name}, class => $me->{class} || 'form_label' },
		[ $me->{bold} && 'b', [ $me->{italic} && 'i', $me->{label} || $me->{name} ] ],
		$me->required && [
			font => { color => '#ff0000' }, ' ', $me->{required_footnote_mark} || '*'
		]
	]
}

sub controls_td {
	my $me = shift;

	HTML(
		[ td => { colspan => $me->{label_colspan}, style => $me->{style} },
			[[ $me->{display} ? $me->display : $me->controls ]]
		]
	);
}

sub display {
	my $me = shift;

	$me->{value};
}

sub number {
	my $me = shift;

	$number = ++$me->{_number};

	$number = [[ "&nbsp;&nbsp;$number" ]] if $number < 10;

	[ td => { align => 'right', class => 'form_label', valign => $me->valign },
		[ nobr =>
			[ $me->{bold} && 'b', [ $me->{italic} && 'i', $number ] ]
	]	]
}

sub space {
	my $me = shift;

	return undef unless defined $me->{spacing};

	[ 'tr' => [ td => { height => $me->{spacing}, colspan => 3 }, ' ', [ img => { src => "/icons/pixel-xparent.gif", width => 1, height => $me->{spacing} } ] ] ];
}

sub set_value_from_CGI_data {
	my ($me, $cgi_data) = @_;

	$me->{value} = delete $cgi_data->{ $me->{name} } if exists $cgi_data->{ $me->{name} };
	undef $me->{value} if ! ref $me->{value} and $me->{value} eq '';
	if ( $me->{trim} && $me->{value} ) { $me->{value} =~ s/^\s+//; $me->{value} =~ s/\s+$//; }
}

1;
