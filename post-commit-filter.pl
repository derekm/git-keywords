#!/usr/bin/env perl
# $Author: $Format:%an <%ae>$ $
# $Date: $Format:%ai$ $
# $Revision: $Format:%h$ $

use strict;
use warnings;

use Git;
use Archive::Zip qw(:ERROR_CODES);

my $git = Git->repository();
if (!defined $git) {
    print STDERR "Must be executed from within a Git repository.\n";
    exit 1;
}

my @files = ();

my $repo_path = $git->repo_path();
my $keywords_path = $repo_path.'/keywords';
my $use_orig_head_path = $keywords_path.'/use_orig_head';
my $use_orig_head;

if (-d $keywords_path && -f $use_orig_head_path) {
    $use_orig_head = 1;
    @files = $git->command('diff-tree', '--name-only', '-r', 'ORIG_HEAD', 'HEAD');
} else {
    @files = $git->command('diff-tree', '--no-commit-id', '--name-only', '-r', 'HEAD');
}

# full file list from ORIG_HEAD to HEAD
# could contain renamed or deleted files
if ($use_orig_head) {
    @files = grep { -e } @files;
}

# extract files that were in the latest commit
# or extant files following a merge resolution
for my $file (@files) {
    my $commit = $git->command_oneline('log', '-1', '--format=%H', 'HEAD', '--', $file);
    my ($fh, $ctx) = $git->command_output_pipe('archive', '--worktree-attributes', '--format=zip', '-0', $commit, $file);
    my $zip_file = do { local $/; <$fh> };
    $git->command_close_pipe($fh, $ctx);

    use IO::String;
    my $zh = IO::String->new($zip_file);
    my $zip = Archive::Zip->new();
    $zip->readFromFileHandle($zh) == AZ_OK or die 'Couldn\'t open original ' . $file . '.';
    $zip->extractMember($file);
    close($zh) or die 'Failed to close in-memory zip:' . $!;

    $git->command('update-index', $file);
}

my $files_path = $keywords_path.'/files';
unlink $use_orig_head_path if $use_orig_head;
unlink $files_path if -e $files_path;
rmdir $keywords_path if -d $keywords_path;

