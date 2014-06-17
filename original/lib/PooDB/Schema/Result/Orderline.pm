use utf8;
package PooDB::Schema::Result::Orderline;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PooDB::Schema::Result::Orderline

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<orderlines>

=cut

__PACKAGE__->table("orderlines");

=head1 ACCESSORS

=head2 orderlineid

  data_type: 'integer'
  is_nullable: 0

=head2 orderid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 prod_id

  data_type: 'integer'
  is_nullable: 0

=head2 quantity

  data_type: 'smallint'
  is_nullable: 0

=head2 orderdate

  data_type: 'date'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "orderlineid",
  { data_type => "integer", is_nullable => 0 },
  "orderid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "prod_id",
  { data_type => "integer", is_nullable => 0 },
  "quantity",
  { data_type => "smallint", is_nullable => 0 },
  "orderdate",
  { data_type => "date", is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<ix_orderlines_orderid>

=over 4

=item * L</orderid>

=item * L</orderlineid>

=back

=cut

__PACKAGE__->add_unique_constraint("ix_orderlines_orderid", ["orderid", "orderlineid"]);

=head1 RELATIONS

=head2 orderid

Type: belongs_to

Related object: L<PooDB::Schema::Result::Order>

=cut

__PACKAGE__->belongs_to(
  "orderid",
  "PooDB::Schema::Result::Order",
  { orderid => "orderid" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-06-18 13:55:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WOXkC7dx4rfv/zan5ab1HQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
