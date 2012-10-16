package HTML::DataForm;

use 5.006;
use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use Encode qw(encode_utf8);
use HTML::FromArrayref qw(HTML start_tag end_tag);
use Data::Dumper;

use overload q{""} => \&html;

=head1 NAME

HTML::DataForm - Render and process HTML forms

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use HTML::DataForm;

    my $foo = HTML::DataForm->new();
    ...

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub show {
	my ($class, %attribs) = @_;

	$class->new( %attribs )->go;
}


sub new {
	my ($class, %attribs) = @_;

	my $me = bless \%attribs => $class;

	$me->{data} = (require HTML::DataForm::CGIData)->() unless defined $me->{data};

	# Three ways to define a form's key field:
	# 1. a scalar names both the CGI parameter and the key in the record
	# 2. an arrayref lists multiple such names
	# 3. a hashref associates pairs of CGI parameter names and record field keys
	if ( $me->{key} and ! ref $me->{key} ) {
		$me->{key} = [ $me->{key} ];
	}
	if ( ref( my $old_key = $me->{key} ) eq 'ARRAY' ) {
		delete $me->{key};
		map $me->{key}->{$_} = $_, @$old_key;
	}

	# Bless the fields into the appropriate subclasses of Field
	my $i = 0;
	for ( @{$me->{fields}} ) {
		$_->{_index} = $i++;
		$me->make_Field( $_ );
	}

	# If we're rendering the form rather than processing it, set
	# the values of any fields that have default values
	if (
		! $me->{_processing} and
		$me->{data}->{_new_record} = $me->key_fields_with_no_CGI_data
	) {
		for ( @{$me->{fields}} ) {
			$_->set_value_to_default() if exists $_->{default};
		}
	}

	local $ENV{PATH} = undef;
	$me->{_checksum_secret} ||= `/usr/bin/uname -a`;

	return $me;
}

sub make_Field {
	my ($me, $field) = @_;

	# Make the field hash into an object
	$me->bless_field( $field );

	# Each field's name is a unique hash of its label and index
	$field->{label} ||= $field->{name};
	$field->{name} ||= $field->{label};
	$field->{name} = 'x' . substr( md5_hex( encode_utf8("$field->{name}$field->{_index}") ), 0, 8 )
			unless $field->{name} =~ /^_/;

	# Default field attributes set on form
	for ( keys %{$me->{field_defaults}} ) {
		$field->{$_} = $me->{field_defaults}->{$_} unless defined $field->{$_};
	}

	# Notice if there are any required fields
	$me->{_required}++ if $field->required;

	# If there are any "file" fields, set the form's enctype
	$me->{enctype} = $field->enctype if $field->can('enctype');

	# Let each field get its value from the CGI data
	$field->set_value_from_CGI_data( $me->{data} );

	# If a Submit field has data, then the form was submitted and
	# we set the form's 'processing' attribute to refer to that field.
	if ( $field->isa('HTML::DataForm::Field::CGI::Submit') and $field->{value} ) {
		$me->{_processing} = $field;
	}

	$me->{field_by_name}->{$field->{name}} = $field;
	$me->{field_by_label}->{$field->{label}} = $field;

	return $field;
}


sub bless_field {
	my ($me, $field) = @_;

	# OK, this ain't easy. The goal is that each subclass of this one can have a
	# matching directory under Fields containing field classes, which presumably
	# subclass those in Field/CGI. But, if any are missing, we want to use the
	# respective base classes from Field/CGI. So...

	( my $type = ucfirst( delete $field->{type} || 'text' ) ) =~ s/[^\w\d_]//;

	my @class = split '::', ref $me;

	for my $which ( pop @class, 'CGI' ) {
		my $field_class = join '::', @class, 'Field', $which, $type;
		if ( eval "require $field_class" ) {
			bless $field, $field_class;
			last;
		} else {
			warn "$! while trying to make a Field of ${which}::$type" if $which eq 'CGI';
		}
	}

	return $field;
}

sub make_field { # For legacy compatability - this is what make_field used to do
	my ($me, %field) = @_;
	$me->bless_field( \%field );
}

sub key_fields_with_no_CGI_data {
	my $me = shift;
	my $table = shift || $me;

	return undef unless $table->{key};
	grep { ! exists $me->{data}->{ $_ } } keys %{$table->{key}};
}

sub field_by_label {
	my ($me, $label) = @_;

	return $me->{field_by_label} || $me->make_Field( type => 'spacer' );
}

sub go {
	my $me = shift;

	# Either print the form, or process it and print the result.
	if ( $me->{_processing} ) {

		$me->print_results();

	} else {

		# Stick the referer into a hidden field so we can go back
		# after processing the form
		$me->{data}->{_referer} = $ENV{HTTP_REFERER};

		# Print the page
		$me->print_page();
}	}


sub print_html {
	my ($me, $bad_fields) = @_;

	print $me->html( $bad_fields );
}


