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

my $sql = 'SELECT * FROM user';
my $sth = $dbh->prepare($sql) or die $dbh->errstr;
$sth->execute() or die $dbh->errstr;
my $data = $sth->fetchall_hashref('account');

$sql = 'INSERT INTO shop_list (account_id, name) VALUES (?, ?)';
$sth = $dbh->prepare($sql) or die $dbh->errstr;

$sth->execute( $data->{gene}{id}, 'Costco' ) or die $dbh->errstr;
$sth->execute( $data->{gene}{id}, 'Safeway' ) or die $dbh->errstr;
$sth->execute( $data->{tabi}{id}, 'Costco' ) or die $dbh->errstr;
$sth->execute( $data->{tabi}{id}, 'Safeway' ) or die $dbh->errstr;

$dbh->disconnect();
