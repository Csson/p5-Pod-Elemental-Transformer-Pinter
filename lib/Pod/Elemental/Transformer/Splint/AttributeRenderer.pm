use 5.14.0;
use strict;
use warnings;

package Pod::Elemental::Transformer::Splint::AttributeRenderer;

# VERSION
# ABSTRACT: Role for attribute renderers

use Moose::Role;
use Pod::Simple::XHTML;

with 'Pod::Elemental::Transformer::Splint::Util';
requires 'render_attribute';

1;
