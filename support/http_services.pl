#!/usr/bin/env perl

use v5.14;

use lib '../local/lib/perl5';
use Mojolicious::Lite;
use JSON;

use lib '../original/lib';
use PooDB::Schema;

# create db handle
helper db => sub {
  my $dsn = "dbi:Pg:dbname=poo";
  my $dbuser = "poo";
  my $dbpass = "pooiscool";
  return PooDB::Schema->connect($dsn, $dbuser, $dbpass);
};

get '/image' => sub {
  my $self = shift;
  
  # randomly wait 1 second before continuing
  my $wait = int(rand(100));
  if ($wait%10 == 0) {
    sleep 1;
  }

  my $id = int(rand(25));
  
  my $db_row = $self->db->resultset('Image')->search(
      { "me.id" => $id }
    )->single;
  
  my $image = $db_row->image;
  
  $self->render(data => $image, format => 'jpg');
};

get '/weather' => sub {
  my $self = shift;
  
  # randomly wait 5 seconds before continuing
  my $wait = int(rand(100));
  if ($wait%10 == 0) {
    sleep 5;
  }
 
  my %weather;
  
  # select a random number between 0-40
  $weather{temperature} = int(rand(40));
  
  my @weather_types = qw(
    snow
    hail
    sunny
    cloudy
    rain
    fog
    windy
    clear
  );
  
  $weather{description} = $weather_types[ int(rand(@weather_types)) ];
  
  my @weather_alerts = (
    'none',
    'none',
    'earthquake warning',
    'storm watch',
    'flood watch',
    'none',
    'high winds warning',
    'tornado watch',
    'volcanic eruption',
    'none',
    'none',
  );
  
  # select 0 or 1
  $weather{alert} = $weather_alerts[int(rand(@weather_alerts))];
  
  my $weather_json = encode_json(\%weather);
  $self->render(json => $weather_json);
};

app->start;
