package Statistics::Basic::Vector;

use strict;
use warnings;
use Carp;
use Scalar::Util qw(blessed weaken looks_like_number);

our $tag_number = 0;

use Statistics::Basic;

use overload
    '0+' => sub { croak "attempt to use vector as scalar numerical value" },
    '""' => sub {
        my $this = $_[0];
        local $" = ", ";
        my @r = map { defined $_ ? $Statistics::Basic::fmt->format_number($_, $Statistics::Basic::IPRES) : "_" } $this->query;
        $Statistics::Basic::DEBUG ? "vector-$this->{tag}:[@r]" : "[@r]";
    },
    'bool' => sub { 1 },
    fallback => 1; # tries to do what it would have done if this wasn't present.

# new {{{
sub new {
    my $class  = shift;
    my $vector = $_[0];

    if( blessed($vector) and $vector->isa(__PACKAGE__) ) {
        warn "vector->new called with blessed argument, returning $vector instead of making another\n" if $Statistics::Basic::DEBUG >= 3;
        return $vector;
    }

    my $this = bless {tag=>(++$tag_number), s=>0, c=>{}, v=>[]}, $class;
       $this->set_vector( @_ );

    warn "created new vector $this\n" if $Statistics::Basic::DEBUG >= 3;

    return $this;
}
# }}}
# copy {{{
sub copy {
    my $this = shift;
    my $that = __PACKAGE__->new( [@{$this->{v}}] );

    warn "copied vector($this -> $that)\n" if $Statistics::Basic::DEBUG >= 3;

    return $that;
}
# }}}

# _set_computer {{{
sub _set_computer {
    my $this = shift;

    while( my ($k,$v) = splice @_, 0, 2 ) {
        warn "$this set_computer($k => " . overload::StrVal($v) . ")\n" if $Statistics::Basic::DEBUG;
        weaken($this->{c}{$k} = $v);
        $v->_recalc_needed;
    }

    return;
}
# }}}
# _set_linked_computer {{{
sub _set_linked_computer {
    my $this = shift;
    my $key  = shift;
    my $var  = shift;

    my $new_key = join("_", ($key, sort {$a<=>$b} map {$_->{tag}} @_));

    $this->_set_computer( $new_key => $var );

    return;
}
# }}}
# _get_computer {{{
sub _get_computer {
    my $this = shift;
    my $k = shift;

    warn "$this get_computer($k): " . overload::StrVal($this->{c}{$k}||"<undef>") . "\n" if $Statistics::Basic::DEBUG;

    return $this->{c}{$k};
}
# }}}
# _get_linked_computer {{{
sub _get_linked_computer {
    my $this = shift;
    my $key  = shift;

    my $new_key = join("_", ($key, sort {$a<=>$b} map {$_->{tag}} @_));

    return $this->_get_computer( $new_key );
}
# }}}
# _inform_computers_of_change {{{
sub _inform_computers_of_change {
    my $this = shift;

    for my $k (keys %{ $this->{c} }) {
        my $v = $this->{c}{$k};

        if( defined($v) and blessed($v) ) {
            $v->_recalc_needed;

        } else {
            delete $this->{c}{$k};
        }
    }

    return;
}
# }}}

# _fix_size {{{
sub _fix_size {
    my $this = shift;

    my $fixed = 0;

    my $d = @{$this->{v}} - $this->{s};
    if( $d > 0 ) {
        splice @{$this->{v}}, 0, $d;
        $fixed = 1;
    }

    unless( $Statistics::Basic::NOFILL ) {
        if( $d < 0 ) {
            unshift @{$this->{v}}, # unshift so the 0s leave first
                map {0} $d .. -1;  # add $d of them

            $fixed = 1;
        }
    }

    warn "[fix_size $this] [@{ $this->{v} }]\n" if $Statistics::Basic::DEBUG >= 2;

    return $fixed;
}
# }}}

# query {{{
sub query {
    my $this = shift;

    return (wantarray ? @{$this->{v}} : $this->{v});
}
# }}}
# query_filled {{{
sub query_filled {
    my $this = shift;

    warn "[query_filled $this $this->{s}]\n" if $Statistics::Basic::DEBUG >= 1;

    return if @{$this->{v}} < $this->{s};
    return 1;
}
# }}}

# insert {{{
sub insert {
    my $this = shift;

    croak "you must define a vector size before using insert()" unless defined $this->{s};

    for my $e (@_) {
        if( ref($e) and not blessed($e) ) {
            if( ref($e) eq "ARRAY" ) {
                push @{ $this->{v} }, @$e;
                warn "[insert $this] @$e\n" if $Statistics::Basic::DEBUG >= 1;

            } else {
                croak "insert() elements do not make sense";
            }

        } else {
            push @{ $this->{v} }, $e;
            warn "[insert $this] $e\n" if $Statistics::Basic::DEBUG >= 1;
        }
    }

    $this->_fix_size;
    $this->_inform_computers_of_change;

    return $this;
}
# }}}
# ginsert {{{
sub ginsert {
    my $this = shift;

    for my $e (@_) {
        if( ref($e) and not blessed($e)) {
            if( ref($e) eq "ARRAY" ) {
                push @{ $this->{v} }, @$e;
                warn "[ginsert $this] @$e\n" if $Statistics::Basic::DEBUG >= 1;

            } else {
                croak "insert() elements do not make sense";
            }

        } else {
            push @{ $this->{v} }, $e;
            warn "[ginsert $this] $e\n" if $Statistics::Basic::DEBUG >= 1;
        }
    }

    $this->{s} = @{$this->{v}} if @{$this->{v}} > $this->{s};
    $this->_inform_computers_of_change;

    return $this;
}
*append = \&ginsert;
# }}}

# query_size {{{
sub query_size {
    my $this = shift;

    return scalar @{$this->{v}};
}

# maybe deprecate this later
*size = \&query_size unless $ENV{TEST_AUTHOR};

# }}}
# set_size {{{
sub set_size {
    my $this = shift;
    my $size = shift;

    croak "invalid vector size ($size)" if $size < 0;

    if( $this->{s} != $size ) {
        $this->{s} = $size;
        $this->_fix_size;
        $this->_inform_computers_of_change;
    }

    return $this;
}
# }}}
# set_vector {{{
sub set_vector {
    my $this     = shift;
    my $vector   = $_[0];

    if( ref($vector) eq "ARRAY" ) {
        @{$this->{v}} = @$vector;
        $this->{s} = int @$vector;
        $this->_inform_computers_of_change;

    } elsif( UNIVERSAL::isa($vector, "Statistics::Basic::ComputedVector") ) {
        $this->set_vector($vector->{input_vector});

    } elsif( UNIVERSAL::isa($vector, "Statistics::Basic::Vector") ) {
        $this->{s} = $vector->{s};
        @{$this->{v}} = @{$vector->{v}}; # copy the vector

        # I don't think this is the behavior that we really want, since they
        # stay separate objects, they shouldn't be linked like this.
        # $this->{s} = $vector->{s};
        # $this->{v} = $vector->{v}; # this links the vectors together
        # $this->{c} = $vector->{c}; # so we should link their computers too

    } elsif( @_ ) {
        @{$this->{v}} = @_;
        $this->{s} = int @_;

    } elsif( defined $vector ) {
        croak "argument to set_vector() too strange";
    }

    warn "[set_vector $this] [@{ $this->{v} }]\n" if $Statistics::Basic::DEBUG >= 2 and ref($this->{v});

    return $this;
}
# }}}

1;
