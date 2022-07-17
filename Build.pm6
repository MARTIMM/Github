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
#TODO
return 1;

#note $!dist-path;
  self.make-sheets;
  self.change-store-css;

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
#  $qa-types.qa-remove( '', :sheet);


  self.gp-config-sheet;

  # cleanup sets afterwards
  $qa-types.qa-remove( 'browser-info', :set);
  $qa-types.qa-remove( 'other-info', :set);
  $qa-types.qa-remove( 'other-files', :set);
  $qa-types.qa-remove( 'images', :set);
#  $qa-types.qa-remove( '', :set);
}

#-------------------------------------------------------------------------------
method gp-config-sheet ( ) {
  self.gp-property-sets;
  self.gp-assets-set;

  my QA::Sheet $sheet .= new(:sheet-name<gp-config>);

  $sheet.width = 400;
  $sheet.height = 450;
  $sheet.button-map<finish> = 'done';

  $sheet.add-page(
    'properties', :title('Github Pages Properties'),
    :description(Q:to/EODecr/)
      Some variables needed to generate the Github pages. It will be based on the use of Jekyll. The port number is used to show the site locally on your computer. The port number is ignored on Github.
      EODecr
  );

  $sheet.add-set( 'properties', 'browser-info');
  $sheet.add-set( 'properties', 'other-info');


  $sheet.add-page(
    'assets', :title('Github Assets'),
    :description('Define your images and stylesheets here.')
  );

  $sheet.add-set( 'assets', 'other-files');
  $sheet.add-set( 'assets', 'images');

  $sheet.save;
}

#-------------------------------------------------------------------------------
method gp-property-sets ( ) {

  my QA::Set $set;
  my QA::Question $question;

  $set .= new(:set-name<browser-info>);
  $set.title = 'Browser Info';
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
  $set.add-question($question);

  $question .= new(:name<port>);
  $question.description = 'Port of the local website';
  $question.default = 40000;
  $question.callback = 'is-uint';

note $question.keys.join(', ');
  $question.example = '40000';
  $set.add-question($question);

  $set.save;


  $set .= new(:set-name<other-info>);
  $set.title = 'Other Info';
  $set.description = "Other optional data";

  $question .= new(:name<email>);
  $question.description = 'Email addres';
  $question.callback = 'is-email';
  $question.example = 'user.name@example.com';
  $set.add-question($question);

  $question .= new(:name<account>);
  $question.description = 'Github account name';
  $set.add-question($question);

  $question .= new(:name<site-dir>);
  $question.description = 'Location root of website. Default at ./docs';
  $question.default = './docs';
  $set.add-question($question);

  $set.save;
}

#-------------------------------------------------------------------------------
method gp-assets-set ( ) {
  my QA::Set $set;
  my QA::Question $question;

  $set .= new(:set-name<other-files>);
  $set.title = 'Other Files';
  $set.description = "Text files like stylesheets";

  $question .= new(:name<browser-stylesheet>);
  $question.description = Q:to/EODecr/;
    A user stylesheet, if any. It must have the line '@import "jekyll-theme-tactile";' at the top.
    EODecr
  $question.fieldtype = QAFileChooser;
  $set.add-question($question);

  $question .= new(:name<printer-stylesheet>);
  $question.description = Q:to/EODecr/;
    A user stylesheet, if any.
    EODecr
  $question.fieldtype = QAFileChooser;
  $set.add-question($question);

  $set.save;



  $set .= new(:set-name<images>);
  $set.description = "Images for background and other purposes";

  $question .= new(:name<top>);
  $question.description = 'Image placed at the top. It should be very wide and about 100 px high';
  $question.fieldtype = QAImage;
  $set.add-question($question);

  $question .= new(:name<top-left-icon>);
  $question.description = 'Image placed at the top left over the top image. It should be a logo of some sort';
  $question.fieldtype = QAImage;
  $set.add-question($question);

#  $question .= new(:name<top-image>);
#  $question.description = 'Upper body part';
#  $question.fieldtype = QAImage;
#  $set.add-question($question);

  $question .= new(:name<body-tile>);
  $question.description = 'Lower part body tile';
  $question.fieldtype = QAImage;
  $set.add-question($question);

  $question .= new(:name<page-background>);
  $question.description = 'As an alternative, a stretchable image as the background image';
  $question.fieldtype = QAImage;
  $set.add-question($question);

  $question .= new(:name<favicon>);
  $question.description = 'A favicon, an html browser icon';
  $question.fieldtype = QAImage;
  $set.add-question($question);

  $question .= new(:name<hrule>);
  $question.description = 'A background image used in a hr-element';
  $question.fieldtype = QAImage;
  $set.add-question($question);

  $set.save;
}

#-------------------------------------------------------------------------------
# at build time resources are not yet installed so changes can happen
#   copy images to config dir
#   modify css in resources for images in config dir
method change-store-css ( ) {

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
