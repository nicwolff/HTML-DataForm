package HTML::DataForm::Field::CGI::Comment;
use base 'HTML::DataForm::Field::CGI::Base';

use HTML::FromArrayref;

sub align_with { 100 }
sub valign { 'top' }

sub table_row {
	my $me = shift;

	my $html = start_tag( 'tr' => { valign => $me->valign } );

	$me->{_label_colspan} = 1;

	# Print number	
	if ( $me->{number} ) {
		$html .= HTML( $me->number );
	} else {
		$me->{_label_colspan}++;
	}

	# Print comment	
	my $label = $me->label;
	$html .= HTML( 
		$label && 
		[ td => 
			{ 
				colspan => $me->{_label_colspan} + 2, 
				align => $me->{label_align} || 'left',
				style => $me->{style}
			}, 
			$me->label 
		]	
	);
	
	$html .= end_tag( 'tr' );	

	# Print spacer row	
	$html .= HTML( $me->space );
 	
 	return $html;
}

sub controls { }

1;
