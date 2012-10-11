package HTML::DataForm::Field::DBI::Checkboxes;
use base qw(
	HTML::DataForm::Field::DBI::MultiplySelectable
	HTML::DataForm::Field::DBI::Base
	HTML::DataForm::Field::CGI::Checkboxes
);

sub set_value_from_DB_datum { # Why is DBI::Base in @ISA before DBI::MultiplySelectable?
	my ($me, $data) = @_;

	my @values = split "\n", $data;
	@{ $me->{value} }{ @values } = @values;

}

1;
