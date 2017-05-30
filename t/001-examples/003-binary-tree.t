#!perl

use strict;
use warnings;

use Test::More qw[no_plan];

BEGIN {
    use_ok('Moes');
}

=pod

TODO:

Make the parent a weak-ref ... it is not right now.

=cut

{
    package BinaryTree;
    use Moes;

    has node   => ( is => 'rw' );
    has parent => ( is => 'ro', predicate => 'has_parent' );

    has left   => (
        is        => 'ro',
        lazy      => 1,
        default   => sub { $_[0]->new( parent => $_[0] ) },
        predicate => 'has_left',
    );

    has right  => (
        is        => 'ro',
        lazy      => 1,
        default   => sub { $_[0]->new( parent => $_[0] ) },
        predicate => 'has_right',
    );
}

{
    my $t = BinaryTree->new;
    ok($t->isa('BinaryTree'), '... this is a BinaryTree object');

    ok(!$t->has_parent, '... this tree has no parent');

    ok(!$t->has_left, '... left node has not been created yet');
    ok(!$t->has_right, '... right node has not been created yet');

    ok($t->left->isa('BinaryTree'), '... left is a BinaryTree object');
    ok($t->right->isa('BinaryTree'), '... right is a BinaryTree object');

    ok($t->has_left, '... left node has now been created');
    ok($t->has_right, '... right node has now been created');

    ok($t->left->has_parent, '... left has a parent');
    is($t->left->parent, $t, '... and it is us');

    #ok($parent_attr->is_data_in_slot_weak_for($t->left), '... the value is weakened');

    ok($t->right->has_parent, '... right has a parent');
    is($t->right->parent, $t, '... and it is us');

    #ok($parent_attr->is_data_in_slot_weak_for($t->right), '... the value is weakened');
}

{
    package MyBinaryTree;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('BinaryTree') }
}

{
    my $t = MyBinaryTree->new;
    ok($t->isa('MyBinaryTree'), '... this is a MyBinaryTree object');
    ok($t->isa('BinaryTree'), '... this is a BinaryTree object');

    ok(!$t->has_parent, '... this tree has no parent');

    ok(!$t->has_left, '... left node has not been created yet');
    ok(!$t->has_right, '... right node has not been created yet');

    ok($t->left->isa('BinaryTree'), '... left is a BinaryTree object');
    ok($t->right->isa('BinaryTree'), '... right is a BinaryTree object');

    ok($t->has_left, '... left node has now been created');
    ok($t->has_right, '... right node has now been created');
}


