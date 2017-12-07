
package Statistics::Basic::Covariance;

use strict;
use warnings;
use Carp;

use base 'Statistics::Basic::_TwoVectorBase';

# new {{{
sub new {
    my $class = shift;
    my @var1  = (shift || ());
    my @var2  = (shift || ());
    my $v1    = eval { Statistics::Basic::Vector->new( @var1 ) } or croak $@;
    my $v2    = eval { Statistics::Basic::Vector->new( @var2 ) } or croak $@;

    my $c = $v1->_get_linked_computer( covariance => $v2 );
    return $c if $c;

    my $this = bless({'v1'=>$v1, 'v2'=>$v2}, $class);
    warn "[new " . ref($this) . " v1:$this->{v1} v2:$this->{v2}]\n" if $Statistics::Basic::DEBUG >= 2;

    $this->{_vectors} = [ $v1, $v2 ];

    $this->{m1} = eval { Statistics::Basic::Mean->new($v1) } or croak $@;
    $this->{m2} = eval { Statistics::Basic::Mean->new($v2) } or croak $@;

    $v1->_set_linked_computer( covariance => $this, $v2 );
    $v2->_set_linked_computer( covariance => $this, $v1 );

    return $this;
}
# }}}
# _recalc {{{
sub _recalc {
    my $this = shift;
    my $sum  = 0;
    my $v1   = $this->{v1};
    my $v2   = $this->{v2};
    my $c1   = $v1->query_size;
    my $c2   = $v2->query_size;

    warn "[recalc " . ref($this) . "] (\$c1, \$c2) = ($c1, $c2)\n" if $Statistics::Basic::DEBUG;

    confess "the two vectors in a " . ref($this) . " object must be the same length ($c2!=$c1)" unless $c2 == $c1;

    my $cardinality = $c1;
       $cardinality -- if $Statistics::Basic::UNBIAS;

    delete $this->{recalc_necessary};
    delete $this->{_value};
    return unless $cardinality > 0;
    return unless $v1->query_filled;
    return unless $v2->query_filled;

    $v1 = $v1->query;
    $v2 = $v2->query;

    my $m1 = $this->{m1}->query;
    my $m2 = $this->{m2}->query;

    if( $Statistics::Basic::DEBUG >= 2 ) {
        for my $i (0 .. $#$v1) {
            warn "[recalc " . ref($this) . "] ( $v1->[$i] - $m1 ) * ( $v2->[$i] - $m2 )\n";
        }
    }

    for my $i (0 .. $#$v1) {
        no warnings 'uninitialized'; ## no critic
        $sum += ( $v1->[$i] - $m1 ) * ( $v2->[$i] - $m2 );
    }

    $this->{_value} = ($sum / $cardinality);

    warn "[recalc " . ref($this) . "] ($sum/$cardinality) = $this->{_value}\n" if $Statistics::Basic::DEBUG;

    return;
}
# }}}

# query_vector1 {{{
sub query_vector1 {
    my $this = shift;

    return $this->{v1};
}
# }}}
# query_vector2 {{{
sub query_vector2 {
    my $this = shift;

    return $this->{v2};
}
# }}}
# query_mean1 {{{
sub query_mean1 {
    my $this = shift;

    return $this->{m1};
}
# }}}
# query_mean2 {{{
sub query_mean2 {
    my $this = shift;

    return $this->{m2};
}
# }}}

1;
