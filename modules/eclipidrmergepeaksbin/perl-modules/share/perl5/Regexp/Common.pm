package Regexp::Common;

$VERSION = '0.01';

sub new {
	my ($class, @data) = @_;
	my %self;
	tie %self, $class, @data;
	return \%self;
}

sub TIEHASH {
	my ($class, @data) = @_;
	bless \@data, $class;
}

sub FETCH {
	my ($self, $extra) = @_;
	return bless ref($self)->new(@$self, $extra), ref($self);
}

use Carp;
use vars '$AUTOLOAD';
sub AUTOLOAD { croak "Can't $AUTOLOAD" }

sub DESTROY {}

my %cache;

my $fpat = qr/^(-\w+)/;

sub _decache {
	my @args = @{tied %{$_[0]}};
	my @nonflags = grep {!/$fpat/} @args;
	my $cache = get_cache(@nonflags);
	croak "Can't create unknown regex: \$RE{"
	    . join("}{",@args) . "}"
		unless exists $cache->{__VAL__};
	croak "Perl $] does not support the pattern "
	    . "\$RE{" . join("}{",@args)
	    . "}.\nYou need Perl $cache->{__VAL__}{version} or later"
		unless ($cache->{__VAL__}{version}||0) <= $];
	my %flags = ( %{$cache->{__VAL__}{default}},
		      map { /$fpat=(.+)/ ? ($1 => $2)
			  : /$fpat/      ? ($1 => undef)
			  :                ()
			  } @args);
	$cache->{__VAL__}->_clone_with(\@args, \%flags);
}

use overload q{""} => \&_decache;

use vars '%RE';

