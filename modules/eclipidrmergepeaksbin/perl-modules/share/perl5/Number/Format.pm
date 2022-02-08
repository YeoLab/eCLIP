package Number::Format;

# Minimum version is 5.10.0.  May work on earlier versions, but not
# supported on any version older than 5.10.  Hack this line at your own risk:
require 5.010;

use strict;
use warnings;

=head1 NAME

Number::Format - Perl extension for formatting numbers

=head1 SYNOPSIS

  use Number::Format;
  my $x = new Number::Format %args;
  $formatted = $x->round($number, $precision);
  $formatted = $x->format_number($number, $precision, $trailing_zeroes);
  $formatted = $x->format_negative($number, $picture);
  $formatted = $x->format_picture($number, $picture);
  $formatted = $x->format_price($number, $precision, $symbol);
  $formatted = $x->format_bytes($number, $precision);
  $number    = $x->unformat_number($formatted);

  use Number::Format qw(:subs);
  $formatted = round($number, $precision);
  $formatted = format_number($number, $precision, $trailing_zeroes);
  $formatted = format_negative($number, $picture);
  $formatted = format_picture($number, $picture);
  $formatted = format_price($number, $precision, $symbol);
  $formatted = format_bytes($number, $precision);
  $number    = unformat_number($formatted);

=head1 REQUIRES

Perl, version 5.8 or higher.

POSIX.pm to determine locale settings.

Carp.pm is used for some error reporting.

=head1 DESCRIPTION

These functions provide an easy means of formatting numbers in a
manner suitable for displaying to the user.

There are two ways to use this package.  One is to declare an object
of type Number::Format, which you can think of as a formatting engine.
The various functions defined here are provided as object methods.
The constructor C<new()> can be used to set the parameters of the
formatting engine.  Valid parameters are:

  THOUSANDS_SEP     - character inserted between groups of 3 digits
  DECIMAL_POINT     - character separating integer and fractional parts
  MON_THOUSANDS_SEP - like THOUSANDS_SEP, but used for format_price
  MON_DECIMAL_POINT - like DECIMAL_POINT, but used for format_price
  INT_CURR_SYMBOL   - character(s) denoting currency (see format_price())
  DECIMAL_DIGITS    - number of digits to the right of dec point (def 2)
  DECIMAL_FILL      - boolean; whether to add zeroes to fill out decimal
  NEG_FORMAT        - format to display negative numbers (def ``-x'')
  KILO_SUFFIX       - suffix to add when format_bytes formats kilobytes (trad)
  MEGA_SUFFIX       -    "    "  "    "        "         "    megabytes (trad)
  GIGA_SUFFIX       -    "    "  "    "        "         "    gigabytes (trad)
  KIBI_SUFFIX       - suffix to add when format_bytes formats kibibytes (iec)
  MEBI_SUFFIX       -    "    "  "    "        "         "    mebibytes (iec)
  GIBI_SUFFIX       -    "    "  "    "        "         "    gibibytes (iec)

They may be specified in upper or lower case, with or without a
leading hyphen ( - ).

If C<THOUSANDS_SEP> is set to the empty string, format_number will not
insert any separators.

The defaults for C<THOUSANDS_SEP>, C<DECIMAL_POINT>,
C<MON_THOUSANDS_SEP>, C<MON_DECIMAL_POINT>, and C<INT_CURR_SYMBOL>
come from the POSIX locale information (see L<perllocale>).  If your
POSIX locale does not provide C<MON_THOUSANDS_SEP> and/or
C<MON_DECIMAL_POINT> fields, then the C<THOUSANDS_SEP> and/or
C<DECIMAL_POINT> values are used for those parameters.  Formerly,
POSIX was optional but this caused problems in some cases, so it is
now required.  If this causes you hardship, please contact the author
of this package at <SwPrAwM@cpan.org> (remove "SPAM" to get correct
email address) for help.

If any of the above parameters are not specified when you invoke
C<new()>, then the values are taken from package global variables of
the same name (e.g.  C<$DECIMAL_POINT> is the default for the
C<DECIMAL_POINT> parameter).  If you use the C<:vars> keyword on your
C<use Number::Format> line (see non-object-oriented example below) you
will import those variables into your namesapce and can assign values
as if they were your own local variables.  The default values for all
the parameters are:

  THOUSANDS_SEP     = ','
  DECIMAL_POINT     = '.'
  MON_THOUSANDS_SEP = ','
  MON_DECIMAL_POINT = '.'
  INT_CURR_SYMBOL   = 'USD'
  DECIMAL_DIGITS    = 2
  DECIMAL_FILL      = 0
  NEG_FORMAT        = '-x'
  KILO_SUFFIX       = 'K'
  MEGA_SUFFIX       = 'M'
  GIGA_SUFFIX       = 'G'
  KIBI_SUFFIX       = 'KiB'
  MEBI_SUFFIX       = 'MiB'
  GIBI_SUFFIX       = 'GiB'

Note however that when you first call one of the functions in this
module I<without> using the object-oriented interface, further setting
of those global variables will have no effect on non-OO calls.  It is
recommended that you use the object-oriented interface instead for
fewer headaches and a cleaner design.

The C<DECIMAL_FILL> and C<DECIMAL_DIGITS> values are not set by the
Locale system, but are definable by the user.  They affect the output
of C<format_number()>.  Setting C<DECIMAL_DIGITS> is like giving that
value as the C<$precision> argument to that function.  Setting
C<DECIMAL_FILL> to a true value causes C<format_number()> to append
zeroes to the right of the decimal digits until the length is the
specified number of digits.

C<NEG_FORMAT> is only used by C<format_negative()> and is a string
containing the letter 'x', where that letter will be replaced by a
positive representation of the number being passed to that function.
C<format_number()> and C<format_price()> utilize this feature by
calling C<format_negative()> if the number was less than 0.

