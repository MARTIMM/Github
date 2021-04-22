#!/usr/bin/env -S raku -I lib

use v6;
use JSON::Fast;
use CPAN::Uploader::Tiny;

#-------------------------------------------------------------------------------
enum gitChecks (
  NotMaster => 0x01,
  NewFiles => 0x02,
  HasChanges => 0x04,
  AtCPAN => 0x08,
);

my Str $git-archive-config = "$*HOME/.config/gitArchiveCPAN.json";
my %git-archive-CPAN = %();

my Str $date = DateTime.now.utc.Str;
$date ~~ s/ \. .* / Z/;
$date ~~ s/ T / /;

#-------------------------------------------------------------------------------
sub MAIN ( *@p6-dirs is copy ) {

  %git-archive-CPAN = from-json($git-archive-config.IO.slurp // '')
    if $git-archive-config.IO.r;

  @p6-dirs //= ();

  for @p6-dirs -> $p6-dir {
    next unless "$p6-dir".IO.d;

    # Check for a Meta file and if there is a git directory
    if "$p6-dir/META6.json".IO.r and "$p6-dir/.git".IO.d {
      archive($p6-dir);
    }
  }

  $git-archive-config.IO.spurt(to-json(%git-archive-CPAN));
}

#-------------------------------------------------------------------------------
sub archive ( Str $p6-dir is copy ) {

  # remove trailing slash if any
  $p6-dir ~~ s/ '/' $ //;
  chdir($p6-dir);

  # Read the meta file and get the version
  my Hash $meta = from-json('META6.json'.IO.slurp);
  my Str $version = $meta<version>;

  # Remove a leading 'v' if it is used, then keep only 3 version parts
  # separated by 2 dots. CPAN does not like more dots than two.
  $version ~~ s:i/ ^ 'v' //;
  #$version ~~ s/ \. \d+ $ // while $version.comb(/\./).join.chars > 2;

  my Str $archiveName = "$p6-dir-$version";
  my Int $checks = check-git( $p6-dir, $version);
  if $checks {
    note "You're not on the master branch" if $checks +& NotMaster;
    note "There are new uncommitted files" if $checks +& NewFiles;
    note "There are uncommitted changes" if $checks +& HasChanges;
    note "Already uploaded $archiveName to CPAN" if $checks +& AtCPAN;

    return;
  }

  note "Build git archive $archiveName.tar.gz";
  run 'git', 'archive', "--prefix=$archiveName/",
      '-o', "../$archiveName.tar.gz", 'HEAD';

  chdir('..');

  # A file $HOME/.pause must exist with username and password.
  # This file may be encrypted. Two rows are in this file;
  #   user <username>
  #   password <password>
  my $uploader = CPAN::Uploader::Tiny.new-from-config($*HOME.add: '.pause');

  try {
    $uploader.upload("$archiveName.tar.gz");
    note "$archiveName.tar.gz is uploaded to PAUSE";
    %git-archive-CPAN{$p6-dir}{$version} = $date;

    CATCH {
      default {
        if .message ~~ m/ Conflict / {
          note "Conflicting archives, did you uploaded it before?";
          %git-archive-CPAN{$p6-dir}{$version} = $date;
        }

        else {
          note "Error: $_.message";
        }
      }
    }
  }

  note "Remove $archiveName.tar.gz";
  unlink "$archiveName.tar.gz";
}

#-------------------------------------------------------------------------------
sub check-git ( Str $p6-dir, Str $version --> Int ) {

  my Int $checks = 0;
  my Bool ( $current-is-master, $untracked, $changes) = ( False, False, False);

  my Proc $p = run 'git', 'branch', :out;
  for $p.out.lines -> $line {
    if $line ~~ m:s/^ '*' master / {
      $current-is-master = True;
      last
    }
  }
  $p.out.close;

  $checks +|= NotMaster unless $current-is-master;

  $p = run 'git', 'status', :out;
  for $p.out.lines -> $line {
    if $line ~~ m:s/ Changes not staged / {
      $changes = True;
    }

    elsif $line ~~ m:s/ Untracked files / {
      $untracked = True;
    }

    elsif $changes and $untracked {
      last;
    }
  }
  $p.out.close;

  $checks +|= HasChanges if $changes;
  $checks +|= NewFiles if $untracked;
  $checks +|= AtCPAN if %git-archive-CPAN{$p6-dir}{$version};

  $checks
}
