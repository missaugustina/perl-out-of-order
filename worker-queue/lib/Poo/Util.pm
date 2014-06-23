package Poo::Util;

use Carp;
use Try::Tiny;
use Config::Any;
use Data::Dumper;

use strict;
use warnings;

use v5.14;

my $DEBUG = 0;

sub get_config {
  my $config_file = $ENV{POO_CONFIG};
  
  # error out if POO_CONFIG is not set
  croak "Environment variable POO_CONFIG is not set."
      unless defined $config_file;

  my @files;
  push @files, $config_file;
  my $cfg = Config::Any->load_files( { files => \@files, use_ext => 1, flatten_to_hash => 1} );

  my $config = $cfg->{$config_file};
  say "loaded config from file: $config_file " . Dumper($config)
      if $DEBUG;


  return $config;
}

1;
