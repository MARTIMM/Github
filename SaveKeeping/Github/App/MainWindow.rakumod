use v6;

#-------------------------------------------------------------------------------
use Gnome::N::N-GObject;

use Gnome::Gtk3::Builder;
use Gnome::Gtk3::AboutDialog;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::ApplicationWindow;
use Gnome::Gtk3::Window;
use Gnome::Gtk3::CssProvider;
use Gnome::Gtk3::StyleContext;
use Gnome::Gtk3::StyleProvider;

use Gnome::Gio::MenuModel;
use Gnome::Gio::SimpleAction;

use Gnome::Gdk3::Pixbuf;
use Gnome::Gdk3::Screen;

use Gnome::Glib::Error;
use Gnome::Glib::VariantType;

use Github::App::GPConfig;
use Github::Pages;

#use Library::Gui::QA::DBFilters;
#use Library::Gui::QA::DBConfig;

#use Library::DB::Client;

#use BSON::Document;

use QA::Gui::OkMsgDialog;
use QA::Types;

use Digest::SHA1::Native;

#use Library::App::Menu::Help;
#use QAManager::App::Page::Category;
#use QAManager::App::Page::Sheet;
#use QAManager::App::Page::Set;

#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
unit class Github::App::MainWindow:auth<github:MARTIMM>:ver<0.2.1>;
also is Gnome::Gtk3::ApplicationWindow;

has $!application is required;
has Gnome::Gtk3::Builder $!builder;
has Str $app-rbpath;
has Version $!app-version;
has Str $!github-id;
#has Library::DB::Client $!db;

#enum NotebookPages <SHEETPAGE CATPAGE SETPAGE>;

#has Library::App::ApplicationWindow $!app-window;
has Gnome::Gtk3::Grid $!grid;
#has Gnome::Gtk3::Notebook $!notebook;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  # let the Gnome::Gtk3::ApplicationWindow class process the options
  self.bless( :GtkApplicationWindow, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( :$!application, Version :$!app-version, Str :$!github-id ) {

#`{{ Not needed, path still set from app
  given my QA::Types $qa-types {
    note "$?LINE ", .list-dirs.gist;

    .data-file-type(QAYAML);
    .cfg-root($!github-id);
    .list-dirs.note;
  }
}}

  $!app-rbpath = $!application.get-resource-base-path;

  $!builder .= new;
  self.load-gui;

  self.setup-application-menu;
  self.setup-application-style('github-style');

  self.set-title('Github Tools');
  self.set-border-width(2);
  self.set-keep-above(True);
#  self.set-position(GTK_WIN_POS_MOUSE);
  self.set-size-request( 400, 450);

  my Gnome::Glib::Error $e = self.set-icon-from-file(
    %?RESOURCES<github-logo.png>.Str
  );
  die $e.message if $e.is-valid;

  $!grid .= new;
  #$!grid.buildable-set-name('main-grid');

  self.add($!grid);
  #self.buildable-set-name('main-window');

  self.show-all;
}

#-------------------------------------------------------------------------------
method load-gui ( ) {
  my Gnome::Glib::Error $e;

  # read the menu xml into the builder
  $e = $!builder.add-from-resource("$!app-rbpath/app-menu");
  die $e.message if $e.is-valid;

  # read the menu xml into the builder
  $e = $!builder.add-from-resource("$!app-rbpath/help-about");
  die $e.message if $e.is-valid;
}

#-------------------------------------------------------------------------------
method setup-application-style ( Str $resource-name ) {

note "set style $resource-name";
  # read the style definitions into the css provider and style context
  my Gnome::Gtk3::CssProvider $css-provider .= new;
  $css-provider.load-from-resource("$!app-rbpath/$resource-name");

  my Gnome::Gtk3::StyleContext $style-context .= new;
  $style-context.add_provider_for_screen(
    Gnome::Gdk3::Screen.new, $css-provider, GTK_STYLE_PROVIDER_PRIORITY_USER
  );
}

#-------------------------------------------------------------------------------
method setup-application-menu ( ) {

  # add application menu from XML in resources
  my Gnome::Gio::MenuModel $menubar .= new(:build-id<menubar>);
  $!application.set-menubar($menubar);

#  self.link-actions( |<app-quit> );
  self.link-actions(
    %( :quit<app-quit>, :about-dialog<help-about>,
       :config<config-gp>, :generate<generate-gp>
#       :edit-db-config<db-config>, :edit-filters<db-filters>,
#       :connect-db<connect-db>, :disconnect-db<disconnect-db>,
    )
  );
  #self.link-state-action( 'select-compression', 'uncompressed');
}

