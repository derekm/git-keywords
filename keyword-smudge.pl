#!/usr/bin/env perl
# $Author: $Format:%an <%ae>$ $
# $Date: $Format:%ai$ $
# $Revision: $Format:%h$ $

use strict;
use warnings;

use Git;
use File::Path qw/make_path/;

my ($file) = @ARGV;
if (!$file) {
    print STDERR "Usage: $0 <path-to-file-being-filtered>\n";
    exit 1;
}

my $git = Git->repository();
if (!defined $git) {
    print STDERR "Must be executed from within a Git repository.\n";
    exit 1;
}

my $temp_path = $git->repo_path() . '/' . 'keywords';
if (!-d $temp_path) {
    make_path($temp_path);
}

open(my $fh, '>>', $temp_path.'/files');
print $fh "$file\n";
close($fh);

local $/ = \8192;
while (<STDIN>) {
    print STDOUT;
}

