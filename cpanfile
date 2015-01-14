requires 'perl', '5.010001';

requires 'List::AllUtils';
requires 'Moose';
requires 'Moose::Role';
requires 'Path::Tiny';
requires 'Safe::Isa';
requires 'syntax';
requires 'Syntax::Feature::Qs';

recommends 'MooseX::AttributeDocumented';
recommends 'Kavorka::TraitFor::ReturnType::doc';

on test => sub {
    requires 'Test::More', '0.96';
    requires 'Test::Warnings';
    requires 'Test::Differences';
    requires 'Pod::Elemental';
    requires 'Pod::Elemental::Transformer::Pod5';
};
