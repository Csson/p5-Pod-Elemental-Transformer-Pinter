use 5.14.0;
use strict;
use warnings;

package Pod::Elemental::Transformer::Splint::Util;

# VERSION
# ABSTRACT: Role for attribute renderers

use Moose::Role;
use Pod::Simple::XHTML;
use Safe::Isa;

sub parse_pod {
    my $self = shift;
    my $pod = shift;

    my $podder = Pod::Simple::XHTML->new;
    $podder->html_header('');
    $podder->html_footer('');
    my $results = '';
    $podder->output_string(\$results);
    $podder->parse_string_document("=pod\n\n$pod");

    $results =~ s{</?p>}{}g;
    $results =~ s{https?://search\.cpan\.org/perldoc\?}{https://metacpan.org/pod/}g;
    return $results;
}

sub make_type_string {
    my $self = shift;
    my $type_constraint = shift;

    if(!$type_constraint->$_can('library')) {
        return $type_constraint if !$self->has_fallback_type_library;
        return $self->parse_pod(sprintf 'L<%s|%s/"%s>', $type_constraint, $self->has_fallback_type_library, $type_constraint);
    }

    my $library = $type_constraint->library;

    return $self->parse_pod(sprintf 'L<%s|%s/"%s>', $type_constraint, $library, $type_constraint) if defined $library;

    if($type_constraint =~ m{InstanceOf}) {
        if($self->has_fallback_type_library) {
            $type_constraint =~ s{InstanceOf}{$self->parse_pod(sprintf 'L<%s|%s/"%s>', 'InstanceOf', $self->fallback_type_library, 'InstanceOf')}egi;
            $type_constraint =~ s{"}{'}g;
        }
        return $type_constraint
    }
    if($type_constraint =~ m{[^a-z0-9_]}i) {
        if($self->has_fallback_type_library) {
            $type_constraint =~ s{\b([a-z0-9_]+)\b}{$self->parse_pod(sprintf 'L<%s|%s/"%s>', $1, $self->fallback_type_library, $1)}egi;
            $type_constraint =~ s{[\v\h]*\|[\v\h]*}{ | }g; # cleanup and ensure some whitespace
            $type_constraint =~ s{\[}{[ }g;
            $type_constraint =~ s{\]}{ ]}g;
        }
        return $type_constraint;
    }
    if($self->has_fallback_type_library) {
        return $self->parse_pod(sprintf 'L<%s|%s/"%s>', $type_constraint, $library, $type_constraint);
    }
    return $type_constraint;
}

1;
