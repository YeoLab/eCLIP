package Statistics::Basic::_TwoVectorBase;

use strict;
use warnings;
use Carp;

use Statistics::Basic; # make sure all the basic classes are loaded

use overload
    '""' => sub { defined( my $v = $_[0]->query ) || return "n/a"; $Statistics::Basic::fmt->format_number("$v", $Statistics::Basic::IPRES) },
    '0+' => sub { $_[0]->query },
    ( defined($Statistics::Basic::TOLER) ? ('==' => sub { abs($_[0]-$_[1])<=$Statistics::Basic::TOLER }) : () ),
    'eq' => sub { "$_[0]" eq "$_[1]" },
    'bool' => sub { 1 },
    fallback => 1; # tries to do what it would have done if this wasn't present.

# query {{{
sub query {
    my $this = shift;

    $this->_recalc if $this->{recalc_needed};

    warn "[query " . ref($this) . " $this->{_value}]\n" if $Statistics::Basic::DEBUG;

    return $this->{_value};
}
# }}}
# query_size {{{
sub query_size {
    my $this = shift;

    my @v = @{$this->{_vectors}};
    return ($v[0]->query_size, $v[1]->query_size); # list rather than map{} so this can be a scalar
}

# maybe deprecate this later
*size = \&query_size unless $ENV{TEST_AUTHOR};

# }}}
# set_size {{{
sub set_size {
    my $this = shift;
    my $size = shift;
    my $nofl = shift;

    eval { $_->set_size($size, $nofl) for @{$this->{_vectors}}; 1 } or croak $@;

    return $this;
}
# }}}
# insert {{{
sub insert {
    my $this = shift;

    warn "[insert " . ref($this) . "]\n" if $Statistics::Basic::DEBUG;

    croak ref($this) . "-insert() takes precisely two arguments.  They can be arrayrefs if you like." unless 2 == int @_;

    my $c = 0;
    $_->insert( $_[$c++] ) for @{$this->{_vectors}};

    return $this;
}
# }}}
# ginsert {{{
sub ginsert {
    my $this = shift;

    warn "[ginsert " . ref($this) . "]\n" if $Statistics::Basic::DEBUG;

    croak "" . ref($this) . "-ginsert() takes precisely two arguments.  They can be arrayrefs if you like." 
        unless 2 == int @_;

    my $c = 0;
    $_->ginsert( $_[$c++] ) for @{$this->{_vectors}};

    my @s = $this->query_size;
    croak "Uneven ginsert detected, the two vectors in a " . ref($this) . " object must remain the same length."
        unless $s[0] == $s[1];

    return $this;
}
*append = \&ginsert;
# }}}
# set_vector {{{
sub set_vector {
    my $this = shift;

    warn "[set_vector " . ref($this) . "]\n" if $Statistics::Basic::DEBUG;

    croak "this set_vector() takes precisely two arguments.  They can be arrayrefs if you like." 
        unless 2 == int @_;

    my $c = 0;
    $_->set_vector( $_[$c++] ) for @{$this->{_vectors}};

    my @s = $this->query_size;
    croak "Uneven set_vector detected, the two vectors in a " . ref($this) . " object must remain the same length."
        unless $s[0] == $s[1];

    return $this;
}
# }}}
# _recalc_needed {{{
sub _recalc_needed {
    my $this = shift;
       $this->{recalc_needed} = 1;

    warn "[recalc_needed " . ref($this) . "]\n" if $Statistics::Basic::DEBUG;

    return;
}
# }}}

1;
