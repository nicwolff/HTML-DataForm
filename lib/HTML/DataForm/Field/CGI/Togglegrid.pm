package HTML::DataForm::Field::CGI::Togglegrid;
use base qw( 
        HTML::DataForm::Field::CGI::Base 
        HTML::DataForm::Field::CGI::MultiplySelectable 
);

use Angel::XHTML;
use Data::Dumper;

sub align_with { 4 }

sub valign { 'top' }

sub required { }

sub set_value_from_CGI_data {
        my ($me, $data) = @_;

        my $pattern = quotemeta( $me->{name} ) . '_SUB_(.*)';
        for ( keys %$data ) {
                if ( /$pattern/ ) {
                        $me->{value}->{$1} = delete $data->{$_};
        }       }
}

sub controls {
        my $me = shift;

        my @options = $me->get_options;
        warn Dumper \@options;
        if ( $me->{other} ) { push @options, '_other', $me->{value} }

        my @checkboxes;
        my $grid;
        my $gridrow = '1';

        while ( my ($item_label, $value) = splice @options, 0, 2 ) {

                my $gridcell;
                my $name = $me->{name};

                my ($control, $label);

                if ( $item_label eq '_other' ) {
                        my $ID = $name . '_SUB__other';
                        $control = xhtml( [ input => { type => 'checkbox', name => $ID, ID => $ID, checked => $me->{value}->{ '_other' } } ] );
                        $label = xhtml( 
                                [ label => { for => $ID }, 'Other' ], 
                                ' ', 
                                [ input => { name => $name . '_SUB__other_value', value => $me->{value}->{_other_value}, onChange => "document.form.$ID.checked=true" } ] 
                        );
                } else {
                        my $ID = $name . '_SUB_' . $value;
                        $control = xhtml( [ input => { type => 'checkbox', name => $ID, ID => $ID, checked => $me->{value}->{ $value } } ] );
                        $label = xhtml( [ label => { for => $ID }, $item_label ] );
                        if ( $me->{value}->{ $value } ){ $toggleclass = 'toggleon'; } else { $toggleclass = 'toggleoff';}
                        $gridcell = qq{<td class='$toggleclass' onClick="togglecell(this, '$ID');">$item_label</td>};

                }

                if ( $gridrow eq '1' ){
                        $grid .= '<tr>' . $gridcell;
                        $gridrow++;
                } elsif ( $gridrow eq $me->{limit} ){
                        $grid .= $gridcell . '</tr>';
                        $gridrow = '1';
                } else {
                        $grid .= $gridcell;
                        $gridrow++;
                }


                push @checkboxes, {
                        at_right => "<td>$control</td><td class=form_label>$label</td>",
                        at_left => "<td class=form_label>$label</td><td>$control</td>",
                        right => "<td>$control</td><td class=form_label>$label</td>",
                        left => "<td class=form_label>$label</td><td>$control</td>",
                        above => "<td align=center class=form_label>$label<br>$control</td>",
                        below => "<td align=center class=form_label>$control<br>$label</td>",
                }->{$me->{label_position} || 'right'};
        }

        my $html = $me->{item_columns} eq 'horizontally' ? 
                '<tr>' . join( '', @checkboxes ) . '</tr>' :
                join '', map "<tr>$_</tr>", @checkboxes;

        $html = qq(<table cellpadding="2" class="form_items">$html</table>);

        my $width = $me->{width} || '350px';
        my $height = $me->{height} || '200px';
        $html = qq(<div style="overflow: auto; width: 0; height: 0;">$html</div>);


        #check grid for lame last row.
        my $empties = ($me->{limit} - $gridrow + 1); # we incremented gridrow even with the  bum ending
        if ($grid !~ /tr>$/){
                $grid .= '<td></td>' x $empties;
                $grid .= '</tr>';
        }


        $grid = '<table class="togglegrid">' . $grid . '</table>';
        $html .= qq(<div>$grid</div>);
        return $html;

}

1;

#[slattery@va5 5.8.8]$ more /web/sites/fix.dev/Angel/Form/Field/CGI/Togglegrid.pm
