use v6;

use Github::Resources;

#-------------------------------------------------------------------------------
unit class Github::Pages:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
has Github::Resources $!resources .= new;
has Str $!site-dir;

#-------------------------------------------------------------------------------
method create-gh-pages ( Hash:D $gp-config ) {

  $!site-dir = $gp-config<properties><other-info><site-dir>;
  my Bool $create-anew;
  my Str $text;


#`{{
  if $!site-dir.IO ~~ :e {
    note "Site already generated, only the files from configuration are replaced";
    $create-anew = False;
  }

  else {
}}
    # create github pages dir
    mkdir $!site-dir, 0o750;
    $create-anew = True;
#  }


  # save directory and step into root of github pages dir
  my Str $cwd = $*CWD.Str;
  chdir $!site-dir;

  # create directories
  for < _data _includes _layouts _sass assets/css assets/images
        content-docs/about content-docs/images content-docs/reference
      > -> $dir {
    mkdir $dir, 0o750 unless 'images'.IO ~~ :e;
  }

  # when new site all files are to be created
  if $create-anew {
    # the below files are templates for the user to fill in, they
    # will never be overwritten.
    for < _data/about-sidebar.yml
          _data/default-nav.yml
          _data/reference-sidebar.yml

          content-docs/about/about.md
          content-docs/about/release-notes.md

          Gemfile
          index.md

        > -> $resource-name {
      self.create-page-from-resource($resource-name);
    }

    # user css or create empty template
note "bs: ",  $gp-config<assets><other-files><browser-stylesheet>;

    if $gp-config<assets><other-files><browser-stylesheet>:exists {
      'assets/css/style.scss'.IO.spurt(
        $gp-config<assets><other-files><browser-stylesheet>.IO.slurp
      );
    }

    else {
      'assets/css/style.scss'.IO.spurt(Q:q:to/EOSCSS/);
          @import "jekyll-theme-tactile";
          EOSCSS
    }

    if $gp-config<assets><other-files><printer-stylesheet>:exists {
      'assets/css/print.css'.IO.spurt(
        $gp-config<assets><other-files><printer-stylesheet>.IO.slurp
      );
    }

    else {
      'assets/css/print.css'.IO.spurt('');
    }

    $text = self.get-text-from-resource('content-docs/reference/reference.md');
    $text ~~ s:g/'[[[REPOSITORY]]]'
                /$gp-config<properties><browser-info><repository>/;
    self.create-page-from-text( $text, "$!site-dir/content-docs/reference/reference.md");
  }

  # when new or old, some files can be replaced.
  # modify the configuration file
  $text = self.get-text-from-resource('_config.yml');
  $text ~~ s:g/'[[[TITLE]]]'/$gp-config<properties><browser-info><title>/;
  $text ~~ s:g/'[[[DESCRIPTION]]]'
              /$gp-config<properties><browser-info><description>/;
  $text ~~ s:g/'[[[EMAIL]]]'/$gp-config<properties><other-info><email>/;
  $text ~~ s:g/'[[[PORT]]]'/$gp-config<properties><browser-info><port>/;
  $text ~~ s:g/'[[[REPOSITORY]]]'
              /$gp-config<properties><browser-info><repository>/;
  self.create-page-from-text( $text, "$!site-dir/_config.yml");

  # select images from resource or user config
  self.user-asset( $gp-config, 'images', 'body-tile', 'body-bg.png');
  self.user-asset( $gp-config, 'images', 'page-background', 'highlight-bg.png');
  self.user-asset( $gp-config, 'images', 'hrule', 'hr.png');
  self.user-asset( $gp-config, 'images', 'top-left-icon', 'top-left-icon.png');
  self.user-asset( $gp-config, 'images', 'top', 'top.png');

