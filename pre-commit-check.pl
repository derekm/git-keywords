#!/usr/bin/env perl
# $Author: $Format:%an <%ae>$ $
# $Date: $Format:%ai$ $
# $Revision: $Format:%h$ $

use strict;
use warnings;

use Git;
use File::Path;

my $git = Git->repository();
if (!defined $git) {
    print STDERR "Must be executed from within a Git repository.\n";
    exit 1;
}

my $repo_path = $git->repo_path();
my $keywords_path = $repo_path.'/keywords';
my $use_orig_head = $keywords_path.'/use_orig_head';
if (-e $repo_path.'/MERGE_MSG') {
    unless (-d $keywords_path) {
        mkpath($keywords_path);
    }
    open(my $fh, '>', $use_orig_head);
    close($fh);
}

