package Poo::ReportBuilder;
use strict;
use warnings;

use v5.14;

use lib '../../../local/lib/perl5';
use Moose;
use namespace::autoclean;

use Carp;
use Try::Tiny;
use JSON;
use LWP;
use DBI;
use Time::HiRes qw(gettimeofday tv_interval);

# db handle
has dbh => (
  isa => 'DBI::db',
  is => 'ro',
  lazy => 1,
  builder => '_build_dbh'
);

sub _build_dbh {
  my $dsn = "dbi:Pg:dbname=poo";
  my $dbuser = "poo";
  my $dbpass = "pooiscool";
  
  return DBI->connect($dsn, $dbuser, $dbpass);
}

has urls => (
  isa => 'HashRef',
  is => 'ro',
  lazy => 1,
  builder => '_build_urls',
);

sub _build_urls {
  return {
    weather => 'http://localhost:8080/weather',
    image => 'http://localhost:8080/image'
  };
}

has _user_agent => (
  isa => 'LWP::UserAgent',
  is => 'ro',
  lazy => 1,
  builder => '_build__user_agent',
);

sub _build__user_agent {
  return LWP::UserAgent->new();
}

has columns => (
  isa => 'ArrayRef',
  is => 'ro',
  lazy => 1,
  builder => '_build_columns',
);
sub _build_columns {
  return [qw(
      customer
      image
      date
      location
      total
      weather_alert
      weather_description
      temperature
    )];
}

sub build_report {
  my $self = shift;
  my ($args) = (@_);
  
  my $report = [];

  my $db_data = $self->_get_data_from_db($args);
  for my $row (@{$db_data}) {
    
    my $report_row;
    
    # get data from external services
    my $http_data = $self->_get_data_from_urls();
    my $weather = $http_data->{weather}->{content};
    
    $report_row->{weather_alert} = $weather->{alert};
    $report_row->{weather_description} = $weather->{description};
    $report_row->{temperature} = $weather->{temperature};
    $report_row->{weather_url_time} = $http_data->{weather}->{url_fetch_time};

    $report_row->{image} = $http_data->{image}->{content};
    $report_row->{image_url_time} = $http_data->{image}->{url_fetch_time};
    
    # build customer name
    $row->{lastname} =~ m/^(\D{1})/;
    my $last_initial = $1 . '.';
    
    $report_row->{customer} = $row->{firstname} . ' ' . $last_initial;
    
    $report_row->{date} = $row->{monthday};
    
    my ($city, $state, $country) = split(/,/, $row->{location});
    if ($state) {
      $report_row->{location} = join(", ", $city, $state, $country);
    } else {
      $report_row->{location} = join(", ", $city, $country);
    }
    
    $report_row->{total} = $row->{total};
    
    push @{$report}, $report_row;
  }
  
  return $report;
}

sub _get_data_from_db {
  my $self = shift;
  my ($args) = (@_);
  
  my $sql = qq|
  SELECT
    CONCAT(c.city, ',', c.state, ',', c.country) as location,
    c.customerid,
    c.firstname,
    c.lastname,
    CONCAT(EXTRACT(MONTH FROM orderdate), '-', EXTRACT(DAY FROM orderdate)) AS monthday,
    SUM(totalamount)::text::money AS total
  FROM
    orders o
  JOIN customers c on o.customerid = c.customerid
  WHERE orderdate > ? AND orderdate < ?
  GROUP BY location, c.customerid, monthday
  ORDER BY location, c.customerid, monthday
  |;
  
  my $sth = $self->dbh->prepare($sql);
  $sth->execute($args->{start_date}, $args->{end_date});
  my @data;

  while (my $row = $sth->fetchrow_hashref) {
    push @data, $row;
  }
  
  return \@data;
}

sub _get_data_from_urls {
  my $self = shift;
  my $http_data;
  
  while (my ($service_name, $url) = (each %{$self->urls})) {
    # obviously this should have better error handling
    #  for our purposes however, it doesn't.
    my $start = [gettimeofday];
    my $req = HTTP::Request->new(GET => $url);
    my $res = $self->_user_agent->request($req);
    my $content = $res->content;
    
    if ($res->content_type eq 'application/json') {
      $content =~ s/\\//g;
      $content =~ s/^\"//;
      $content =~ s/\"$//;
    }
    
    if ($service_name eq 'weather') {
      $http_data->{$service_name}->{content} = decode_json($content);
    } else {
      $http_data->{$service_name}->{content} = $content;
    }
    $http_data->{$service_name}->{url_fetch_time} = tv_interval($start, [gettimeofday]);
  }
  
  return $http_data;
}

1;