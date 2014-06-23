use utf8;
package PooDB::Schema::Result::CustHist;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PooDB::Schema::Result::CustHist

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<cust_hist>

=cut

__PACKAGE__->table("cust_hist");

=head1 ACCESSORS

=head2 customerid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 orderid

  data_type: 'integer'
  is_nullable: 0

=head2 prod_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "customerid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "orderid",
  { data_type => "integer", is_nullable => 0 },
  "prod_id",
  { data_type => "integer", is_nullable => 0 },
);

=head1 RELATIONS

=head2 customerid

Type: belongs_to

Related object: L<PooDB::Schema::Result::Customer>

=cut

__PACKAGE__->belongs_to(
  "customerid",
  "PooDB::Schema::Result::Customer",
  { customerid => "customerid" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-06-19 23:08:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9q6KNhvAht/pLMQcBt7hKg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