C<KILO_SUFFIX>, C<MEGA_SUFFIX>, and C<GIGA_SUFFIX> are used by
C<format_bytes()> when the value is over 1024, 1024*1024, or
1024*1024*1024, respectively.  The default values are "K", "M", and
"G".  These apply in the default "traditional" mode only.  Note: TERA
or higher are not implemented because of integer overflows on 32-bit
systems.

C<KIBI_SUFFIX>, C<MEBI_SUFFIX>, and C<GIBI_SUFFIX> are used by
C<format_bytes()> when the value is over 1024, 1024*1024, or
1024*1024*1024, respectively.  The default values are "KiB", "MiB",
and "GiB".  These apply in the "iso60027"" mode only.  Note: TEBI or
higher are not implemented because of integer overflows on 32-bit
systems.

The only restrictions on C<DECIMAL_POINT> and C<THOUSANDS_SEP> are that
they must not be digits and must not be identical.  There are no
restrictions on C<INT_CURR_SYMBOL>.

For example, a German user might include this in their code:

  use Number::Format;
  my $de = new Number::Format(-thousands_sep   => '.',
                              -decimal_point   => ',',
                              -int_curr_symbol => 'DEM');
  my $formatted = $de->format_number($number);

Or, if you prefer not to use the object oriented interface, you can do
this instead:

  use Number::Format qw(:subs :vars);
  $THOUSANDS_SEP   = '.';
  $DECIMAL_POINT   = ',';
  $INT_CURR_SYMBOL = 'DEM';
  my $formatted = format_number($number);

=head1 EXPORTS

Nothing is exported by default.  To export the functions or the global
variables defined herein, specify the function name(s) on the import
list of the C<use Number::Format> statement.  To export all functions
defined herein, use the special tag C<:subs>.  To export the
variables, use the special tag C<:vars>; to export both subs and vars
you can use the tag C<:all>.

=cut

###---------------------------------------------------------------------

use strict;
use Exporter;
use Carp;
use POSIX qw(localeconv);
use base qw(Exporter);

our @EXPORT_SUBS =
    qw( format_number format_negative format_picture
        format_price format_bytes round unformat_number );

our @EXPORT_LC_NUMERIC =
    qw( $DECIMAL_POINT $THOUSANDS_SEP $GROUPING );

our @EXPORT_LC_MONETARY =
    qw( $INT_CURR_SYMBOL $CURRENCY_SYMBOL $MON_DECIMAL_POINT
        $MON_THOUSANDS_SEP $MON_GROUPING $POSITIVE_SIGN $NEGATIVE_SIGN
        $INT_FRAC_DIGITS $FRAC_DIGITS $P_CS_PRECEDES $P_SEP_BY_SPACE
        $N_CS_PRECEDES $N_SEP_BY_SPACE $P_SIGN_POSN $N_SIGN_POSN );

our @EXPORT_OTHER =
    qw( $DECIMAL_DIGITS $DECIMAL_FILL $NEG_FORMAT
        $KILO_SUFFIX $MEGA_SUFFIX $GIGA_SUFFIX
        $KIBI_SUFFIX $MEBI_SUFFIX $GIBI_SUFFIX );

our @EXPORT_VARS = ( @EXPORT_LC_NUMERIC, @EXPORT_LC_MONETARY, @EXPORT_OTHER );
our @EXPORT_ALL  = ( @EXPORT_SUBS, @EXPORT_VARS );

our @EXPORT_OK   = ( @EXPORT_ALL );

our %EXPORT_TAGS = ( subs             => \@EXPORT_SUBS,
                     vars             => \@EXPORT_VARS,
                     lc_numeric_vars  => \@EXPORT_LC_NUMERIC,
                     lc_monetary_vars => \@EXPORT_LC_MONETARY,
                     other_vars       => \@EXPORT_OTHER,
                     all              => \@EXPORT_ALL );

our $VERSION = '1.75';

# Refer to http://www.opengroup.org/onlinepubs/007908775/xbd/locale.html
# for more details about the POSIX variables

# Locale variables provided by POSIX for numbers (LC_NUMERIC)
our $DECIMAL_POINT      = '.';  # decimal point symbol for numbers
our $THOUSANDS_SEP      = ',';  # thousands separator for numbers
our $GROUPING           = undef;# grouping rules for thousands (UNSUPPORTED)

# Locale variables provided by POSIX for currency (LC_MONETARY)
our $INT_CURR_SYMBOL    = 'USD';# intl currency symbol
our $CURRENCY_SYMBOL    = '$';  # domestic currency symbol
our $MON_DECIMAL_POINT  = '.';  # decimal point symbol for monetary values
our $MON_THOUSANDS_SEP  = ',';  # thousands separator for monetary values
our $MON_GROUPING       = undef;# like 'grouping' for monetary (UNSUPPORTED)
our $POSITIVE_SIGN      = '';   # string to add for non-negative monetary
our $NEGATIVE_SIGN      = '-';  # string to add for negative monetary
our $INT_FRAC_DIGITS    = 2;    # digits to right of decimal for intl currency
our $FRAC_DIGITS        = 2;    # digits to right of decimal for currency
our $P_CS_PRECEDES      = 1;    # curr sym precedes(1) or follows(0) positive
our $P_SEP_BY_SPACE     = 1;    # add space to positive; 0, 1, or 2
our $N_CS_PRECEDES      = 1;    # curr sym precedes(1) or follows(0) negative
our $N_SEP_BY_SPACE     = 1;    # add space to negative; 0, 1, or 2
our $P_SIGN_POSN        = 1;    # sign rules for positive: 0-4
our $N_SIGN_POSN        = 1;    # sign rules for negative: 0-4

# The following are specific to Number::Format
our $DECIMAL_DIGITS     = 2;
our $DECIMAL_FILL       = 0;
our $NEG_FORMAT         = '-x';
our $KILO_SUFFIX        = 'K';
our $MEGA_SUFFIX        = 'M';
our $GIGA_SUFFIX        = 'G';
our $KIBI_SUFFIX        = 'KiB';
our $MEBI_SUFFIX        = 'MiB';
our $GIBI_SUFFIX        = 'GiB';

