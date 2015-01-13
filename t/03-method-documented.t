use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Differences;

use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';
use lib('t/corpus/lib');
use Pod::Elemental;
use Pod::Elemental::Transformer::Pod5;
use Pod::Elemental::Transformer::Splint;

eval "use Kavorka::TraitFor::Parameter::doc";
plan skip_all => 'These tests need Kavorka::TraitFor::Parameter::doc' if $@;
eval "use Kavorka::TraitFor::ReturnType::doc";
plan skip_all => 'These tests need Kavorka::TraitFor::ReturnType::doc' if $@;

my $pod5 = Pod::Elemental::Transformer::Pod5->new;
my $splint = Pod::Elemental::Transformer::Splint->new;


my $doc = Pod::Elemental->read_file('t/corpus/lib/SplintTestMethods.pm');
$pod5->transform_node($doc);
$splint->transform_node($doc);
is 1, 1, 1;
done_testing;
__END__
unified_diff;
eq_or_diff $doc->as_pod_string, test1(), 'good';

sub test1 {

return q{=pod

=cut
use 5.14.1;
use strict;

use Moops;

class SplintTestMethods using Moose {

    method a_test_method(Int $thing!  does doc('The first argument') = '',
                         Int $woo!    does doc('More arg'),
                         Bool :$maybe does doc("If necessary\nmethod_doc|Just a test")
                     --> Str          does doc('In the future')
    ) {
        return 'woo';
    }

    method another(ArrayRef $thirsty is slurpy does doc('slurper')) {
        return;
    }
}

__END__

=pod


=encoding utf-8




=head2 a_test_method

=begin HTML

<p>Just a test</p>

<table style="margin-bottom: 10px;" cellpadding="0" cellspacing="0">
<tr style="vertical-align: top;"><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;" colspan="5">Positional parameters</td></tr>
<tr style="vertical-align: top;">
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;"><code>$thing</code>

</td>
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;"><a href="https://metacpan.org/pod/Types::Standard#Int">Int</a>

</td>
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;">required, default <code>= &#39;&#39;</code>

</td>
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;"><span style="color: #aaa;">no traits</span></td>
<td style="padding: 3px 6px; vertical-align: top;  border-bottom: 1px solid #eee;">The first argument<br /></td>
</tr>
<tr style="vertical-align: top;">
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;"><code>$woo</code>

</td>
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;"><a href="https://metacpan.org/pod/Types::Standard#Int">Int</a>

</td>
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;">required</td>
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;"><span style="color: #aaa;">no traits</span></td>
<td style="padding: 3px 6px; vertical-align: top;  border-bottom: 1px solid #eee;">More arg<br /></td>
</tr>
<tr style="vertical-align: top;"><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;" colspan="5">Named parameters</td></tr>
<tr style="vertical-align: top;">
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;"><code>maybe =&gt; $value</code>

</td>
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;"><a href="https://metacpan.org/pod/Types::Standard#Bool">Bool</a>

</td>
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;">optional, <span style="color: #999;">no default</span></td>
<td style="padding: 3px 6px; vertical-align: top; white-space: nowrap; border-right: 1px solid #eee; border-bottom: 1px solid #eee;"><span style="color: #aaa;">no traits</span></td>
<td style="padding: 3px 6px; vertical-align: top;  border-bottom: 1px solid #eee;">If necessary</td>
</tr>
<tr style="vertical-align: top;"><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;" colspan="5">Returns</td></tr>
<tr style="vertical-align: top;">
<td colspan="5" style="padding: 3px 6px; vertical-align: top; border-right: 1px solid #eee; border-bottom: 1px solid #eee;"><a href="https://metacpan.org/pod/Types::Standard#Str">Str</a>

</td>

</table>

=end HTML


=head2 another

=begin HTML

<p></p>

<table style="margin-bottom: 10px;" cellpadding="0" cellspacing="0">
<tr style="vertical-align: top;"><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;" colspan="4">Positional parameters</td></tr>
</table>

=end HTML

=cut
};
}



done_testing;
