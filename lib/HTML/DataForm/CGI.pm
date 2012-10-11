package HTML::DataForm::CGI;
use base HTML::DataForm;

sub print_page {
	my ($me, $text, $bad_fields) = @_;

	my ($bgcolor, @html, $line);

	$bgcolor = 'bgcolor=' . $me->{bgcolor} if $me->{bgcolor};

	# Print the HTML page header
	print qq(Content-type: text/html\n\n);

	if ( $me->{html_template} ) {
		@html = split /PUT CONTENT HERE/, $me->{html_template};
		print shift( @html );
	} elsif ( $me->{template} ) {
		open( TEMPLATEF, $me->{template} );
		while ( defined( $line = <TEMPLATEF> ) and $line !~ /PUT CONTENT HERE/ ) {
			$line =~ s/<field:([^>]+)>/$me->{$1}/g;
			print $line;
		}
	} else {
		my $title = join ' / ', grep $_, ( $me->{hed}, $me->{title} );
		print qq(<html><head><title>$title</title>);
		print qq(<link rel=StyleSheet href="$me->{stylesheet}" type="text/css">)
			if $me->{stylesheet};
		print qq(<style>$me->{style}</style>) if $me->{style};
		print qq(</head><body $bgcolor>);
	}

	# Print the form
	if ( $text ) {
		print $text;
	} else {
		$me->print_html( $bad_fields );
	}

	# Print the HTML page footer
	if ( $me->{html_template} ) {
		print shift( @html );
	} elsif ( $me->{template} ) {
		while ( $line = <TEMPLATEF> ) {
			$line =~ s/<field:([^>]+)>/$me->{$1}/g;
			print $line;
		}
		close TEMPLATEF;
	} else {
		print q(</body></html>);
	}
}

1;