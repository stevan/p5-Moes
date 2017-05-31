package Moes;
# ABSTRACT: Something mashed

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use UNIVERSAL::Object;

our @EXPORT = ('meta', 'extends', 'has');

sub import {
    shift;
    my $into = caller;
    my @args = @_;

    return if $into eq 'main';

    strict->import;
    warnings->import;

    no strict 'refs';
    @{$into.'::ISA'} = ('UNIVERSAL::Object');

    *{$into.'::meta'} = sub {
        require MOP;
        return MOP::Class->new( name => $into );
    };

    *{$into.'::extends'} = sub {
        my @supers = @_;

        @{$into.'::ISA'} = @supers;
        %{$into.'::HAS'} = map %{$_.'::HAS'}, @supers
    };

    *{$into.'::has'} = sub {
        my ($name, @args) = @_;

        my %options;

        if ( scalar @args == 1 ) {
            if ( ref $args[0] eq 'CODE' ) {
                $options{default} = $args[0];
            }
            elsif ( ref $args[0] eq 'HASH' ) {
                %options = %{$args[0]};
            }
        }
        else {
            %options = @args;
        }

        my $lazy_default;
        if ( my $is_lazy = $options{'lazy'} ) {

            die 'Lazy attributes need defaults'
                unless exists $options{default};

            $lazy_default = delete $options{default};
        }

        if ( my $is = $options{'is'} ) {
            if ( $lazy_default ) {
                if ( $is eq 'ro' ) {
                    *{$into.'::'.$name} = sub { $_[0]->{ $name } //= $lazy_default->( $_[0] ) };
                }
                elsif ( $is eq 'rw' ) {
                    *{$into.'::'.$name} = sub {
                        $_[0]->{ $name } = $_[1] if $_[1];
                        $_[0]->{ $name } //= $lazy_default->( $_[0] );
                    };
                }
            }
            else {
                if ( $is eq 'ro' ) {
                    *{$into.'::'.$name} = sub { $_[0]->{ $name } };
                }
                elsif ( $is eq 'rw' ) {
                    *{$into.'::'.$name} = sub {
                        $_[0]->{ $name } = $_[1] if $_[1];
                        $_[0]->{ $name };
                    };
                }
            }
        }

        if ( my $reader = $options{'reader'} ) {
            *{$into.'::'.$reader} = sub { $_[0]->{ $name } };
        }

        if ( my $writer = $options{'writer'} ) {
            *{$into.'::'.$writer} = sub { $_[0]->{ $name } = $_[1] };
        }

        if ( my $predicate = $options{'predicate'} ) {
            *{$into.'::'.$predicate} = sub { defined $_[0]->{ $name } };
        }

        if ( my $clearer = $options{'clearer'} ) {
            *{$into.'::'.$clearer} = sub { undef $_[0]->{ $name } };
        }

        ${$into.'::HAS'}{ $name } = $options{default} // eval 'package '.$into.';sub {}';
    };
}

1;

__END__

=pod

=head1 SYNOPSIS

    package Point;
    use Moes;

    has 'x' => (is => 'rw', default => sub { 0 });
    has 'y' => (is => 'rw', default => sub { 0 });

    sub clear {
        my $self = shift;
        $self->x(0);
        $self->y(0);
    }

    package Point3D;
    use Moes;

    extends 'Point';

    has 'z' => (is => 'rw', default => sub { 0 });

    sub clear {
        my $self = shift;
        $self->next::method;
        $self->z(0);
    }

=head1 DESCRIPTION

L<Moes> is named in the homophonic tradition of L<Mousse>
and is Dutch for "something mashed".

=head1 SEE ALSO

L<http://www.heardutchhere.net/quiz2/moes.MP3>

L<https://en.wiktionary.org/wiki/moes#Dutch>

=cut
