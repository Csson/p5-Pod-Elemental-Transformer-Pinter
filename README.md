# NAME

Pod::Elemental::Transformer::Splint - Documentation from class metadata

# VERSION

Version 0.1002, released 2015-01-18.

# SYNOPSIS

    # in weaver.ini
    [-Transformer / Splint]
    transformer = Splint

# DESCRIPTION

Pod::Elemental::Transformer::Splint uses [MooseX::AttributeDocumented](https://metacpan.org/pod/MooseX::AttributeDocumented) to add inlined documentation about attributes to pod.
If you write your classes with [Moops](https://metacpan.org/pod/Moops) you can also document method signatures with [Kavorka::TraitFor::Parameter::doc](https://metacpan.org/pod/Kavorka::TraitFor::Parameter::doc) (and [::ReturnType::doc](https://metacpan.org/pod/Kavorka::TraitFor::ReturnType::doc)).

A class defined like this:

    package My::Class;

    use Moose;

    has has_brakes => (
        is => 'ro',
        isa => Bool,
        default => 1,
        traits => ['Documented'],
        documentation => 'Does the bike have brakes?',
        documentation_alts => {
            0 => 'Hopefully a track bike',
            1 => 'Always nice to have',
        },
    );

    =pod

    :splint classname My::Class

    :splint attributes

    =cut

Will render like this (to html):

_begin_

_end_

A [Moops](https://metacpan.org/pod/Moops) class defined like this:

    class My::MoopsClass using Moose {

        ...

        method advanced_method(Int $integer                        does doc("Just an integer\nmethod_doc|This method is advanced."),
                               ArrayRef[Str|Bool] $lots_of_stuff   does doc('It works with both types'),
                               Str :$name!                         does doc("What's the name"),
                               Int :$age                           does doc('The age of the thing') = 0,
                               Str :$pseudonym                     does doc('Incognito..')
                           --> Bool but assumed                    does doc('Did it succeed?')

        ) {
            return 1;
        }

        method less_advanced($stuff,
                             $another_thing                     does doc("Don't know what we get here"),
                             ArrayRef $the_remaining is slurpy  does doc('All the remaining')
        )  {
            return 1;
        }

        ...
    }

    =pod

    :splint classname My::MoopsClass

    :splint method advanced_method

    It needs lots of documentation.

    :splint method less_advanced

    =cut

Will render like this (to html):

_begin_

_end_

# SEE ALSO

# SOURCE

[https://github.com/Csson/p5-Pod-Elemental-Transformer-Splint](https://github.com/Csson/p5-Pod-Elemental-Transformer-Splint)

# HOMEPAGE

[https://metacpan.org/release/Pod-Elemental-Transformer-Splint](https://metacpan.org/release/Pod-Elemental-Transformer-Splint)

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Erik Carlsson <info@code301.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
