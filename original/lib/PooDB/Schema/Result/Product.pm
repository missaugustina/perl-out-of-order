use utf8;
package PooDB::Schema::Result::Product;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PooDB::Schema::Result::Product

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<products>

=cut

__PACKAGE__->table("products");

=head1 ACCESSORS

=head2 prod_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'products_prod_id_seq'

=head2 category

  data_type: 'integer'
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 actor

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 price

  data_type: 'numeric'
  is_nullable: 0
  size: [12,2]

=head2 special

  data_type: 'smallint'
  is_nullable: 1

=head2 common_prod_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "prod_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "products_prod_id_seq",
  },
  "category",
  { data_type => "integer", is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "actor",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "price",
  { data_type => "numeric", is_nullable => 0, size => [12, 2] },
  "special",
  { data_type => "smallint", is_nullable => 1 },
  "common_prod_id",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</prod_id>

=back

=cut

__PACKAGE__->set_primary_key("prod_id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-06-18 13:55:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ftPvh7uGFNtATlNYdQmv+Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
