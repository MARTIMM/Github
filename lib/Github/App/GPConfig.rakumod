use v6.d;

use Gnome::Gtk3::Dialog;
use QA::Gui::SheetSimple;
use QA::Types;
#use Gnome::N::X;

#-------------------------------------------------------------------------------
unit class Github::App::GPConfig:auth<github:MARTIMM>:ver<0.1.0>;

has Str $!sheet-name is required;
has Hash $!user-data;

#-------------------------------------------------------------------------------
submethod BUILD ( Str:D :$!sheet-name, Hash :$!user-data = %() ) {
  my QA::Types $qa-types .= instance;
  $qa-types.set-check-handler( 'is-uint', self, 'check-uint');
  $qa-types.set-check-handler( 'is-email', self, 'check-email');
}

#-------------------------------------------------------------------------------
method show-dialog ( --> Hash ) {

  my QA::Gui::SheetSimple $sheet-dialog .= new(
    :$!sheet-name, :$!user-data, :show-cancel-warning, :!save-data
  );

  my Int $response = $sheet-dialog.show-sheet;
  $sheet-dialog.result-user-data // %()
}

#-------------------------------------------------------------------------------
method check-uint ( Str $input --> Any ) {
  "Only unsigned integers are allowed" unless $input ~~ m/^ \d* $/;
}

#-------------------------------------------------------------------------------
method check-email ( Str $input --> Any ) {
  "Email not properly specified"
    unless $input ~~ m/^ <[.\-_\w]>+ '@' <[.\-_\w]>+ $/;
}
