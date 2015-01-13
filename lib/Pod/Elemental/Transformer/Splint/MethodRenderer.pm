use 5.14.0;
use strict;
use warnings;

package Pod::Elemental::Transformer::Splint::MethodRenderer;

# VERSION
# ABSTRACT: Role for method renderers

use Moose::Role;
use Pod::Simple::XHTML;

with 'Pod::Elemental::Transformer::Splint::Util';
requires 'render_method';


1;
