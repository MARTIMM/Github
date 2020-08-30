use v6;
use Test;

#-------------------------------------------------------------------------------
use Github::Resources;
my Github::Resources $r .= new;

dies-ok {$r.get-resource('no-dir/abc.def'); }, 'resource not found';

for ( "gh-pages/Gemfile", "gh-pages/_config.yml", "gh-pages/404.html",
    "gh-pages/favicon.ico", "gh-pages/index.md",

    "gh-pages/_data/about-nav.yml", "gh-pages/_data/about-sidebar.yml",
    "gh-pages/_data/change-log-data.yml", "gh-pages/_data/default-nav.yml",
    "gh-pages/_data/main-sidebar.yml",

    "gh-pages/_includes/changes-section.html",
    "gh-pages/_includes/header-section.html",
    "gh-pages/_includes/sidebar-section.html",

    "gh-pages/_layouts/default.html", "gh-pages/_layouts/plain-text.html",
    "gh-pages/_layouts/sidebar.html",

    "gh-pages/_sass/jekyll-theme-tactile.scss",
    "gh-pages/_sass/rouge-base16-dark.scss",

    "gh-pages/assets/css/print.css", "gh-pages/assets/css/style.scss",

    "gh-pages/assets/images/body-bg.png",
    "gh-pages/assets/images/highlight-bg.jpg",
    "gh-pages/assets/images/hr.png", "gh-pages/assets/images/octocat-icon.png",
    "gh-pages/assets/images/tar-gz-icon.png",
    "gh-pages/assets/images/top5.png", "gh-pages/assets/images/zip-icon.png",

    "gh-pages/content-docs/about.md", "gh-pages/content-docs/images/me-1a.png"
) -> $rname {
  is $r.get-resource($rname), "$*CWD/resources/$rname", $rname;
}

#-------------------------------------------------------------------------------
done-testing;
