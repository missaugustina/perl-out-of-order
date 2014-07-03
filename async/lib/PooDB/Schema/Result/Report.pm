use utf8;
package PooDB::Schema::Result::Report;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PooDB::Schema::Result::Report

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<reports>

=cut

__PACKAGE__->table("reports");

=head1 ACCESSORS

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 status

  data_type: 'varchar'
  default_value: 'pending'
  is_nullable: 1
  size: 60

=head2 start_date

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 end_date

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 submitted_on

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 modified_on

  data_type: 'timestamp'
  is_nullable: 1

=head2 completed_on

  data_type: 'timestamp'
  is_nullable: 1

=head2 report_fields_json

  data_type: 'text'
  is_nullable: 1

=head2 total_time

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "status",
  {
    data_type => "varchar",
    default_value => "pending",
    is_nullable => 1,
    size => 60,
  },
  "start_date",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "end_date",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "submitted_on",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
  "modified_on",
  { data_type => "timestamp", is_nullable => 1 },
  "completed_on",
  { data_type => "timestamp", is_nullable => 1 },
  "report_fields_json",
  { data_type => "text", is_nullable => 1 },
  "total_time",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-07-03 11:01:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1WwVMhOwLxf2DdXjULRM/g
__PACKAGE__->resultset_class( 'DBIx::Class::ResultSet::HashRef' );

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
