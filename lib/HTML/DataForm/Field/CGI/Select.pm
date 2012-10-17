package HTML::DataForm::Field::CGI::Select;
use base qw(
	HTML::DataForm::Field::CGI::Base
	HTML::DataForm::Field::CGI::Selectable
);

use HTML::FromArrayref qw(HTML :TAGS);

sub align_with { 2 }

sub multiple { undef }

sub is_selected {
	my ($me, $value) = @_;

	$value eq $me->{value};
}

sub controls {
	my $me = shift;

	my @options = $me->get_options;
	$me->{directions} ||= '- Select one -';

	my $is_multiple = $me->multiple;

	my $html = start_tag( select => { name => $me->{name}, id => $me->{id} || $me->{name}, multiple => $is_multiple, onChange => $me->{onChange} } );
	if ( not $is_multiple ) {
		if ( $me->{required} ) {
			$html .= HTML( [ option => { value => '' }, $me->{directions} || '- Select one -' ] );
		} else {
			$html .= HTML( [ 'option' ] );
		}
	}
	while ( my ($option, $value) = splice @options, 0, 2 ) {
		$html .= HTML(
			[ option => { value => $value, selected => ( $me->is_selected( $value ) or undef ) }, $option ]
		);
	}
	$html .= end_tag( 'select' );

	return $html;
}

sub display {
	my $me = shift;

	my @options = $me->get_options;
	while ( my ($option, $value) = splice @options, 0, 2 ) {
		return $option if $me->is_selected( $value );
	}
}

sub test {
	my ($me, $data) = @_;

	my %options = reverse $me->get_options;
	exists $options{$data};
}

sub message {
	my ($me, $data) = @_;

	"$data is not an option for field $me->{label}";
}

1;
