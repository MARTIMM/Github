#!/usr/bin/env -S raku -I lib

use v6;

use Github::Pages;

#-------------------------------------------------------------------------------
my Github::Pages $pages .= new;

#-------------------------------------------------------------------------------
sub MAIN ( Str $src = 'docs' ) {
  $pages.create-gh-pages($src);
}
