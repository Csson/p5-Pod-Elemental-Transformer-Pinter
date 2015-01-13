use 5.14.0;
use strict;
use warnings;

package Pod::Elemental::Transformer::Splint::MethodRenderer::HtmlDefault;

# VERSION
# ABSTRACT: Default html method renderer

use Moose;
use Path::Tiny;
use Pod::Simple::XHTML;
use List::AllUtils qw/any uniq/;
use syntax 'qs';

with 'Pod::Elemental::Transformer::Splint::MethodRenderer';

sub render_method {
	my $self = shift;
	my $data = shift;

    my $positional_params = $data->{'positional_params'};
    my $named_params = $data->{'named_params'};
    my $return_types = $data->{'return_types'};

    my $html = '';
    my $table_style = q{style="margin-bottom: 10px;" cellpadding="0" cellspacing="0"};
    my $th_style = q{style="text-align: left; color: #444; background-color: #eee; font-weight: bold;"};
    my $tr_style = q{style="vertical-align: top;"};

    my $method_doc = undef;

    $html .= sprintf qq{<table $table_style>
                        <tr $tr_style><td $th_style colspan="%s">Positional parameters</td></tr>}, $self->get_colspan($positional_params);

    warn 'positional: ' . scalar @$positional_params;
    warn 'named: ' . scalar @$named_params;
    if(scalar @$positional_params) {
        foreach my $param (@$positional_params) {

            $method_doc = $param->{'method_doc'} if defined $param->{'method_doc'};

            $html .= "<tr $tr_style>";
            $html .= $self->make_cell_with_border(nowrap => 1, text => $self->parse_pod(sprintf 'C<%s>', $param->{'name'}))
                  .  $self->make_cell_with_border(nowrap => 1, text => $param->{'type'})
                  .  $self->make_cell_with_border(nowrap => 1, text => sprintf q{%s, %s}, $param->{'required_text'}, $self->param_default_text($param))
                  .  $self->make_cell_with_border(nowrap => 1, text => $self->param_trait_text($param))
                  .  $self->make_cell_without_border(nowrap => 0, text => join '' => map { "$_<br />" } @{ $param->{'docs'} })
            ;
            $html .= '</tr>';
        }
    }

    if(scalar @$named_params) {

        $html .= sprintf qq{  <tr $tr_style><td $th_style colspan="%s">Named parameters</td></tr>}, $self->get_colspan($named_params);

        foreach my $param (@$named_params) {
            $method_doc = $param->{'method_doc'} if defined $param->{'method_doc'};

            $html .= "<tr $tr_style>";
            $html .= $self->make_cell_with_border(nowrap => 1, text => $self->parse_pod(sprintf 'C<%s =E<gt> %s>', $param->{'name_without_sigil'}, '$value'))
                  .  $self->make_cell_with_border(nowrap => 1, text => $param->{'type'})
                  .  $self->make_cell_with_border(nowrap => 1, text => sprintf q{%s, %s}, $param->{'required_text'}, $self->param_default_text($param))
                  .  $self->make_cell_with_border(nowrap => 1, text => $self->param_trait_text($param))
                  .  $self->make_cell_without_border(nowrap => 0, text => join '' => map { "$_<br />" } @{ $param->{'docs'} })
            ;
            $html .= '</tr>';
        }
    }
    if(scalar @$return_types) {
        $html .= sprintf qq{  <tr $tr_style><td $th_style colspan="%s">Returns</td></tr>}, $self->get_colspan($named_params > $positional_params ? $named_params : $positional_params);

        foreach my $return_type (@$return_types) {
            $html .= sprintf qq{<tr $tr_style>
             .                  <td colspan="5" style="padding: 3px 6px; vertical-align: top; border-right: 1px solid #eee; border-bottom: 1px solid #eee;">%s</td>
                            }, $return_type
            ;
        }
    }
    $html .= '</table>';

    my $content = sprintf qs{
        =begin HTML
        
            <p>%s</p>

            %s

        =end HTML
    }, $method_doc // '', $html;

    return $content;
}

sub get_colspan {
    my $self = shift;
    my $params = shift;

    return (any { defined $_->{'docs'} && scalar @{ $_->{'docs'} } } @$params) ? (any { ref $_->{'docs'} eq 'HASH' } @$params) ? 6
                                                                               :                                                 5
           :                                                                                                                     4
           ;
}

sub param_trait_text {
    my $self = shift;
    my $param = shift;

    my @traits = grep { my $trait = $_; (any { $trait ne $_ } qw/any optional/); } @{ $self->param_trait_list };

    return q{<span style="color: #aaa;">no traits</span>} if !scalar @traits;
    return join ', ' => @traits;
}

sub param_trait_list {
    my $self = shift;
    my $param = shift;

    my $trait_list = [ sort uniq map { keys %{ $_ } } @{ $param->{'traits'} } ];

    return $trait_list;

}

sub param_default_text {
    my $self = shift;
    my $param = shift;

    return q{<span style="color: #999;">no default</span>} if !defined $param->{'default'};
    return $self->parse_pod(sprintf q{default C<%s coderef>}, $param->{'default_when'}) if ref $param->{'default'} eq 'CODE';
    return $self->parse_pod(sprintf q{default C<%s %s>}, $param->{'default_when'}, $param->{'default'});
}

sub make_cell_without_border {
    my $self = shift;
    my %args = @_;
    my $text = $args{'text'};
    my $nowrap = !$args{'nowrap'} ? '' : ' white-space: nowrap;';

    return qq{<td style="padding: 3px 6px; vertical-align: top; $nowrap border-bottom: 1px solid #eee;">$text</td>};
}
sub make_cell_with_border {
    my $self = shift;
    my %args = @_;
    my $text = $args{'text'};
    my $nowrap = !$args{'nowrap'} ? '' : ' white-space: nowrap;';

    return qq{<td style="padding: 3px 6px; vertical-align: top;$nowrap border-right: 1px solid #eee; border-bottom: 1px solid #eee;">$text</td>};
}

1;
