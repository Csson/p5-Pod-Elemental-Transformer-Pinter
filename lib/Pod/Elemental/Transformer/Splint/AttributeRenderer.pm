use 5.10.1;
use strict;
use warnings;

package Pod::Elemental::Transformer::Splint::AttributeRenderer;

# ABSTRACT: Role for attribute renderers
# AUTHORITY
our $VERSION = '0.1202';

use Moose::Role;
use Pod::Simple::XHTML;
use Types::Standard qw/Str/;

with 'Pod::Elemental::Transformer::Splint::Util';
requires 'render_attribute';

has for => (
    is => 'ro',
    isa => Str,
    required => 1,
);

1;
