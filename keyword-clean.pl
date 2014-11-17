#!/usr/bin/env perl
# $Author: $Format:%an <%ae>$ $
# $Date: $Format:%ai$ $
# $Revision: $Format:%h$ $

my @allow = qw/Author Date Revision/;
my %config = (
    Date => '%ai',
    Author => '%an <%ae>',
    Revision => '%h'
);

my @regex = ();
my @subst = ();
my $format = 'Format';
for my $key (@allow) {
  push @regex, qr/\$$key.*\$/;
  push @subst, "\$$key: \$$format:$config{$key}\$ \$";
}

while (<>) {
  for my $i (0..scalar keys %config) {
    s/$regex[$i]/$subst[$i]/;
  }
} continue {
  print;
}

