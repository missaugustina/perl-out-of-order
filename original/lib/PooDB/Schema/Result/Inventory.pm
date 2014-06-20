use utf8;
package PooDB::Schema::Result::Inventory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PooDB::Schema::Result::Inventory

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<inventory>

=cut

__PACKAGE__->table("inventory");

=head1 ACCESSORS

=head2 prod_id

  data_type: 'integer'
  is_nullable: 0

=head2 quan_in_stock

  data_type: 'integer'
  is_nullable: 0

=head2 sales

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "prod_id",
  { data_type => "integer", is_nullable => 0 },
  "quan_in_stock",
  { data_type => "integer", is_nullable => 0 },
  "sales",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</prod_id>

=back

=cut

__PACKAGE__->set_primary_key("prod_id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-06-19 23:08:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GVEctZJRCBzupp5zFBdSDQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
