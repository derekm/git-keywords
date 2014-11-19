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

my @commits = ();
my %uniq = ();
{
  my $commit;
  while (<STDIN>) {
      my $commit = (split)[1]
      and ++$uniq{$commit} == 1
      and push @commits, $commit;
  }
}

undef %uniq;
my @files = grep {
              ++$uniq{$_} == 1 && -e
            } map {
              $git->command('diff-tree', '--no-commit-id', '--name-only', '-r', $_)
            } @commits;

# the smudge filter may notify us of files from
# our own shifted commits
#my $repo_path = $git->repo_path();
#my $keywords_path = $repo_path.'/keywords';
#my $files_path = $keywords_path.'/files';
#if (-d $keywords_path && -f $files_path) {
#    open(my $fh, '<', $files_path);
#    while (<$fh>) {
#        chomp;
#        ++$uniq{$_} == 1 && -e
#        and push @files, $_;
#    }
#    close($fh);
#}

# extract extant files following an amend or rebase
for my $file (@files) {
    my $commit = $git->command_oneline('log', '-1', '--format=%H', 'HEAD', '--', $file);
    my ($fh, $ctx) = $git->command_output_pipe('archive', '--format=zip', '-0', $commit, $file);
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

#unlink $files_path;
# TODO FIXME may need to unlink use_orig_head file
#rmdir $keywords_path;

