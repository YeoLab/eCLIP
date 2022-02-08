
package Statistics::Basic;

use strict;
use warnings;
use Carp;

use Number::Format;

our $VERSION = '1.6611';
our $fmt = new Number::Format;

our( $NOFILL, $DEBUG, $IPRES, $TOLER, $UNBIAS );

BEGIN {
    $NOFILL = exists($ENV{NOFILL})        ? $ENV{NOFILL}        : 0;
    $DEBUG  = exists($ENV{DEBUG_STATS_B}) ? $ENV{DEBUG_STATS_B} : 0;
    $IPRES  = exists($ENV{IPRES})         ? $ENV{IPRES}         : 2;
    $TOLER  = $ENV{TOLER} if exists $ENV{TOLER};
}

use base 'Exporter';

our @EXPORT_OK   = (qw(
    vector computed
    mean average avg
    median
    mode
    variance var
    stddev
    covariance cov
    correlation cor corr
    leastsquarefit LSF lsf
    handle_missing_values handle_missing
));
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

sub import {
    my @special = ();

    @_ = grep { m/^(ignore_env|nofill|debug|ipres|toler|unbias)(?:=([\d\.\-_]+))?\z/i
        ? do {push @special, [lc($1), $2]; 0} : 1 }
        @_;

    if( grep {$_->[0] =~ m/ignore_env/} @special ) {
        delete $ENV{TOLER};
        $NOFILL = 0;
        $DEBUG  = 0;
        $IPRES  = 2;
        $TOLER  = undef;
        $UNBIAS = 0;
    }

    for( grep {$_->[0] !~ m/ignore_env/} @special ) {
        my ($k, $v) = @$_;
        $v = eval $v if defined $v; ## no critic

        if( lc($k) eq "ipres" ) {
            $v = 2 unless defined($v);
            croak "bad ipres value ($v)" unless $v >= 0;
            $IPRES = $v;

        } elsif( lc($k) eq "toler" ) {
            if( defined $v ) {
                croak "bad toler value($v)" unless $v >= 0;
                $TOLER = $v;

            } else {
                $TOLER = undef;
            }

        } else {
            no strict 'refs'; ## no critic
            ${uc($k)} = defined($v) ? $v : 1; ## no critic
        }
    }

    my $pull = q {

        use Statistics::Basic::Covariance;
        use Statistics::Basic::Correlation;
        use Statistics::Basic::LeastSquareFit;
        use Statistics::Basic::Mean;
        use Statistics::Basic::Median;
        use Statistics::Basic::Mode;
        use Statistics::Basic::StdDev;
        use Statistics::Basic::Variance;
        use Statistics::Basic::Vector;
        use Statistics::Basic::ComputedVector;

        1;

    };

    eval $pull or die "problem loading base modules: $@"; ## no critic

    return __PACKAGE__->export_to_level(1, @_);
}

sub computed { my $r = eval { Statistics::Basic::ComputedVector->new(@_) } or croak $@; return $r }

sub vector   { my $r = eval { Statistics::Basic::Vector->new(@_)   } or croak $@; return $r }
sub mean     { my $r = eval { Statistics::Basic::Mean->new(@_)     } or croak $@; return $r }
sub median   { my $r = eval { Statistics::Basic::Median->new(@_)   } or croak $@; return $r }
sub mode     { my $r = eval { Statistics::Basic::Mode->new(@_)     } or croak $@; return $r }
sub variance { my $r = eval { Statistics::Basic::Variance->new(@_) } or croak $@; return $r }
sub stddev   { my $r = eval { Statistics::Basic::StdDev->new(@_)   } or croak $@; return $r }

sub covariance     { my $r = eval { Statistics::Basic::Covariance->new(     $_[0], $_[1] ) } or croak $@; return $r }
sub correlation    { my $r = eval { Statistics::Basic::Correlation->new(    $_[0], $_[1] ) } or croak $@; return $r }
sub leastsquarefit { my $r = eval { Statistics::Basic::LeastSquareFit->new( $_[0], $_[1] ) } or croak $@; return $r }

sub handle_missing_values {
    my ($v1,$v2) = @_;

    my $v3 = eval { computed($v1) } or croak $@;
    my $v4 = eval { computed($v2) } or croak $@;

    $v3->set_filter(sub {
        my @v = $v2->query;
        map {$_[$_]} grep { defined $v[$_] and defined $_[$_] } 0 .. $#_;
    });

    $v4->set_filter(sub {
        my @v = $v1->query;
        map {$_[$_]} grep { defined $v[$_] and defined $_[$_] } 0 .. $#_;
    });

    return ($v3,$v4);
}
*handle_missing = \&handle_missing_values;

*average = *mean;
*avg     = *mean;
*var     = *variance;

*cov  = *covariance;
*cor  = *correlation;
*corr = *correlation;
*lsf  = *leastsquarefit;
*LSF  = *leastsquarefit;

1;
