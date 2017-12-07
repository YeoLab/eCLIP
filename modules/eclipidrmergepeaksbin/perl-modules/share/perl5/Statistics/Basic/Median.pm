
package Statistics::Basic::Median;

use strict;
use warnings;
use Carp;

use base 'Statistics::Basic::_OneVectorBase';

sub new {
    my $class = shift;

    warn "[new $class]\n" if $Statistics::Basic::DEBUG >= 2;

    my $this   = bless {}, $class;
    my $vector = eval { Statistics::Basic::Vector->new(@_) } or croak $@;
    my $c      = $vector->_get_computer("median"); return $c if defined $c;

    $this->{v} = $vector;

    $vector->_set_computer( median => $this );

    return $this;
}

sub _recalc {
    my $this = shift;
    my $v = $this->{v};
    my $cardinality = $v->query_size;

    delete $this->{recalc_needed};
    delete $this->{_value};
    return unless $cardinality > 0;
    return unless $v->query_filled; # only applicable in certain circumstances

    my @v = (sort {$a <=> $b} ($v->query));
    my $center = int($cardinality/2);

    { no warnings 'uninitialized'; ## no critic
        if ($cardinality%2) {
            $this->{_value} = $v[$center];

        } else {
            $this->{_value} = ($v[$center] + $v[$center-1])/2;
        }
    }

    warn "[recalc " . ref($this) . "] vector[int($cardinality/2)] = $this->{_value}\n" if $Statistics::Basic::DEBUG;

    return;
}

1;
