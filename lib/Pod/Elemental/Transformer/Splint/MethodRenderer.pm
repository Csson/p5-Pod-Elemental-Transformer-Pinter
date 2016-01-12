use 5.14.0;
use strict;
use warnings;

package Pod::Elemental::Transformer::Splint::MethodRenderer;

# VERSION
# ABSTRACT: Role for method renderers

use Moose::Role;
use Pod::Simple::XHTML;
use Types::Standard qw/Str/;

with 'Pod::Elemental::Transformer::Splint::Util';
requires 'render_method';

has for => (
    is => 'ro',
    isa => Str,
    required => 1,
);

1;