our $DEFAULT_LOCALE = { (
                         # LC_NUMERIC
                         decimal_point     => $DECIMAL_POINT,
                         thousands_sep     => $THOUSANDS_SEP,
                         grouping          => $GROUPING,

                         # LC_MONETARY
                         int_curr_symbol   => $INT_CURR_SYMBOL,
                         currency_symbol   => $CURRENCY_SYMBOL,
                         mon_decimal_point => $MON_DECIMAL_POINT,
                         mon_thousands_sep => $MON_THOUSANDS_SEP,
                         mon_grouping      => $MON_GROUPING,
                         positive_sign     => $POSITIVE_SIGN,
                         negative_sign     => $NEGATIVE_SIGN,
                         int_frac_digits   => $INT_FRAC_DIGITS,
                         frac_digits       => $FRAC_DIGITS,
                         p_cs_precedes     => $P_CS_PRECEDES,
                         p_sep_by_space    => $P_SEP_BY_SPACE,
                         n_cs_precedes     => $N_CS_PRECEDES,
                         n_sep_by_space    => $N_SEP_BY_SPACE,
                         p_sign_posn       => $P_SIGN_POSN,
                         n_sign_posn       => $N_SIGN_POSN,

                         # The following are specific to Number::Format
                         decimal_digits    => $DECIMAL_DIGITS,
                         decimal_fill      => $DECIMAL_FILL,
                         neg_format        => $NEG_FORMAT,
                         kilo_suffix       => $KILO_SUFFIX,
                         mega_suffix       => $MEGA_SUFFIX,
                         giga_suffix       => $GIGA_SUFFIX,
                         kibi_suffix       => $KIBI_SUFFIX,
                         mebi_suffix       => $MEBI_SUFFIX,
                         gibi_suffix       => $GIBI_SUFFIX,
                        ) };

#
# On Windows, the POSIX localeconv() call returns illegal negative
# numbers for some values, seemingly attempting to indicate null.  The
# following list indicates the values for which this has been
# observed, and for which the values should be stripped out of
# localeconv().
#
our @IGNORE_NEGATIVE = qw( frac_digits int_frac_digits
                           n_cs_precedes n_sep_by_space n_sign_posn
                           p_xs_precedes p_sep_by_space p_sign_posn );

#
# Largest integer a 32-bit Perl can handle is based on the mantissa
# size of a double float, which is up to 53 bits.  While we may be
# able to support larger values on 64-bit systems, some Perl integer
# operations on 64-bit integer systems still use the 53-bit-mantissa
# double floats.  To be safe, we cap at 2**53; use Math::BigFloat
# instead for larger numbers.
#
use constant MAX_INT => 2**53;

###---------------------------------------------------------------------

# INTERNAL FUNCTIONS

# These functions (with names beginning with '_' are for internal use
# only.  There is no guarantee that they will remain the same from one
# version to the next!

##----------------------------------------------------------------------

# _get_self creates an instance of Number::Format with the default
#     values for the configuration parameters, if the first element of
#     @_ is not already an object.

my $DefaultObject;
sub _get_self
{
    # Not calling $_[0]->isa because that may result in unblessed
    # reference error
    unless (ref $_[0] && UNIVERSAL::isa($_[0], "Number::Format"))
    {
        $DefaultObject ||= new Number::Format();
        unshift (@_, $DefaultObject);
    }
    @_;
}

##----------------------------------------------------------------------

# _check_seps is used to validate that the thousands_sep,
#     decimal_point, mon_thousands_sep and mon_decimal_point variables
#     have acceptable values.  For internal use only.

sub _check_seps
{
    my ($self) = @_;
    croak "Not an object" unless ref $self;
    foreach my $prefix ("", "mon_")
    {
        croak "${prefix}thousands_sep is undefined"
            unless defined $self->{"${prefix}thousands_sep"};
        croak "${prefix}thousands_sep may not be numeric"
            if $self->{"${prefix}thousands_sep"} =~ /\d/;
        croak "${prefix}decimal_point may not be numeric"
            if $self->{"${prefix}decimal_point"} =~ /\d/;
        croak("${prefix}thousands_sep and ".
              "${prefix}decimal_point may not be equal")
            if $self->{"${prefix}decimal_point"} eq
                $self->{"${prefix}thousands_sep"};
    }
}

##----------------------------------------------------------------------

# _get_multipliers returns the multipliers to be used for kilo, mega,
# and giga (un-)formatting.  Used in format_bytes and unformat_number.
# For internal use only.

sub _get_multipliers
{
    my($base) = @_;
    if (!defined($base) || $base == 1024)
    {
        return ( kilo => 0x00000400,
                 mega => 0x00100000,
                 giga => 0x40000000 );
    }
    elsif ($base == 1000)
    {
        return ( kilo => 1_000,
                 mega => 1_000_000,
                 giga => 1_000_000_000 );
    }
    else
    {
        croak "base overflow" if $base **3 > MAX_INT;
        croak "base must be a positive integer"
            unless $base > 0 && $base == int($base);
        return ( kilo => $base,
                 mega => $base ** 2,
                 giga => $base ** 3 );
    }
}

##----------------------------------------------------------------------

# _complain_undef displays a warning message on STDERR and is called
# when a subroutine has been invoked with an undef value.  A warning
# message is printed if the calling environment has "uninitialized"
# warnings enabled.

sub _complain_undef
{
    my @stack;
    my($sub, $bitmask) = (caller(1))[3,9];
    my $offset = $warnings::Offsets{"uninitialized"};
    carp "Use of uninitialized value in call to $sub"
         if vec($bitmask, $offset, 1);
}


###---------------------------------------------------------------------

=head1 METHODS

=over 4

=cut

##----------------------------------------------------------------------

=item new( %args )