sub import {
	tie %RE, __PACKAGE__;
	*{ caller() . "::RE" } = \%RE;
	*{ caller() . "::pattern" } = \&pattern if grep /^pattern$/, @_;
	$; = "=" unless grep /^clean$/, @_;
	if (grep /^RE_ALL$/, @_) {
		foreach (keys %sub_interface) {
			*{ caller() . "::$_" } = $sub_interface{$_};
		}
	}
	else {
		foreach (@_[1..$#_]) {
			croak "Can't export unknown subroutine &$_"
				unless $sub_interface{$_};
			*{ caller() . "::$_" } = $sub_interface{$_};
		}
	}

}

sub get_cache {
	my $cache = \%cache;
	foreach (@_) {
		$cache = $cache->{$_}
		      || ($cache->{$_} = {});
	}
	return $cache;
}

sub croak_version {
	my ($entry, @args) = @_;
}

sub pattern {
	my %spec = @_;
	croak 'pattern() requires argument: name => [ @list ]'
		unless $spec{name} && ref $spec{name} eq 'ARRAY';
	croak 'pattern() requires argument: create => $sub_ref_or_string'
		unless $spec{create};

	if (ref $spec{create} ne "CODE") {
		my $fixed_str = "$spec{create}";
		$spec{create} = sub { $fixed_str }
	}

	my @nonflags;
	my %default;
	foreach ( @{$spec{name}} ) {
		if (/$fpat=(.*)/) {
			$default{$1} = $2;
		}
		elsif (/$fpat\s*$/) {
			$default{$1} = undef;
		}
		else {
			push @nonflags, $_;
		}
	}

	my $entry = get_cache(@nonflags);

	if ($entry->{__VAL__}) {
		carp "Overriding \$RE{"
		   . join("}{",@nonflags)
		   . "}";
	}

	$entry->{__VAL__} = bless {
				create  => $spec{create},
				match   => $spec{match} || \&generic_match,
				subs    => $spec{subs}  || \&generic_subs,
				version => $spec{version},
				default => \%default,
		            }, 'Regexp::Common::Entry';

	foreach (@nonflags) { s/\W/X/g }
	my $subname = "RE_".join("_",@nonflags);
	$sub_interface{$subname} = sub {
		my %flags = @_;
		my $pat = $spec{create}->($entry->{__VAL__}, {%default, %flags}, \@non_flags);
		if (exists $flags{-keep}) { $pat =~ s/\Q(?k:/(/g; }
		else { $pat =~ s/\Q(?k:/(?:/g; }
		return qr/$pat/;
	};

	return 1;
}

sub generic_match { $_[0] =~ /$_[1]/ }
sub generic_subs  { $_[0] =~ s/$_[1]/$_[2]/ }

sub matches {
	my ($self, $str) = @_;
	my $entry = $self->_decache;
	$entry->{match}->($entry,$str);
}

sub subs {
	my ($self, $str, $newstr) = @_;
	my $entry = $self->_decache;
	$entry->{subs}->($entry, $str, $newstr);
	return $str;
}

package Regexp::Common::Entry;
use Carp;

use overload
	q{""} => sub {
			my ($self) = @_;
			my $pat = $self->{create}->($self, $self->{flags}, $self->{args});
			if (exists $self->{flags}{-keep}) {
				$pat =~ s/\Q(?k:/(/g;
			}
			else {
				$pat =~ s/\Q(?k:/(?:/g;
			}
			return $pat;
		 };

sub _clone_with {
	my ($self, $args, $flags) = @_;
	bless { %$self, args=>$args, flags=>$flags },
	      ref $self;
}

=pod

=head1 NAME

Regexp::Common - Provide commonly requested regular expressions


=head1 SYNOPSIS

 # STANDARD USAGE 

 use Regexp::Common;

 while (<>) {
	/$RE{num}{real}/ 		and print q{a number\n};
	/$RE{quoted}			and print q{a ['"`] quoted string\n};
	/$RE{delimited}{-delim=>'/'}/	and print q{a /.../ sequence\n};
	/$RE{balanced}{-parens=>'()'}/	and print q{balanced parentheses\n};
	/$RE{profanity}/ 		and print q{a #*@%-ing word\n};
 }


 # SUBROUTINE-BASED INTERFACE

 use Regexp::Common 'RE';

 while (<>) {
	$_ =~ RE_num_real() 		 and print q{a number\n};
	$_ =~ RE_quoted()		 and print q{a ['"`] quoted string\n};
	$_ =~ RE_delimited(-delim=>'/')	 and print q{a /.../ sequence\n};
	$_ =~ RE_balanced(-parens=>'()'} and print q{balanced parentheses\n};
	$_ =~ RE_profanity() 		 and print q{a #*@%-ing word\n};
 }


 # IN-LINE MATCHING...

 if ( $RE{num}{int}->matches($text} ) {...}


 # ...AND SUBSTITUTION

 my $cropped = $RE{ws}{crop}->subs($uncropped);


 # ROLL-YOUR-OWN PATTERNS

 use Regexp::Common 'pattern';

 pattern name   => ['name', 'mine'],
	 create => '(?i:J[.]?\s+A[.]?\s+Perl-Hacker)',
	 ;

 my $name_matcher = $RE{name}{mine};

 pattern name    => [ 'lineof', '-char=_' ],
	 create  => sub {
			my $flags = shift;
			my $char = quotemeta $flags->{-char};
			return '(?:^$char+$)';
		    },
	 matches => sub {
    			my ($self, $str) = @_;
    			return $str !~ /[^$self->{flags}{-char}]/;
		    },
	 subs   => sub {
			my ($self, $str, $replacement) = @_;
			$_[1] =~ s/^$self->{flags}{-char}+$//g;
		   },
	 ;

 my $asterisks = $RE{lineof}{-char=>'*'};


=head1 DESCRIPTION

By default, this module exports a single hash (C<%RE>) that stores or generates
commonly needed regular expressions (see L<"List of available patterns">).

There is an alternative, subroutine-based syntax described in
L<"Subroutine-based interface">.


=head2 General syntax for requesting patterns

To access a particular pattern, C<%RE> is treated as a hierarchical hash of
hashes (of hashes...), with each successive key being an identifier. For
example, to access the pattern that matches real numbers, you 
specify:

	$RE{num}{real}
	
and to access the pattern that matches integers: 

	$RE{num}{int}

Deeper layers of the hash are used to specify I<flags>: arguments that
modify the resulting pattern in some way. The keys used to access these
layers are prefixed with a minus sign and may include a value that is
introduced by an equality sign. For example, to access the pattern that
matches base-2 real numbers with embedded commas separating
groups of three digits (e.g. 10,101,110.110101101):

        $RE{num}{real}{'-base=2'}{'-sep=,'}{'-group=3'}

Through the magic of Perl, these flag layers may be specified in any order
(and even interspersed through the identifier keys!)
so you could get the same pattern with:

        $RE{num}{real}{'-sep=,'}{'-group=3'}{'-base=2'}

or:

        $RE{num}{'-base=2'}{real}{'-group=3'}{'-sep=,'}

or even:

        $RE{'-base=2'}{'-group=3'}{'-sep=,'}{num}{real}

etc.

Note, however, that the relative order of amongst the identifier keys
I<is> significant. That is:

        $RE{list}{set}

would not be the same as:

        $RE{set}{list}


=head2 Alternative flag syntax

As the examples in the previous section indicate, the syntax for
specifying flags is somewhat cumbersome, because of the need to quote
the entire (non-identifier) key-plus-value. To make such specifications
less ugly, Regexp::Common permanently changes the value of the magical
C<$;> variable (setting it to the character C<'='>), so that flags can
also be specified like so:

        $RE{num}{real}{-base=>2}{-group=>3}{-sep=>','}

This syntax is preferred, and is used throughout the rest of this document.

In the unlikely case that the non-standard value of C<$;> breaks your
program, this behaviour can be disabled by importing the module as:

        use Regexp::Common 'clean';


=head2 Universal flags

Normally, flags are specific to a single pattern.
However, there is one flag that all patterns may specify.

By default, the patterns provided by C<%RE> contain no capturing
parentheses. However, if the C<-keep> flag is specified (it requires
no value) then any significant substrings that the pattern matches
are captured. For example:

        if ($str =~ $RE{num}{real}{-keep}) {
                $number   = $1;
                $whole    = $3;
                $decimals = $5;
        }

Special care is needed if a "kept" pattern is interpolated into a
larger regular expression, as the presence of other capturing
parentheses is likely to change the "number variables" into which significant
substrings are saved.

See also L<"Adding new regular expressions">, which describes how to create
new patterns with "optional" capturing brackets that respond to C<-keep>.


=head2 OO interface and inline matching/substitution

The patterns returned from C<%RE> are objects, so rather than writing:

        if ($str =~ /$RE{some}{pattern}/ ) {...}

you can write:

        if ( $RE{some}{pattern}->matches($str) ) {...}

For matching this would seem to have no great advantage apart from readability
(but see below).

For substitutions, it has other significant benefits. Frequently you want to
perform a substitution on a string without changing the original. Most people
use this:

        $changed = $original;
        $changed =~ s/$RE{some}{pattern}/$replacement/;

The more adept use:

        ($changed = $original) =~ s/$RE{some}{pattern}/$replacement/;

Regexp::Common allows you do write this:

        $changed = $RE{some}{pattern}->subs($original=>$replacement);

Apart from reducing precedence-angst, this approach has the daded
advantages that the substitution behaviour can be optimized fro the 
regular expression, and the replacement string can be provided by
default (see L<"Adding new regular expressions">).

For example, in the implementation of this substitution:

        $cropped = $RE{ws}{crop}->subs($uncropped);

the default empty string is provided automatically, and the substitution is
optimized to use:

        $uncropped =~ s/^\s+//;
        $uncropped =~ s/\s+$//;

rather than:

        $uncropped =~ s/^\s+|\s+$//g;


=head2 Subroutine-based interface

The hash-based interface was chosen because it allows regexes to be
effortlessly interpolated, and because it also allows them to be
"curried". For example:

        my $num = $RE{num}{int};

        my $comma'd    = $num->{-sep=>','}{-group=>3};
        my $duodecimal = $num->{-base=>12};


However, the use of tied hashes does make the access to Regexp::Common
patterns slower than it might otherwise be. In contexts where impatience
overrules laziness, Regexp::Common provides an additional
subroutine-based interface.

For each (sub-)entry in the C<%RE> hash (C<$RE{key1}{key2}{etc}>), there
is a corresponding exportable subroutine: C<RE_key1_key2_etc()>. The name of
each subroutine is the underscore-separated concatenation of the I<non-flag>
keys that locate the same pattern in C<%RE>. Flags are passed to the subroutine
in its argument list. Thus:

        use Regexp::Common qw( RE_ws_crop RE_num_real RE_profanity );

        $str =~ RE_ws_crop() and die "Surrounded by whitespace";

        $str =~ RE_num_real(-base=>8, -sep=>" ") or next;

        $offensive = RE_profanity(-keep);
        $str =~ s/$offensive/$bad{$1}++; "<expletive deleted>"/ge;

Note that, unlike the hash-based interface (which returns objects), these
subroutines return ordinary C<qr>'d regular expressions. Hence they do not
curry, nor do they provide the OO match and substitution inlining described
in the previous section.

It is also possible to export subroutines for all available patterns like so:

        use Regexp::Common 'RE_ALL';


=head2 Adding new regular expressions

You can add your own regular expressions to the C<%RE> hash at run-time,
using the exportable C<pattern> subroutine. It expects a hash-like list of 
key/value pairs that specify the behaviour of the pattern. The various
possible argument pairs are:

=over 4

=item C<name =E<gt> [ @list ]>

A required argument that specifies the name of the pattern, and any
flags it may take, via a reference to a list of strings. For example:

         pattern name => [qw( line of -char )],
                 # other args here
                 ;

This specifies an entry C<$RE{line}{of}>, which may take a C<-char> flag.

Flags may also be specified with a default value, which is then used whenever
the flag is omitted, or specified without an explicit value. For example:

         pattern name => [qw( line of -char=_ )],
                 # default char is '_'
                 # other args here
                 ;


=item C<create =E<gt> $sub_ref_or_string>

A required argument that specifies either a string that is to be returned
as the pattern:

        pattern name    => [qw( line of underscores )],
                create  => q/(?:^_+$)/
                ;

or a reference to a subroutine that will be called to create the pattern:

        pattern name    => [qw( line of -char=_ )],
                create  => sub {
                                my ($self, $flags) = @_;
                                my $char = quotemeta $flags->{-char};
                                return '(?:^$char+$)';
                            },
                ;

If the subroutine version is used, the subroutine will be called with 
three arguments: a reference to the pattern object itself, a reference
to a hash containing the flags and their values,
and a reference to an array containing the non-flag keys. 

Whatever the subroutine returns is stringified as the pattern.

No matter how the pattern is created, it is immediately postprocessed to
include or exclude capturing parentheses (according to the value of the
C<-keep> flag). To specify such "optional" capturing parentheses within
the regular expression associated with C<create>, use the notation
C<(?k:...)>. Any parentheses of this type will be converted to C<(...)>
when the C<-keep> flag is specified, or C<(?:...)> when it is not.
It is a Regexp::Common convention that the outermost capturing parentheses
always capture the entire pattern, but this is not enforced.


=item C<matches =E<gt> $sub_ref>

An optional argument that specifies a subroutine that is to be called when
the C<$RE{...}-E<gt>matches(...)> method of this pattern is invoked.

The subroutine should expect two arguments: a reference to the pattern object
itself, and the string to be matched against.

It should return the same types of values as a C<m/.../> does.

        pattern name    => [qw( line of -char )],
                create  => sub {...},
                matches => sub {
                                my ($self, $str) = @_;
                                return $str !~ /[^$self->{flags}{-char}]/;
                           },
                ;


=item C<subs =E<gt> $sub_ref>

An optional argument that specifies a subroutine that is to be called when
the C<$RE{...}-E<gt>subs(...)> method of this pattern is invoked.

The subroutine should expect three arguments: a reference to the pattern object
itself, the string to be changed, and the value to be substituted into it.
The third argument may be C<undef>, indicating the default substitution is
required.

The subroutine should return the same types of values as an C<s/.../.../> does.

For example:

        pattern name    => [ 'lineof', '-char=_' ],
                create  => sub {...},
                subs   => sub {
                                my ($self, $str, $ignore_replacement) = @_;
                                $_[1] =~ s/^$self->{flags}{-char}+$//g;
                          },
                 ;

Note that such a subroutine will almost always need to modify C<$_[1]> directly.


=item C<version =E<gt> $minimum_perl_version>

If this argument is given, it specifies the minimum version of perl required
to use the new pattern. Attempts to use the pattern with earlier versions of
perl will generate a fatal diagnostic.

=back


=head2 List of available patterns

The following patterns are currently available:

=over 4

=cut

package Regexp::Common;

use re 'eval';

##### BALANCED BRACKETS #####

my %closer = ( '{'=>'}', '('=>')', '['=>']', '<'=>'>' );
sub balanced {
   my ($r,$p,$ap,$k) = @_;
   $r = "(??{\$Regexp::Common::$r})";
   return if $] < 5.006;
   return $k
	? qr/(?:[$p]((?:(?>[^$ap]+)|$r)*)[$closer{$p}])/
	: qr/(?:[$p](?:(?>[^$ap]+)|$r)*[$closer{$p}])/
}

=pod

=item C<$RE{balanced}{-parens}>

Returns a pattern that matches a string that starts with the nominated
opening parenthesis or bracket, contains characters and properly nested
parenthesized subsequences, and ends in the matching parenthesis.

More than one type of parenthesis can be specified:

        $RE{balanced}{-parens=>'(){}'}

in which case all specified parenthesis types must be correctly balanced within
the string.

Under C<-keep>:

=over 4

=item $1

captures the entire expression

=back


=cut 

pattern 
        name    => [qw( balanced -parens=() )],
        create  => sub { my $flag = $_[1];
                         my @parens = grep {index($flag->{-parens},$_)>=0} ('[','(','{','<');
                         my $parens = join "", map "$closer{$_}$_", @parens;
                         my $sig = "SIG" . join "", @parens;
                         $sig =~ tr/[({</1234/;
                         my $pat = qr/(?!)/;
			 my $keep = exists $flag->{-keep};
                         foreach (@parens)
                         {
                                my $add = balanced("parens{$sig}", $_, $parens, $keep);
                                $pat = qr/$add|$pat/;
                         }
			 $pat = $keep ? qr/($pat)/ : $pat;
                         $Regexp::Common::parens{$sig} = $pat;
                   },
        version => 5.006,
        ;


##### NUMBERS #####

$SIG{__WARN__} = sub{};

=pod

=item C<$RE{num}{int}{-sep}{-group}>

Returns a pattern that matches a decimal integer.

If C<-sep=I<P>> is specified, the pattern I<P> is required as a grouping marker
within the number.

If C<-group=I<N>> is specified, digits between grouping markers must be
grouped in sequences of exactly I<N> characters. The default value of I<N> is 3.

For example:

        $RE{num}{int}                            # match 1234567
        $RE{num}{int}{-sep=>','}                 # match 1,234,567
        $RE{num}{int}{-sep=>',?'}                # match 1234567 or 1,234,567
        $RE{num}{int}{-sep=>'.'}{-group=>4}      # match 1.2345.6789

Under C<-keep>:

=over 4

=item $1

captures the entire number

=item $2

captures the optional sign number

=item $3

captures the complete set of digits

=back

=cut

pattern name   => [qw( num int -sep=  -group=3 )],
        create => sub { my $flag = $_[1];
                        my ($sep, $group) = @{$flag}{-sep, -group};
                        $sep = ',' if exists $flag->{-sep}
                                     && !defined $flag->{-sep};
                        return $sep 
                                ? qq{(?k:(?k:[+-]?)(?k:\\d{1,$group}(?:$sep\\d{$group})*))}
                                : qq{(?k:(?k:[+-]?)(?k:\\d+))}
                      }
        ;

sub real_creator { 
        my ($base, $places, $radix, $sep, $group, $expon) =
                @{$_[1]}{-base, -places, -radix, -sep, -group, -expon};
        croak "Base must be between 1 and 36"
                unless $base >= 1 && $base <= 36;
        $sep = ',' if exists $_[1]->{-sep}
                     && !defined $_[1]->{-sep};
	if ($base>14 && $expon =~ /^[Ee]$/) { $expon = 'G' }
	foreach ($radix, $sep, $expon) { $_ = "[$_]" if length($_) == 1 }
        my $digits = substr(join("",0..9,"A".."Z"),0,$base);
        return $sep
                ? qq{(?k:(?i)(?k:[+-]?)(?k:(?=[$digits]|$radix)(?k:[$digits]{1,$group}(?:(?:$sep)[$digits]{$group})*)(?:(?k:$radix)(?k:[$digits]{$places}))?)(?:(?k:$expon)(?k:(?k:[+-]?)(?k:[$digits]+))|))}
                : qq{(?k:(?i)(?k:[+-]?)(?k:(?=[$digits]|$radix)(?k:[$digits]*)(?:(?k:$radix)(?k:[$digits]{$places}))?)(?:(?k:$expon)(?k:(?k:[+-]?)(?k:[$digits]+))|))};
}

=pod

=item C<$RE{num}{real}{-base}{-radix}{-places}{-sep}{-group}{-expon}>

Returns a pattern that matches a floating-point number.

If C<-base=I<N>> is specified, the number is assumed to be in that base
(with A..Z representing the digits for 11..36). By default, the base is 10.

If C<-radix=I<P>> is specified, the pattern I<P> is used as the radix point for
the number (i.e. the "decimal point" in base 10). The default is C<qr/[.]/>.

If C<-places=I<N>> is specified, the number is assumed to have exactly
I<N> places after the radix point.
If C<-places=I<M,N>> is specified, the number is assumed to have between
I<M> and I<N> places after the radix point.
By default, the number of places is unrestricted.

If C<-sep=I<P>> specified, the pattern I<P> is required as a grouping marker
within the pre-radix section of the number. By default, no separator is
allowed.

If C<-group=I<N>> is specified, digits between grouping separators
must be grouped in sequences of exactly I<N> characters. The default value of
I<N> is 3.

If C<-expon=I<P>> is specified, the pattern I<P> is used as the exponential
marker.  The default value of I<P> is C<qr/[Ee]/.

For example:

        $RE{num}{real}                  # matches 123.456 or -0.1234567
        $RE{num}{real}{-places=2}       # matches 123.45 or -0.12
        $RE{num}{real}{-places='0,3'}   # matches 123.456 or 0 or 9.8
        $RE{num}{real}{-sep=>'[,.]?'}   # matches 123,456 or 123.456
        $RE{num}{real}{-base=>3'}       # matches 121.102

Under C<-keep>:

=over 4

=item $1

captures the entire match

=item $2

captures the optional sign

=item $3

captures the complete mantissa

=item $4

captures the whole number portion of the mantissa

=item $5

captures the radix point

=item $6

captures the fractional portion of the mantissa

=item $7

captures the optional exponent marker

=item $8

captures the entire exponent value

=item $9

captures the optional sign of the exponent

=item $10

captures the digits of the exponent

=back

=cut

pattern name   => [qw( num real -base=10 ), '-places=0,',
                   qw( -radix=[.] -sep= -group=3 -expon=E )],
        create => \&real_creator,
        ;

sub real_synonym {
        my ($name, $base) = @_;
        pattern name   => ['num', $name, '-places=0,', '-radix=[.]',
			   '-sep=', '-group=3', '-expon=E' ],
                create => sub { my %flags = ( %{$_[1]}, -base => $base );
                                real_creator(undef,\%flags);
                              }
}

=pod

=item C<$RE{num}{dec}{-radix}{-places}{-sep}{-group}{-expon}>

A synonym for C<$RE{num}{real}{-base=>10}{...}>

=item C<$RE{num}{oct}{-radix}{-places}{-sep}{-group}{-expon}>

A synonym for C<$RE{num}{real}{-base=>8}{...}>

=item C<$RE{num}{bin}{-radix}{-places}{-sep}{-group}{-expon}>

A synonym for C<$RE{num}{real}{-base=>2}{...}>

=item C<$RE{num}{hex}{-radix}{-places}{-sep}{-group}{-expon}>

A synonym for C<$RE{num}{real}{-base=>16}{...}>

=cut

real_synonym(hex=>16);
real_synonym(dec=>10);
real_synonym(oct=>8);
real_synonym(bin=>2);


##### COMMENTS #####

=pod

=item C<$RE{comment}{I<language>}>

A comment string in the nominated language.

Available languages are:

        $RE{comment}{C}
        $RE{comment}{C++}
        $RE{comment}{shell}
        $RE{comment}{Perl}

Under C<-keep>:

=over 4

=item $1

captures the entire match

=item $2

captures the opening comment marker (except for C<$RE{comment}{C++}>)

=item $3

captures the contents of the comment (except for C<$RE{comment}{C++}>)

=item $4

captures the  closing comment marker (except for C<$RE{comment}{C++}>)

=back

=cut

pattern name   => [qw( comment C )],
        create => q{(?k:(?k:\/\*)(?k:(?:(?!\*\/)[\s\S])*)(?k:\*\/))},
        ;

pattern name   => [qw( comment C++ )],
        create => q{(?k:\/\*(?:(?!\*\/)[\s\S])*\*\/|\/\/[^\n]*\n)},
        ;

pattern name   => [qw( comment shell )],
        create => q{(?k:(?k:#)(?k:[^\n]*)(?k:\n))},
        ;

pattern name   => [qw( comment Perl )],
        create => q{(?k:(?k:#)(?k:[^\n]*)(?k:\n))},
        ;

##### PROFANITY #####

my $profanity = '(?:cvff(?:\\ gnxr|\\-gnxr|gnxr|r(?:ef|[feq])|vat|l)?|dhvzf?|fuvg(?:g(?:r(?:ef|[qe])|vat|l)|r(?:ef|[fqel])|vat|[fr])?|g(?:heqf?|jngf?)|jnax(?:r(?:ef|[eq])|vat|f)?|n(?:ef(?:r(?:\\ ubyr|\\-ubyr|ubyr|[fq])|vat|r)|ff(?:\\ ubyrf?|\\-ubyrf?|rq|ubyrf?|vat))|o(?:hyy(?:\\ fuvg(?:g(?:r(?:ef|[qe])|vat)|f)?|\\-fuvg(?:g(?:r(?:ef|[qe])|vat)|f)?|fuvg(?:g(?:r(?:ef|[qe])|vat)|f)?)|ybj(?:\\ wbof?|\\-wbof?|wbof?))|p(?:bpx(?:\\ fhpx(?:ref?|vat)|\\-fhpx(?:ref?|vat)|fhpx(?:ref?|vat))|enc(?:c(?:r(?:ef|[eq])|vat|l)|f)?|h(?:agf?|z(?:vat|zvat|f)))|qvpx(?:\\ urnq|\\-urnq|rq|urnq|vat|yrff|f)|s(?:hpx(?:rq|vat|f)?|neg(?:r[eq]|vat|[fl])?|rygpu(?:r(?:ef|[efq])|vat)?)|un(?:eq[\\-\\ ]?ba|ys(?:\\ n[fe]|\\-n[fe]|n[fe])frq)|z(?:bgure(?:\\ shpx(?:ref?|vat)|\\-shpx(?:ref?|vat)|shpx(?:ref?|vat))|hgu(?:n(?:\\ shpx(?:ref?|vat|[nnn])|\\-shpx(?:ref?|vat|[nnn])|shpx(?:ref?|vat|[nnn]))|re(?:\\ shpx(?:ref?|vat)|\\-shpx(?:ref?|vat)|shpx(?:ref?|vat)))|reqr?))';

my $contextual = '(?:c(?:bex|e(?:bax|vpxf?)|hff(?:vrf|l)|vff(?:\\ gnxr|\\-gnxr|gnxr|r(?:ef|[feq])|vat|l)?)|dhvzf?|ebbg(?:r(?:ef|[eq])|vat|f)?|f(?:bq(?:q(?:rq|vat)|f)?|chax|perj(?:rq|vat|f)?|u(?:nt(?:t(?:r(?:ef|[qe])|vat)|f)?|vg(?:g(?:r(?:ef|[qe])|vat|l)|r(?:ef|[fqel])|vat|[fr])?))|g(?:heqf?|jngf?|vgf?)|jnax(?:r(?:ef|[eq])|vat|f)?|n(?:ef(?:r(?:\\ ubyr|\\-ubyr|ubyr|[fq])|vat|r)|ff(?:\\ ubyrf?|\\-ubyrf?|rq|ubyrf?|vat))|o(?:ba(?:r(?:ef|[fe])|vat|r)|h(?:ttre|yy(?:\\ fuvg(?:g(?:r(?:ef|[qe])|vat)|f)?|\\-fuvg(?:g(?:r(?:ef|[qe])|vat)|f)?|fuvg(?:g(?:r(?:ef|[qe])|vat)|f)?))|n(?:fgneq|yy(?:r(?:ef|[qe])|vat|f)?)|yb(?:bql|j(?:\\ wbof?|\\-wbof?|wbof?)))|p(?:bpx(?:\\ fhpx(?:ref?|vat)|\\-fhpx(?:ref?|vat)|fhpx(?:ref?|vat)|f)?|enc(?:c(?:r(?:ef|[eq])|vat|l)|f)?|h(?:agf?|z(?:vat|zvat|f)))|q(?:batf?|vpx(?:\\ urnq|\\-urnq|rq|urnq|vat|yrff|f)?)|s(?:hpx(?:rq|vat|f)?|neg(?:r[eq]|vat|[fl])?|rygpu(?:r(?:ef|[efq])|vat)?)|u(?:hzc(?:r(?:ef|[eq])|vat|f)?|n(?:eq[\\-\\ ]?ba|ys(?:\\ n[fe]|\\-n[fe]|n[fe])frq))|z(?:bgure(?:\\ shpx(?:ref?|vat)|\\-shpx(?:ref?|vat)|shpx(?:ref?|vat))|hgu(?:n(?:\\ shpx(?:ref?|vat|[nnn])|\\-shpx(?:ref?|vat|[nnn])|shpx(?:ref?|vat|[nnn]))|re(?:\\ shpx(?:ref?|vat)|\\-shpx(?:ref?|vat)|shpx(?:ref?|vat)))|reqr?))';

tr/A-Za-z/N-ZA-Mn-za-m/ foreach $profanity, $contextual;

=pod

=item $RE{profanity}

Returns a pattern matching words -- such as Carlin's "big seven" -- that
are most likely to give offense. Note that correct anatomical terms are
deliberately I<not> included in the list.

Under C<-keep>:

=over 4

=item $1

captures the entire word

=back

=item C<$RE{profanity}{contextual}>

Returns a pattern matching words that are likely to give offense when
used in specific contexts, but which also have genuinely
non-offensive meanings.

Under C<-keep>:

=over 4

=item $1

captures the entire word

=back


=cut

pattern name   => [qw( profanity )],
        create => '(?:\b(?k:' . $profanity . ')\b)',
        ;

pattern name   => [qw( profanity contextual)],
        create => '(?:\b(?k:' . $contextual . ')\b)',
        ;


##### WHITESPACE #####

=pod

=item C<$RE{ws}{crop}>

Returns a pattern that identifies leading or trailing whitespace.

For example:

        $str =~ s/$RE{ws}{crop}//g;     # Delete surrounding whitespace

The call:

        $RE{ws}{crop}->subs($str);

is optimized (but probably still slower than doing the s///g explicitly).

This pattern does not capture under C<-keep>.

=cut

pattern name   => [qw( ws crop )],
        create => '(?:^\s+|\s+$)',
        subs   => sub { $_[1] =~ s/^\s+//; $_[1] =~ s/\s+$//; }
        ;


##### DELIMITED SEQUENCES #####


sub gen_delimited
{
        my ($dels, $escs) = @_;
        return '(?:\S*)' unless $dels =~ /\S/;
        if (length $escs) {
                $escs .= substr($escs,-1) x (length($dels)-length($escs));
        }
        my @pat = ();
        my $i;
        for ($i=0; $i<length $dels; $i++)
        {
                my $del = quotemeta substr($dels,$i,1);
                my $esc = length($escs) ? quotemeta substr($escs,$i,1) : "";
                if ($del eq $esc) {
                        push @pat, "(?k:$del)(?k:[^$del]*(?:(?:$del$del)[^$del]*)*)(?k:$del)";
                }
                elsif (length $esc) {
                        push @pat, "(?k:$del)(?k:[^$esc$del]*(?:$esc.[^$esc$del]*)*)(?k:$del)";
                }
                else {
                        push @pat, "(?k:$del)(?k:[^$del]*)(?k:$del)";
                }
        }
        my $pat = join '|', @pat;
        return "(?k:$pat)";
}

=pod

=item C<$RE{delimited}{-delim}{-esc}>

Returns a pattern that matches a single-character-delimited substring,
with optional internal escaping of the delimiter.

When C<-delim=I<S>> is specified, each character in the sequence I<S> is
a possible delimiter. There is no default delimiter, so this flag must always
be specified.

If C<-esc=I<S>> is specified, each character in the sequence I<S> is
the delimiter for the corresponding character in the C<-delim=I<S>> list.
The default escape is backslash.

For example:

        $RE{delimited}{-delim=>'"'}             # match "a \" delimited string"
        $RE{delimited}{-delim=>'"'}{-esc=>'"'}  # match "a "" delimited string"
        $RE{delimited}{-delim=>'/'}             # match /a \/ delimited string/
        $RE{delimited}{-delim=>q{'"}}           # match "string" or 'string'

Under C<-keep>:

=over 4

=item $1

captures the entire match

=item $2

captures the opening delimiter (provided only one delimiter was specified)

=item $3

captures delimited portion of the string (provided only one delimiter was
specified)

=item $4

captures the closing delimiter (provided only one delimiter was specified)

=back

=cut

sub local_croak {
        my $msg = join "", @_;
        $msg =~ s/\s+$//;
        die $msg . ' at '
          . join(" line ", (caller 3)[1,2])
          . "\n";
}

pattern name   => [qw( delimited -delim= -esc=\\ )],
        create => sub {
                        my $flags = $_[1];
                        local_croak 'Must specify delimiter in $RE{delimited}'
                                unless length $flags->{-delim};
                        return gen_delimited(@{$flags}{-delim, -esc});
                  },
        ;

=pod

=item $RE{quoted}{-esc}

A synonym for C<$RE{delimited}{q{-delim='"`}{...}}>

=cut

pattern name   => [qw( quoted -esc=\\ )],
        create => sub {
                        my $flags = $_[1];
                        return gen_delimited(q{"'`},$flags->{-esc});
                  },
        ;

=pod

=item C<$RE{list}{-pat}{-sep}{-lastsep}>

Returns a pattern matching a list of (at least two) substrings.

If C<-pat=I<P>> is specified, it defines the pattern for each substring
in the list. By default, I<P> is C<qr/.*?/>.

If C<-sep=I<P>> is specified, it defines the pattern I<P> to be used as
a separator between each pair of substrings in the list, except the final two.
By default I<P> is C<qr/\s*,\s*/>.

If C<-lastsep=I<P>> is specified, it defines the pattern I<P> to be used as
a separator between the final two substrings in the list.
By default I<P> is the same as the pattern specified by the C<-sep> flag.

For example:

        $RE{list}{-pat=>'\w+'}                # match a list of word chars
        $RE{list}{-pat=>$RE{num}{real}}       # match a list of numbers
        $RE{list}{-sep=>"\t"}                 # match a tab-separated list
        $RE{list}{-lastsep=>',\s+and\s+'}     # match a proper English list

Under C<-keep>:

=over 4

=item $1

captures the entire list

=item $2

captures the last separator

=back


=item C<$RE{list}{conj}{-word=I<PATTERN>}>

An alias for C<$RE{list}{-lastsep=>'\s*,?\s*I<PATTERN>\s*'}>

If C<-word> is not specified, the default pattern is C<qr/and|or/>.

For example:

        $RE{list}{conj}{-word=>'et'}             # match Jean, Paul, et Satre
        $RE{list}{conj}{-word=>'oder'}           # match Bonn, Koln oder Hamburg

=item C<$RE{list}{and}>

An alias for C<$RE{list}{conj}{-word=>'and'}>

=item C<$RE{list}{or}>

An alias for C<$RE{list}{conj}{-word=>'or'}>

=cut

sub gen_list_pattern {
        my ($pat, $sep, $lsep) = @_;
        $lsep = $sep unless defined $lsep;
        return "(?k:(?:(?:$pat)(?:$sep))*(?:$pat)(?k:$lsep)(?:$pat))";
}

my $defpat  = '.*?';
my $defsep = '\s*,\s*';

pattern name   => [ 'list', "-pat=$defpat", "-sep=$defsep", '-lastsep' ],
        create => sub { gen_list_pattern(@{$_[1]}{-pat, -sep, -lastsep}) },
        ;

pattern name   => [ 'list', 'conj', '-word=(?:and|or)' ],
        create => sub { gen_list_pattern($defpat, $defsep,
                                         '\s*,?\s*'.$_[1]->{-word}.'\s*');
                      },
        ;

pattern name   => [ 'list', 'and' ],
        create => sub { gen_list_pattern($defpat, $defsep, '\s*,?\s*and\s*') },
        ;

pattern name   => [ 'list', 'or' ],
        create => sub { gen_list_pattern($defpat, $defsep, '\s*,?\s*or\s*') },
        ;


##### IP ADDRESSES #####

=pod

=item C<$RE{net}{IPv4}>

Returns a pattern that matches a valid IP address in "dotted decimal"

For this pattern and the next four, under C<-keep>:

=over 4

=item $1

captures the entire match

=item $2

captures the first component of the address

=item $3

captures the second component of the address

=item $4

captures the third component of the address

=item $5

captures the final component of the address

=back

=item C<$RE{net}{IPv4}{dec}{-sep}>

Returns a pattern that matches a valid IP address in "dotted decimal"

If C<-sep=I<P>> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>. 


=item C<$RE{net}{IPv4}{hex}{-sep}>

Returns a pattern that matches a valid IP address in "dotted hexadecimal"

If C<-sep=I<P>> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>. C<-sep=>""> and
C<-sep=>" "> are useful alternatives.

=item C<$RE{net}{IPv4}{oct}{-sep}>

Returns a pattern that matches a valid IP address in "dotted octal"

If C<-sep=I<P>> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>.

=item C<$RE{net}{IPv4}{bin}{-sep}>

Returns a pattern that matches a valid IP address in "dotted binary"

If C<-sep=I<P>> is specified the pattern I<P> is used as the separator.
By default I<P> is C<qr/[.]/>.

=cut

my %IPunit = (
        dec => q{(?k:25[0-5]|2[0-4]\d|[0-1]??\d{1,2})},
        oct => q{(?k:[0-3]??[0-7]{1,2})},
        hex => q{(?k:[0-9A-F]{1,2})},
        bin => q{(?k:[0-1]{1,8})},
);

$defsep = '[.]';

pattern name   => [qw( net IPv4 )],
        create => "(?k:$IPunit{dec}$defsep$IPunit{dec}$defsep$IPunit{dec}$defsep$IPunit{dec})",
        ;


pattern name   => [qw( net IPv4 dec -sep=[.] )],
        create => sub { my $sep = $_[1]->{-sep};
                        "(?k:$IPunit{dec}$sep$IPunit{dec}$sep$IPunit{dec}$sep$IPunit{dec})",
                      },
pattern name   => [qw( net IPv4 oct -sep=[.] )],
        create => sub { my $sep = $_[1]->{-sep};
                        "(?k:$IPunit{oct}$sep$IPunit{oct}$sep$IPunit{oct}$sep$IPunit{oct})",
                      },
        ;
pattern name   => [qw( net IPv4 hex -sep=[.] )],
        create => sub { my $sep = $_[1]->{-sep};
                        "(?k:$IPunit{hex}$sep$IPunit{hex}$sep$IPunit{hex}$sep$IPunit{hex})",
                      },
        ;
pattern name   => [qw( net IPv4 bin -sep=[.] )],
        create => sub { my $sep = $_[1]->{-sep};
                        "(?k:$IPunit{bin}$sep$IPunit{bin}$sep$IPunit{bin}$sep$IPunit{bin})",
                      },
        ;

__END__

=back


=head2 Forthcoming patterns and features

Future releases of the module will also provide patterns for the following:

        * email addresses 
        * HTML/XML tags
        * more numerical matchers,
        * mail headers (including multiline ones),
        * URLS (various genres)
        * telephone numbers of various countries
        * currency (universal 3 letter format, Latin-1, currency names)
        * dates
        * binary formats (e.g. UUencoded, MIMEd)

If you have other patterns or pattern generators that you think would be
generally useful, please send them to the author -- preferably as source
code using the C<pattern> subroutine. Submissions that include a set of
tests, will be especially welcome.


=head1 DIAGNOSTICS

=over 4

=item C<Can't export unknown subroutine %s>

The subroutine-based interface didn't recognize the requested subroutine.
Often caused by a spelling mistake or an incompletely specified name.

        
=item C<Can't create unknown regex: $RE{...}>

Regexp::Common doesn't have a generator for the requested pattern.
Often indicates a mispelt or missing parameter.

=item
C<Perl %f does not support the pattern $RE{...}.
You need Perl %f or later>

The requested pattern requires advanced regex features (e.g. recursion)
that not available in your version of Perl. Time to upgrade.

=item C<pattern() requires argument: name => [ @list ]>

Every user-defined pattern specification must have a name.

=item C<pattern() requires argument: create => $sub_ref_or_string>

Every user-defined pattern specification must provide a pattern creation
mechanism: either a pattern string or a reference to a subroutine that
returns the pattern string.

=item C<Base must be between 1 and 36>

The C<$RE{num}{real}{-base=>'I<N>'}> pattern uses the characters [0-9A-Z]
to represent the digits of various bases. Hence it only produces
regular expressions for bases up to hexatricensimal.

=item C<Must specify delimiter in $RE{delimited}>

The pattern has no default delimiter.
You need to write: C<$RE{delimited}{-delim=>I<X>'}> for some character I<X>

=back

=head1 ACKNOWLEDGEMENTS

Deepest thanks to the many people who have encouraged and contributed to this
project, especially: Elijah, Jarkko, Tom, Nat, Ed, and Vivek.


=head1 AUTHOR

Damian Conway (damian@conway.org)


=head1 BUGS AND IRRITATIONS

Bound to be plenty.

For a start, there are many common regexes missing.
Send them in!


=head1 COPYRIGHT

         Copyright (c) 2001, Damian Conway. All Rights Reserved.
       This module is free software. It may be used, redistributed
      and/or modified under the terms of the Perl Artistic License
            (see http://www.perl.com/perl/misc/Artistic.html)
