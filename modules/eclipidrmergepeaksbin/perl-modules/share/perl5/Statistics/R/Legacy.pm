package Statistics::R::Legacy;


use strict;
use warnings;

use base qw( Statistics::R );

use vars qw{@ISA @EXPORT};

BEGIN {
   @ISA     = 'Exporter';
   @EXPORT  = qw{
      startR
      stopR
      restartR
      Rbin
      start_sharedR
      start_shared
      read
      receive
      is_blocked
      is_locked
      lock
      unlock
      send 
      error
      clean_up
   };
}

=head1 NAME

Statistics::R::Legacy - Legacy methods for Statistics::R

=head1 DESCRIPTION

B<Do not use this module directly. Use L<Statistics::R> instead.>

This module contains legacy methods for I<Statistics::R>. They are provided
solely so that code that uses older versions of I<Statistics::R> does not crash
with recent version. Do not use these methods in new code!

Some of these legacy methods simply had their name changed, but some others were
changed to do nothing and return only single value because it did not make sense
to keep these methods as originally intended anymore.

=head1 METHODS

=over 4

=item startR()

This is the same thing as start().

=item stopR()

This is the same thing as stop().

=item restartR()

This is the same thing as restart().

=item Rbin()

This is the same thing as bin().

=item start_sharedR() / start_shared()

Use the shared option of new() instead.

=item send / read() / receive()

Use run() instead.

=item lock()

Does nothing anymore.

=item unlock()

Does nothing anymore.

=item is_blocked() / is_locked()

Return 0.

=item error()

Return the empty string.

=item clean_up()

Does nothing anymore.

=back

=head1 SEE ALSO

=over 4

=item * L<Statistics::R>

=back

=head1 AUTHORS

Florent Angly E<lt>florent.angly@gmail.comE<gt> (2011 rewrite)

Graciliano M. P. E<lt>gm@virtuasites.com.brE<gt> (original code)

=head1 MAINTAINERS

Florent Angly E<lt>florent.angly@gmail.comE<gt>

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 BUGS

All complex software has bugs lurking in it, and this program is no exception.
If you find a bug, please report it on the CPAN Tracker of Statistics::R:
L<http://rt.cpan.org/Dist/Display.html?Name=Statistics-R>

Bug reports, suggestions and patches are welcome. The Statistics::R code is
developed on Github (L<http://github.com/bricas/statistics-r>) and is under Git
revision control. To get the latest revision, run:

   git clone git@github.com:bricas/statistics-r.git

=cut


{
   # Prevent "Name XXX used only once" warnings in this block
   no warnings 'once';
   *startR        = \&Statistics::R::start;
   *stopR         = \&Statistics::R::stop;
   *restartR      = \&Statistics::R::restart;
   *Rbin          = \&Statistics::R::bin;
   *receive       = \&Statistics::R::result;
   *start_sharedR = \&start_shared;
   *read          = \&receive;
   *is_blocked    = \&is_locked;
}


sub start_shared {
    my $self = shift;
    $self->start( shared => 1 );
}


sub lock {
    return 1;
}


sub unlock {
    return 1;
}


sub is_locked {
    return 0;
}


sub send {
   # Send a command to R. Do not return the output.
   my ($self, $cmd) = @_;
   $self->run($cmd);
   return 1;
}


sub error {
    return '';
}


sub clean_up {
   return 1;
}


1;
