use utf8;
package PooDB::Schema::Result::Order;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PooDB::Schema::Result::Order

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<orders>

=cut

__PACKAGE__->table("orders");

=head1 ACCESSORS

=head2 orderid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'orders_orderid_seq'

=head2 orderdate

  data_type: 'date'
  is_nullable: 0

=head2 customerid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 netamount

  data_type: 'numeric'
  is_nullable: 0
  size: [12,2]

=head2 tax

  data_type: 'numeric'
  is_nullable: 0
  size: [12,2]

=head2 totalamount

  data_type: 'numeric'
  is_nullable: 0
  size: [12,2]

=cut

__PACKAGE__->add_columns(
  "orderid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "orders_orderid_seq",
  },
  "orderdate",
  { data_type => "date", is_nullable => 0 },
  "customerid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "netamount",
  { data_type => "numeric", is_nullable => 0, size => [12, 2] },
  "tax",
  { data_type => "numeric", is_nullable => 0, size => [12, 2] },
  "totalamount",
  { data_type => "numeric", is_nullable => 0, size => [12, 2] },
);

=head1 PRIMARY KEY

=over 4

=item * L</orderid>

=back

=cut

__PACKAGE__->set_primary_key("orderid");

=head1 RELATIONS

=head2 customerid

Type: belongs_to

Related object: L<PooDB::Schema::Result::Customer>

=cut

__PACKAGE__->belongs_to(
  "customerid",
  "PooDB::Schema::Result::Customer",
  { customerid => "customerid" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "NO ACTION",
  },
);

=head2 orderlines

Type: has_many

Related object: L<PooDB::Schema::Result::Orderline>

=cut

__PACKAGE__->has_many(
  "orderlines",
  "PooDB::Schema::Result::Orderline",
  { "foreign.orderid" => "self.orderid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-06-18 13:55:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UlwABlOR821f08Q/kED4yw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
