requires 'perl', '5.010001';

requires 'List::AllUtils';
requires 'Moose';
requires 'Moose::Role';
requires 'Path::Tiny';
requires 'Safe::Isa';
requires 'syntax';
requires 'Syntax::Feature::Qs', '0.2003';
requires 'List::UtilsBy';
requires 'Try::Tiny';

recommends 'MooseX::AttributeDocumented', '0.1003';
recommends 'Kavorka::TraitFor::Parameter::doc', '0.1102';

on test => sub {
    requires 'Test::More', '0.96';
    requires 'Test::Warnings';
    requires 'Test::Differences';
    requires 'Pod::Elemental';
    requires 'Pod::Elemental::Transformer::Pod5';
};
