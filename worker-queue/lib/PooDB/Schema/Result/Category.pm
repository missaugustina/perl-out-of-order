use utf8;
package PooDB::Schema::Result::Category;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PooDB::Schema::Result::Category

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<categories>

=cut

__PACKAGE__->table("categories");

=head1 ACCESSORS

=head2 category

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'categories_category_seq'

=head2 categoryname

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=cut

__PACKAGE__->add_columns(
  "category",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "categories_category_seq",
  },
  "categoryname",
  { data_type => "varchar", is_nullable => 0, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</category>

=back

=cut

__PACKAGE__->set_primary_key("category");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-06-19 23:08:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3MV7194u7VHQ0ooVzi2GmQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
