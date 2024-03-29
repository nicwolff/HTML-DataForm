package HTML::DataForm::Field::CGI::Selectable;

sub get_options {
	my ($me) = @_;

	my @options;

	unless ( @options = @{ $me->{pairs} } ) {
		if ( ref( $me->{list} ) eq 'ARRAY' ) {
			push( @options, $_, $_ ) for @{ $me->{list} };
		} else {
			my $sorter = $me->{sort_by_value} ?
				sub { lc $me->{list}->{$a} cmp lc $me->{list}->{$b} } :
				sub { lc $a cmp lc $b };
			push( @options, $_, $me->{list}->{$_} ) for sort $sorter keys %{ $me->{list} };
		}
	}

	if ( $me->{random} ) {
		my @random;
		srand;
		while ( @options ) { push @random, splice @options, int( rand( scalar $#options ) ) * 2, 2 };
		@options = @random;
	}

 	return @options;
}

1;