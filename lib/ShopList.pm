package ShopList;

# ABSTRACT: Interactive Shopping List App

use Dancer2;
use Dancer2::Plugin::Auth::Extensible;
use Dancer2::Plugin::Auth::Extensible::Provider::Database;
use Dancer2::Plugin::Database;

use Data::Dumper;

use constant SQL0 => 'SELECT id FROM user WHERE account = ?';
use constant SQL1 => 'SELECT shop_list.id, shop_list.name, shop_list.tags FROM user INNER JOIN shop_list ON shop_list.account_id = user.id WHERE user.account = ?';
use constant SQL2 => 'SELECT list_item.id, list_item.item_id, list_item.quantity, list_item.note, list_item.tags, item.name FROM list_item INNER JOIN item ON item.id = list_item.item_id WHERE list_item.account_id = ? AND list_item.shop_list_id = ?';
use constant SQL3 => 'SELECT list_item.id, list_item.item_id, list_item.quantity, list_item.note, list_item.tags, item.name, item.category, item.id AS item_id FROM list_item INNER JOIN item ON item.id = list_item.item_id WHERE list_item.account_id = ? AND list_item.id = ?';
use constant SQL4 => 'INSERT INTO shop_list (account_id, name, tags) VALUES (?, ?, ?)';
use constant SQL5 => 'UPDATE shop_list SET name = ?, tags = ? WHERE id = ? AND account_id = ?';
use constant SQL6 => 'DELETE FROM shop_list WHERE id = ? AND account_id = ?';
use constant SQL7 => 'INSERT INTO item (account_id, name, category) VALUES (?, ?, ?)';
use constant SQL8 => 'SELECT id, account_id, name, category FROM item WHERE account_id = ?';
use constant SQL9 => 'DELETE FROM item WHERE id = ? AND account_id = ?';
use constant SQL10 => 'UPDATE item SET name = ?, category = ? WHERE id = ? AND account_id = ?';
use constant SQL11 => 'INSERT INTO list_item (account_id, shop_list_id, item_id, quantity, note, tags) VALUES (?, ?, ?, ?, ?, ?)';
use constant SQL12 => 'UPDATE list_item SET quantity = ?, tags = ?, note = ? WHERE id = ?';
use constant SQL13 => 'DELETE FROM list_item WHERE id = ?';

our $VERSION = '0.01';

=head1 NAME

ShopList - Interactive Shopping List App

=head1 DESCRIPTION

C<ShopList> is an interactive shopping list application.

=head1 ROUTES

=head2 /

Main page.

=cut

get '/' => require_login sub {
    my $user = logged_in_user;

    my $sth = database->prepare(SQL1);
    $sth->execute( $user->{account} );
    my $data = $sth->fetchall_hashref('id');

    my @data = map { $data->{$_} } sort { $a <=> $b } keys %$data;

    $sth = database->prepare(SQL0);
    $sth->execute( $user->{account} );
    my $account = ( $sth->fetchrow_array )[0];

    template 'index' => {
        user    => $user->{account},
        account => $account,
        data    => \@data,
    };
};

=head2 /account/list

List page.

=cut

get '/:account/:list' => require_login sub {
    my $user = logged_in_user;

    my $account = route_parameters->get('account');
    my $list    = route_parameters->get('list');

    send_error( 'Not allowed', 403 )
        unless _is_allowed( $user->{account}, $account );

    my $sth = database->prepare(SQL2);
    $sth->execute( $account, $list );
    my $data = $sth->fetchall_hashref('id');

    my %seen = ();
    @seen{ map { $data->{$_}{item_id} } keys %$data } = undef;

    my @data = map { $data->{$_} } sort { $data->{$a}{name} cmp $data->{$b}{name} } keys %$data;

    $sth = database->prepare(SQL8);
    $sth->execute($account);
    my $items = $sth->fetchall_hashref('id');

    my @items = map { $items->{$_} } sort { $items->{$a}{name} cmp $items->{$b}{name} } grep { !exists $seen{$_} } keys %$items;

    template 'list' => {
        user    => $user->{account},
        account => $account,
        list    => $list,
        data    => \@data,
        items   => \@items,
    };
};

=head2 /account/new_list

Add a list.

=cut

post '/:account/new_list' => require_login sub {
    my $user = logged_in_user;

    my $account = route_parameters->get('account');
    my $name    = body_parameters->get('new_name');
    my $tags    = body_parameters->get('new_tags') || '';

    send_error( 'Not allowed', 403 )
        unless _is_allowed( $user->{account}, $account );

    if ( $name ) {
        my $sth = database->prepare(SQL4);
        $sth->execute( $account, $name, $tags );
    }

    redirect '/';
};

=head2 /account/list/update_list

Update list page.

=cut

