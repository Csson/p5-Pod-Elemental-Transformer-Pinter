requires 'perl', '5.010001';

requires 'List::AllUtils';
requires 'Moose';
requires 'Moose::Role';
requires 'Path::Tiny';
requires 'Safe::Isa';
requires 'syntax';
requires 'Syntax::Feature::Qs';

on test => sub {
    requires 'Test::More', '0.96';
};
