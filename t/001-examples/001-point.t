#!perl

use strict;
use warnings;

use Test::More qw[no_plan];

BEGIN {
    use_ok('Moes');
}

=pod

TODO:
- test constructors with data
    - for both Point and Point3D
- test some meta info

=cut

{
    package Point;
    use Moes;

    has x => ( is => 'ro', writer => 'set_x', default => sub { 0 } );
    has y => ( is => 'ro', writer => 'set_y', default => sub { 0 } );

    sub clear {
        my ($self) = @_;
        @{ $self }{'x', 'y'} = (0, 0);
    }

    sub pack {
        my ($self) = @_;
        +{ x => $self->x, y => $self->y }
    }
}

# ... subclass it ...

{
    package Point3D;
    use Moes;

    extends 'Point';

    has z => ( is => 'ro', writer => 'set_z', default => sub { 0 } );

    sub clear {
        my ($self) = @_;
        my $data = $self->next::method;
        $self->{'z'} = 0;
    }

    sub pack {
        my ($self) = @_;
        my $data = $self->next::method;
        $data->{z} = $self->{z};
        $data;
    }

}

## Test an instance
{
    my $p = Point->new;
    isa_ok($p, 'Point');

    is_deeply(
        mro::get_linear_isa('Point'),
        [ 'Point', 'UNIVERSAL::Object' ],
        '... got the expected linear isa'
    );

    is $p->x, 0, '... got the default value for x';
    is $p->y, 0, '... got the default value for y';

    $p->set_x(10);
    is $p->x, 10, '... got the right value for x';

    $p->set_y(320);
    is $p->y, 320, '... got the right value for y';

    is_deeply $p->pack, { x => 10, y => 320 }, '... got the right value from pack';
}

## Test the instance
{
    my $p3d = Point3D->new();
    isa_ok($p3d, 'Point3D');
    isa_ok($p3d, 'Point');

    is_deeply(
        mro::get_linear_isa('Point3D'),
        [ 'Point3D', 'Point', 'UNIVERSAL::Object' ],
        '... got the expected linear isa'
    );

    is $p3d->z, 0, '... got the default value for z';

    $p3d->set_x(10);
    is $p3d->x, 10, '... got the right value for x';

    $p3d->set_y(320);
    is $p3d->y, 320, '... got the right value for y';

    $p3d->set_z(30);
    is $p3d->z, 30, '... got the right value for z';

    is_deeply $p3d->pack, { x => 10, y => 320, z => 30 }, '... got the right value from pack';
}




