package HTML::DataForm::Field::CGI::Checkboxes;
use base qw(
	HTML::DataForm::Field::CGI::Base
	HTML::DataForm::Field::CGI::MultiplySelectable
);

use Angel::XHTML;

sub align_with { 4 }

sub valign { 'top' }

sub required { }

sub set_value_from_CGI_data {
	my ($me, $data) = @_;

	my $pattern = quotemeta( $me->{name} ) . '_SUB_(.*)';
	for ( keys %$data ) {
		if ( /$pattern/ ) {
			if ( $me->{column} ) {
				$me->{value} .= "\n" if $me->{value};
				$me->{value} .= $1;
				delete $data->{$_};
			} else {
				$me->{value}->{$1} = delete $data->{$_};
			}
		}
	}
}

sub controls {
	my $me = shift;

	my @options = $me->get_options;
	if ( $me->{other} ) { push @options, '_other', $me->{value} }

	my @checkboxes;

	while ( my ($item_label, $value) = splice @options, 0, 2 ) {

		my ($control, $label);

		my $name = $me->{name};

		if ( $item_label eq '_other' ) {

			my $ID = $name . '_SUB__other';
			$control = [ input => {
				type => 'checkbox', name => $ID, ID => $ID,
				checked => $me->{_all_checked} || $me->{value}->{ '_other' }
			} ];
			$label = [ label => { for => $ID }, 'Other' ], ' ',
				[ input => {
					name => $name . '_SUB__other_value',
					value => $me->{value}->{_other_value},
					onChange => "document.form.$ID.checked=true" }
				];

		} else {

			my $ID = $name . '_SUB_' . $value;
			$control = [ input => {
				type => 'checkbox', name => $ID, ID => $ID,
				checked => $me->{_all_checked} || $me->{value}->{ $value } }
			];
			$label = [ label => { for => $ID }, $item_label ];

		}

		push @checkboxes, {
			right => [ [ td => $control ], [ td => { class => 'form_label' }, $label ] ],
			left => [ [ td => { class => 'form_label' }, $label ], [ td => $control ] ],
			above => [ [ td => { align => 'center', class => 'form_label' }, $label, ['br'], $control ] ],
			below => [ [ td => { align => 'center', class => 'form_label' }, $control, ['br'], $label ] ],
		}->{$me->{label_position} || 'right'};

	}

	my $width = $me->{width} || '350px';
	my $height = $me->{height} || '200px';

	return xhtml [ $me->{scrolling} && 'div' =>
		{
			style => "overflow: auto; width: $width; height: $height; border: 1px solid gray;",
			class => 'checkboxes_scroller'
		},
		[ table => { cellpadding => 2, class => 'form_items' },
			$me->{item_columns} eq 'horizontally' ? [ tr => map @$_, @checkboxes ] : map [ tr => @$_ ], @checkboxes
		]
	];

}

1;
