
package Statistics::Basic::LeastSquareFit;

use strict;
use warnings;
use Carp;

use base 'Statistics::Basic::_TwoVectorBase';

use overload
    '""' => sub {
        my ($alpha,$beta) = map{$Statistics::Basic::fmt->format_number($_, $Statistics::Basic::IPRES)} $_[0]->query;
        "LSF( alpha: $alpha, beta: $beta )";
    },
    '0+' => sub { croak "the result of LSF may not be used as a number" },
    fallback => 1; # tries to do what it would have done if this wasn't present.

# new {{{
sub new {
    my $this = shift;
    my @var1  = (shift || ());
    my @var2  = (shift || ());
    my $v1    = eval { Statistics::Basic::Vector->new( @var1 ) } or croak $@;
    my $v2    = eval { Statistics::Basic::Vector->new( @var2 ) } or croak $@;

    $this = bless {}, $this;

    my $c = $v1->_get_linked_computer( LSF => $v2 );
    return $c if $c;

    $this->{_vectors} = [ $v1, $v2 ];

    $this->{vrx} = eval { Statistics::Basic::Variance->new($v1)        } or croak $@;
    $this->{mnx} = eval { Statistics::Basic::Mean->new($v1)            } or croak $@;
    $this->{mny} = eval { Statistics::Basic::Mean->new($v2)            } or croak $@;
    $this->{cov} = eval { Statistics::Basic::Covariance->new($v1, $v2) } or croak $@;

    $v1->_set_linked_computer( LSF => $this, $v2 );
    $v2->_set_linked_computer( LSF => $this, $v1 );

    return $this;
}
# }}}
# _recalc {{{
sub _recalc {
    my $this  = shift;

    delete $this->{recalc_needed};
    delete $this->{alpha};
    delete $this->{beta};

    my $vrx = $this->{vrx}->query; return unless defined $vrx; return unless $vrx > 0;
    my $mnx = $this->{mnx}->query; return unless defined $mnx;
    my $mny = $this->{mny}->query; return unless defined $mny;
    my $cov = $this->{cov}->query; return unless defined $cov;

    $this->{beta}  = ($cov / $vrx);
    $this->{alpha} = ($mny - ($this->{beta} * $mnx));

    warn "[recalc " . ref($this) . "] (alpha: $this->{alpha}, beta: $this->{beta})\n" if $Statistics::Basic::DEBUG;

    return;
}
# }}}
# query {{{
sub query {
    my $this = shift;

    $this->_recalc if $this->{recalc_needed};

    warn "[query " . ref($this) . " ($this->{alpha}, $this->{beta})]\n" if $Statistics::Basic::DEBUG;

    return (wantarray ? ($this->{alpha}, $this->{beta}) : [$this->{alpha}, $this->{beta}] );
}
# }}}

# query_vector1 {{{
sub query_vector1 {
    my $this = shift;

    return $this->{cov}->query_vector1;
}
# }}}
# query_vector2 {{{
sub query_vector2 {
    my $this = shift;

    return $this->{cov}->query_vector2;
}
# }}}
# query_mean1 {{{
sub query_mean1 {
    my $this = shift;

    return $this->{mnx};
}
# }}}
# query_variance1 {{{
sub query_variance1 {
    my $this = shift;

    return $this->{vrx};
}
# }}}
# query_covariance {{{
sub query_covariance {
    my $this = shift;

    return $this->{cov};
}
# }}}

# y_given_x {{{
sub y_given_x {
    my $this = shift;
    my ($alpha, $beta) = $this->query;
    my $x = shift;

    return ($beta*$x + $alpha);
}
# }}}
# x_given_y {{{
sub x_given_y {
    my $this = shift;
    my ($alpha, $beta) = $this->query;
    my $y = shift;

    defined( my $x = eval { ( ($y-$alpha)/$beta ) }) or croak $@;
    return $x;
}
# }}}

1;