sub html {
	my ($me, $bad_fields) = @_;

	my $html;

	# Stick the referer into a hidden field so we can go back
	# after processing the form
	$me->{data}->{_referer} ||= $ENV{HTTP_REFERER};

	my $required_footnote_mark = $me->{required_footnote_mark} || '*';
	my $required_footnote_text = $me->{required_footnote_text} ||
		qq(<font color="#ff0000">$required_footnote_mark</font> Required);
	my $required_footnote_location = $me->{required_footnote_location} || 'bottom';

	$html .= qq(<p class="hed">$me->{hed}</p>) if $me->{hed};

	if ( $me->{title} ) {
		$me->{title} =~ s/{([^}]+)}/$me->{data}->{$1}/g;
		$html .= qq(<p>$me->{title});
		$html .= " ($required_footnote_text)" if $me->{_required} and $required_footnote_location eq 'title';
		$html .= qq(</p>);
	}

	$html .= qq(<p>$required_footnote_text</p>) if $me->{_required} and $required_footnote_location eq 'top';

	$html .= $me->error_message( %$bad_fields );

	$html .= $me->form_start;

	# Get the stored record if we have the key
	if ( $me->{key} and ! $me->{data}->{_new_record} and ! %$bad_fields ) {
		$me->get_record();
	}

	# Add a hidden field to hold the checksum of the hidden fields
	$me->{data}->{_HFchecksum} = MD5->hexhash(
		join '',
			$me->{_checksum_secret},
			map $_->{value},
				grep { $_->isa('HTML::DataForm::Field::CGI::Hidden') } @{$me->{fields}}
	);

	# Add extra hidden fields to pass along any remaining CGI data
	for my $key ( keys %{$me->{data}} ) {
		my $hidden_field = { type => 'hidden', name => $key, value => $me->{data}->{$key} };
		$me->bless_field( $hidden_field );
		$html .= $hidden_field->controls;
	}

	$html .= my $table_start_tag = start_tag( table => {
		border => $me->{table_border} || '0',
		cellpadding => $me->{cellpadding} || '2',
		cellspacing => $me->{cellspacing} || '0'
	} );

	# Tell each field to print itself
	my $prev_align;
	for my $field ( @{ $me->{fields} } ) {

		next if ( $field->{edit_only} || $field->{display} ) && $me->{data}->{_new_record};
		next if ( $field->{new_record_only} ) && ! $me->{data}->{_new_record};

		my $align_with = $field->align_with;
		if (
			$prev_align ne $align_with and
			$field->{align_with_previous} !~ /y/i or
			$field->{align_with_previous} =~ /n/i
		) {
			my $width = $align_with == 100 ? 'width="100%"' : '';
			$html .= end_tag( 'table' ) . $table_start_tag;
		}

		$field->{required_footnote_mark} = ' ' if $me->{required_footnote_location} eq 'none';

		$html .= $field->table_row;

		$prev_align = $align_with;

	}

	$html .= end_tag( 'table' ) . end_tag( 'form' );

	$html .= qq(<p>$required_footnote_text</p>) if $me->{_required} and $required_footnote_location eq 'bottom';

	return $html;
}


sub get_record {
	my $me = shift;

	# Called only when the key fields are all in the CGI data
	# Overload to populate the form from the data store

	map $_->{value} = $me->{record}->{ $_->{name} }, @{$me->{fields}};
}


sub form_start {
	my $me = shift;

	my $html = start_tag( form => {
		name => 'form',
		id => 'form',
		action => $me->{action} || ( split( /[\/\\]/, $0 ) )[-1],
		method => $me->{method} || 'POST',
		'accept-charset' => $me->{accept_charset} || 'UTF-8',
		enctype => $me->{enctype}
	} );

	return $html;
}


sub error_message {
	my ($me, %bad_fields) = @_;

	return unless $me->{_processing} && %bad_fields;

	# Format the list of missing fields for printing.

	my @messages;

	for ( @{$me->{fields}} ) {
		if ( my $format = delete $bad_fields{ $_->{name} } ) {
			push @messages, sprintf $format, $_->{label};
		}
	}

	push @messages, keys %bad_fields;

	return xhtml( [ font => { color => 'red' }, [ p => 'Please correct these errors:' ], [ ul => map [ li => [ b => $_ ] ], @messages ] ] );
}


sub fields {
	my $me = shift;

	map $me->{field_by_label}->{$_}->table_row, @_;
}

#########################
# Handle submitted form


