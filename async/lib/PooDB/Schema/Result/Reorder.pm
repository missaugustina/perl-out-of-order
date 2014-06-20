use utf8;
package PooDB::Schema::Result::Reorder;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PooDB::Schema::Result::Reorder

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<reorder>

=cut

__PACKAGE__->table("reorder");

=head1 ACCESSORS

=head2 prod_id

  data_type: 'integer'
  is_nullable: 0

=head2 date_low

  data_type: 'date'
  is_nullable: 0

=head2 quan_low

  data_type: 'integer'
  is_nullable: 0

=head2 date_reordered

  data_type: 'date'
  is_nullable: 1

=head2 quan_reordered

  data_type: 'integer'
  is_nullable: 1

=head2 date_expected

  data_type: 'date'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "prod_id",
  { data_type => "integer", is_nullable => 0 },
  "date_low",
  { data_type => "date", is_nullable => 0 },
  "quan_low",
  { data_type => "integer", is_nullable => 0 },
  "date_reordered",
  { data_type => "date", is_nullable => 1 },
  "quan_reordered",
  { data_type => "integer", is_nullable => 1 },
  "date_expected",
  { data_type => "date", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-06-19 23:08:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Cp5SzYfXneXx6DxbuPIWKg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
