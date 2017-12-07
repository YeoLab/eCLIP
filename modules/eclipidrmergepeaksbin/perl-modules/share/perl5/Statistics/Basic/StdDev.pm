
package Statistics::Basic::StdDev;

use strict;
use warnings;
use Carp;

use base 'Statistics::Basic::_OneVectorBase';

sub new {
    my $class = shift;

    warn "[new $class]\n" if $Statistics::Basic::DEBUG >= 2;

    my $this     = bless {}, $class;
    my $variance = $this->{V} = eval { Statistics::Basic::Variance->new(@_) } or croak $@;
    my $vector   = $this->{v} = $variance->query_vector;
    my $c        = $vector->_get_computer( 'stddev' ); return $c if defined $c;

    $vector->_set_computer( stddev => $this );

    return $this;
}

sub _recalc {
    my $this  = shift;
    my $first = shift;

    delete $this->{recalc_needed};

    my $var = $this->{V}->query;
    return unless defined $var;
    # no need to query filled here, variance does it for us

    warn "[recalc " . ref($this) . "] sqrt( $var )\n" if $Statistics::Basic::DEBUG;

    $this->{_value} = sqrt( $var );

    return;
}

sub query_mean {
    my $this = shift;

    return $this->{V}->query_mean;
}

1;
