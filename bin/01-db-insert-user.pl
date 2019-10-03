#!/usr/bin/env perl
use strict;
use warnings;

use Crypt::SaltedHash;
use DBI;
use Term::ReadKey;

my $account = shift or die "Usage: perl $0 account [passphrase]\n";
my $pass    = shift;

unless ( $pass ) {
    print "Password: ";
    ReadMode('noecho');
    $pass = ReadLine(0);
    chomp $pass;
    ReadMode('restore');
    print "\n";

    print "Again: ";
    ReadMode('noecho');
    my $again = ReadLine(0);
    chomp $again;
    ReadMode('restore');
    print "\n";

    die "\nERROR: Passwords do not match.\n"
        unless $pass eq $again;
}

die 'No password given'
    unless $pass;

my $driver   = 'SQLite';
my $database = 'shoplist.db';
my $dsn      = "DBI:$driver:dbname=$database";
my $userid   = '';
my $password = '';
my $dbh      = DBI->connect( $dsn, $userid, $password, { RaiseError => 1 } ) or die $DBI::errstr;

my $csh = Crypt::SaltedHash->new( algorithm => 'SHA-1' );
$csh->add($pass);
$pass = $csh->generate;

my $sql = 'INSERT INTO user (account, password) VALUES (?, ?)';
my $sth = $dbh->prepare($sql) or die $dbh->errstr;
$sth->execute( $account, $pass ) or die $dbh->errstr;

$dbh->disconnect();
