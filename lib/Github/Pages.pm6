use v6;

#-------------------------------------------------------------------------------
unit class Github::Pages:auth<github:MARTIMM>;

use Github::Resources;

has Github::Resources $!resources .= new;

#-------------------------------------------------------------------------------
method create-gh-pages ( Str $src = 'docs' ) {

  if $src.IO ~~ :e {
    say "Site already generated, abort";
    return;
  }

  # create github pages dir
  mkdir $src, 0o750 unless $src.IO.e;

  # save directory and step into root of github pages dir
  my Str $cwd = $*CWD.Str;
  chdir $src;

  # create directories and copy content
  mkdir 'images', 0o750 unless 'images'.IO ~~ :e;

  for (
        "gh-pages/_config.yml",

        "gh-pages/_data/about-nav.yml",
        "gh-pages/_data/about-sidebar.yml",
        "gh-pages/_data/default-nav.yml",
        "gh-pages/_data/main-sidebar.yml",

        "gh-pages/_includes/header-section.html",
        "gh-pages/_includes/sidebar-section.html",

        "gh-pages/_layouts/default.html",
        "gh-pages/_layouts/plain-text.html",
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

        "gh-pages/content-docs/About/about.md",
        "gh-pages/content-docs/About/release-notes.md",

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

  # check/update or install bundler
  shell "/usr/bin/gem install bundler";

  # copy the ruby Gemfile and initialize
  shell "bundle config set path 'vendor/bundle'";
  shell "bundle install";

  # return to previous directory
  chdir $cwd;
}
