use utf8;
package PooDB::Schema::Result::Customer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PooDB::Schema::Result::Customer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<customers>

=cut

__PACKAGE__->table("customers");

=head1 ACCESSORS

=head2 customerid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'customers_customerid_seq'

=head2 firstname

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 lastname

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 address1

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 address2

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 city

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 state

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 zip

  data_type: 'integer'
  is_nullable: 1

=head2 country

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 region

  data_type: 'smallint'
  is_nullable: 0

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 phone

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 creditcardtype

  data_type: 'integer'
  is_nullable: 0

=head2 creditcard

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 creditcardexpiration

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 password

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 age

  data_type: 'smallint'
  is_nullable: 1

=head2 income

  data_type: 'integer'
  is_nullable: 1

=head2 gender

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=cut

__PACKAGE__->add_columns(
  "customerid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "customers_customerid_seq",
  },
  "firstname",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "lastname",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "address1",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "address2",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "city",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "state",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "zip",
  { data_type => "integer", is_nullable => 1 },
  "country",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "region",
  { data_type => "smallint", is_nullable => 0 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "creditcardtype",
  { data_type => "integer", is_nullable => 0 },
  "creditcard",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "creditcardexpiration",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "password",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "age",
  { data_type => "smallint", is_nullable => 1 },
  "income",
  { data_type => "integer", is_nullable => 1 },
  "gender",
  { data_type => "varchar", is_nullable => 1, size => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</customerid>

=back

=cut

__PACKAGE__->set_primary_key("customerid");

=head1 UNIQUE CONSTRAINTS

=head2 C<ix_cust_username>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("ix_cust_username", ["username"]);

=head1 RELATIONS

=head2 cust_hists

Type: has_many

Related object: L<PooDB::Schema::Result::CustHist>

=cut

__PACKAGE__->has_many(
  "cust_hists",
  "PooDB::Schema::Result::CustHist",
  { "foreign.customerid" => "self.customerid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 orders

Type: has_many

Related object: L<PooDB::Schema::Result::Order>

=cut

__PACKAGE__->has_many(
  "orders",
  "PooDB::Schema::Result::Order",
  { "foreign.customerid" => "self.customerid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-06-19 23:08:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9cCCaGW4q+P/Os4RmNa0Aw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
