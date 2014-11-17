#!/usr/bin/env perl
# $Author: $Format:%an <%ae>$ $
# $Date: $Format:%ai$ $
# $Revision: $Format:%h$ $

my %config = (
    Date => '%ai',
    Author => '%an <%ae>',
    Revision => '%h'
);

my @regex = ();
my @subst = ();
for my $key (keys %config) {
  push @regex, qr/\$$key.*\$/;
  push @subst, "\$$key: \$Format:$config{$key}\$ \$";
}

while (<>) {
  for my $i (0..scalar keys %config) {
    s/$regex[$i]/$subst[$i]/;
  }
} continue {
  print;
}

