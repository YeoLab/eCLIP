
package Statistics::Basic::Mean;

use strict;
use warnings;
use Carp;

use base 'Statistics::Basic::_OneVectorBase';

sub new {
    my $class = shift;

    warn "[new $class]\n" if $Statistics::Basic::DEBUG >= 2;

    my $this   = bless {}, $class;
    my $vector = eval { Statistics::Basic::Vector->new(@_) } or croak $@;
    my $c      = $vector->_get_computer("mean"); return $c if defined $c;

    $this->{v} = $vector;

    $vector->_set_computer( mean => $this );

    return $this;
}

sub _recalc {
    my $this = shift;
    my $sum = 0;
    my $v = $this->{v};
    my $cardinality = $v->query_size;

    delete $this->{recalc_needed};
    delete $this->{_value};

    return unless $cardinality > 0;
    return unless $v->query_filled; # only applicable in certain circumstances

    { no warnings 'uninitialized'; ## no critic
      $sum += $_ for $v->query;
    }

    $this->{_value} = ($sum / $cardinality);

    warn "[recalc " . ref($this) . "] ($sum/$cardinality) = $this->{_value}\n" if $Statistics::Basic::DEBUG;

    return;
}

1;