sub print_results {
	my $me = shift;

	# Check to see if any required fields are missing; if so, print the
	# form again with an error message. If not, process the submitted data
	# as indicated by the button pressed and print the success page.

	my $procname = 'process_' . lc $me->{_processing}->{process} || $me->{_processing}->{label};

	if (
		$procname eq 'process_save' and
		my %bad = $me->check() and
		not exists $me->{data}->{partial_save_ok}
	) {

		$me->print_page( undef, \%bad );

	} else {

		# Should really test defined( $procname ) here...

		$me->{_processing}->{pre_process}->( $me )
			if ref $me->{_processing}->{pre_process} eq 'CODE';

		my $result = $me->$procname();

		$me->{_processing}->{post_process}->( $me )
			if ref $me->{_processing}->{post_process} eq 'CODE';

		if ( $result ) {
			# A button handler can return an arbitrary page or redirect...
			print $result;
		} else {
			# Or else we go back where we came from, or someplace else good.
			if ( $me->{error} ) {
				$me->print_page( $me->{error} );
			} elsif ( $me->{success_text} ||= $me->{_processing}->{success_text} ) {
				$me->print_page( $me->{success_text} );
			} elsif ( $me->{success} ||= $me->{_processing}->{success} ) {
				$me->redirect( $me->{success} );
			} elsif ( $me->{data}->{_referer} ) {
				$me->redirect( $me->{data}->{_referer} );
			} else {
				$me->print_page( 'Form processed' );
			}
		}

	}
}


sub process_save {
	my $me = shift;

	# This is a dummy test handler for the "Save" button

	return undef;
}

sub process_cancel {
	my $me = shift;

	return undef;
}

sub redirect {
	my ($me, $url) = @_;

	if ( $me->{pass_data} and $me->{data}->{$me->{key_field}} ) {
		if ( $url =~ /\?/ ) {
			$url .= '&';
		} else {
			$url .= '?';
		}
		$url .= "$me->{key_field}=$me->{data}->{$me->{key_field}}";
	}
	print qq(Location: $url\n\n);
}


sub check {
	my $me = shift;

	return if $me->{_processing}->can('skip_check') and $me->{_processing}->skip_check;

	my %bad_fields;

	my %tests = (
		e_mail => [
			sub {
				require Email::Valid; Email::Valid->address( shift );
			} => '%s is incorrectly formatted'
		],
		zip5 => [ qr/^\d{5}$/ => '%s must be five digits' ],
		ssn => [ qr/^\d{3}-\d\d-\d{4}$/ => '%s must be in the format NNN-NN-NNNN' ],
		no_html => [
			sub {
				require HTML::CGIChecker;
				(( new HTML::CGIChecker mode => 'allow', allowtags => [] )->checkHTML( shift ))[0];
			} => '%s does not allow HTML'
		],
		safe_html => [
			sub {
				require HTML::CGIChecker;
				my ($data, $message_ref) = @_;
				my ($html, $error) = ( new HTML::CGIChecker
					mode => 'allow',
					allowclasses => [ 'tables', 'lists', 'heading' ],
					allowtags => [qw( b i a u strong em font p br hr img )]
				)->checkHTML( $data );
				$$message_ref = '%s has HTML errors: ' . join '; ', map substr( $_, 0, -1 ), @$error;
				$html;
			} => '%s contains illegal HTML'
		],
	);

	my @hidden_values;

	for my $field ( @{ $me->{fields} } ) {

		my $data = $field->{value};

		# If the field is required, does it have data?
		if ( $field->required and ! length $data ) {
			$bad_fields{ $field->{name} } = '%s is a required field';
		}

		push @hidden_values, $data if $field->isa('HTML::DataForm::Field::CGI::Hidden') and $field->{name} ne '_HFchecksum';

		next unless length $data;

		# Is field value supposed to be unique?
		if ( $field->{unique} and $me->can('test_unique') and ! $me->test_unique( $field ) ) {
			$bad_fields{ $field->{name} } = qq(%s "$field->{value}" is already taken);
		}

		# If $field->{test} is a scalar, is it the name of one of the predefined tests?
		if ( $field->{test} and ! ref $field->{test} ) { $field->{test} = $tests{$field->{test}} }

		my $message;

		# If $field->{test} is an array ref, then it sets its own message
		if ( ref $field->{test} eq 'ARRAY' ) { ($field->{test}, $message) = @{$field->{test}} }

		# If the test is a regex, does it match?
		if ( ref $field->{test} eq 'REGEXP' and $data !~ $field->{test} ) {
			$bad_fields{ $field->{name} } = $message || '%s is incorrectly formatted';
		}

		# If the test is a subroutine, does it return non-false?
		if ( ref $field->{test} eq 'CODE' and ! $field->{test}->( $data, \$message ) ) {
			$bad_fields{ $field->{name} } = $message || '%s has an illegal value';
		}

		# If the field class has its own generic test method, does it return non-false?
		if ( $field->can('test') and ! $field->test( $data ) ) {
			$bad_fields{ $field->{name} } = ( $field->can('message') and $field->message )
				|| '%s has an illegal value';
		}

	}

	if (
		! $me->{allow_hidden_field_changes} and
		MD5->hexhash( join '', $me->{_checksum_secret}, @hidden_values ) ne $me->{data}->{_HFchecksum}
	) {
		$bad_fields{ 'Hidden fields were changed' }++;
	}

	return %bad_fields;
}

=head1 AUTHOR

Nic Wolff, C<< <nic at angel.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-html-dataform at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-DataForm>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HTML::DataForm


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=HTML-DataForm>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HTML-DataForm>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HTML-DataForm>

=item * Search CPAN

L<http://search.cpan.org/dist/HTML-DataForm/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Nic Wolff.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

\&new; # End of HTML::DataForm