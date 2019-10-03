#!/usr/bin/env perl
use strict;
use warnings;

use DBI;

my $driver   = 'SQLite';
my $database = 'shoplist.db';
my $dsn      = "DBI:$driver:dbname=$database";
my $userid   = '';
my $password = '';
my $dbh      = DBI->connect( $dsn, $userid, $password, { RaiseError => 1 } ) or die $DBI::errstr;

my $sql = 'SELECT * FROM user';
my $sth = $dbh->prepare($sql) or die $dbh->errstr;
$sth->execute() or die $dbh->errstr;
print "Users:\n";
while( my @row = $sth->fetchrow_array ) {
    print join( ',', @row ), "\n";
}

#$sql = 'SELECT * FROM shop_list WHERE account_id = ? ORDER BY id';
#$sth = $dbh->prepare($sql) or die $dbh->errstr;
#$sth->execute($account) or die $dbh->errstr;
#print "Shoping lists for account_id $account:\n";
#while( my @row = $sth->fetchrow_array ) {
#    print join( ',', @row ), "\n";
#}

$dbh->disconnect();