#-------------------------------------------------------------------------------
# all actions are linked to methods with same name
method link-actions ( Hash $actions ) {

  my Gnome::Gio::SimpleAction $simple-action;
  for $actions.keys -> $action {
    my Str $method = $actions{$action};
note "Map action $action.fmt('%-20.20s') ~~~> .$method\()";
    $simple-action .= new(:name($action));
    $simple-action.set-enabled(True);
    $!application.add-action($simple-action);
    $simple-action.register-signal( self, $method, 'activate');
    $simple-action.clear-object;
  }
}

#-------------------------------------------------------------------------------
method link-state-action (
  Str:D $action, Str:D :$state!, Str :$method is copy
) {
  $method //= $action;
note "Map action $action.fmt('%-20.20s') with state $state ~~~> .$method\()";

  my Gnome::Gio::SimpleAction $simple-action;
  $simple-action .= new(
    :name($action),
    :parameter-type(Gnome::Glib::VariantType.new(:type-string<s>)),
    :state(Gnome::Glib::Variant.new(:parse("'$state'")))
  );
  $simple-action.register-signal( self, $method, 'change-state');
  $!application.add-action($simple-action);
  $simple-action.clear-object;
}

#`{{
#-------------------------------------------------------------------------------
method link-action ( Str:D $action, Str :$method is copy ) {

  $method //= $action;
note "Map action $action.fmt('%-20.20s') ~~~> .$method\()";

  my Gnome::Gio::SimpleAction $simple-action;
  $simple-action .= new(:name($action));
  $simple-action.register-signal( self, $method, 'activate');
  $!application.add-action($simple-action);
  $simple-action.clear-object;
}
}}

#--[ signal handlers ]----------------------------------------------------------

#-- [ menu ] -------------------------------------------------------------------
# Application > Quit
method app-quit ( N-GObject $n-parameter ) {
  note "Selected 'Quit' from 'Application' menu";

  $!application.quit;
}

#-------------------------------------------------------------------------------
# Github Pages > Configure
method config-gp ( N-GObject $n-parameter ) {
  note "Selected 'Configure' from 'Github Pages' menu";

  # load and store data in files depending on the current directory.
  my QA::Types $qa-types .= instance;
  my Str $filename = sha1-hex($*CWD.Str);
  my Hash $gp-config = $qa-types.qa-load( $filename, :userdata);

  # initialize and show QA dialog
  my Github::App::GPConfig $gpc .= new(
    :sheet-name<gp-config>, :user-data($gp-config)
  );

  #self.setup-application-style('QA');
  $gp-config = $gpc.show-dialog;

  # after return save the data
  self!show-hash($gp-config);

  if ?$gp-config {
    $qa-types.qa-save( $filename, $gp-config, :userdata);
  }

  else {
    note 'No data returned, data not saved';
  }
}

#-------------------------------------------------------------------------------
# Github Pages > Generate
method generate-gp ( N-GObject $n-parameter ) {
  note "Selected 'Generate' from 'Github Pages' menu";

  my QA::Types $qa-types .= instance;
  my Str $filename = sha1-hex($*CWD.Str);
  my Hash $gp-config = $qa-types.qa-load( $filename, :userdata);
  my Github::Pages $pages .= new;
  $pages.create-gh-pages($gp-config);
}

#-------------------------------------------------------------------------------
# Help > About
method help-about ( N-GObject $n-parameter ) {
  note "Selected 'About' from 'Help' menu";
  my Gnome::Gtk3::AboutDialog $about .= new(:build-id<aboutdialog>);
  $about.set-transient-for(self);
  $about.set-version($!app-version.Str);

  # Getting some ideas to show different UML images of what program does.
  # Using some scratch images now…
  my Gnome::Gdk3::Pixbuf $pix .= new(
    :file(%?RESOURCES<github-logo.png>.Str), :width(200), :height(200)
  );
  $about.set-logo($pix);
  #self.setup-application-style('about-dialog');
  $about.run;
  $about.hide;  # cannot destroy, builder keeps same native-object
}

#-------------------------------------------------------------------------------
# show message
method !show-msg($message) {
  my QA::Gui::OkMsgDialog $msg-diag .= new(:$message);
  $msg-diag.run;
  $msg-diag.destroy;
}

