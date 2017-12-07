package Statistics::Basic::Variance;

use strict;
use warnings;
use Carp;

use base 'Statistics::Basic::_OneVectorBase';

sub new {
    my $class = shift;

    warn "[new $class]\n" if $Statistics::Basic::DEBUG >= 2;

    my $this   = bless {}, $class;
    my $vector = eval { Statistics::Basic::Vector->new(@_) } or croak $@;
    my $c      = $vector->_get_computer("variance"); return $c if defined $c;

    $this->{v} = $vector;
    $this->{m} = eval { Statistics::Basic::Mean->new($vector) } or croak $@;

    $vector->_set_computer( variance => $this );

    return $this;
}

sub _recalc {
    my $this = shift;
    my $first = shift;

    delete $this->{recalc_needed};
    delete $this->{_value};

    my $mean = $this->{m}->query;
    return unless defined $mean;

    my $v = $this->{v};
    my $cardinality = $v->query_size;
       $cardinality -- if $Statistics::Basic::UNBIAS;
    return unless $cardinality > 0;

    if( $Statistics::Basic::DEBUG >= 2 ) {
        warn "[recalc " . ref($this) . "] ( $_ - $mean ) ** 2\n" for $v->query;
    }

    my $sum = 0; { no warnings 'uninitialized'; ## no critic
       $sum += ( $_ - $mean ) ** 2 for $v->query;
    }

    $this->{_value} = ($sum / $cardinality);

    warn "[recalc " . ref($this) . "] ($sum/$cardinality) = $this->{_value}\n" if $Statistics::Basic::DEBUG;

    return;
}

sub query_mean { return $_[0]->{m} }

1;
