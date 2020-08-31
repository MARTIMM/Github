# Small Github Tools

There are not many tools yet. The tools are Rake scripts and made for my specific environment. If you are interested, clone the repository and check out the programs and libraries if it can be useful for you.

# Programs

* `gitArchive.pl6`. Program to upload my projects to CPAN. It finds out if anything needs to be committed and if the master branch is selected.
  **Dependencies**;
  * None (I think...), username and password are noted in `~/.pause`. Github access is controlled using data from `~/ssh` on my machine.

* `githubPages.pl6`. Program to setup github pages in a directory by default    called `docs`.
  **Dependencies**;
  * Style of theme, background image etc. You must change that to have your own theme.
  * Need to have Ruby installed and bundle.
