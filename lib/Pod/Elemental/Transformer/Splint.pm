use 5.14.0;
use strict;
use warnings;

package Pod::Elemental::Transformer::Splint;

# VERSION
# ABSTRACT: ...

use Moose;
use Path::Tiny;
use Safe::Isa;
use lib 'lib';
with qw/Pod::Elemental::Transformer Pod::Elemental::Transformer::Splint::Util/;

has command_name => (
    is => 'rw',
    isa => 'Str',
    default => ':splint',
);
has default_type_library => (
    is => 'rw',
    isa => 'Str',
    default => 'Types::Standard',
    predicate => 'has_default_type_library',
);
has type_libraries => (
    is => 'rw',
    isa => 'HashRef',
    traits => ['Hash'],
    handles => {
        get_library_for_type => 'get',
    },
);
has classmeta => (
    is => 'rw',
    predicate => 'has_classmeta',
);
has html_attribute_renderer => (
    is => 'rw',
    isa => 'Str',
    default => 'HtmlDefault',
);
has text_attribute_renderer => (
    is => 'rw',
    isa => 'Str',
    default => '0',
);
has html_method_renderer => (
    is => 'rw',
    isa => 'Str',
    default => 'HtmlDefault',
);
has text_method_renderer => (
    is => 'rw',
    isa => 'Str',
    default => '0',
);
has attribute_renderers => (
    is => 'rw',
    isa => 'ArrayRef',
    traits => ['Array'],
    handles => {
        add_attribute_renderer => 'push',
        all_attribute_renderers => 'elements',
    }
);
has method_renderers => (
    is => 'rw',
    isa => 'ArrayRef',
    traits => ['Array'],
    handles => {
        add_method_renderer => 'push',
        all_method_renderers => 'elements',
    }
);
around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
    my $args = shift;

    my $type_libraries = {};

    if(exists $args->{'type_libraries'}) {
        my $lib = $args->{'type_libraries'};
        $lib =~ s{([^\h]+=)}{---$1}g;
        $lib =~ s{^---}{};
        $lib =~ s{\h}{}g;
        my @libraries = split /---/ => $lib;

        foreach my $librarydata (@libraries) {
            my($library, $typesdata) = split /=/ => $librarydata;
            my @types = split /,/ => $typesdata;

            foreach my $type (@types) {
                $type_libraries->{ $type } = $library;
            }
        }
    }
    $args->{'type_libraries'} = $type_libraries;
    $class->$orig($args);
};

sub BUILD {
    my $self = shift;

    my $base = 'Pod::Elemental::Transformer::Splint';

    TYPE:
    foreach my $type (qw/attribute method/) {

        RENDERER:
        foreach my $output (qw/html text/) {
            my $accessor = sprintf '%s_%s_renderer', $output, $type;
            my $class = sprintf '%s::%sRenderer::%s', $base, ucfirst $type, $self->$accessor;

            next RENDERER if $self->$accessor eq '0';
            eval "use $class";
            die "Can't use $class as renderer: $@" if $@;

            my $wanted_role = sprintf '%s::%sRenderer', $base, ucfirst $type;
            if(!$class->does($wanted_role)) {
                die "$class doesn't do the $wanted_role role";
            }

            my $add_method = sprintf 'add_%s_renderer', $type;
            $self->$add_method($class->new);
        }
    }
}

