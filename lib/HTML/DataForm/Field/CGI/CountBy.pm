package HTML::DataForm::Field::CGI::CountBy;
use base 'HTML::DataForm::Field::CGI::Select';

sub new {
        my $class = shift;

        my $me = $class->SUPER::new( @_ );
		for ($n=0; $n < $me->$count_to; $n++) {
			push @$me->{pairs}, {$n => $n} if $n % $me->{count_by};
		}
        return $me;
}

1;
