use strict;
use warnings FATAL => 'all';
use Test::More;
use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';

use Pod::Elemental::Transformer::Splint;
use Pod::Simple::XHTML;
use Path::Tiny;

eval "use MooseX::AttributeDocumented";
skip_all => 'These tests need MooseX::AttributeDocumented' if $@;

my $podder = get_podder();
my $contents = path('corpus/lib/SplintTestAttributes.pm')->slurp_utf8;

my $results = parse_pod($contents);

is $results, 'this', 'good';



sub get_podder {
    my $podder = Pod::Simple::XHTML->new;
    $podder->html_header('');
    $podder->html_footer('');
    return $podder;
}
sub parse_pod {
    my $results = '';
    $podder->output_string(\$results);
    $podder->parse_string_document("=pod\n\n$pod");
    return $reuslts;
}

done_testing;
