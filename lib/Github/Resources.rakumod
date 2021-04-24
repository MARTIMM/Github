use v6;

#-------------------------------------------------------------------------------
unit class Github::Resources:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
method get-resource ( Str $name --> Str ) {
  my Str $r = (%?RESOURCES{$name} // '').Str;
  die "Resource '$name' not available" unless ?$r;
  $r
}
