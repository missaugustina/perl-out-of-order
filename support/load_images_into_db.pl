#!/usr/bin/perl

use v5.14;

use lib '../local/lib/perl5';
use Try::Tiny;
use DBI;
use DBD::Pg qw(:pg_types);

# ARGS: path/to/images
my $path = $ARGV[0];

# open db connection
my $dsn = "dbi:Pg:dbname=poo";
my $dbuser = "poo";
my $dbpass = "pooiscool";

my $dbh = DBI->connect($dsn, $dbuser, $dbpass);
# empty the images table to avoid id conflicts

$dbh->do('DELETE FROM images');

# open directory that contains the images
my @image_files = glob($path . '/*.jpg');

my $id = 0;
for my $image_file (@image_files) {
  try {
    
    say "loading $image_file";
    my $image;
    {
      # read in each one as binary
      open(my $fh, '<', $image_file);
      local $/ = undef;
      $image = <$fh>;
      close $fh;
    }

    # insert into postgres
    #$db->resultset('Image')->create({ id => $id, image => $image });
    my $sth = $dbh->prepare('INSERT INTO images VALUES(?, ?)');
    $sth->bind_param(2, $image, { pg_type => DBD::Pg::PG_BYTEA });
    $sth->execute($id, $image);
    
  } catch {
    say "Error loading image $image_file into database: $!";
  };
  
  $id++;
}

say "Done!";