#!/usr/bin/env perl
use strict;
use warnings;

use DBI;

use constant ENCODING => ':encoding(UTF-8)';

my $driver   = 'SQLite';
my $database = 'shoplist.db';
my $dsn      = "DBI:$driver:dbname=$database";
my $userid   = '';
my $password = '';
my $dbh      = DBI->connect( $dsn, $userid, $password, { RaiseError => 1 } ) or die $DBI::errstr;

my $sql = 'INSERT INTO item (account_id, name, category) VALUES (?, ?, ?)';
my $sth = $dbh->prepare($sql) or die $dbh->errstr;

$sth->execute( 1, 'salmon', 'fish' ) or die $dbh->errstr;
$sth->execute( 2, 'Salmon', 'fish' ) or die $dbh->errstr;
$sth->execute( 1, 'Fritos', 'snacks' ) or die $dbh->errstr;
$sth->execute( 2, 'Doritos', 'snacks' ) or die $dbh->errstr;
$sth->execute( 1, 'Coke', 'beverages' ) or die $dbh->errstr;
$sth->execute( 1, 'Dr Pepper', 'beverages' ) or die $dbh->errstr;
$sth->execute( 2, 'Dr Pepper', 'beverages' ) or die $dbh->errstr;

$dbh->disconnect();
