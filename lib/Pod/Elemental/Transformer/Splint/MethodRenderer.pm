use 5.10.1;
use strict;
use warnings;

package Pod::Elemental::Transformer::Splint::MethodRenderer;

# ABSTRACT: Role for method renderers
# AUTHORITY
our $VERSION = '0.1203';

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
