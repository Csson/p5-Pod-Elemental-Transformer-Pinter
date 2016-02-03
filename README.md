# NAME

Pod::Elemental::Transformer::Splint - Documentation from class metadata

![Requires Perl 5.10.1+](https://img.shields.io/badge/perl-5.10.1+-brightgreen.svg) [![Travis status](https://api.travis-ci.org/Csson/p5-Pod-Elemental-Transformer-Splint.svg?branch=master)](https://travis-ci.org/Csson/p5-Pod-Elemental-Transformer-Splint) ![coverage 81.4%](https://img.shields.io/badge/coverage-81.4%-orange.svg)

# VERSION

Version 0.1201, released 2016-02-03.

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

# ATTRIBUTES

The following settings are available in `weaver.ini`:

## command\_name

Default: `:splint`

Defines the command used at the beginning of the line in pod.

## attribute\_renderer

Default: `HTML=HtmlDefault, markdown=HtmlDefault`

Define which renderers to use. Comma separated list of pairs where the key defines the format in pod and the value defines the renderer (in the `Pod::Elemental::Transformer::Splint::AttributeRenderer` namespace).

The default will render each attribute like this:

    =begin HTML

    <!-- attribute information -->

    =end HTML

    =begin markdown

    <!-- attribute information -->

    =end markdown

## method\_renderer

Default: `HTML=HtmlDefault, markdown=HtmlDefault`

Similar to ["attribute\_renderer"](#attribute_renderer) but for methods. This is currently only assumed to work for methods defined with [Kavorka](https://metacpan.org/pod/Kavorka) or [Moops](https://metacpan.org/pod/Moops).

Method renderers are in the `Pod::Elemental::Transformer::Splint::MethodRenderer` namespace.

## type\_libraries

Default: `undef`

If you use [Type::Tiny](https://metacpan.org/pod/Type::Tiny) based type libraries, the types are usually linked to the correct library. Under some circumstances it might be necessary to specify which library a certain type
belongs to.

It is a space separated list:

    type_libraries = Custom::Types=AType Types::Standard=Str,Int

## default\_type\_library

Default: `Types::Standard`

The default Type::Tiny based type library to link types to.

# SOURCE

[https://github.com/Csson/p5-Pod-Elemental-Transformer-Splint](https://github.com/Csson/p5-Pod-Elemental-Transformer-Splint)

# HOMEPAGE

[https://metacpan.org/release/Pod-Elemental-Transformer-Splint](https://metacpan.org/release/Pod-Elemental-Transformer-Splint)

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Erik Carlsson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
