package Algorithm::LUHN;

use strict;
use Exporter;

use vars qw/$VERSION @ISA @EXPORT @EXPORT_OK $ERROR/;

@ISA       = qw/Exporter/;
@EXPORT    = qw//;
@EXPORT_OK = qw/check_digit is_valid valid_chars/;

$VERSION = '1.00';

# The hash of valid characters.
my %map = map { $_ => $_ } 0..9;

=pod

=head1 NAME

Algorithm::LUHN - Calculate the Modulus 10 Double Add Double checksum

=head1 SYNOPSIS

  use Algorithm::LUHN qw/check_digit is_valid/;

  $c = check_digit("43881234567");
  print "It works\n" if is_valid("43881234567$c");

  $c = check_digit("A2C4E6G8"); # this will cause an error

  print "Valid LUHN characters are:\n";
  my %vc = Algorithm::LUHN::valid_chars();
  for (sort keys %vc) {
    print "$_ => $vc{$_}\n";
  }

  Algorithm::LUHN::valid_chars(map {$_ => ord($_)-ord('A')+10} A..Z);
  $c = check_digit("A2C4E6G8");
  print "It worked again\n" if is_valid("A2C4E6G8$c");

=head1 DESCRIPTION

This module calculates the Modulus 10 Double Add Double checksum, also known as
the LUHN Formula. This algorithm is used to verify credit card numbers and
Standard & Poor's security identifiers such as CUSIP's and CSIN's.

You can find plenty of information about the algorithm by searching the web for
"modulus 10 double add double".

=head1 FUNCTION

=over 4

=cut

=item is_valid CHECKSUMMED_NUM

This function returns true if the final character of CHECKSUMMED_NUM is the
correct checksum for the rest of the number and false if not. Obviously the
final character does not factor into the checksum calculation. False will also
be returned if NUM contains in an invalid character as defined by
valid_chars(). If NUM is not valid, $Algorithm::LUHN::ERROR will contain the
reason.

This function is equivalent to

  substr $N,length($N)-1 eq check_digit(substr $N,0,length($N)-1)

=cut
sub is_valid {
  my $N = shift;
  my $c = check_digit(substr($N, 0,length($N)-1));
  if (defined $c) {
    if (substr($N,length($N)-1, 1) eq $c) {
      return 1;
    } else {
      $ERROR = "Check digit incorrect. Expected $c";
      return '';
    }
  } else {
    # $ERROR will have been set by check_digit
    return '';
  }
}

=item check_digit NUM

This function returns the checksum of the given number. If it cannot calculate
the check_digit it will return undef and set $Algorithm::LUHN::ERROR to contain
the reason why.

=cut
sub check_digit {
  my @buf = reverse split //, shift;

  my $totalVal = 0;
  my $flip = 1;
  foreach my $c (@buf) {
    unless (exists $map{$c}) {
      $ERROR = "Invalid character, '$c', in check_digit calculation";
      return;
    }
    my $posVal = $map{$c};

    $posVal *= 2 unless $flip = !$flip;

    while ($posVal) {
      $totalVal += $posVal % 10;
      $posVal = int($posVal / 10);
    }
  }

  return (10 - $totalVal % 10) % 10;
}

=item valid_chars LIST

By default this module only recognizes 0..9 as valid characters, but sometimes
you want to consider other characters as valid, e.g. Standard & Poor's
identifers may contain 0..9, A..Z, @, #, *. This function allows you to add
additional characters to the accepted list.

LIST is a mapping of c<character> => c<value>. For example, Standard & Poor's
maps A..Z to 10..35 so the LIST to add these valid characters would be (A, 10,
B, 11, C, 12, ...)

Please note that this I<adds> or I<re-maps> characters, so any characters
already considered valid but not in LIST will remain valid.

If you do not provide LIST, this function returns the current valid character
map.

=cut
sub valid_chars {
  return %map unless @_;
  while (@_) {
    my ($k, $v) = splice @_, 0, 2;
    $map{$k} = $v;
  }
}

sub _dump_map {
  my %foo = valid_chars();
  my ($k,$v);
  print "$k => $v\n" while (($k, $v) = each %foo);
}

=back

=cut

1;

__END__

=head1 AUTHOR

This module was written by
Tim Ayers (http://search.cpan.org/search?author=TAYERS).

=head1 COPYRIGHT

Copyright (c) 2001 Tim Ayers. All rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
