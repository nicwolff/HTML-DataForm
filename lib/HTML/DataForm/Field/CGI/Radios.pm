package HTML::DataForm::Field::CGI::Radios;
use base qw(
	HTML::DataForm::Field::CGI::Base
	HTML::DataForm::Field::CGI::Selectable
);


use HTML::FromArrayref;

sub align_with { 1 }

sub valign { 'top' }

sub set_value_from_CGI_data {
	my ($me, $data) = @_;

	$me->SUPER::set_value_from_CGI_data( $data );
	$me->{other_value} = $data->{ $me->{name} . '_SUB__other_value' };
}

sub controls {
	my $me = shift;
	
	my @options = $me->get_options;
	if ( $me->{other} ) { push @options, '_other', $me->{value} }
	my $name = $me->{name};
	
	my @items;
	while ( my ($item_label, $value) = splice @options, 0, 2 ) {
		my ($control_html, $label_html);
		if ( $item_label eq '_other' ) {
			my $ID = $name . '_SUB__other';
			my $n_items = $#items + 1;
			$control_html = HTML( 
				[ input => {
					type => 'radio', 
					name => $name, 
					ID => $ID, 
					value => '_other', 
					checked => ( $me->{value} eq '_other' or undef ) 
				} ] 
			);
			$label_html = HTML( 
				[ label => { for => $ID }, 'Other' ],
				' ',
				[ input => { name => $name . '_SUB__other_value', value => $me->{other_value}, onChange => "document.form.$name\[$n_items].checked=true" } ] 
			);
		} else {
			my $ID = $me->{name} . '_SUB_' . $value;
			$control_html = HTML( 
				[ input => { 
					type => 'radio', 
					name => $me->{name}, 
					ID => $ID, 
					value => $value, 
					checked => ( $me->{value} eq $value or undef ) 
				} ] 
			);
			$label_html = HTML( [ label => { for => $ID }, $item_label ] );
		}

		push @items, {
			at_right => "<td>$control_html</td><td class=form_label>$label_html</td>",
			at_left => "<td class=form_label>$label_html</td><td>$control_html</td>",
			right => "<td>$control_html</td><td class=form_label>$label_html</td>",
			left => "<td class=form_label>$label_html</td><td>$control_html</td>",
			above => "<td align=center class=form_label>$label_html<br>$control_html</td>",
			below => "<td align=center class=form_label>$control_html<br>$label_html</td>",
		}->{$me->{label_position} || 'right'};
	}

	my $html = $me->{item_columns} eq 'horizontally' ? 
		'<tr>' . join( '', @items ) . '</tr>' :
		join '', map "<tr>$_</tr>", @items;

	$html = qq(<table cellpadding=2 class="form_items">$html</table>);

	my $width = $me->{width} || '350px';
	my $height = $me->{height} || '200px';
	$html = qq(<div style="overflow: auto; width: $width; height: $height; border: 1px solid gray;">$html</div>) if $me->{scrolling};
	
	return $html;
}

1;
