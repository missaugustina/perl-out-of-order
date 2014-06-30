#!/usr/bin/env perl
use v5.14;

use lib '../../local/lib/perl5';
use Data::Dumper;
use Carp qw(croak);
use JSON;
use AnyEvent::RabbitMQ;
use Time::HiRes qw(gettimeofday tv_interval);

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
                        
                        my $report_builder = Poo::ReportBuilder->new();
                        
                        my $start = [gettimeofday];

                        $report_builder->build_report($params, sub {
                          # because we passed the result via callback,
                          #  we get the result, not condvar
                          my $report_data = shift;
                          
                          say "building report " . $params->{name};
                        
                          my $report_json = encode_json($report_data);
                          
                          my %args = (
                            db => $db, # this is blocking
                            report_fields_json => $report_json,
                            status => 'complete',
                            %{$params},
                          );
                          
                          # update the report
                          my $report = Poo::Report->new(\%args)->save;
                          say "finished building report " . $params->{name};
                          say "report took " . tv_interval($start, [gettimeofday]);
                          
                          $channel->ack(delivery_tag => $delivery_tag);
                          
                        });
                    },
                    no_ack => 0
                );

            },
            on_failure => sub { $cv->croak("Report Worker Channel failure: " . Dumper(@_)) },
            on_close   => sub { $cv->croak("Report Worker Channel closed: " . Dumper(@_)) }
        );
    },
    on_failure => sub {die "Report Worker Connection Failure: " . Dumper(@_)},
    on_read_failure => sub {die "Report Worker Connection Read Failure: " . Dumper(@_)},
    on_return  => sub {
        my $frame = shift;
        die "Report Worker Unable to deliver ", Dumper($frame);
    },
    on_close   => sub {
        my $method_frame = shift->method_frame;
        die $method_frame->reply_code, $method_frame->reply_text;
    }
);

say "Report Worker: " . $cv->recv;