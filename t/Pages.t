use v6;
use Test;

#-------------------------------------------------------------------------------
use Github::Pages;
my Github::Pages $pages .= new;
my Str $root = 't/docs';

$pages.create-gh-pages( $root, :rebuild);

ok $root.IO.e, "$root exists";

#-------------------------------------------------------------------------------
done-testing;



=finish
unlink "$root/Gemfile";
rmdir $root;
