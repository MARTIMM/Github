---
#title: some title
layout: default
nav_menu: default-nav
#sidebar_menu: main-sidebar
---

[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Project page title

This is the main page of any of your projects. You likely want to replace my gibberish with your information.

Above you see (in the file that is) a few lines called frontmatter. There you see that the layout of this page is set to `default` which uses `default.html` in `docs/_layouts`.

The menu is still simple but can be changed easily. The main menu is set by `nav_menu` and in this case points to `default-nav.yml` in `docs/_data`.

When a side bar is needed, change the layout to `sidebar` and set the setting to a sidebar menu. E.g. About uses the sidebar_menu `about-sidebar` which points to the file `about-sidebar.yml` in `docs/_data`.

A sitemap is shown below along with notes which files are replaced when the site is generated again;
```
docs
├─ 404.md                            replaced
├─ Gemfile                           replaced
├─ Gemfile.lock                      replaced
├─ _config.yml                       replaced
├─ _data
│  ├─ about-sidebar.yml              user may add/change content
│  ├─ default-nav.yml                user may add/change content
│  ╰─ reference-sidebar.yml          user may add/change content
├─ _includes
│  ├─ header-section.html            replaced
│  ╰─ sidebar-section.html           replaced
├─ _layouts
│  ├─ default.html                   replaced
│  ├─ plain-text.html                replaced
│  ├─ reference-page.html            replaced
│  ╰─ sidebar.html                   replaced
├─ _sass
│  ├─ jekyll-theme-tactile.scss      replaced
│  ╰─ rouge-base16-dark.scss         replaced
├─ assets
│  ├─ css
│  │  ├─ print.css                   user may add/change content
│  │  ╰─ style.scss                  user may add/change content
│  ╰─ images
│     ├─ body-bg.png                 replaced
│     ├─ favicon.ico                 replaced
│     ├─ highlight-bg.png            replaced
│     ├─ hrule.png                   replaced
│     ├─ octocat-icon.png            replaced
│     ├─ tar-gz-icon.png             replaced
│     ├─ top.png                     replaced
│     ├─ top-left-icon.png           replaced
│     ╰─ zip-icon.png                replaced
├─ content-docs
│  ├─ about
│  │  ├─ about.md                    user may add/change content
│  │  ╰─ release-notes.md            user may add/change content
│  ├─ images
│  ╰─ reference
│     ╰─ reference.md                user may add/change content
├─ index.md                          user may add/change content
╰─ favicon.ico                       replaced
```
