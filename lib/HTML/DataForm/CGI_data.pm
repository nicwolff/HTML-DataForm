package HTML::DataTable::CGIData;

sub get {
	my ($pkg) = @_;

	return bless get_cgi_data(), $pkg;
}

sub get_cgi_data {

	my ($qs, %data) = ('', ());

	if ( $ENV{REQUEST_METHOD} eq 'GET' ) {
		$qs = $ENV{QUERY_STRING};
	} else {
		read( STDIN, $qs, $ENV{CONTENT_LENGTH} );
	}

	for ( split '&', $qs || '' ) {
		tr/+/ /;
		my @p = split '=';
		map s/%([\dA-Fa-f][\dA-Fa-f])/pack 'C', hex($1)/eg, @p;
		if ( defined $data{$p[0]} ) { $data{$p[0]} .= "\0" }
		$data{$p[0]} .= $p[1];
	}

	warn join ', ', map "$_ = $data{$_}", keys %data if $CGI_data::debug;

	return \%data;

}

sub missing {
	my ($me, @list) = @_;

	grep ! $me->{$_}, @list;
}

\&get;
