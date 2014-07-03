#!/usr/bin/env perl
use Mojolicious::Lite;

use lib '../../local/lib/perl5';
use Try::Tiny;
use Data::Dumper;
use Carp qw(croak);
use Storable qw(dclone);
use JSON;
use MIME::Base64;
use AnyEvent::RabbitMQ;
use Time::HiRes qw(gettimeofday tv_interval);

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
  
  my $reports = $self->db->resultset('Report')->search(undef, {order_by => 'submitted_on'})->hashref_pk;

  # ordered list of columns for display
  my @reports_head = qw(
    name
    status
    submitted_on
    completed_on
    modified_on
    start_date
    end_date
    total_time
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
  
  my $name = $self->param('id');
  my $report = Poo::Report->new(db => $self->db, name => $name);
  my $report_array = $report->report_fields;
  
  $self->stash(
    report_head => "",
    report => $report_array,
    report_name => $name,
  );

  $self->render('view_report');
};

get '/report_request' => sub {
  my $self = shift;
  $self->render('report_request');
};

post '/post_report_request' => sub {
  my $self = shift;
  my $params = dclone($self->req->body_params->to_hash);
  
  my %args = (
    db => $self->db,
    create => 1,
    %{$params}
  );
  
  # create a new report entry
  my $report = Poo::Report->new(\%args);
  $report->save();

  # push a job to the RabbitMQ queue
  my $cv = AnyEvent->condvar;

  my $ar = AnyEvent::RabbitMQ->new->load_xml_spec()->connect(
    host       => 'localhost',
    port       => 5672,
    user       => 'guest',
    pass       => 'guest',
    vhost      => '/',
    on_success => sub {

      my $ar = shift;

      $ar->open_channel(
        on_success => sub {

          my $channel = shift;
  
          $channel->declare_queue(
              queue => 'reports',
              auto_delete => 0,
          );
  
          # if reply-to, include in args
          my %publish_args = (
              header => {
                  content_type    => 'application/json',
              },
              body => encode_json($params),
              routing_key => 'reports',
          );

          $channel->publish(%publish_args);

          my $now = localtime(time);

          my $queued_report = Poo::Report->new(
            db => $self->db,
            name => $params->{name},
            status => 'queued',
            modified_on => $now
          );

          $queued_report->save();

          # exit once processing is done
          $cv->send("Added report request to queue");
        },
        on_failure => sub { $cv->croak("Channel failure: " . Dumper(@_)) },
        on_close   => sub { $cv->croak("Channel closed: " . Dumper(@_)) }
      );
    },
    on_failure => sub {die "Connection Failure: " . Dumper(@_)},
    on_read_failure => sub {die "Connection Read Failure: " . Dumper(@_)},
    on_return  => sub {
        my $frame = shift;
        die "Unable to deliver ", Dumper($frame);
    },
    on_close   => sub {
        my $method_frame = shift->method_frame;
        die $method_frame->reply_code, $method_frame->reply_text;
    },

  );

  say $cv->recv;
  
  my $report_for_display = Poo::Report->new(db => $self->db, name => $params->{name});
  my $report_data = $report_for_display->report_fields;
  my $report_head = "";
  
  if ($report_for_display->status ne 'complete') {
    $report_head = 'Report Request Submitted';
  }
  
  $self->stash(
                report_head => $report_head,
                report => $report_data,
                report_name => $params->{name},
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
<b><%=$report_head%></b><br />
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
<tr><td>Start Date: </td><td><%= text_field 'start_date' %></td></tr>
<tr><td>End Date: </td><td><%= text_field 'end_date' %></td></tr>
<tr><td>Name (optional): </td><td><%= text_field 'name' %></td></tr>
</table>
%= submit_button 'Get Report'
%= end