Creates a new Number::Format object.  Valid keys for %args are any of
the parameters described above.  Keys may be in all uppercase or all
lowercase, and may optionally be preceded by a hyphen (-) character.
Example:

  my $de = new Number::Format(-thousands_sep   => '.',
                              -decimal_point   => ',',
                              -int_curr_symbol => 'DEM');

=cut

sub new
{
    my $type = shift;
    my %args = @_;

    # Fetch defaults from current locale, or failing that, using globals
    my $me            = {};
    # my $locale        = setlocale(LC_ALL, "");
    my $locale_values = localeconv();

    # Strip out illegal negative values from the current locale
    foreach ( @IGNORE_NEGATIVE )
    {
        if (defined($locale_values->{$_}) && $locale_values->{$_} eq '-1')
        {
            delete $locale_values->{$_};
        }
    }

    while(my($arg, $default) = each %$DEFAULT_LOCALE)
    {
        $me->{$arg} = (exists $locale_values->{$arg}
                       ? $locale_values->{$arg}
                       : $default);

        foreach ($arg, uc $arg, "-$arg", uc "-$arg")
        {
            next unless defined $args{$_};
            $me->{$arg} = $args{$_};
            delete $args{$_};
            last;
        }
    }

    #
    # Some broken locales define the decimal_point but not the
    # thousands_sep.  If decimal_point is set to "," the default
    # thousands_sep will be a conflict.  In that case, set
    # thousands_sep to empty string.  Suggested by Moritz Onken.
    #
    foreach my $prefix ("", "mon_")
    {
        $me->{"${prefix}thousands_sep"} = ""
            if ($me->{"${prefix}decimal_point"} eq
                $me->{"${prefix}thousands_sep"});
    }

    croak "Invalid argument(s)" if %args;
    bless $me, $type;
    $me;
}

##----------------------------------------------------------------------

=item round($number, $precision)

Rounds the number to the specified precision.  If C<$precision> is
omitted, the value of the C<DECIMAL_DIGITS> parameter is used (default
value 2).  Both input and output are numeric (the function uses math
operators rather than string manipulation to do its job), The value of
C<$precision> may be any integer, positive or negative. Examples:

  round(3.14159)       yields    3.14
  round(3.14159, 4)    yields    3.1416
  round(42.00, 4)      yields    42
  round(1234, -2)      yields    1200

Since this is a mathematical rather than string oriented function,
there will be no trailing zeroes to the right of the decimal point,
and the C<DECIMAL_POINT> and C<THOUSANDS_SEP> variables are ignored.
To format your number using the C<DECIMAL_POINT> and C<THOUSANDS_SEP>
variables, use C<format_number()> instead.

=cut

sub round
{
    my ($self, $number, $precision) = _get_self @_;

    unless (defined($number))
    {
        _complain_undef();
        $number = 0;
    }

    $precision = $self->{decimal_digits} unless defined $precision;
    $precision = 2 unless defined $precision;

    croak("precision must be integer")
        unless int($precision) == $precision;

    if (ref($number) && $number->isa("Math::BigFloat"))
    {
        my $rounded = $number->copy();
        $rounded->precision(-$precision);
        return $rounded;
    }

    my $sign       = $number <=> 0;
    my $multiplier = (10 ** $precision);
    my $result     = abs($number);
    my $product    = $result * $multiplier;

    croak "round() overflow. Try smaller precision or use Math::BigFloat"
        if $product > MAX_INT;

    # We need to add 1e-14 to avoid some rounding errors due to the
    # way floating point numbers work - see string-eq test in t/round.t
    $result = int($product + .5 + 1e-14) / $multiplier;
    $result = -$result if $sign < 0;
    return $result;
}

##----------------------------------------------------------------------

=item format_number($number, $precision, $trailing_zeroes)

Formats a number by adding C<THOUSANDS_SEP> between each set of 3
digits to the left of the decimal point, substituting C<DECIMAL_POINT>
for the decimal point, and rounding to the specified precision using
C<round()>.  Note that C<$precision> is a I<maximum> precision
specifier; trailing zeroes will only appear in the output if
C<$trailing_zeroes> is provided, or the parameter C<DECIMAL_FILL> is
set, with a value that is true (not zero, undef, or the empty string).
If C<$precision> is omitted, the value of the C<DECIMAL_DIGITS>
parameter (default value of 2) is used.

If the value is too large or great to work with as a regular number,
but instead must be shown in scientific notation, returns that number
in scientific notation without further formatting.

Examples:

  format_number(12345.6789)             yields   '12,345.68'
  format_number(123456.789, 2)          yields   '123,456.79'
  format_number(1234567.89, 2)          yields   '1,234,567.89'
  format_number(1234567.8, 2)           yields   '1,234,567.8'
  format_number(1234567.8, 2, 1)        yields   '1,234,567.80'
  format_number(1.23456789, 6)          yields   '1.234568'
  format_number("0.000020000E+00", 7);' yields   '2e-05'

Of course the output would have your values of C<THOUSANDS_SEP> and
C<DECIMAL_POINT> instead of ',' and '.' respectively.

=cut

