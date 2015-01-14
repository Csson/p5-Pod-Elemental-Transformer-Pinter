use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Differences;

use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';
use lib('t/corpus/lib');
use Pod::Elemental;
use Pod::Elemental::Transformer::Pod5;
use Pod::Elemental::Transformer::Splint;

eval "use Moops";
plan skip_all => 'These tests need Moops' if $@;
eval "use Kavorka::TraitFor::ReturnType::doc";
plan skip_all => 'These tests need Kavorka::TraitFor::ReturnType::doc' if $@;

my $pod5 = Pod::Elemental::Transformer::Pod5->new;
my $splint = Pod::Elemental::Transformer::Splint->new;


my $doc = Pod::Elemental->read_file('t/corpus/lib/SplintTestMethods.pm');
$pod5->transform_node($doc);
$splint->transform_node($doc);

unified_diff;
eq_or_diff $doc->as_pod_string, test1(), 'good';

done_testing;

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

    method another(Int $before does doc('whooo'), ArrayRef[Int] $thirsty is slurpy does doc('slurper')) {
        return;
    }
}

__END__

=pod


=encoding utf-8




=head2 a_test_method

=begin HTML

<p>Just a test</p>

<table style="margin-bottom: 10px; margin-left: 10px; border-collapse: bollapse;" cellpadding="0" cellspacing="0">
<tr style="vertical-align: top;"><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">Positional parameters</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td></tr>
<tr style="vertical-align: top;">
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;"><code>$thing</code>

</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;"><a href="https://metacpan.org/pod/Types::Standard#Int">Int</a>

</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;">required, default <code>= &#39;&#39;</code>

</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  border-bottom: 1px solid #eee;"></td>
<td style="padding: 3px 6px; vertical-align: top;  border-bottom: 1px solid #eee;">The first argument<br /></td>
</tr>
<tr style="vertical-align: top;">
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;"><code>$woo</code>

</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;"><a href="https://metacpan.org/pod/Types::Standard#Int">Int</a>

</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;">required</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  border-bottom: 1px solid #eee;"></td>
<td style="padding: 3px 6px; vertical-align: top;  border-bottom: 1px solid #eee;">More arg<br /></td>
</tr>
<tr style="vertical-align: top;"><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">Named parameters</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td></tr>
<tr style="vertical-align: top;">
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;"><code>maybe =&gt; $value</code>

</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;">optional, <span style="color: #999;">no default</span></td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  border-bottom: 1px solid #eee;"></td>
<td style="padding: 3px 6px; vertical-align: top;  border-bottom: 1px solid #eee;">If necessary</td>
</tr>
<tr style="vertical-align: top;"><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">Returns</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td></tr>
<tr style="vertical-align: top;">
<td style="vertical-align: top; border-right: 1px solid #eee;  padding: 3px 6px; border-bottom: 1px solid #eee;"><a href="https://metacpan.org/pod/Types::Standard#Str">Str</a>

</td><td style="vertical-align: top; border-right: 1px solid #eee;  padding: 3px 6px; border-bottom: 1px solid #eee;">&#160;</td><td style="vertical-align: top; border-right: 1px solid #eee;  padding: 3px 6px; border-bottom: 1px solid #eee;">&#160;</td><td style="vertical-align: top; border-right: 1px solid #eee;  padding: 3px 6px; border-bottom: 1px solid #eee;">&#160;</td>
<td style="padding: 3px 6px; vertical-align: top;  border-bottom: 1px solid #eee;">In the future</td>
</tr>
</table>

=end HTML


=head2 another

=begin HTML

<p></p>

<table style="margin-bottom: 10px; margin-left: 10px; border-collapse: bollapse;" cellpadding="0" cellspacing="0">
<tr style="vertical-align: top;"><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">Positional parameters</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td><td style="text-align: left; color: #444; background-color: #eee; font-weight: bold;">&#160;</td></tr>
<tr style="vertical-align: top;">
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;"><code>$before</code>

</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;"><a href="https://metacpan.org/pod/Types::Standard#Int">Int</a>

</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;">required</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  border-bottom: 1px solid #eee;"></td>
<td style="padding: 3px 6px; vertical-align: top;  border-bottom: 1px solid #eee;">whooo<br /></td>
</tr>
<tr style="vertical-align: top;">
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;"><code>$thirsty</code>

</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;"><a href="https://metacpan.org/pod/Types::Standard#ArrayRef">ArrayRef</a>[ <a href="https://metacpan.org/pod/Types::Standard#Int">Int</a> ]</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;">required</td>
<td style="vertical-align: top; border-right: 1px solid #eee; white-space: nowrap;  padding: 3px 6px; border-bottom: 1px solid #eee;">slurpy</td>
<td style="padding: 3px 6px; vertical-align: top;  border-bottom: 1px solid #eee;">slurper<br /></td>
</tr>
</table>

=end HTML

=cut
};
}