sub transform_node {
    my $self = shift;
    my $node = shift;

    CHILD:
    foreach my $child (@{ $node->children }) {

        my $line_start = substr($child->content, 0 => length ($self->command_name) + 1);
        next CHILD if $line_start ne sprintf '%s ', $self->command_name;

        my($prefix, $action, $param, $data) = split m/\h+/, $child->content, 4;

        if($action eq 'classname' && defined $param) {
            eval "use $param";
            die "Can't use $param: $@" if $@;

            $self->classmeta($param->meta);
            $child->content('');

            next CHILD;
        }
        next CHILD if !$self->has_classmeta;

        if($action eq 'attributes' && scalar $self->classmeta->get_attribute_list) {

            my @attribute_names = sort {
                                         ($a->does('Documented') && $a->has_documentation_order ? $a->documentation_order : 1000) <=> ($b->does('Documented') && $b->has_documentation_order ? $b->documentation_order : 1000)
                                      || ($b->is_required || 0) <=> ($a->is_required || 0)
                                      ||  $a->name cmp $b->name
                                  }
                                  map { $self->classmeta->get_attribute($_) }
                                  $self->classmeta->get_attribute_list;
            my $content = '';

            ATTR:
            foreach my $attr (@attribute_names) {

                next ATTR if $attr->does('Documented') && $attr->has_documentation_order && $attr->documentation_order == 0;

                $content .= sprintf "\n=head2 %s\n", $attr->name;
                my $prepared_attr = $self->prepare_attr($attr);
                foreach my $attribute_renderer ($self->all_attribute_renderers) {
                    $content .= $attribute_renderer->render_attribute($prepared_attr);
                }

            }
            $child->content($content);
        }

        if($action eq 'method') {
            if(!$self->classmeta->has_method($param)) {
                $child->content('');
                return;
            }

            my $method = $self->classmeta->get_method($param);
            my $content = sprintf "\n=head2 %s\n", $method->name;
            my $prepared_method = $self->prepare_method($method);

            foreach my $method_renderer ($self->all_method_renderers) {
                $content .= $method_renderer->render_method($prepared_method);
            }
            $child->content($content);

        }



    }
}
sub prepare_attr {
    my $self = shift;
    my $attr = shift;

    my $settings = {
        type => ($attr->type_constraint ? $self->make_type_string($attr->type_constraint) : undef),
        required_text => $self->required_text($attr->is_required),
        is_text => $self->is_text($attr),
        default => $attr->default,
        is_default_a_coderef => !!$attr->is_default_a_coderef(),
        documentation_default => $attr->does('Documented') ? $attr->documentation_default : undef,
    };

    my $documentation_alts = [];
    if($attr->does('Documented') && $attr->has_documentation_alts) {
        my $documentation = $attr->documentation_alts;

        foreach my $key (sort grep { $_ ne '_' } keys %{ $documentation }) {
            push @{ $documentation_alts } => [ $key, $documentation->{ $key } ];
        }
    }
    return {
        settings => $settings,
        documentation_alts => $documentation_alts,
        $attr->does('Documented') && $attr->has_documentation ? (documentation => $attr->documentation) : (),
    };
}

sub prepare_method {
    my $self = shift;
    my $method = shift;

    my $positional_params = [];
    my $named_params = [];

    return { map { $_ => [] } qw/positional_params named_params return_types/ } if !$method->signature;

    foreach my $param ($method->signature->positional_params) {
        push @$positional_params => {
            name => $param->name,
            %{ $self->prepare_param($param) },
        };
    }
    if($method->signature->has_slurpy) {
        my $slurpy = $method->signature->slurpy_param;

        push @$positional_params => {
            name => $slurpy->name,
            %{ $self->prepare_param($slurpy) },
        };
    }

    foreach my $param (sort { $a->optional <=> $b->optional || $a->name cmp $b->name } $method->signature->named_params) {
        my $name = $param->name;
        $name =~ s{[\@\$\%]}{};
        push @$named_params => {
            name => $param->name,
            name_without_sigil => $name,
            %{ $self->prepare_param($param) },
        };
    }

    my $all_return_types = [];
    foreach my $return_types ($method->signature->return_types) {

        foreach my $return_type (@$return_types) {
            next if !$return_type->$_can('type');

            my($docs, $method_doc) = $self->get_docs($return_type);
            push @$all_return_types => {
                type => $self->make_type_string($return_type->type),
                docs => $docs,
                method_doc => $method_doc,
            };
        }
    }

    my $data = {
        positional_params => $positional_params,
        named_params => $named_params,
        return_types => $all_return_types,
    };

    return $data;

}

sub get_docs {
    my $self = shift;
    my $thing = shift;

    my $docs = [];
    my $method_doc = undef;

    if(exists $thing->traits->{'doc'} && ref $thing->traits->{'doc'} eq 'ARRAY') {
        $docs = [ split /\n/ => join "\n" => @{ $thing->traits->{'doc'} } ];

        if(index ($docs->[-1], 'method_doc|') == 0) {
            $method_doc = substr pop @{ $docs }, 11;
        }
    }
    return ($docs, $method_doc);
}

sub prepare_param {
    my $self = shift;
    my $param = shift;

    my($docs, $method_doc) = $self->get_docs($param);

    my $prepared = {
            type => $self->make_type_string($param->type),
            default => defined $param->default ? $param->default->() : undef,
            default_when => $param->default_when,
            has_default => defined $param->default ? 1 : 0,
            traits => [ sort grep { $_ && $_ ne 'doc' && $_ ne 'optional' } ($param->traits, ($param->coerce ? 'coerce' : () ) ) ],
            required_text => $self->required_text(!$param->optional),
            is_required => !$param->optional,
            method_doc => $method_doc,
            docs => $docs,
    };

    return $prepared;
}

sub required_text {
    my $self = shift;
    my $value = shift;
    return $value ? 'required' : 'optional';
}
sub is_text {
    my $self = shift;
    my $attr = shift;

    return $attr->has_write_method ? 'read/write' : 'read-only';
}


1;


__END__

=pod

=head1 SYNOPSIS

    use Pod::Elemental::Transformer::Splint;

=head1 DESCRIPTION

Pod::Elemental::Transformer::Splint is ...

=head1 SEE ALSO

=cut
