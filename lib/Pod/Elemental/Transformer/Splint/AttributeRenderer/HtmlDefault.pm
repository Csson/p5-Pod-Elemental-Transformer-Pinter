use 5.14.0;
use strict;
use warnings;

package Pod::Elemental::Transformer::Splint::AttributeRenderer::HtmlDefault;

# VERSION
# ABSTRACT: Default html attribute renderer

use Moose;
use Path::Tiny;
use Pod::Simple::XHTML;
use syntax 'qs';

with 'Pod::Elemental::Transformer::Splint::AttributeRenderer';

sub render_attribute {
    my $self = shift;
    my $data = shift;

    my $settings = $data->{'settings'};
    my $documentation_alts = $data->{'documentation_alts'};
    my $documentation = $data->{'documentation'};

    my $items = [];
    push @$items => $settings->{'type'} if defined $settings->{'type'};
    my $req_and_default = '';

    if(!defined $settings->{'default'}) {
        $req_and_default = $settings->{'required_text'};
    }
    elsif($settings->{'is_default_a_coderef'}) {
        if(defined $settings->{'documentation_default'}) {
            $req_and_default = $self->parse_pod(sprintf '%s, default: C<%s>', $settings->{'required_text'}, $settings->{'documentation_default'});
        }
        else {
            $req_and_default = $self->parse_pod(sprintf '%s, default is a C<coderef>', $settings->{'required_text'});
        }
    }
    else {
        $req_and_default = $self->parse_pod(sprintf '%s, default: C<%s>', $settings->{'required_text'}, $settings->{'default'});
    }

    push @$items => $req_and_default;
    push @$items => $settings->{'is_text'};

    my $last_item = pop @$items;
    my $cells = [ map { $self->make_cell_with_border($_) } @$items ];

    push @$cells => scalar @{ $documentation_alts } ? $self->make_cell_with_border($last_item)
                 :                                    $self->make_cell_without_border($last_item)
                 ;

    if(scalar @{ $documentation_alts }) {
        my $first_doc_alt = shift @{ $documentation_alts };

        push @$cells => $self->make_cell_without_border_right_aligned( $self->parse_pod(sprintf 'C<%s>:', $first_doc_alt->[0]) ),
                       $self->make_cell_extra_padded_without_border($first_doc_alt->[1]);
    }

    my $rows = [ $cells ];

    if(scalar @{ $documentation_alts} ){
        my $number_of_cells_left_of_doc = scalar @$cells - 2;

        foreach my $doc_alt (@{ $documentation_alts }) {
            my $row = [ ('<td>&#160;</td>') x $number_of_cells_left_of_doc ];
            push @{ $row } => $self->make_cell_without_border_right_aligned( $self->parse_pod(sprintf 'C<%s>:', $doc_alt->[0]) ),
                              $self->make_cell_extra_padded_without_border($doc_alt->[1]);
            push @{ $rows } => $row;
        }
    }

    my $table = '';
    foreach my $row (@{ $rows }) {
        $table .= '<tr>';
        $table .= join "\n" => @{ $row };
        $table .= '</tr>';
    }

    my $content =  sprintf qs{
        =begin HTML

            <table cellpadding="0" cellspacing="0">
                %s
            </table>

            <p>%s</p>

        =end HTML
    }, $table, $documentation // '';

    return $content;
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