sub format_number
{
    my ($self, $number, $precision, $trailing_zeroes, $mon) = _get_self @_;

    unless (defined($number))
    {
        _complain_undef();
        $number = 0;
    }

    $self->_check_seps();       # first make sure the SEP variables are valid

    my($thousands_sep, $decimal_point) =
        $mon ? @$self{qw(mon_thousands_sep mon_decimal_point)}
            : @$self{qw(thousands_sep decimal_point)};

    # Set defaults and standardize number
    $precision = $self->{decimal_digits}     unless defined $precision;
    $trailing_zeroes = $self->{decimal_fill} unless defined $trailing_zeroes;

    # Handle negative numbers
    my $sign = $number <=> 0;
    $number = abs($number) if $sign < 0;
    $number = $self->round($number, $precision); # round off $number

    # detect scientific notation
    my $exponent = 0;
    if ($number =~ /^(-?[\d.]+)e([+-]\d+)$/)
    {
        # Don't attempt to format numbers that require scientific notation.
        return $number;
    }

    # Split integer and decimal parts of the number and add commas
    my $integer = int($number);
    my $decimal;

    # Note: In perl 5.6 and up, string representation of a number
    # automagically includes the locale decimal point.  This way we
    # will detect the decimal part correctly as long as the decimal
    # point is 1 character.
    $decimal = substr($number, length($integer)+1)
        if (length($integer) < length($number));
    $decimal = '' unless defined $decimal;

    # Add trailing 0's if $trailing_zeroes is set.
    $decimal .= '0'x( $precision - length($decimal) )
        if $trailing_zeroes && $precision > length($decimal);

    # Add the commas (or whatever is in thousands_sep).  If
    # thousands_sep is the empty string, do nothing.
    if ($thousands_sep)
    {
        # Add leading 0's so length($integer) is divisible by 3
        $integer = '0'x(3 - (length($integer) % 3)).$integer;

        # Split $integer into groups of 3 characters and insert commas
        $integer = join($thousands_sep,
                        grep {$_ ne ''} split(/(...)/, $integer));

        # Strip off leading zeroes and optional thousands separator
        $integer =~ s/^0+(?:\Q$thousands_sep\E)?//;
    }
    $integer = '0' if $integer eq '';

    # Combine integer and decimal parts and return the result.
    my $result = ((defined $decimal && length $decimal) ?
                  join($decimal_point, $integer, $decimal) :
                  $integer);

    return ($sign < 0) ? $self->format_negative($result) : $result;
}

##----------------------------------------------------------------------

=item format_negative($number, $picture)

Formats a negative number.  Picture should be a string that contains
the letter C<x> where the number should be inserted.  For example, for
standard negative numbers you might use ``C<-x>'', while for
accounting purposes you might use ``C<(x)>''.  If the specified number
begins with a ``-'' character, that will be removed before formatting,
but formatting will occur whether or not the number is negative.

=cut

sub format_negative
{
    my($self, $number, $format) = _get_self @_;

    unless (defined($number))
    {
        _complain_undef();
        $number = 0;
    }

    $format = $self->{neg_format} unless defined $format;
    croak "Letter x must be present in picture in format_negative()"
        unless $format =~ /x/;
    $number =~ s/^-//;
    $format =~ s/x/$number/;
    return $format;
}

##----------------------------------------------------------------------

=item format_picture($number, $picture)

Returns a string based on C<$picture> with the C<#> characters
replaced by digits from C<$number>.  If the length of the integer part
of $number is too large to fit, the C<#> characters are replaced with
asterisks (C<*>) instead.  Examples:

  format_picture(100.023, 'USD ##,###.##')   yields   'USD    100.02'
  format_picture(1000.23, 'USD ##,###.##')   yields   'USD  1,000.23'
  format_picture(10002.3, 'USD ##,###.##')   yields   'USD 10,002.30'
  format_picture(100023,  'USD ##,###.##')   yields   'USD **,***.**'
  format_picture(1.00023, 'USD #.###,###')   yields   'USD 1.002,300'

The comma (,) and period (.) you see in the picture examples should
match the values of C<THOUSANDS_SEP> and C<DECIMAL_POINT>,
respectively, for proper operation.  However, the C<THOUSANDS_SEP>
characters in C<$picture> need not occur every three digits; the
I<only> use of that variable by this function is to remove leading
commas (see the first example above).  There may not be more than one
instance of C<DECIMAL_POINT> in C<$picture>.

The value of C<NEG_FORMAT> is used to determine how negative numbers
are displayed.  The result of this is that the output of this function
my have unexpected spaces before and/or after the number.  This is
necessary so that positive and negative numbers are formatted into a
space the same size.  If you are only using positive numbers and want
to avoid this problem, set NEG_FORMAT to "x".

=cut

