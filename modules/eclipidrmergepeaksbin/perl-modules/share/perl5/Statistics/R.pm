package Statistics::R;


=head1 NAME

Statistics::R - Perl interface with the R statistical program

=head1 DESCRIPTION

I<Statistics::R> is a module to controls the R interpreter (R project for
statistical computing: L<http://www.r-project.org/>). It lets you start R, pass
commands to it and retrieve their output. A shared mode allows several instances
of I<Statistics::R> to talk to the same R process.

The current I<Statistics::R> implementation uses pipes (stdin, stdout and stderr)
to communicate with R. This implementation is more efficient and reliable than
that in versions < 0.20, which relied on reading and writing intermediary files.
As before, this module works on GNU/Linux, MS Windows and probably many more
systems. I<Statistics::R> has been tested with R version 2 and 3.

=head1 SYNOPSIS

  use Statistics::R;
  
  # Create a communication bridge with R and start R
  my $R = Statistics::R->new();
  
  # Run simple R commands
  my $output_file = "file.ps";
  $R->run(qq`postscript("$output_file", horizontal=FALSE, width=500, height=500)`);
  $R->run(q`plot(c(1, 5, 10), type = "l")`);
  $R->run(q`dev.off()`);

  # Pass and retrieve data (scalars or arrays)
  my $input_value = 1;
  $R->set('x', $input_value);
  $R->run(q`y <- x^2`);
  my $output_value = $R->get('y');
  print "y = $output_value\n";

  $R->stop();

=head1 METHODS

=over 4

=item new()

Build a I<Statistics::R> bridge object connecting Perl and R. Available options
are:

=over 4

=item bin

Specify the full path to the R executable, if it is not automatically found. See
L</INSTALLATION>.

=item shared

Start a shared bridge. When using a shared bridge, several instances of 
Statistics::R can communicate with the same unique R instance. Example:

   use Statistics::R;

   my $R1 = Statistics::R->new( shared => 1);
   my $R2 = Statistics::R->new( shared => 1);

   $R1->set( 'x', 'pear' );
   my $x = $R2->get( 'x' );
   print "x = $x\n";

   $R1->stop; # or $R2->stop

Note that in shared mode, you are responsible for calling the I<stop()> method
from one of your Statistics::R instances when you are finished. But be careful
not to call the I<stop()> method if you still have processes that need to
interact with R!

=back


=item run()

First, I<start()> R if it is not yet running. Then, execute R commands passed
as a string and return the output as a string. If your commands failed to run
in R, an error message will be displayed.

Example:

   my $out = $R->run( q`print( 1 + 2 )` );

If you intend on runnning many R commands, it may be convenient to pass a list
of commands or put multiple commands in an here-doc:

   # List of R commands:
   my $out1 = $R->run(
      q`a <- 2`,
      q`b <- 5`,
      q`c <- a * b`,
      q`print("ok")`
   );

   # Here-doc with multiple R commands:
   my $cmds = <<EOF;
   a <- 2
   b <- 5
   c <- a * b
   print('ok')
   EOF
   my $out2 = $R->run($cmds);

Alternatively, to run commands from a file, use the I<run_from_file()> method.

The return value you get from I<run()> is a combination of what R would display
on the standard output and the standard error, but the exact order may differ.

When loading modules, some may write numerous messages on standard error. You
can disable this behavior using the following R command:

   suppressPackageStartupMessages(library(library_to_load))

Note that older versions of R impose a limit on how many characters can be
contained on a line: about 4076 bytes maximum. You will be warned if this
occurs, with an error message stating:

  '\0' is an unrecognized escape in character string starting "...

In this case, try to break down your R code into several smaller, more
manageable statements. Alternatively, adding newline characters "\n" at
strategic places in the R statements will work around the issue.

=item run_from_file()

Similar to I<run()> but reads the R commands from the specified file.
Internally, this method converts the filename to a format compatible with R and
then passes it to the R I<source()> command to read the file and execute the
commands.

=item result()

Get the results from the last R command.

=item set()

Set the value of an R variable (scalar or vector). Example:

  # Create an R scalar
  $R->set( 'x', 'pear' );

or

  # Create an R list
  $R->set( 'y', [1, 2, 3] );

=item get()
 
Get the value of an R variable (scalar or vector). Example:

  # Retrieve an R scalar. $x is a Perl scalar.
  my $x = $R->get( 'x' );

or

  # Retrieve an R list. $x is a Perl arrayref.
  my $y = $R->get( 'y' );

=item start()

Explicitly start R. Most times, you do not need to do that because the first
execution of I<run()> or I<set()> will automatically call I<start()>.

=item stop()

Stop a running instance of R. You need to call this method after running a
shared bridge. For a simple bridge, you do not need to do this because
I<stop()> is automatically called when the Statistics::R object goes out of
scope.

=item restart()

I<stop()> and I<start()> R.

=item bin()

Get or set the path to the R executable. Note that the path will be available
only after start() has been called.

=item version()

Get the version number of R.

=item is_shared()

Was R started in shared mode?

=item is_started()

Is R running?

=item pid()

Return the PID of the running R process

=back

=head1 INSTALLATION

Since I<Statistics::R> relies on R to work, you need to install R first. See
this page for downloads, L<http://www.r-project.org/>. If R is in your PATH
environment variable, then it should be available from a terminal and be
detected automatically by I<Statistics::R>. This means that you don't have to do
anything on Linux systems to get I<Statistics::R> working. On Windows systems,
in addition to the folders described in PATH, the usual suspects will be checked
for the presence of the R binary, e.g. C:\Program Files\R. If I<Statistics::R>
does not find where R is installed, your last recourse is to specify its full
path when calling new():

    my $R = Statistics::R->new( bin => $fullpath );

You also need to have the following CPAN Perl modules installed:

=over 4

=item IPC::Run

=item Regexp::Common

=item Text::Balanced (>= 1.97)

=item Text::Wrap

=item version (>= 0.77)

=back

=head1 SEE ALSO

=over 4

=item * L<Statistics::R::Win32>

=item * L<Statistics::R::Legacy>

=item * The R-project web site: L<http://www.r-project.org/>

=item * Statistics::* modules for Perl: L<http://search.cpan.org/search?query=Statistics&mode=module>

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

   git clone git://github.com/bricas/statistics-r.git

=cut


use 5.006;
use strict;
use warnings;
use version;
use Regexp::Common;
use Statistics::R::Legacy;
use IPC::Run qw( harness start pump finish );
use File::Spec::Functions qw(catfile splitpath splitdir);
use Text::Balanced qw ( extract_delimited extract_multiple );

if ( $^O =~ m/^(?:.*?win32|dos)$/i ) {
    require Statistics::R::Win32;
}

our $VERSION = '0.34';

our ($SHARED_BRIDGE, $SHARED_STDIN, $SHARED_STDOUT, $SHARED_STDERR);

use constant DEBUG      => 0;                     # debugging messages
use constant PROG       => 'R';                   # executable name... R
use constant MAXLINELEN => 1023;                  # maximum line length for R < 2.5

use constant EOS        => '\\1';                 # indicate the end of R output with \1
use constant EOS_RE     => qr/[${\(EOS)}]\n$/;    # regexp to match end of R stream

use constant NUMBER_RE  => qr/^$RE{num}{real}$/;  # regexp matching numbers
use constant BLANK_RE   => qr/^\s*$/;             # regexp matching whitespaces
use constant ILINE_RE   => qr/^\s*\[\d+\] /;      # regexp matching indexed line

my $ERROR_STR_1 = 'Error: ';
my $ERROR_STR_2 = 'Error in ';
my $ERROR_RE;                                     # regexp matching R errors

my $WRAP_LINES = sub { return shift };            # function to wrap R commands


sub new {
   # Create a new R communication object
   my ($class, %args) = @_;
   my $self = {};
   bless $self, ref($class) || $class;
   $self->_initialize( %args );
   return $self;
}


sub is_shared {
   # Get (or set) the whether or not Statistics::R is setup to run in shared mode
   my ($self, $val) = @_;
   if (defined $val) {
      $self->{is_shared} = $val;
   }
   return $self->{is_shared};
}


{
no warnings 'redefine';
sub start {
   my ($self, %args) = @_;
   my $status = 1;
   if (not $self->is_started) {

      # If shared mode option of start() requested, rebuild the bridge in shared
      # mode. Don't use this option though. It is only here to cater for the legacy
      # method start_shared()
      if ( exists($args{shared}) && ($args{shared} == 1) ) {
         $self->is_shared( 1 );
         $self->_bridge( 1 );
      }

      # Now, start R
      my $bridge = $self->_bridge;
      $status = $bridge->start or die "Error starting ".PROG.": $?\n";
      $self->bin( $bridge->{KIDS}->[0]->{PATH} );
      delete $self->{died};
      print "DBG: Started R, ".$self->bin." (pid ".$self->pid.")\n" if DEBUG;

      # Generate regexp to catch R errors
      if (not defined $ERROR_RE) {
         $self->_generate_error_re;
         $self->_localize_error_str;
         $self->_generate_error_re;
      }

      # Set up a function to wrap lines for R < 2.5
      if ( version->parse($self->version) < version->parse('2.5.0') ) {
         print "DBG: Need to wrap to ".MAXLINELEN."\n" if DEBUG;
         require Text::Wrap;
         $Text::Wrap::columns   = MAXLINELEN;
         $Text::Wrap::break     = ',';
         $Text::Wrap::huge      = 'overflow';
         $Text::Wrap::separator = ",\n";
         $WRAP_LINES = sub { return Text::Wrap::wrap('', '', shift) };
      }

   }

   return $status;
}
}


sub stop {
   my ($self) = @_;
   my $status = 1;
   if ( $self->is_started ) {
      $status = $self->_bridge->finish or die "Error stopping ".PROG.": $?\n";
      print "DBG: Stopped R\n" if DEBUG;
   }
   return $status;
}


sub restart {
   my ($self) = @_;
   return $self->stop && $self->start;
}


sub is_started {
   # Query whether or not R has been started and is still running - hackish.
   # See https://rt.cpan.org/Ticket/Display.html?id=70595
   my ($self) = @_;
   my $is_started = 0;
   my $bridge = $self->_bridge;
   if (defined $bridge && not $self->{died}) {
      if (not exists $bridge->{STATE}) {
         die "Internal error: could not get STATE from IPC::Run\n";
      }
      if ($bridge->{STATE} eq IPC::Run::_started && $bridge->pumpable) {
         $is_started = 1;
      }
   }
   return $is_started;
}


sub pid {
   # Get (or set) the PID of the running R process - hackish.
   # See https://rt.cpan.org/Ticket/Display.html?id=70595It
   # The PID is accessible only after the bridge has start()ed.
   my ($self) = @_;
   my $bridge = $self->_bridge;
   if ( not exists $bridge->{KIDS} ) {
      die "Internal error: could not get KIDS from IPC::Run\n";
   }
   if ( not exists $bridge->{KIDS}->[0]->{PID} ) {
      die "Internal error: could not get PID from IPC::Run\n";
   }
   return $bridge->{KIDS}->[0]->{PID};
}


sub bin {
   # Get or set the full path to the R binary program to use. Unless you have set
   # the path yourself, it is accessible only after the bridge has start()ed
   my ($self, $val) = @_;
   if (defined $val) {
      $self->{bin} = $val;
   }
   return $self->{bin};
}


sub version {
   # Get the version of R, e.g. '3.1.1'
   my ($self) = @_;
   return $self->run(q`write(paste(sep=".",R.Version()$major,R.Version()$minor), stdout())`);
}


sub run {
   # Pass the input and get the output
   my ($self, @cmds) = @_;

   # Need to start R now if it is not already running
   $self->start if not $self->is_started;

   # Process each command
   my $results = '';
   for my $cmd (@cmds) {

      # Wrap command for execution in R
      print "DBG: Command is '$cmd'\n" if DEBUG;
      $self->_stdin( $self->wrap_cmd($cmd) );
      print "DBG: stdin is '".$self->_stdin."'\n" if DEBUG;

      # Pass input to R and get its output
      my $bridge = $self->_bridge;
      while (  $self->_stdout !~ EOS_RE  &&  $bridge->pumpable  ) {
         $bridge->pump;
      }

      # Parse output, detect errors
      my $out = $self->_stdout;
      $out =~ s/${\(EOS_RE)}//;
      chomp $out;
      my $err = $self->_stderr;
      chomp $err;

      print "DBG: stdout is '$out'\n" if DEBUG;
      print "DBG: stderr is '$err'\n" if DEBUG;

      if ($err =~ $ERROR_RE) {
         # Catch errors on stderr. Leave warnings alone.
         print "DBG: Error\n" if DEBUG;
         $self->{died} = 1; # for proper cleanup after failed eval
         my $err_msg = "Error:\n".$1;
         if ( $err_msg =~ /unrecognized escape in character string/ &&
              version->parse($self->version) < version->parse('2.5.0') ) {
            $err_msg .= "\nMost likely, the given R command contained lines ".
               "exceeding ".MAXLINELEN." characters.";
         }
         $self->_stdout('');
         $self->_stderr('');
         die "Problem while running this R command:\n$cmd\n\n$err_msg\n";
      }

      # Save results and reinitialize
      $results .= "\n" if $results;
      $results .= $err.$out;
      $self->_stdout('');
      $self->_stderr('');
   }

   $self->result($results);

   return $results;
}


sub run_from_file {
   # Execute commands in given file: first, convert filepath to an R-compatible
   # format and then pass it to source().
   my ($self, $filepath) = @_;
   if (not -f $filepath) {
      die "Error: '$filepath' does not seem to exist or is not a file.\n";
   }

   # Split filepath
   my ($volume, $directories, $filename) = splitpath($filepath);
   my @elems;
   push @elems, $volume if $volume; # $volume is '' if unused
   push @elems, splitdir($directories);
   push @elems, $filename;

   # Use file.path to create an R-compatible filename (bug #77761), e.g.:
   #   file <- file.path("E:", "DATA", "example.csv")
   # Then use source() to read file and execute the commands it contains
   #   source(file)
   my $cmd = 'source(file.path('.join(',',map {'"'.$_.'"'}@elems).'))';
   my $results = $self->run($cmd);

   return $results;
}


sub result {
   # Get / set result of last R command
   my ($self, $val) = @_;
   if (defined $val) {
      $self->{result} = $val;
   }
   return $self->{result};
}


sub set {
   # Assign a variable or array of variables in R. Use undef if you want to
   # assign NULL to an R variable
   my ($self, $varname, $arr) = @_;
    
   # Start R now if it is not already running
   $self->start if not $self->is_started;

   # Check variable type, convert everything into an arrayref
   my $ref = ref $arr;
   if ($ref eq '') {
      # This is a scalar
      $arr = [ $arr ];
   } elsif ($ref eq 'ARRAY') {
      # This is an array reference, nothing to do
   } else {
      die "Error: Import variable of type $ref is not supported\n";
   }

   # Quote strings and nullify undef variables
   for my $i (0 .. scalar @$arr - 1) {
      if (defined $$arr[$i]) {
         if ( $$arr[$i] !~ NUMBER_RE ) {
            $$arr[$i] = _quote( $$arr[$i] );
         }
      } else {
         $$arr[$i] = 'NULL';
      }
   }

   # Build a variable assignment command and run it!
   my $cmd = $varname.'<-c('.join(',',@$arr).')';
   $cmd = &$WRAP_LINES( $cmd );
   $self->run( $cmd );

   return 1;
}


sub get {
   # Get the value of an R variable
   my ($self, $varname) = @_;
   my $string = $self->run(qq`print($varname)`);

   # Parse R output
   my $value;
   if ($string eq 'NULL') {
      $value = undef;
   } elsif ($string =~ ILINE_RE) {
      # Vector: its string look like:
      # ' [1]  6.4 13.3  4.1  1.3 14.1 10.6  9.9  9.6 15.3
      #  [16]  5.2 10.9 14.4'
      my @lines = split /\n/, $string;
      for my $i (0 .. scalar @lines - 1) {
         $lines[$i] =~ s/${\(ILINE_RE)}//;
      }
      $value = join ' ', @lines;
   } else {
      my @lines = split /\n/, $string;
      if (scalar @lines == 2) {
         # String looks like: '    mean 
         # 10.41111 '
         # Extract value from second line
         $value = _trim( $lines[1] );
      } else {
         $value = $string;
      }
   }

   # Clean
   my @arr;
   if (not defined $value) {
      @arr = ( undef );
   } else {
      # Split string into an array, paying attention to strings containing spaces:
      # extract_delim should be enough but we use extract_delim + split because
      # of Text::Balanced bug #73416
      if ($value =~ m{['"]}) {
         @arr = extract_multiple( $value, [sub { extract_delimited($_[0],q{'"}) },] );
         my $nof_empty = 0;
         for my $i (0 .. scalar @arr - 1) {
            my $elem = $arr[$i];
            if ($arr[$i] =~ BLANK_RE) {
               # Remove elements that are simply whitespaces later, in a single operation
               $nof_empty++;
            } else {
               # Trim and unquote
               $arr[$i-$nof_empty] = _unquote( _trim($elem) );
            }
         }
         if ($nof_empty > 0) {
            splice @arr, -$nof_empty, $nof_empty;
         }
      } else {
         @arr = split( /\s+/, _trim($value) );
      }
   }

   # Return either a scalar of an arrayref
   my $ret_val;
   if (scalar @arr == 1) {
       $ret_val = $arr[0];
   } else {
       $ret_val = \@arr;
   }

   return $ret_val;
}


#---------- INTERNAL METHODS --------------------------------------------------#


sub _initialize {
   my ($self, %args) = @_;

   # Full path of R binary specified by bin (r_bin or R_bin for backward
   # compatibility), or executable name (IPC::Run will find its full path later)
   $self->bin( $args{bin} || $args{r_bin} || $args{R_bin} || PROG );

   # Using shared mode?
   if ( exists $args{shared} && $args{shared} == 1 ) {
      $self->is_shared( 1 );
   } else {
      $self->is_shared( 0 );
   }

   # Build the bridge
   $self->_bridge( 1 );

   return 1;
}


sub _bridge {
   # Get or build the communication bridge and IOs with R
   my ($self, $build) = @_;
   my %params = ( debug => 0 );
   if ($build) {
      my $cmd = [ $self->bin, '--vanilla', '--slave' ];
      if (not $self->is_shared) {
         my ($stdin, $stdout, $stderr);
         $self->{stdin}  = \$stdin;
         $self->{stdout} = \$stdout;
         $self->{stderr} = \$stderr;
         $self->{bridge} = harness $cmd, $self->{stdin}, $self->{stdout}, $self->{stderr}, %params;
      } else {
         $self->{stdin}  = \$SHARED_STDIN ;
         $self->{stdout} = \$SHARED_STDOUT;
         $self->{stderr} = \$SHARED_STDERR;
         if (not defined $SHARED_BRIDGE) {
            # The first Statistics::R instance builds the bridge
            $SHARED_BRIDGE = harness $cmd, $self->{stdin}, $self->{stdout}, $self->{stderr}, %params;
         }
         $self->{bridge} = $SHARED_BRIDGE;
      }
   }
   return $self->{bridge};
}


sub _stdin {
   # Get / set standard input string for R
   my ($self, $val) = @_;
   if (defined $val) {
      ${$self->{stdin}} = $val;
   }
   return ${$self->{stdin}};
}


sub _stdout {
   # Get / set standard output string for R
   my ($self, $val) = @_;
   if (defined $val) {
      ${$self->{stdout}} = $val;
   }
   return ${$self->{stdout}};
}


sub _stderr {
   # Get / set standard error string for R
   my ($self, $val) = @_;
   if (defined $val) {
      ${$self->{stderr}} = $val;
   }
   return ${$self->{stderr}};
}


sub wrap_cmd {
   # Wrap a command to pass to R. Whether the command is successful or not, the
   # end of stream string will appear on stdout and indicate that R has finished
   # processing the data. Note that $cmd can be multiple R commands.
   my ($self, $cmd) = @_;
   chomp $cmd;
   $cmd =~ s/;$//;
   $cmd .= qq`; write("`.EOS.qq`",stdout())\n`;
   return $cmd;
}


sub _generate_error_re {
   # Generate a regular expression to catch R internal errors, e.g.:
   #    Error: object 'zzz' not found"
   #    Error in print(ASDF) : object 'ASDF' not found
   my ($self) = @_;
   $ERROR_RE = qr/^(?:$ERROR_STR_1|$ERROR_STR_2)\s*(.*)$/s;
   print "DBG: Regexp for catching errors is '$ERROR_RE'\n" if DEBUG;
   return 1;
}


sub _localize_error_str {
   # Find the translation for the R error strings. Internationalization is
   # present in R >=2.1, with Natural Language Support enabled.
   my ($self) = @_;
   my @strings;
   for my $error_str ($ERROR_STR_1, $ERROR_STR_2) {
      my $cmd = qq`write(ngettext(1, "$error_str", "", domain="R"), stdout())`;
      $self->set('cmd', $cmd);
      # Try to translate string, return '' if not possible
      my $str = $self->run(q`tryCatch( eval(parse(text=cmd)) , error=function(e){write("",stdout())} )`);
      $str ||= $error_str;
      push @strings, $str;
   }
   ($ERROR_STR_1, $ERROR_STR_2) = @strings;
   return 1;
}


sub DESTROY {
   # The bridge to R is not automatically bombed when Statistics::R instances
   # get out of scope. Do it now (unless running in shared mode)!
   my ($self) = @_;
   if (not $self->is_shared) {
      $self->stop;
   }
}


#---------- HELPER SUBS -------------------------------------------------------#


sub _trim {
   # Remove flanking whitespaces
   my ($str) = @_;
   $str =~ s{^\s+}{};
   $str =~ s{\s+$}{};
   return $str;
}


sub _quote {
   # Quote a string for use in R. We use double-quotes because the documentation
   # Quotes {base} R documentation states that this is preferred over single-
   # quotes. Double-quotes inside the string are escaped.
   my ($str) = @_;
   # Escape " by \" , \" by \\\" , ...
   $str =~ s/ (\\*) " / '\\' x (2*length($1)+1) . '"' /egx;
   # Surround by "
   $str = qq("$str");
   return $str;
}


sub _unquote {
   # Opposite of _quote
   my ($str) = @_;
   # Remove surrounding "
   $str =~ s{^"}{};
   $str =~ s{"$}{};
   # Interpolate (de-escape) \\\" to \" , \" to " , ...
   $str =~ s/ ((?:\\\\)*) \\ " / '\\' x (length($1)*0.5) . '"' /egx;
   return $str;
}


1;
