use utf8;
package PooDB::Schema::Result::Image;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PooDB::Schema::Result::Image

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<images>

=cut

__PACKAGE__->table("images");

=head1 ACCESSORS

=head2 id

  data_type: 'varchar'
  is_nullable: 0
  size: 3

=head2 image

  data_type: 'bytea'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "varchar", is_nullable => 0, size => 3 },
  "image",
  { data_type => "bytea", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-06-19 23:08:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bFWH5jksA8Lcqbt/X+j1CA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