sub format_picture
{
    my ($self, $number, $picture) = _get_self @_;

    unless (defined($number))
    {
        _complain_undef();
        $number = 0;
    }

    croak "Picture not defined" unless defined($picture);

    $self->_check_seps();

    # Handle negative numbers
    my($neg_prefix) = $self->{neg_format} =~ /^([^x]+)/;
    my($pic_prefix) = $picture            =~ /^([^\#]+)/;
    my $neg_pic = $self->{neg_format};
    (my $pos_pic = $self->{neg_format}) =~ s/[^x\s]/ /g;
    (my $pos_prefix = $neg_prefix) =~ s/[^x\s]/ /g;
    $neg_pic =~ s/x/$picture/;
    $pos_pic =~ s/x/$picture/;
    my $sign = $number <=> 0;
    $number = abs($number) if $sign < 0;
    $picture = $sign < 0 ? $neg_pic : $pos_pic;
    my $sign_prefix = $sign < 0 ? $neg_prefix : $pos_prefix;

    # Split up the picture and die if there is more than one $DECIMAL_POINT
    my($pic_int, $pic_dec, @cruft) =
        split(/\Q$self->{decimal_point}\E/, $picture);
    $pic_int = '' unless defined $pic_int;
    $pic_dec = '' unless defined $pic_dec;

    croak "Only one decimal separator permitted in picture"
        if @cruft;

    # Obtain precision from the length of the decimal part...
    my $precision = $pic_dec;       # start with copying it
    $precision =~ s/[^\#]//g;       # eliminate all non-# characters
    $precision = length $precision; # take the length of the result

    # Format the number
    $number = $self->round($number, $precision);

    # Obtain the length of the integer portion just like we did for $precision
    my $intsize = $pic_int;     # start with copying it
    $intsize =~ s/[^\#]//g;     # eliminate all non-# characters
    $intsize = length $intsize; # take the length of the result

    # Split up $number same as we did for $picture earlier
    my($num_int, $num_dec) = split(/\./, $number, 2);
    $num_int = '' unless defined $num_int;
    $num_dec = '' unless defined $num_dec;

    # Check if the integer part will fit in the picture
    if (length $num_int > $intsize)
    {
        $picture =~ s/\#/\*/g;  # convert # to * and return it
        $pic_prefix = "" unless defined $pic_prefix;
        $picture =~ s/^(\Q$sign_prefix\E)(\Q$pic_prefix\E)(\s*)/$2$3$1/;
        return $picture;
    }

    # Split each portion of number and picture into arrays of characters
    my @num_int = split(//, $num_int);
    my @num_dec = split(//, $num_dec);
    my @pic_int = split(//, $pic_int);
    my @pic_dec = split(//, $pic_dec);

    # Now we copy those characters into @result.
    my @result;
    @result = ($self->{decimal_point})
        if $picture =~ /\Q$self->{decimal_point}\E/;
    # For each characture in the decimal part of the picture, replace '#'
    # signs with digits from the number.
    my $char;
    foreach $char (@pic_dec)
    {
        $char = (shift(@num_dec) || 0) if ($char eq '#');
        push (@result, $char);
    }

    # For each character in the integer part of the picture (moving right
    # to left this time), replace '#' signs with digits from the number,
    # or spaces if we've run out of numbers.
    while ($char = pop @pic_int)
    {
        $char = pop(@num_int) if ($char eq '#');
        $char = ' ' if (!defined($char) ||
                        $char eq $self->{thousands_sep} && $#num_int < 0);
        unshift (@result, $char);
    }

    # Combine @result into a string and return it.
    my $result = join('', @result);
    $sign_prefix = '' unless defined $sign_prefix;
    $pic_prefix  = '' unless defined $pic_prefix;
    $result =~ s/^(\Q$sign_prefix\E)(\Q$pic_prefix\E)(\s*)/$2$3$1/;
    $result;
}

##----------------------------------------------------------------------

=item format_price($number, $precision, $symbol)

Returns a string containing C<$number> formatted similarly to
C<format_number()>, except that the decimal portion may have trailing
zeroes added to make it be exactly C<$precision> characters long, and
the currency string will be prefixed.

The C<$symbol> attribute may be one of "INT_CURR_SYMBOL" or
"CURRENCY_SYMBOL" (case insensitive) to use the value of that
attribute of the object, or a string containing the symbol to be used.
The default is "INT_CURR_SYMBOL" if this argument is undefined or not
given; if set to the empty string, or if set to undef and the
C<INT_CURR_SYMBOL> attribute of the object is the empty string, no
currency will be added.

If C<$precision> is not provided, the default of 2 will be used.
Examples:

  format_price(12.95)   yields   'USD 12.95'
  format_price(12)      yields   'USD 12.00'
  format_price(12, 3)   yields   '12.000'

The third example assumes that C<INT_CURR_SYMBOL> is the empty string.

=cut

sub format_price
{
    my ($self, $number, $precision, $curr_symbol) = _get_self @_;

    unless (defined($number))
    {
        _complain_undef();
        $number = 0;
    }

    # Determine what the monetary symbol should be
    $curr_symbol = $self->{int_curr_symbol}
        if (!defined($curr_symbol) || lc($curr_symbol) eq "int_curr_symbol");
    $curr_symbol = $self->{currency_symbol}
        if (!defined($curr_symbol) || lc($curr_symbol) eq "currency_symbol");
    $curr_symbol = "" unless defined($curr_symbol);

    # Determine which value to use for frac digits
    my $frac_digits = ($curr_symbol eq $self->{int_curr_symbol} ?
                       $self->{int_frac_digits} : $self->{frac_digits});

    # Determine precision for decimal portion
    $precision = $frac_digits            unless defined $precision;
    $precision = $self->{decimal_digits} unless defined $precision; # fallback
    $precision = 2                       unless defined $precision; # default

    # Determine sign and absolute value
    my $sign = $number <=> 0;
    $number = abs($number) if $sign < 0;

    # format it first
    $number = $self->format_number($number, $precision, undef, 1);

    # Now we make sure the decimal part has enough zeroes
    my ($integer, $decimal) =
        split(/\Q$self->{mon_decimal_point}\E/, $number, 2);
    $decimal = '0'x$precision unless $decimal;
    $decimal .= '0'x($precision - length $decimal);

    # Extract positive or negative values
    my($sep_by_space, $cs_precedes, $sign_posn, $sign_symbol);
    if ($sign < 0)
    {
        $sep_by_space = $self->{n_sep_by_space};
        $cs_precedes  = $self->{n_cs_precedes};
        $sign_posn    = $self->{n_sign_posn};
        $sign_symbol  = $self->{negative_sign};
    }
    else
    {
        $sep_by_space = $self->{p_sep_by_space};
        $cs_precedes  = $self->{p_cs_precedes};
        $sign_posn    = $self->{p_sign_posn};
        $sign_symbol  = $self->{positive_sign};
    }

    # Combine it all back together.
    my $result = ($precision ?
                  join($self->{mon_decimal_point}, $integer, $decimal) :
                  $integer);

    # Determine where spaces go, if any
    my($sign_sep, $curr_sep);
    if ($sep_by_space == 0)
    {
        $sign_sep = $curr_sep = "";
    }
    elsif ($sep_by_space == 1)
    {
        $sign_sep = "";
        $curr_sep = " ";
    }
    elsif ($sep_by_space == 2)
    {
        $sign_sep = " ";
        $curr_sep = "";
    }
    else
    {
        croak "Invalid sep_by_space value";
    }

    # Add sign, if any
    if ($sign_posn >= 0 && $sign_posn <= 2)
    {
        # Combine with currency symbol and return
        if ($curr_symbol ne "")
        {
            if ($cs_precedes)
            {
                $result = $curr_symbol.$curr_sep.$result;
            }
            else
            {
                $result = $result.$curr_sep.$curr_symbol;
            }
        }

        if ($sign_posn == 0)
        {
            return "($result)";
        }
        elsif ($sign_posn == 1)
        {
            return $sign_symbol.$sign_sep.$result;
        }
        else                    # $sign_posn == 2
        {
            return $result.$sign_sep.$sign_symbol;
        }
    }

    elsif ($sign_posn == 3 || $sign_posn == 4)
    {
        if ($sign_posn == 3)
        {
            $curr_symbol = $sign_symbol.$sign_sep.$curr_symbol;
        }
        else                    # $sign_posn == 4
        {
            $curr_symbol = $curr_symbol.$sign_sep.$sign_symbol;
        }

        # Combine with currency symbol and return
        if ($cs_precedes)
        {
            return $curr_symbol.$curr_sep.$result;
        }
        else
        {
            return $result.$curr_sep.$curr_symbol;
        }
    }

    else
    {
        croak "Invalid *_sign_posn value";
    }
}

##----------------------------------------------------------------------

=item format_bytes($number, %options)

=item format_bytes($number, $precision)  # deprecated

Returns a string containing C<$number> formatted similarly to
C<format_number()>, except that large numbers may be abbreviated by
adding a suffix to indicate 1024, 1,048,576, or 1,073,741,824 bytes.
Suffix may be the traditional K, M, or G (default); or the IEC
standard 60027 "KiB," "MiB," or "GiB" depending on the "mode" option.

Negative values will result in an error.

The second parameter can be either a hash that sets options, or a
number.  Using a number here is deprecated and will generate a
warning; early versions of Number::Format only allowed a numeric
value.  A future release of Number::Format will change this warning to
an error.  New code should use a hash instead to set options.  If it
is a number this sets the value of the "precision" option.

Valid options are:

=over 4

=item precision

Set the precision for displaying numbers.  If not provided, a default
of 2 will be used.  Examples:

  format_bytes(12.95)                   yields   '12.95'
  format_bytes(12.95, precision => 0)   yields   '13'
  format_bytes(2048)                    yields   '2K'
  format_bytes(2048, mode => "iec")     yields   '2KiB'
  format_bytes(9999999)                 yields   '9.54M'
  format_bytes(9999999, precision => 1) yields   '9.5M'

=item unit

Sets the default units used for the results.  The default is to
determine this automatically in order to minimize the length of the
string.  In other words, numbers greater than or equal to 1024 (or
other number given by the 'base' option, q.v.) will be divided by 1024
and C<$KILO_SUFFIX> or C<$KIBI_SUFFIX> added; if greater than or equal
to 1048576 (1024*1024), it will be divided by 1048576 and
C<$MEGA_SUFFIX> or C<$MEBI_SUFFIX> appended to the end; etc.

However if a value is given for C<unit> it will use that value
instead.  The first letter (case-insensitive) of the value given
indicates the threshhold for conversion; acceptable values are G (for
giga/gibi), M (for mega/mebi), K (for kilo/kibi), or A (for automatic,
the default).  For example:

  format_bytes(1048576, unit => 'K') yields     '1,024K'
                                     instead of '1M'

Note that the valid values to this option do not vary even when the
suffix configuration variables have been changed.

=item base

Sets the number at which the C<$KILO_SUFFIX> is added.  Default is
1024.  Set to any value; the only other useful value is probably 1000,
as hard disk manufacturers use that number to make their disks sound
bigger than they really are.

If the mode (see below) is set to "iec" or "iec60027" then setting the
base option results in an error.

=item mode

Traditionally, bytes have been given in SI (metric) units such as
"kilo" and "mega" even though they represent powers of 2 (1024, etc.)
rather than powers of 10 (1000, etc.)  This "binary prefix" causes
much confusion in consumer products where "GB" may mean either
1,048,576 or 1,000,000, for example.  The International
Electrotechnical Commission has created standard IEC 60027 to
introduce prefixes Ki, Mi, Gi, etc. ("kibibytes," "mebibytes,"
"gibibytes," etc.) to remove this confusion.  Specify a mode option
with either "traditional" or "iec60027" (or abbreviate as "trad" or
"iec") to indicate which type of binary prefix you want format_bytes
to use.  For backward compatibility, "traditional" is the default.
See http://en.wikipedia.org/wiki/Binary_prefix for more information.

=back

=cut

sub format_bytes
{
    my ($self, $number, @options) = _get_self @_;

    unless (defined($number))
    {
        _complain_undef();
        $number = 0;
    }

    croak "Negative number not allowed in format_bytes"
        if $number < 0;

    # If a single scalar is given instead of key/value pairs for
    # @options, treat that as the value of the precision option.
    my %options;
    if (@options == 1)
    {
        # To be changed to 'croak' in a future release:
        carp "format_bytes: number instead of options is deprecated";
        %options = ( precision => $options[0] );
    }
    else
    {
        %options = @options;
    }

    # Set default for precision.  Test using defined because it may be 0.
    $options{precision} = $self->{decimal_digits}
        unless defined $options{precision};
    $options{precision} = 2
        unless defined $options{precision}; # default

    $options{mode} ||= "traditional";
    my($ksuff, $msuff, $gsuff);
    if ($options{mode} =~ /^iec(60027)?$/i)
    {
        ($ksuff, $msuff, $gsuff) =
            @$self{qw(kibi_suffix mebi_suffix gibi_suffix)};
        croak "base option not allowed in iec60027 mode"
            if exists $options{base};
    }
    elsif ($options{mode} =~ /^trad(itional)?$/i)
    {
        ($ksuff, $msuff, $gsuff) =
            @$self{qw(kilo_suffix mega_suffix giga_suffix)};
    }
    else
    {
        croak "Invalid mode";
    }

    # Set default for "base" option.  Calculate threshold values for
    # kilo, mega, and giga values.  On 32-bit systems tera would cause
    # overflows so it is not supported.  Useful values of "base" are
    # 1024 or 1000, but any number can be used.  Larger numbers may
    # cause overflows for giga or even mega, however.
    my %mult = _get_multipliers($options{base});

    # Process "unit" option.  Set default, then take first character
    # and convert to upper case.
    $options{unit} = "auto"
        unless defined $options{unit};
    my $unit = uc(substr($options{unit},0,1));

    # Process "auto" first (default).  Based on size of number,
    # automatically determine which unit to use.
    if ($unit eq 'A')
    {
        if ($number >= $mult{giga})
        {
            $unit = 'G';
        }
        elsif ($number >= $mult{mega})
        {
            $unit = 'M';
        }
        elsif ($number >= $mult{kilo})
        {
            $unit = 'K';
        }
        else
        {
            $unit = 'N';
        }
    }

    # Based on unit, whether specified or determined above, divide the
    # number and determine what suffix to use.
    my $suffix = "";
    if ($unit eq 'G')
    {
        $number /= $mult{giga};
        $suffix = $gsuff;
    }
    elsif ($unit eq 'M')
    {
        $number /= $mult{mega};
        $suffix = $msuff;
    }
    elsif ($unit eq 'K')
    {
        $number /= $mult{kilo};
        $suffix = $ksuff;
    }
    elsif ($unit ne 'N')
    {
        croak "Invalid unit option";
    }

    # Format the number and add the suffix.
    return $self->format_number($number, $options{precision}) . $suffix;
}

##----------------------------------------------------------------------

=item unformat_number($formatted)

Converts a string as returned by C<format_number()>,
C<format_price()>, or C<format_picture()>, and returns the
corresponding value as a numeric scalar.  Returns C<undef> if the
number does not contain any digits.  Examples:

  unformat_number('USD 12.95')   yields   12.95
  unformat_number('USD 12.00')   yields   12
  unformat_number('foobar')      yields   undef
  unformat_number('1234-567@.8') yields   1234567.8

The value of C<DECIMAL_POINT> is used to determine where to separate
the integer and decimal portions of the input.  All other non-digit
characters, including but not limited to C<INT_CURR_SYMBOL> and
C<THOUSANDS_SEP>, are removed.

If the number matches the pattern of C<NEG_FORMAT> I<or> there is a
``-'' character before any of the digits, then a negative number is
returned.

If the number ends with the C<KILO_SUFFIX>, C<KIBI_SUFFIX>,
C<MEGA_SUFFIX>, C<MEBI_SUFFIX>, C<GIGA_SUFFIX>, or C<GIBI_SUFFIX>
characters, then the number returned will be multiplied by the
appropriate multiple of 1024 (or if the base option is given, by the
multiple of that value) as appropriate.  Examples:

  unformat_number("4K", base => 1024)   yields  4096
  unformat_number("4K", base => 1000)   yields  4000
  unformat_number("4KiB", base => 1024) yields  4096
  unformat_number("4G")                 yields  4294967296

=cut

sub unformat_number
{
    my ($self, $formatted, %options) = _get_self @_;

    unless (defined($formatted))
    {
        _complain_undef();
        $formatted = "";
    }

    $self->_check_seps();
    return undef unless $formatted =~ /\d/; # require at least one digit

    # Regular expression for detecting decimal point
    my $pt = qr/\Q$self->{decimal_point}\E/;

    # ru_RU locale has comma for decimal_point, but period for
    # mon_decimal_point!  But as long as thousands_sep is different
    # from either, we can allow either decimal point.
    if ($self->{mon_decimal_point} &&
        $self->{decimal_point} ne $self->{mon_decimal_point} &&
        $self->{decimal_point} ne $self->{mon_thousands_sep} &&
        $self->{mon_decimal_point} ne $self->{thousands_sep})
    {
        $pt = qr/(?:\Q$self->{decimal_point}\E|
                    \Q$self->{mon_decimal_point}\E)/x;
    }

    # Detect if it ends with one of the kilo / mega / giga suffixes.
    my $kp = ($formatted =~
              s/\s*($self->{kilo_suffix}|$self->{kibi_suffix})\s*$//);
    my $mp = ($formatted =~
              s/\s*($self->{mega_suffix}|$self->{mebi_suffix})\s*$//);
    my $gp = ($formatted =~
              s/\s*($self->{giga_suffix}|$self->{gibi_suffix})\s*$//);
    my %mult = _get_multipliers($options{base});

    # Split number into integer and decimal parts
    my ($integer, $decimal, @cruft) = split($pt, $formatted);
    croak "Only one decimal separator permitted"
        if @cruft;

    # It's negative if the first non-digit character is a -
    my $sign = $formatted =~ /^\D*-/ ? -1 : 1;
    my($before_re, $after_re) = split /x/, $self->{neg_format}, 2;
    $sign = -1 if $formatted =~ /\Q$before_re\E(.+)\Q$after_re\E/;

    # Strip out all non-digits from integer and decimal parts
    $integer = '' unless defined $integer;
    $decimal = '' unless defined $decimal;
    $integer =~ s/\D//g;
    $decimal =~ s/\D//g;

    # Join back up, using period, and add 0 to make Perl think it's a number
    my $number = join('.', $integer, $decimal) + 0;
    $number = -$number if $sign < 0;

    # Scale the number if it ended in kilo or mega suffix.
    $number *= $mult{kilo} if $kp;
    $number *= $mult{mega} if $mp;
    $number *= $mult{giga} if $gp;

    return $number;
}

###---------------------------------------------------------------------

=back

=head1 CAVEATS

Some systems, notably OpenBSD, may have incomplete locale support.
Using this module together with L<setlocale(3)> in OpenBSD may therefore
not produce the intended results.

=head1 BUGS

No known bugs at this time.  Report bugs using the CPAN request
tracker at L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Number-Format>
or by email to the author.

=head1 AUTHOR

William R. Ward, SwPrAwM@cpan.org (remove "SPAM" before sending email,
leaving only my initials)

=head1 SEE ALSO

perl(1).

=cut

1;
