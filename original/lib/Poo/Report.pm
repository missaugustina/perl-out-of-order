package Poo::Report;
use strict;
use warnings;

use v5.14;

use lib '../../../local/lib/perl5';
use Moose;
use namespace::autoclean;

use Carp;
use Try::Tiny;
use JSON;

use lib '../../lib';
use PooDB::Schema;

# with Database

# flag to indicate the report doesn't exist in the db
has create => (
  isa => 'Bool',
  is => 'ro',
);

# track what fields were set in the event of an update
has unmodified_fields => (
  isa => 'HashRef',
  is => 'ro',
  lazy => 1,
  builder => '_build_unmodified_fields'
);

sub _build_unmodified_fields {
  my %unmodified_fields;
  return \%unmodified_fields;
}

# db handle
has db => (
  isa => 'PooDB::Schema',
  is => 'ro',
  required => 1,
);

# define fields that can be updated
has db_fields => (
  isa => 'ArrayRef',
  is => 'ro',
  lazy => 1,
  builder => '_build_db_fields',
);

sub _build_db_fields {
  my $self = shift;

  my @ok_to_update = qw(
    name
    status
    report_fields_json
  );

  return \@ok_to_update;
}

# select whole record
has db_row => (
  is => 'ro',
  lazy => 1,
  builder => '_build_db_row',
);

sub _build_db_row {
  my $self = shift;

  my $db_row;

  unless ($self->create) {
    $db_row = $self->db->resultset('Report')->search(
      { "me.name" => $self->name }
    )->single;
  }

  croak "Report " . $self->name . " not found."
    unless $db_row;

  return $db_row;
}

has name => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    lazy => 1,
    builder => '_build_name',
);

sub _build_name {
  my $self = shift;

  # if create flag is set, generate the name
  if ($self->create) {
    return 'report_' . time;
  }

  $self->unmodified_fields->{name} = 1;
  return $self->db_row->name;
}

has start_date => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    lazy => 1,
    builder => '_build_start',
);

sub _build_start_date {
  my $self = shift;

  $self->unmodified_fields->{start_date} = 1;
  return $self->db_row->start_date;
}

has end_date => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    lazy => 1,
    builder => '_build_end_date',
);

sub _build_end_date {
  my $self = shift;

  $self->unmodified_fields->{start_date} = 1;
  return $self->db_row->end_date;
}

has status => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    lazy => 1,
    builder => '_build_status',
);

sub _build_status {
  my $self = shift;
  # if create flag is set, status defaults to 'pending'
  if ($self->create) {
    return 'pending';
  }

  $self->unmodified_fields->{status} = 1;
  return $self->db_row->status;
}

has submitted_on => (
  isa => 'Str',
  is => 'ro',
  lazy => 1,
  builder => '_build_submitted_on',
);

sub _build_submitted_on {
  my $self = shift;
  return $self->db_row->submitted_on;
}

has completed_on => (
  isa => 'Str',
  is => 'ro',
  lazy => 1,
  builder => '_build_completed_on',
);

sub _build_completed_on {
  my $self = shift;
  return $self->db_row->completed_on || "";
}

# specifically to track status updates
has modified_on => (
  isa => 'Str',
  is => 'ro',
  lazy => 1,
  builder => '_build_modified_on',
);

sub _build_modified_on {
  my $self = shift;
  return $self->db_row->modified_on;
}

has report_fields_json => (
  isa => 'HashRef',
  is => 'ro',
  lazy => 1,
  builder => '_build_report_fields_json',
);

sub _build_report_fields {
  my $self = shift;
  my $report_fields = $self->db_row->report_fields_json || "{}";
  $self->unmodified_fields->{report_fields_json} = 1;
}

has report_fields => (
  isa => 'HashRef',
  is => 'ro',
  lazy => 1,
  builder => '_build_report_fields',
);

sub _build_report_fields_json {
  my $self = shift;

  if ($self->report_fields_json) {
    return decode_json($self->report_fields_json);
  } else {
    return {};
  }
}

# make a list of fields set by the user on construction
has modified_fields => (
  isa => 'HashRef',
  is => 'ro',
  lazy => 1,
  builder => '_build_modified_fields'
);

sub _build_modified_fields {
  my $self = shift;

  my %modified_fields;

  # get a list of db fields
  for my $field (@{$self->db_fields}) {
    $modified_fields{$field} = $self->$field
      unless $self->unmodified_fields->{$field};
  }

  return \%modified_fields;
}

# list of fields that make sense to display to end users
has fields_for_display => (
  isa => 'ArrayRef',
  is => 'ro',
  lazy => 1,
  builder => '_build_fields_for_display',
);

sub _build_fields_for_display {
  my $self = shift;

  my @safe_fields = qw(
    name
    status
    start_date
    end_date
    submitted_on
    completed_on
  );

  return \@safe_fields;
}

# return a hash of data safe for display on a web page
has hash_for_web => (
  isa => 'HashRef',
  is => 'ro',
  lazy => 1,
  builder => '_build_hash_for_web',
);

sub _build_hash_for_web {
  my $self = shift;

  my %user_info;

  for my $field (@{$self->fields_for_display}) { # maybe there's already a Moosey flag for this
    $user_info{$field} = $self->$field;
  }

  return \%user_info;
}

# public function for writing to the db
sub _update {
  my $self = shift;

  $self->db->resultset('Report')->update($self->modified_fields);

  return;
}

sub _insert {
  my $self = shift;

  my $db_row;

  my %insert = (
    name => $self->name,
    %{$self->modified_fields}
  );

    try {
      $db_row = $self->db->resultset('Report')->new(\%insert);
      $db_row->insert;
    } catch {
      croak "Creating new Report failed: " . $_
        unless $db_row->in_storage();
    };

    return;
}

sub save {
  my $self = shift;

  if ($self->create) {
    $self->_insert;
  } else {
    $self->_update;
  }

  return $self->new(db => $self->db, name => $self->name);
}

__PACKAGE__->meta->make_immutable;

1;
