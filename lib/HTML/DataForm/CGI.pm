package HTML::DataForm::CGI;
use base HTML::DataForm;

use HTML::FromArrayref;

sub print_page {
	my ($me, $body, $bad_fields) = @_;

	$body ||= $me->print_html( $bad_fields );

	# Print the HTML page header
	print qq(Content-type: text/html\n\n);

	if ( $me->{html_template} ) {
		my @html = split /PUT CONTENT HERE/, $me->{html_template};
		print $html[0], $body, $html[1];
	} elsif ( $me->{template} ) {
		open( TEMPLATEF, $me->{template} );
		while ( defined( my $line = <TEMPLATEF> ) ) {
			print $body if $line =~ /PUT CONTENT HERE/;
			$line =~ s/<field:([^>]+)>/$me->{$1}/g;
			print $line;
		}
		close TEMPLATEF;
	} else {
		my $title = join ' / ', grep $_, $me->{hed}, $me->{title};
		print HTML [ html =>
			[ head =>
				[ title => $title || 'Form' ],
				$me->{stylesheet} && [ link => { rel => 'StyleSheet', href => $me->{stylesheet}, type => 'text/css' } ],
				$me->{style} && [ style => $me->{style} ]
			],
			[ body => $body ]
		];
	}

}

1;