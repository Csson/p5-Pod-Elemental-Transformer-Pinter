use 5.14.0;
use strict;
use warnings;

package Pod::Elemental::Transformer::Pinter;

# VERSION
# ABSTRACT: ...

use Moose;
use Path::Tiny;
use Pod::Simple::XHTML;
use syntax 'qs';
use lib 'lib';
with 'Pod::Elemental::Transformer';

has command_name => (
    is => 'rw',
    isa => 'Str',
    default => ':pinter',
);

#has classname => (
#    is => 'rw',
#    isa => 'Str',
#    predicate => 'has_classname',
#);
has classmeta => (
    is => 'rw',
    predicate => 'has_classmeta',
);

has output_html => (
    is => 'rw',
    isa => 'Bool',
    default => 1,
);
has output_text => (
    is => 'rw',
    isa => 'Bool',
    default => 1,
);


sub transform_node {
    my $self = shift;
    my $node = shift;

    CHILD:
    foreach my $child (@{ $node->children }) {
        

        my $line_start = substr($child->content, 0 => length ($self->command_name) + 1);
        next CHILD if $line_start ne sprintf '%s ', $self->command_name;
        warn ' ';

        warn '  ' . $child->content;
        my($prefix, $action, $param, $data) = split m/\h+/, $child->content, 4;

        if($action eq 'classname' && defined $param) {
            warn '--> found class: ' . $param;
            eval "use $param";
            die "Can't use $param: $@" if $@;

            $self->classmeta($param->meta);
            $child->content('');

            next CHILD;
        }
        warn 'do we have it?';
        next CHILD if !$self->has_classmeta;
        warn 'yes..';

        if($action eq 'attributes' && scalar $self->classmeta->get_attribute_list) {
            my $content = '';

            my @attribute_names = sort { $a->documentation_order <=> $b->documentation_order || $a->name cmp $b->name } 
                                  map { $self->classmeta->get_attribute($_) } 
                                  $self->classmeta->get_attribute_list;

            ATTR:
            foreach my $attr (@attribute_names) {

                next ATTR if !defined $attr->init_arg;

                if($self->output_html) {
                    $content .= $self->create_html_for_attribute($attr);
                }
                if($self->output_text) {
                    $content .= $self->create_text_for_attribute($attr);
                }
                warn "attr contents: \n---\n$content\n---";
                $child->content($content);
            }
        }
        else {
            warn 'but no attributes';
        }

        warn sprintf "prefix: '%s' action: '%s'  param: '%s'  data: '%s'", $prefix, $action, $param, $data;

        if($action eq 'method') {
            if(!$self->classmeta->has_method($param)) {
                warn sprintf 'No such method ' . $param;
                $child->content('');
                return;
            }

            my $param1 = $self->classmeta->get_method($param)->signature->params->[1];
            my $returns = $self->classmeta->get_method($param)->signature->return_types->[0];
use Data::Dump::Streamer;
            my $content = sprintf qs{
                =head2 %s()

                %s

                %s %s. %s returns %s
            }, $param, ($data // ''), $param1->optional ? 'Optional' : 'Required', $param1->type->name, $param1->traits->{'doc'}[0], join ', ' => $returns->type->display_name, $returns->traits->{'doc'}[0];

            warn "CONTENTS: \n     ----\n$content\n----";
            $child->content($content);

        }



    }
}

sub create_html_for_attribute {
    my $self = shift;
    my $attr = shift;
    warn 'making html!';

    my @items = ();

    if($attr->type_constraint) {
        my $typename = $attr->type_constraint;
        my $library = $attr->type_constraint->library;

        if(defined $library) {
            push @items => $self->parse_pod(sprintf 'L<%s|%s/"%s>', $typename, $library, $typename);
        }
        else {
            push @items => $typename;
        }
    }
    push @items => $self->required_text($attr),
                   $self->is_text($attr),
                   ;

    my $amount_of_doc = $attr->does('Documented') && $attr->has_documentation && ref $attr->documentation eq 'HASH' ? scalar keys %{ $attr->documentation }
                      : $attr->does('Documented') && $attr->has_documentation                                       ? 1
                      :                                                                                               0
                      ;

    if($attr->has_default) {
        if(!$attr->is_default_a_coderef) {
            push @items => $self->parse_pod(sprintf q{Default: C<%s>}, $attr->default);
        }
        elsif($attr->has_documentation_default) {
            push @items => sprintf q{Default: %s}, $attr->documentation_default;
        }
        else {
            push @items => 'Default value is a coderef';
        }
    }
    if($attr->has_documentation_alts) {
        my $documentation = $attr->documentation_alts;

        foreach my $key (sort grep { $_ ne '_' } keys %{ $documentation }) {
            warn 'PUSHING EXTRA ==========>>>>>>';
            push @{ $extra_documentation } => [ $key, $documentation->{ $key } ];
        }
    }

    my $extra_documentation = [];
    warn $attr->name . ' -->amount_of_doc: ' . $amount_of_doc;
    if($amount_of_doc) {

        my $documentation = $attr->documentation;

        if($amount_of_doc == 1) {
            if(ref $documentation eq 'HASH') {
                my $key = (keys %{ $documentation })[0];
                push @items => ($key, $documentation->{ $key });
            }
        }
        elsif($amount_of_doc > 1) {
            foreach my $key (sort grep { $_ ne '_' } keys %{ $documentation }) {
                warn 'PUSHING EXTRA ==========>>>>>>';
                push @{ $extra_documentation } => [ $key, $documentation->{ $key } ];
            }
        }
    }

    my $last_cell = pop @items;
    my @cells = map { $self->make_cell_with_border($_) } @items;
    push @cells => scalar @{ $extra_documentation } ? $self->make_cell_with_border($last_cell)
                :                                     $self->make_cell_without_border($last_cell)
                ;

    if(scalar @{ $extra_documentation }) {
        my $first_extra_doc = shift @{ $extra_documentation };
        push @cells => $self->make_cell_without_border_right_aligned( $self->parse_pod(sprintf 'C<%s>:', $first_extra_doc->[0]) ),
                       $self->make_cell_extra_padded_without_border($first_extra_doc->[1]);
    }

    my $rows = [ \@cells ];
    warn 'EXTRA_DOC:' . scalar @{ $extra_documentation };
    if(scalar @{ $extra_documentation} ){
        my $number_of_cells_left_of_doc = scalar @cells - 2;

        foreach my $extra_doc (@{ $extra_documentation }) {
            warn 'USES EXTRA DOC!!!!';
            my $row = [ ('<td>&#160;</td>') x $number_of_cells_left_of_doc ];
            push @{ $row } => $self->make_cell_without_border_right_aligned( $self->parse_pod(sprintf 'C<%s>:', $extra_doc->[0]) ),
                              $self->make_cell_extra_padded_without_border($extra_doc->[1]);
            push @{ $rows } => $row;
        }
    }
use Data::Dump::Streamer;
warn Dump($rows)->Out;
    my $table = '<table cellpadding="0" cellspacing="0">';
    foreach my $row (@{ $rows }) {
        $table .= '<tr>';
        $table .= join "\n" => @{ $row };
        $table .= '</tr>';
    }
    $table .= '</table>';
#    my $definition = undef;
#    if(scalar @items) {
#        $definition = sprintf qs{
#            <ul style="list-style: none; padding-left: 0px;">
#                <li style="display: inline;">%s</li>
#                %s
#            </ul>
#        }, shift @items,
#           join "\n" => map { sprintf qq{<li style="display: inline; padding-left: 4px; border-left: 1px solid #b8b8b8;">$_</li>} } @items,
#        ;
#    }
    my $simple_documentation = $attr->has_documentation && ref $attr->documentation eq 'HASH' ? $attr->documentation->{'_'} || ''
                             : $attr->has_documentation                                       ? $attr->documentation
                             :                                                                  ''
                             ;

    return sprintf qs{

        =head2 %s

        =begin HTML

            %s

        =end HTML

            %s
    }, $attr->name, $table, $simple_documentation;

}

sub create_text_for_attribute {
    my $self = shift;
    my $attribute = shift;
    warn '--> making text';
    warn $attribute->init_arg;
    warn $attribute->type_constraint->library;
    warn $attribute->default;
    warn $attribute->has_write_method ? 'has writer' : 'dont have writer';
    warn $attribute->is_required;
    warn $attribute->does('Documented') ? 'yes!' : 'no...';
    #warn $attribute->isa->display_name;
    warn '                ';
#use Data::Dump::Streamer;
#path('attr_out.txt')->spew(Dump($attribute)->Out);
#die;
    return sprintf qs{
        =begin TEXT

        =head2 %s %s %s

        =end TEXT
    }, $attribute->name, $attribute->type_constraint, $attribute->is_required;
}

sub required_text {
    my $self = shift;
    return shift->is_required ? 'required' : 'optional';
}
sub is_text {
    my $self = shift;
    my $attr = shift;

    return $attr->has_write_method ? 'read/write' : 'read-only';
}

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
    return $results;
}

sub make_cell_without_border {
    my $self = shift;
    my $item = shift;

    return sprintf q{<td style="padding-left: 6px; padding-right: 6px;"><span>%s</span></td>}, $item;
}
sub make_cell_extra_padded_without_border {
    my $self = shift;
    my $item = shift;

    return sprintf q{<td style="padding-left: 12px;"><span>%s</span></td>}, $item;
}
sub make_cell_with_border {
    my $self = shift;
    my $item = shift;

    return sprintf q{<td><span style="padding-right: 6px; padding-left: 6px; border-right: 1px solid #b8b8b8;">%s</span></td>}, $item;
}
sub make_cell_without_border_right_aligned {
    my $self = shift;
    my $item = shift;

    return sprintf q{<td style="text-align: right;"><span style="padding-right: 6px; padding-left: 6px;">%s</span></td>}, $item;
}

1;


__END__

=pod

=head1 SYNOPSIS

    use Pod::Elemental::Transformer::Pinter;

=head1 DESCRIPTION

Pod::Elemental::Transformer::Pinter is ...

=head1 SEE ALSO

=cut