post '/:account/:list/update_list' => require_login sub {
    my $user = logged_in_user;

    my $account = route_parameters->get('account');
    my $list    = route_parameters->get('list');
    my $name    = body_parameters->get('new_name');
    my $tags    = body_parameters->get('new_tags') || '';

    send_error( 'Not allowed', 403 )
        unless _is_allowed( $user->{account}, $account );

    my $sth = database->prepare(SQL5);
    $sth->execute( $name, $tags, $list, $account );

    redirect '/';
};

=head2 /account/list/delete_list

Delete list page.

=cut

get '/:account/:list/delete_list' => require_login sub {
    my $user = logged_in_user;

    my $account = route_parameters->get('account');
    my $list    = route_parameters->get('list');

    send_error( 'Not allowed', 403 )
        unless _is_allowed( $user->{account}, $account );

    my $sth = database->prepare(SQL6);
    $sth->execute( $list, $account );

    redirect '/';
};

=head2 /account/list/row/update_row

Update a row of the C<list_item> table.

=cut

post '/:account/:list/:row/update_row' => require_login sub {
    my $user = logged_in_user;

    my $account = route_parameters->get('account');
    my $list    = route_parameters->get('list');
    my $row     = route_parameters->get('row');
    my $quant   = body_parameters->get('new_quantity') || 0;
    my $tags    = body_parameters->get('new_tags');
    my $note    = body_parameters->get('new_note');
    my $active  = body_parameters->get('active');

    send_error( 'Not allowed', 403 )
        unless _is_allowed( $user->{account}, $account );

    if ( $active && $quant > 0 ) {
        my $sth = database->prepare(SQL12);
        $sth->execute( $quant, $tags, $note, $row );
    }
    else {
        my $sth = database->prepare(SQL13);
        $sth->execute($row);
    }

    redirect "/$account/$list";
};


=head2 /account/list/item

Item page.

=cut

get '/:account/:list/:item' => require_login sub {
    my $user = logged_in_user;

    my $account = route_parameters->get('account');
    my $list    = route_parameters->get('list');
    my $item    = route_parameters->get('item');

    send_error( 'Not allowed', 403 )
        unless _is_allowed( $user->{account}, $account );

    my $sth = database->prepare(SQL3);
    $sth->execute( $account, $item );
    my $data = $sth->fetchall_hashref('id');

    template 'item' => {
        user    => $user->{account},
        account => $account,
        list    => $list,
        item    => $item,
        data    => Dumper(values(%$data)),
    };
};

=head2 /account/list/new_item

Add an item.

=cut

post '/:account/:list/new_item' => require_login sub {
    my $user = logged_in_user;

    my $account = route_parameters->get('account');
    my $list    = route_parameters->get('list');
    my $name    = body_parameters->get('new_name');
    my $cat     = body_parameters->get('new_category') || '';

    send_error( 'Not allowed', 403 )
        unless _is_allowed( $user->{account}, $account );

    if ( $name ) {
        my $sth = database->prepare(SQL7);
        $sth->execute( $account, $name, $cat );

        my $item_id = database->sqlite_last_insert_rowid;

        $sth = database->prepare(SQL11);
        $sth->execute( $account, $list, $item_id, 1, '', '' );
    }

    redirect "/$account/$list";
};

=head2 /account/list/item/update_item

Update item.

=cut

post '/:account/:list/:item/update_item' => require_login sub {
    my $user = logged_in_user;

    my $account = route_parameters->get('account');
    my $list    = route_parameters->get('list');
    my $item    = route_parameters->get('item');
    my $name    = body_parameters->get('new_name');
    my $cat     = body_parameters->get('new_category') || '';
    my $active  = body_parameters->get('active');

    send_error( 'Not allowed', 403 )
        unless _is_allowed( $user->{account}, $account );

    my $sth = database->prepare(SQL10);
    $sth->execute( $name, $cat, $item, $account );

    if ( $active ) {
        $sth = database->prepare(SQL11);
        $sth->execute( $account, $list, $item, 1, '', '' );
    }

    redirect "/$account/$list";
};


=head2 /account/list/item/delete_item

Delete an item.

=cut

get '/:account/:list/:item/delete_item' => require_login sub {
    my $user = logged_in_user;

    my $account = route_parameters->get('account');
    my $list    = route_parameters->get('list');
    my $item    = route_parameters->get('item');

    send_error( 'Not allowed', 403 )
        unless _is_allowed( $user->{account}, $account );

    my $sth = database->prepare(SQL9);
    $sth->execute( $item, $account );

    redirect "/$account/$list";
};


sub _is_allowed {
    my ($name, $id) = @_;
    my $sth = database->prepare(SQL0);
    $sth->execute($name);
    my $account = ( $sth->fetchrow_array )[0];
    return $id == $account;
}

true;

__END__

=head1 SEE ALSO

L<Dancer2>

L<Dancer2::Plugin::Auth::Extensible>

L<Dancer2::Plugin::Auth::Extensible::Provider::Database>

L<Dancer2::Plugin::Database>

=head1 AUTHOR

Gene Boggs <gene@cpan.org>

=head1 COPYRIGHT AND LICENSE
 
This software is copyright (c) 2019 by Gene Boggs.
 
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut