package Statistics::Basic::_OneVectorBase;

use strict;
use warnings;
use Carp;

use Statistics::Basic; # make sure all the basic classes are loaded

use overload
    '""' => sub { defined( my $v = $_[0]->query ) or return "n/a"; $Statistics::Basic::fmt->format_number("$v", $Statistics::Basic::IPRES) },
    '0+' => sub { $_[0]->query },
    ( defined($Statistics::Basic::TOLER) ? ('==' => sub { abs($_[0]-$_[1])<=$Statistics::Basic::TOLER }) : () ),
    'eq' => sub { "$_[0]" eq "$_[1]" },
    'bool' => sub { 1 },
    fallback => 1; # tries to do what it would have done if this wasn't present.

# _recalc_needed {{{
sub _recalc_needed {
    my $this = shift;
       $this->{recalc_needed} = 1;

    warn "[recalc_needed " . ref($this) . "]\n" if $Statistics::Basic::DEBUG;

    return;
}
# }}}
# query {{{
sub query {
    my $this = shift;

    $this->_recalc if $this->{recalc_needed};

    warn "[query " . ref($this) . " $this->{_value}]\n" if $Statistics::Basic::DEBUG;

    return $this->{_value};
}
# }}}
# query_vector {{{
sub query_vector {
    my $this = shift;

    return $this->{v};
}
# }}}

# query_size {{{
sub query_size {
    my $this = shift;

    return $this->{v}->query_size;
}

# maybe deprecate this later
*size = \&query_size unless $ENV{TEST_AUTHOR};

# }}}
# set_size {{{
sub set_size {
    my $this = shift;
    my $size = shift;
    my $nofl = shift;

    eval { $this->{v}->set_size($size, $nofl) } or croak $@;

    return $this;
}
# }}}
# set_vector {{{
sub set_vector {
    my $this = shift;

    warn "[set_vector " . ref($this) . "]\n" if $Statistics::Basic::DEBUG;

    $this->{v}->set_vector(@_);

    return $this;
}
# }}}
# insert {{{
sub insert {
    my $this = shift;

    warn "[insert " . ref($this) . "]\n" if $Statistics::Basic::DEBUG;

    $this->{v}->insert(@_);

    return $this;
}
# }}}
# ginsert {{{
sub ginsert {
    my $this = shift;

    warn "[ginsert " . ref($this) . "]\n" if $Statistics::Basic::DEBUG;

    $this->{v}->ginsert(@_);

    return $this;
}

*append = \&ginsert;
# }}}

1;
