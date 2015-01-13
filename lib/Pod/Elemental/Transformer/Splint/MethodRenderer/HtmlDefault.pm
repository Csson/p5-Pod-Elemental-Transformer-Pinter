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

    my @html = ();
    my $table_style = q{style="margin-bottom: 10px; border-collapse: bollapse;" cellpadding="0" cellspacing="0"};
    my $th_style = q{style="text-align: left; color: #444; background-color: #eee; font-weight: bold;"};
    my $tr_style = q{style="vertical-align: top;"};

    my $method_doc = undef;

    my $colspan = $self->get_colspan([ @$positional_params, @$named_params, @$return_types]);

    if(scalar @$positional_params) {

        push @html => qq{<tr $tr_style><td $th_style colspan="$colspan">Positional parameters</td></tr>};

        foreach my $param (@$positional_params) {

            $method_doc = $param->{'method_doc'} if defined $param->{'method_doc'};

            push @html => "<tr $tr_style>";
            push @html => $self->make_cell_with_border(nowrap => 1, text => $self->parse_pod(sprintf 'C<%s>', $param->{'name'}));
            push @html => $self->make_cell_with_border(nowrap => 2, text => $param->{'type'});
            push @html => $self->make_cell_with_border(nowrap => 3, text => (join ', ' => $param->{'required_text'}, $param->{'is_required'} ? defined $param->{'default'} ? $self->param_default_text($param) : () : $self->param_default_text($param)));
            push @html => $self->make_cell_with_border(nowrap => 4, text => $self->param_trait_text($param));
            push @html => $self->make_cell_without_border(nowrap => 0, text => join '' => map { "$_<br />" } @{ $param->{'docs'} });

            push @html => '</tr>';
        }
    }
    if(scalar @$named_params) {

        push @html => qq{  <tr $tr_style><td $th_style colspan="$colspan">Named parameters</td></tr>};

        foreach my $param (@$named_params) {
            $method_doc = $param->{'method_doc'} if defined $param->{'method_doc'};

            push @html => "<tr $tr_style>";
            push @html => $self->make_cell_with_border(nowrap => 5, text => $self->parse_pod(sprintf 'C<%s =E<gt> %s>', $param->{'name_without_sigil'}, '$value'));
            push @html => $self->make_cell_with_border(nowrap => 6, text => $param->{'type'});
            push @html => $self->make_cell_with_border(nowrap => 7, text => join ', ' => $param->{'required_text'}, $param->{'is_required'} && defined $param->{'default'} ? $self->param_default_text($param) : $param->{'is_required'} ? () : $self->param_default_text($param));
            push @html => $self->make_cell_with_border(nowrap => 8, text => $self->param_trait_text($param));
            push @html => $self->make_cell_without_border(nowrap => 0, text => join '<br />' => @{ $param->{'docs'} });

            push @html => '</tr>';
        }
    }
    if(scalar @$return_types) {
        push @html => qq{  <tr $tr_style><td $th_style colspan="$colspan">Returns</td></tr>};

        foreach my $return_type (@$return_types) {
            $method_doc = $return_type->{'method_doc'} if defined $return_type->{'method_doc'};
            my $has_doc = scalar @{ $return_type->{'docs'} };
            my $return_colspan = $has_doc ? $colspan - 1 : $colspan;

            push @html => qq{<tr $tr_style>};
            push @html => $has_doc ? $self->make_cell_with_border(nowrap => 0, colspan => $return_colspan, text => $return_type->{'type'})
                                   : $self->make_cell_without_border(nowrap => 0, colspan => $return_colspan, text => $return_type->{'type'})
                                   ;
            push @html => $self->make_cell_without_border(nowrap => 0, text => join '<br />' => @{ $return_type->{'docs'} });
            push @html => '</tr>';
        }
    }
    if(scalar @html) {
        unshift @html => qq{<table $table_style>};
        push @html => '</table>';
    }

    my $content = sprintf qs{
        =begin HTML

            <p>%s</p>

            %s

        =end HTML
    }, $method_doc // '', join "\n" => map { qqs{$_} } @html;

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

    my @traits = grep { $_ ne 'doc' && $_ ne 'optional' } @{ $self->param_trait_list($param) };

    return undef if !scalar @traits;
    return join ', ' => map { $_ eq 'slurpy' ? $_ : sprintf '<a href="https://metacpan.org/pod/Kavorka/TraitFor/Parameter/%s">$_</a>', $_ } @traits;
}

sub param_trait_list {
    my $self = shift;
    my $param = shift;

    my $trait_list = [ uniq sort map { keys %{ $_ } } @{ $param->{'traits'} } ];

    return $trait_list;

}

sub param_default_text {
    my $self = shift;
    my $param = shift;

    return q{<span style="color: #999;">no default</span>} if !defined $param->{'default'};
    return $self->parse_pod(sprintf q{default C<%s coderef>}, $param->{'default_when'}) if ref $param->{'default'} eq 'CODE';
    return $self->parse_pod(sprintf q{default C<%s %s>}, $param->{'default_when'}, $param->{'default'} eq '' ? "''" : $param->{'default'});
}

sub make_cell_without_border {
    my $self = shift;
    my($text, $nowrap, $colspan_text) = $self->fix_cell_args(@_);
    $text = defined $text ? $text : '';

    return qq{<td $colspan_text style="padding: 3px 6px; vertical-align: top; $nowrap border-bottom: 1px solid #eee;">$text</td>};
}
sub make_cell_with_border {
    my $self = shift;

    my($text, $nowrap, $colspan_text) = $self->fix_cell_args(@_);
    my $padding = defined $text ? ' padding: 3px 6px;' : '';
    $text = defined $text ? $text : '';

    return qq{<td $colspan_text style="vertical-align: top; border-right: 1px solid #eee;$nowrap $padding border-bottom: 1px solid #eee;">$text</td>};
}

sub fix_cell_args {
    my $self = shift;
    my %args = @_;

    my $text = $args{'text'};
    my $nowrap = !$args{'nowrap'} ? '' : ' white-space: nowrap;';
    my $colspan_text = !exists $args{'colspan'} ? '' : qq{ colspan="$args{'colspan'}" };

    return ($text, $nowrap, $colspan_text);
}

1;
