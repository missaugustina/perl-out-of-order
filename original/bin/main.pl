#!/usr/bin/env perl
use Mojolicious::Lite;

use Try::Tiny;
use Data::Dumper;
use Carp qw(croak);
use Storable qw(dclone);
use JSON;
use MIME::Base64;

use lib '../lib';
use Poo::Util;
use Poo::Report;
use Poo::ReportBuilder;
use PooDB::Schema;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

# create db handle
helper db => sub {
  my $dsn = "dbi:Pg:dbname=poo";
  my $dbuser = "poo";
  my $dbpass = "pooiscool";
  return PooDB::Schema->connect($dsn, $dbuser, $dbpass);
};

get '/' => sub {
  my $self = shift;
  $self->render('index');
};

get '/my_reports' => sub {
  my $self = shift;
  
    my $reports;

  # ordered list of columns for display
  my @reports_head = qw(
    name
    status
    start
    end
  );

  $self->stash(reports_head => \@reports_head);

  my @reports_list;
  for my $id (keys %{$reports}) {
    my @row;
  for my $col (@reports_head) {
    push @row, $reports->{$id}->{$col};
  }

    push @reports_list, \@row;
  }

  $self->stash(reports_list => \@reports_list);
  $self->render('my_reports');
};

get '/view_report/:id' => sub {
  my $self = shift;
  
  my $id = $self->param('id');
  my $report; #$report->hash_for_web
  $self->stash( report => $report);

  $self->render('view_report');
};

get '/report_request' => sub {
  my $self = shift;
  $self->render('report_request');
};

post '/post_report_request' => sub {
  my $self = shift;
  my $params = dclone($self->req->body_params->to_hash);
  my $report_builder = Poo::ReportBuilder->new();
  my $report = $report_builder->build_report($params);
  
  my %args = (
    create => 1,
  );

  # create a new report instance with the results
  #my $report = Poo::Report->new(%args);
  
  $self->stash(
               report => $report,
               report_name => $params->{name}
               );
  $self->render( 'view_report' );
};


app->start;
__DATA__

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

@@ index.html.ep
% layout 'default';
% title 'Welcome';
Welcome to your reports!<br />
<ul>
<li><a href=/my_reports>My Reports</a></li>
<li><a href=/report_request>Get New Report</a></li>
</ul>

@@ my_reports.html.ep
% layout 'default';
% title 'My Reports';
My Reports: <br />
<table border=1>
% for my $col (@{$reports_head}) {
<th><%= $col %></th>
% }
% for my $row (@{$reports_list}) {
<tr>
% my ($id, @tail) = @{$row};
<td><a href=/view_report/<%= $id %>><%= $id %></a></td>
% for my $field (@tail) {
  <td><%= $field %></td>
% }
</tr>
% }
</table>

@@ view_report.html.ep
% layout 'default';
% title 'My Report';
<%=$report_name%> <br />
<br />
<table border=1>
% for my $col (keys %{$report->[0]}){
<th><%= $col %></th>
%}
% for my $row (@{$report}) {
<tr>
%  while( my ($k, $v) = each(%{$row})) {
% if ($k eq 'image') {
<td><img src='data:image/jpg;base64,<%= MIME::Base64::encode_base64($v) %>' height=200></td>
% } else {
<td><%= $v %></td>
%  }
% }
</tr>
% }
</table>
</p>

@@ report_request.html.ep
% layout 'default';
% title 'New Report';
%= t h1 => 'New Report'
<table border=1>
%= form_for '/post_report_request' => (method => 'post') => begin
%= hidden_field request_id => $self->param('id');
<tr><td>Start Date: </td><td><%= text_field 'start_date' %></td></tr>
<tr><td>End Date: </td><td><%= text_field 'end_date' %></td></tr>
<tr><td>Name (optional): </td><td><%= text_field 'name' %></td></tr>
</table>
%= submit_button 'Get Report'
%= end