#  self.user-asset( $gp-config, 'images', 'favicon', 'favicon.ico');
  ( $gp-config<assets><images><favicon> //
    $!resources.get-resource('gh-pages/favicon.ico')
  ).IO.copy('favicon.ico');


  # then, always replace these control files.
  for < _includes/header-section.html
        _includes/sidebar-section.html

        _layouts/default.html
        _layouts/plain-text.html
        _layouts/reference-page.html
        _layouts/sidebar.html

        _sass/jekyll-theme-tactile.scss
        _sass/rouge-base16-dark.scss

        404.md

        assets/images/octocat-icon.png
        assets/images/tar-gz-icon.png
        assets/images/zip-icon.png

      > -> $resource-name {
    self.create-page-from-resource($resource-name);
  }


  # generate and/or copy content
#`{{
  for (
        "gh-pages/_config.yml",

        "gh-pages/_data/about-sidebar.yml",
        "gh-pages/_data/default-nav.yml",
        "gh-pages/_data/reference-sidebar.yml",

        "gh-pages/_includes/header-section.html",
        "gh-pages/_includes/sidebar-section.html",

        "gh-pages/_layouts/default.html",
        "gh-pages/_layouts/plain-text.html",
        "gh-pages/_layouts/reference-page.html",
        "gh-pages/_layouts/sidebar.html",

        "gh-pages/_sass/jekyll-theme-tactile.scss",
        "gh-pages/_sass/rouge-base16-dark.scss",

        "gh-pages/404.html",

        "gh-pages/assets/css/print.css",
        "gh-pages/assets/css/style.scss",

        "gh-pages/assets/images/body-bg.png",
        "gh-pages/assets/images/highlight-bg.jpg",
        "gh-pages/assets/images/hr.png",
        "gh-pages/assets/images/me-1a.png",
        "gh-pages/assets/images/octocat-icon.png",
        "gh-pages/assets/images/tar-gz-icon.png",
        "gh-pages/assets/images/top5.png",
        "gh-pages/assets/images/zip-icon.png",

        "gh-pages/content-docs/about/about.md",
        "gh-pages/content-docs/about/release-notes.md",

        "gh-pages/favicon.ico",
        "gh-pages/Gemfile",
        "gh-pages/index.md",
  ) -> $rname is copy {
    my $fname = $!resources.get-resource($rname);
    $rname ~~ s/^ .*? 'gh-pages' '/'? //;
    my $path = $rname.IO.dirname;
    mkdir $path, 0o750 if ?$path and $path.IO !~~ :e;
    shell "cp $fname $rname";
  }
}}

##`{{ TODO make windows aware
  # check/update or install bundler
  shell "/usr/bin/gem install bundler";

  # copy the ruby Gemfile and initialize
  shell "bundle config set path 'vendor/bundle'";
  shell "bundle install";

#  note "Now go to directory '$!site-dir' and run 'bundle exec jekyll serve'";
#}}

  # return to previous directory
  chdir $cwd;
}

#-------------------------------------------------------------------------------
method create-page-from-resource ( Str $source-path ) {
  my Str ( $from, $to);

  $from = $!resources.get-resource('gh-pages/' ~ $source-path);
  $to = $source-path;
#  $to ~~ s/^ .*? 'gh-pages' '/'? //;

  my Str $path = $to.IO.dirname;
  $path.IO.mkdir(0o750) if ?$path and $path.IO !~~ :e;
  $from.IO.copy($to);
}

#-------------------------------------------------------------------------------
method get-text-from-resource ( Str $source-path --> Str ) {
  $!resources.get-resource('gh-pages/' ~ $source-path).IO.slurp;
}

#-------------------------------------------------------------------------------
method create-page-from-text ( Str $text, Str $to-path ) {
  $to-path.IO.spurt($text);
}

#-------------------------------------------------------------------------------
# set user asset
method user-asset ( Hash:D $gp-config, Str:D $k1, Str:D $k2, Str:D $iname ) {
  if ?$gp-config<assets>{$k1}{$k2} {
    $gp-config<assets>{$k1}{$k2}.IO.copy("assets/$k1/$iname");
  }

  else {
    self.create-page-from-resource("assets/$k1/$iname")
  }
}
