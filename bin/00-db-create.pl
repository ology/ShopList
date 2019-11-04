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

my $sql = <<'SQL';
CREATE TABLE user (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    account TEXT NOT NULL,
    password TEXT NOT NULL
)
SQL

my $r = $dbh->do($sql);
print $r < 0 ? $DBI::errstr : "user table created\n";

$sql = <<'SQL';
CREATE TABLE shop_list (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    account_id INT NOT NULL,
    name TEXT NOT NULL
)
SQL

$r = $dbh->do($sql);
print $r < 0 ? $DBI::errstr : "shop_list table created\n";

$sql = <<'SQL';
CREATE TABLE item (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    account_id INT NOT NULL,
    shop_list_id INT,
    name TEXT NOT NULL,
    note TEXT,
    category TEXT
)
SQL

$r = $dbh->do($sql);
print $r < 0 ? $DBI::errstr : "item table created\n";

$sql = <<'SQL';
CREATE TABLE list_item (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    account_id INT NOT NULL,
    shop_list_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1
)
SQL

$r = $dbh->do($sql);
print $r < 0 ? $DBI::errstr : "list_item table created\n";

$dbh->disconnect();
