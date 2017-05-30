#!perl

use strict;
use warnings;

use Test::More qw[no_plan];

BEGIN {
    use_ok('Moes');
}

=pod

TODO:
- test CheckingAccount constructor with a balance
- more meta info tests

=cut

{
    package BankAccount;
    use Moes;

    has balance => ( is => 'ro', default => sub { 0 } );

    sub deposit {
        my ($self, $amount) = @_;
        $self->{balance} += $amount;
    }

    sub withdraw {
        my ($self, $amount) = @_;
        ($self->{balance} >= $amount)
            || die "Account overdrawn";
        $self->{balance} -= $amount;
    }
}

{
    package CheckingAccount;
    use Moes;

    extends 'BankAccount';

    has overdraft_account => ( is => 'ro', default => sub { undef } );

    sub withdraw {
        my ($self, $amount) = @_;

        my $overdraft_amount = $amount - $self->balance;

        if ( $self->{overdraft_account} && $overdraft_amount > 0 ) {
            $self->{overdraft_account}->withdraw( $overdraft_amount );
            $self->deposit( $overdraft_amount );
        }

        $self->next::method( $amount );
    }
}

{
    my $savings = BankAccount->new( balance => 250 );
    isa_ok($savings, 'BankAccount' );

    is $savings->balance, 250, '... got the savings balance we expected';

    $savings->withdraw( 50 );
    is $savings->balance, 200, '... got the savings balance we expected';

    $savings->deposit( 150 );
    is $savings->balance, 350, '... got the savings balance we expected';

    {

        my $checking = CheckingAccount->new(
            overdraft_account => $savings,
        );
        isa_ok($checking, 'CheckingAccount');
        isa_ok($checking, 'BankAccount');

        is $checking->balance, 0, '... got the checking balance we expected';

        $checking->deposit( 100 );
        is $checking->balance, 100, '... got the checking balance we expected';
        is $checking->overdraft_account, $savings, '... got the right overdraft account';

        $checking->withdraw( 50 );
        is $checking->balance, 50, '... got the checking balance we expected';
        is $savings->balance, 350, '... got the savings balance we expected';

        $checking->withdraw( 200 );
        is $checking->balance, 0, '... got the checking balance we expected';
        is $savings->balance, 200, '... got the savings balance we expected';
    }
}