#-------------------------------------------------------------------------------
method !show-hash ( Hash $h, Int :$i is copy ) {
  if $i.defined {
    $i++;
  }

  else {
    note '';
    $i = 0;
  }

  for $h.keys.sort -> $k {
    if $h{$k} ~~ Hash {
      note '  ' x $i, "$k => \{";
      self!show-hash( $h{$k}, :$i);
      note '  ' x $i, '}';
    }

    elsif $h{$k} ~~ Array {
      note '  ' x $i, "$k => $h{$k}.perl()";
    }

    else {
      note '  ' x $i, "$k => $h{$k}";
    }
  }

  $i--;
}

=finish




  # make main window widgets
  #my Gnome::Gtk3::Grid $grid .= new;
  #self.add($grid);

  #my Gnome::Gtk3::Grid $fst-page = self.setup-workarea;
  #self.setup-workarea;

#Gnome::N::debug(:on);

  # set the visibility of the menu after all is shown
#  self.set-menu-visibility( 'sheet', :visible);
#  self.set-menu-visibility( 'category', :!visible);
#  self.set-menu-visibility( 'set', :!visible);


#`{{
  my Gnome::Gtk3::Label $strut .= new(:text(''));
  $strut.set-line-wrap(False);
  #$description.set-max-width-chars(60);
  $strut.set-justify(GTK_JUSTIFY_FILL);
  $strut.widget-set-halign(GTK_ALIGN_START);

  my Gnome::Gtk3::MenuBar $mb .= new(:build-id<menubar>);
  $!grid.grid-attach( $mb, 0, 0, 1, 1);

  my $app := self;

  my Library::App::Menu::File $file .= new(:$app);
  my Library::App::Menu::Help $help .= new(:$app);

  my Hash $handlers = %(
    :file-quit($file),
    :help-about($help),
  );

  $builder.connect-signals-full($handlers);
}}

#`{{
#-------------------------------------------------------------------------------
# register a handler for a menu item. The $build-id is also the name
# of the handler method in the $menu object.
method menu-handler ( $menu, $build-id ) {

  my Gnome::Gtk3::MenuItem $mi .= new(:$build-id);
  $mi.register-signal( $menu, $build-id, 'activate');
}
}}

#-------------------------------------------------------------------------------
#`{{
method setup-workarea ( --> Gnome::Gtk3::Grid ) {
  $!notebook .= new;
  $!notebook.widget-set-hexpand(True);
  $!notebook.widget-set-vexpand(True);

  my $app := self;
  my QAManager::App::Page::Sheet $sheet .= new;
  $!notebook.append-page( $sheet, Gnome::Gtk3::Label.new(:text<Sheets>));

  $!notebook.append-page(
    QAManager::App::Page::Category.new,
    Gnome::Gtk3::Label.new(:text<Categories>)
  );

  $!notebook.append-page(
    QAManager::App::Page::Set.new(
      :$app, :$!app-window, :rbase-path(self.get-resource-base-path)
    ),
    Gnome::Gtk3::Label.new(:text<Sets>)
  );

#  $!notebook.register-signal( self, 'change-menu', 'switch-page');
  $!grid.grid-attach( $!notebook, 0, 1, 1, 1);

  # return one of the pages to set the visibility of the menu after all is shown
  $sheet
}
}}

#`{{
#-------------------------------------------------------------------------------
method set-menu-visibility( Str $menu-id, Bool :$visible ) {
  my Gnome::Gtk3::MenuItem $menu .= new(:build-id($menu-id));
  $menu.set-visible($visible);
}
}}

#--[ signal handlers ]----------------------------------------------------------
#`{{
# change menu on change of notebook pages
method change-menu ( N-GObject $no, uint32 $page-num --> Int ) {

  given $page-num {
    when SHEETPAGE {
      self.set-menu-visibility( 'sheet', :visible);
      self.set-menu-visibility( 'category', :!visible);
      self.set-menu-visibility( 'set', :!visible);
    }

    when CATPAGE {
      self.set-menu-visibility( 'sheet', :!visible);
      self.set-menu-visibility( 'category', :visible);
      self.set-menu-visibility( 'set', :!visible);
    }

    when SETPAGE {
      self.set-menu-visibility( 'sheet', :!visible);
      self.set-menu-visibility( 'category', :!visible);
      self.set-menu-visibility( 'set', :visible);
    }
  }

  1;
}
}}
