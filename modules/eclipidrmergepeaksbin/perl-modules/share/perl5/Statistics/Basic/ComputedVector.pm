
package Statistics::Basic::ComputedVector;

use strict;
use warnings;
use Carp;

our $tag_number = 0;

use Statistics::Basic;
use base 'Statistics::Basic::Vector';

# new {{{
sub new {
    my $class = shift;
    my $that  = eval { Statistics::Basic::Vector->new(@_) } or croak $@;
    croak "input vector must be supplied to ComputedVector" unless defined $that;

    my $this = bless { tag=>(--$tag_number), c=>{}, input_vector=>$that, output_vector=>Statistics::Basic::Vector->new() }, $class;
       $this->_recalc_needed;

    return $this;
}
# }}}
# copy {{{
sub copy {
    my $this = shift;
    my $that = __PACKAGE__->new( $this->{input_vector} );
       $that->{computer} = $this->{computer};

    warn "copied computedvector($this -> $that)\n" if $Statistics::Basic::DEBUG >= 3;

    return $that;
}
# }}}
# set_filter {{{
sub set_filter {
    my $this = shift;
    my $cref = shift; croak "cref should be a code reference" unless ref($cref) eq "CODE";

    $this->{computer} = $cref;

    my $a = Scalar::Util::refaddr($this);
    $this->{input_vector}->_set_computer( "cvec_$a" => $this ); # sets recalc needed in this object

    return $this;
}
# }}}
# _recalc {{{
sub _recalc {
    my $this = shift;

    delete $this->{recalc_needed};

    if( ref( my $c = $this->{computer} ) eq "CODE" ) {
        $this->{output_vector}->set_vector( [$c->($this->{input_vector}->query)] );

    } else {
        $this->{output_vector}->set_vector( [$this->{input_vector}->query] );
    }

    warn "[recalc " . ref($this) . "]\n" if $Statistics::Basic::DEBUG;
    $this->_inform_computers_of_change;

    return;
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
# query_size {{{
sub query_size {
    my $this = shift;

    $this->_recalc if $this->{recalc_needed};

    return $this->{output_vector}->query_size;
}

# maybe deprecate this later
*size = \&query_size unless $ENV{TEST_AUTHOR};

# }}}
# query {{{
sub query {
    my $this = shift;

    $this->_recalc if $this->{recalc_needed};

    return $this->{output_vector}->query;
}
# }}}

sub query_vector { return $_[0]{input_vector} }

# query_filled {{{
sub query_filled {
    my $this = shift;

    # even though this makes little sense, imo, we need to provide it since so many other objects call it

    $this->_recalc if $this->{recalc_needed};

    return $this->{input_vector}->query_filled;
}
# }}}

sub _fix_size  { croak "fix_size() makes no sense on computed vectors" }
sub set_size   { my $this = shift; $this->{input_vector}->set_size  (@_); return $this }
sub insert     { my $this = shift; $this->{input_vector}->insert    (@_); return $this }
sub ginsert    { my $this = shift; $this->{input_vector}->ginsert   (@_); return $this }
sub append     { my $this = shift; $this->{input_vector}->append    (@_); return $this }
sub set_vector { my $this = shift; $this->{input_vector}->set_vector(@_); return $this }

1;
