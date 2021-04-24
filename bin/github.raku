#!/usr/bin/env -S raku -I lib

use v6.d;

#use lib '/home/marcel/Languages/Raku/Projects/question-answer/lib';

use Github::App::Application;

#-------------------------------------------------------------------------------
our $github::version = Version.new(v0.2.1);
our $github::options-filter = <version archive:s>;
#-------------------------------------------------------------------------------
given my Int $exit-code = Github::App::Application.new.run // 1 {
  when 0 { }

  when 1 {
    show-usage;
  }

  default {
    note "Unknown error: $exit-code";
  }
}

exit($exit-code);

#-------------------------------------------------------------------------------
sub show-usage ( ) {
  note Q:q:to/EO-USAGE/;

  Github Tools program.

  Usage;
    github [<Options>] [<Arguments>]

  Options;
    --archive <project dir>           Archive project to CPAN
    --version                         Show version of program and exit

  Arguments;
    no arguments yet

  EO-USAGE
}





=finish
#-------------------------------------------------------------------------------
use Github::Pages;

#-------------------------------------------------------------------------------
my Github::Pages $pages .= new;

#-------------------------------------------------------------------------------
sub MAIN ( Str $src = 'docs' ) {
  $pages.create-gh-pages($src);
}
