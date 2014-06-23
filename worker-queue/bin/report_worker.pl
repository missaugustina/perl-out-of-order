#!/usr/bin/env perl
use v5.14;

use lib '../../local/lib/perl5';
use Data::Dumper;
use Carp qw(croak);
use JSON;
use AnyEvent::RabbitMQ;

use lib '../lib';
use Poo::Report;
use Poo::ReportBuilder;
use PooDB::Schema;

my $dsn = "dbi:Pg:dbname=poo";
my $dbuser = "poo";
my $dbpass = "pooiscool";
my $db = PooDB::Schema->connect($dsn, $dbuser, $dbpass);

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

                # get a message from the queue
                $channel->consume(
                    on_failure => sub { $cv->croak("Consume failure: @_") },
                    on_consume => sub {

                        my ($message) = @_;

                        # get delivery tag for communication with the queue later
                        my $delivery_tag = $message->{deliver}->method_frame->delivery_tag;

                        # decode queue item content
                        my $params = decode_json($message->{body}->payload);
                        say "Report Worker Job Item Received " . Dumper($params);
                        
                        my $report_builder = Poo::ReportBuilder->new();
                        say "building report";
                        $report_builder->build_report($params, sub {
                          my $report_data = shift; # because we passed result via cb, we get the result, not cv.
                          say "built report";
                        
                          my $report_json = encode_json($report_data);
                          
                          my %args = (
                            db => $db,
                            report_fields_json => $report_json,
                            %{$params},
                          );
                          
                          # update the report
                          my $report = Poo::Report->new(\%args)->save;
                          
                          $channel->ack(delivery_tag => $delivery_tag);
                          
                        });
                    },
                    no_ack => 0
                );

            },
            on_failure => sub { $cv->croak("CES Worker Channel failure: " . Dumper(@_)) },
            on_close   => sub { $cv->croak("CES Worker Channel closed: " . Dumper(@_)) }
        );
    },
    on_failure => sub {die "CES Worker Connection Failure: " . Dumper(@_)},
    on_read_failure => sub {die "CES Worker Connection Read Failure: " . Dumper(@_)},
    on_return  => sub {
        my $frame = shift;
        die "CES Worker Unable to deliver ", Dumper($frame);
    },
    on_close   => sub {
        my $method_frame = shift->method_frame;
        die $method_frame->reply_code, $method_frame->reply_text;
    }
);

say "Report Worker: " . $cv->recv;