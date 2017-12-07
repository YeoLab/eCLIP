
package Statistics::Basic::Mode;

use strict;
use warnings;
use Carp;

use Statistics::Basic;
use Scalar::Util qw(blessed);
use base 'Statistics::Basic::_OneVectorBase';

use overload
    '""' => sub {
        defined( my $q = $_[0]->query ) or return "n/a";
        return $q if ref $q; # vectors interpolate themselves
        $Statistics::Basic::fmt->format_number($_[0]->query, $Statistics::Basic::IPRES);
    },
    '0+' => sub {
        my $q = $_[0]->query;
        croak "result is multimodal and cannot be used as a number" if ref $q;
        $q;
    },
    fallback => 1; # tries to do what it would have done if this wasn't present.

sub new {
    my $class = shift;

    warn "[new $class]\n" if $Statistics::Basic::DEBUG >= 2;

    my $this   = bless {}, $class;
    my $vector = eval { Statistics::Basic::Vector->new(@_) } or croak $@;
    my $c      = $vector->_get_computer("mode"); return $c if defined $c;

    $this->{v} = $vector;

    $vector->_set_computer( mode => $this );

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

    my %mode;
    my $max = 0;

    for my $val ($v->query) {
        no warnings 'uninitialized'; ## no critic
        my $t = ++ $mode{$val};
        $max = $t if $t > $max;
    }
    my @a = sort {$a<=>$b} grep { $mode{$_}==$max } keys %mode;

    $this->{_value} = ( (@a == 1) ?  $a[0] : Statistics::Basic::Vector->new(\@a) );

    warn "[recalc " . ref($this) . "] count of $this->{_value} = $max\n" if $Statistics::Basic::DEBUG;

    return;
}

sub is_multimodal {
    my $this = shift;
    my $that = $this->query;

    return (blessed($that) ? 1:0);
}

1;
