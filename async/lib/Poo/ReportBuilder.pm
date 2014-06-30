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
use AnyEvent::HTTP;
use DBI;

use Data::Dumper;

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
  my %pre_report;
  my %urls_list;

  my $db_data = $self->_get_data_from_db($args);
  
  for my $row (@{$db_data}) {
    
    my $report_row;
    
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
    
    $urls_list{$row->{customerid}}->{weather} = $self->_url_with_args($self->urls->{weather}, args => { location => $report_row->{location} });
    $urls_list{$row->{customerid}}->{image} = $self->_url_with_args($self->urls->{image}, args => { customerid => $row->{customerid} });
    
    $pre_report{$row->{customerid}} = $report_row;
  }
  
  my $http_data = $self->_get_data_from_urls(\%urls_list); # build url, add args to it and pass
  
  for my $customerid (keys %pre_report) {
    my $pre_report_row = $pre_report{$customerid};
    
    my $weather = decode_json($http_data->{$customerid}->{weather});
    
    $pre_report_row->{weather_alert} = $weather->{alert};
    $pre_report_row->{weather_description} = $weather->{description};
    $pre_report_row->{temperature} = $weather->{temperature};

    $pre_report_row->{image} = $http_data->{$customerid}->{image};
    
    push @{$report}, $pre_report_row;
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
  LIMIT 10
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
  my $urls = shift;

  # NOTE: never handle cv within a library call
  #   see the worker-queue example for how to do this correctly.
  #   This is here for you to play with, try using the RabbitMQ code
  #   or creating another AnyEvent call in main.pl, call "build_report"
  #   and see what happens!
  # This will help you to understand why we need callbacks.

  my $cv = AnyEvent->condvar();
  
  my $result;
  my $start = time;

  $cv->begin(sub { shift->send($result) });

  while (my ($customerid, $urls) = (each %{$urls})) {
    for my $service_name (keys %{$urls}) {
      $cv->begin;
  
      my $now = time;
      my $request;

      $request = http_request(
        GET => $urls->{$service_name},
        timeout => 2, # seconds
        sub {
          my ($body, $hdr) = @_;
        
          if ($hdr->{'content-type'} eq 'application/json') {
            $body =~ s/\\//g;
            $body =~ s/^\"//;
            $body =~ s/\"$//;
          }
          
          $result->{$customerid}->{$service_name} = $body;
          say "got url for " . $service_name;
          #say "time to fetch $service_name url: " . time - $now;
          
          undef $request;
          $cv->end;
        }
      );
    }
  }
  
  $cv->end;

  my $http_result = $cv->recv;
  return $http_result;
}

# normally this would take the additional url args
#  and make a url with data for the get request
#  but for purposes of this demo, we aren't going to do that.
sub _url_with_args {
  my $self = shift;
  my ($url, $args) = (@_);
  
  return $url;
}

1;


