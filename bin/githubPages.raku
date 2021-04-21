#!/usr/bin/env raku

use v6;

use Github::Pages;

#-------------------------------------------------------------------------------
my Github::Pages $pages .= new;

#-------------------------------------------------------------------------------
sub MAIN ( Str $src = 'docs' ) {
  $pages.create-gh-pages($src);
}
