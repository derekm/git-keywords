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
    print 'Must be executed from within a Git repository.';
    exit 1;
}

#my $branch = $git->command_oneline('symbolic-ref', '--short', 'HEAD');
#
#if (!$branch) { # if detached head, get commit hash
#    $branch = $git->command_oneline('rev-parse', 'HEAD');
#}
my $branch = $ARGV[1];

my $prior = $ARGV[0];
#if ($ARGV[2]) {
#    # works for branch or commit
#    # in a newly-cloned repo, there won't be a $prior branch
#    $prior = $git->command_oneline('check-ref-format', '--branch', '@{-1}');
#}

my $temp_path = $git->repo_path() . '/' . 'keywords';

my @files = ();
my %commits = ();
if (-d $temp_path && -f $temp_path.'/files') {
  open(my $fh, '<', $temp_path.'/files');
  while (<$fh>) {
      chomp;
      push @files, $_;
      $commits{$_} = $git->command_oneline('log', '-1', '--format=%H', $branch, '--', $_);
  }
  close($fh);
}

if (defined $prior) {

# find files common between @ & @{-1}
  # get files in current tree
  # remove files the smudge filter wanted to process
  # get files in prior tree
  # take the intersection
my @intersect = ();
{
  my %after = ();
  @after{$git->command('ls-tree', '--full-tree', '--name-only', '-r', $branch)} = undef;
  map { exists $after{$_} && delete $after{$_} } @files;
  my @before = $git->command('ls-tree', '--full-tree', '--name-only', '-r', $prior);
  @intersect = grep { exists $after{$_} } @before;
}

# find current branch's commits for common files
my %antecedent = ();
map {
    $antecedent{$_} = $git->command_oneline('log', '-1', '--format=%H', $branch, '--', $_)
} @intersect;

# find files common between @ & @{-1} where latest commits differ
map {
    $antecedent{$_} ne $git->command_oneline('log', '-1', '--format=%H', $prior, '--', $_)
    and push @files, $_
    and $commits{$_} = $antecedent{$_}
} @intersect;

}

# extract files that smudge filter wanted to process
# along with the common files where commits differed
for my $file (@files) {
    my ($fh, $ctx) = $git->command_output_pipe('archive', '--format=zip', '-0', $commits{$file}, $file);
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

unlink $temp_path.'/files';
rmdir $temp_path;

