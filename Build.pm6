use v6;

use QA::Sheet;
use QA::Set;
use QA::Question;
use QA::Types;

#------------------------------------------------------------------------------
unit class Build;

constant github-id = 'io.github.martimm.github';

has Str $!dist-path;

#my Str $*cfg-dir = '';
#my Str $*shr-dir = '';

#-------------------------------------------------------------------------------
method build ( Str $!dist-path --> Int ) {

#note $!dist-path;
  self.make-sheets;

  # return success
  1
}

#-------------------------------------------------------------------------------
method make-sheets ( ) {

  # let QA look at the proper locations
  given my QA::Types $qa-types {
    .data-file-type(QAYAML);
    .cfg-root(github-id);
    .init-dirs(:reset)
#note "Config directories: ", .list-dirs.join(', ');
  }

  # cleanup sheets before creating
  $qa-types.qa-remove( 'gp-config', :sheet);
#return;
#  $qa-types.qa-remove( '', :sheet);


  self.gp-config-sheet;
#  self.tag-skip-filter-sheet;

  # cleanup sets afterwards
  $qa-types.qa-remove( 'gp-properties', :set);
#  $qa-types.qa-remove( 'tag-filter-properties', :set);
#  $qa-types.qa-remove( 'skip-filter-properties', :set);
#  $qa-types.qa-remove( '', :set);
}

#-------------------------------------------------------------------------------
method gp-config-sheet ( ) {
  self.gp-properties-set;

  my QA::Sheet $sheet .= new(:sheet-name<gp-config>);
#  $sheet.remove;

  $sheet.width = 500;
  $sheet.height = 450;
  $sheet.button-map<finish> = 'done';

  $sheet.add-page(
    'gp', :title('Github Pages Properties'),
    :description(Q:to/EODecr/)
      Some variables needed to generate the Github pages. It will be based
      on the use of Jekyll. The port number is used to show the site
      locally on your computer. The port number is ignored on Github.
      EODecr
  );

  $sheet.add-set( 'gp', 'gp-properties');

  $sheet.save;
}

#-------------------------------------------------------------------------------
method gp-properties-set ( ) {
  my QA::Set $set;
  my QA::Question $question;

  $set .= new(:set-name<gp-properties>);
  $set.description = Q:to/EODecr/;
    These properties are used to generate the github pages. After generating the data and jekyll is started, you can browse to https://localhost:port/repository/ and https://account.github.io/repository/.
    EODecr

  $question .= new(:name<repository>);
  $question.description = "The name of your github repository";
  $question.required = True;
  $set.add-question($question);

  $question .= new(:name<title>);
  $question.description = 'The main title on the website';
  $question.required = True;
  $set.add-question($question);

  $question .= new(:name<description>);
  $question.description = 'A short description of the project';
#  $question.required = True;
  $set.add-question($question);

  $question .= new(:name<email>);
  $question.description = 'Your email addres if you want to';
#  $question.required = True;
  $question.callback = 'is-email';
  $question.example = 'user.name@example.com';
  $set.add-question($question);

  $question .= new(:name<port>);
  $question.description = 'Port of the local website';
  $question.default = 40000;
  $question.callback = 'is-uint';
  $question.example = '40000';
  $set.add-question($question);

  $question .= new(:name<images>);
  $question.description = 'Asset images to build the pages';
  $question.fieldtype = QAImage;
  $question.repeatable = True;
  $question.selectlist = [ |<
      Top-Area Body-Tile Page-Background Top-Left-Icon
    >
  ];
  $set.add-question($question);


  $set.save;
}






=finish
#-------------------------------------------------------------------------------
method tag-skip-filter-sheet ( ) {
  self.tag-filter-set;
  self.skip-filter-set;

  my QA::Sheet $sheet .= new(:sheet-name<tag-skip-filter-config>);
#  $sheet.remove;

  $sheet.width = 525;
  $sheet.height = 450;

  $sheet.add-page(
    'filters', :title('Tag and Skip Filter List'),
    :description('Filter descriptions using Raku regex')
  );
  $sheet.add-set( 'filters', 'tag-filter-properties');
  $sheet.add-set( 'filters', 'skip-filter-properties');

  $sheet.save;
}

#-------------------------------------------------------------------------------
method tag-filter-set ( ) {
  my QA::Set $set;
  my QA::Question $question;

  $set .= new(:set-name<tag-filter-properties>);
  #$set.remove;
  $set.description = 'Tag filter properties';

  $question .= new(:name<tag-filter>);
  $question.description = 'Tag filters';
  $question.repeatable = True;
  $set.add-question($question);

  $set.save;
}

#-------------------------------------------------------------------------------
method skip-filter-set ( ) {
  my QA::Set $set;
  my QA::Question $question;

  $set .= new(:set-name<skip-filter-properties>);
  $set.description = 'skip filter properties';

  $question .= new(:name<skip-filter>);
  $question.description = 'Skip filters';
  $question.repeatable = True;
  $set.add-question($question);

  $set.save;
}
