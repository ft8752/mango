package Mango::Web::Controller::Admin::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Web::Base::Form/;
    use FormValidator::Simple::Constants;
};

=head1 NAME

Mango::Web::Controller::Admin::Products - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
    my ($self, $c) = @_;
    $c->stash->{'template'} = 'admin/products/default';

    my $page = $c->request->param('page') || 1;
    my $products = $c->model('Products')->search(undef, {
        page => $page,
        rows => 10
    });

    $c->stash->{'products'} = $products;
    $c->stash->{'pager'} = $products->pager;
};

sub load : PathPart('admin/products') Chained('/') CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    my $product = $c->model('Products')->get_by_id($id);
warn "PRODUCT: ", $product;
    if ($product) {
        $c->stash->{'product'} = $product;
    } else {
        $c->response->status(404);
        $c->detach;
    };
};

sub create : Local {
    my ($self, $c) = @_;
    my $form = $c->forward('form');

    ## I love being evil. I'll make plugins eventually, but I don't want
    ## the module clutter at the moment
    local *FormValidator::Simple::Validator::PRODUCT_UNIQUE = sub {
        return $c->model('Products')->get_by_sku($form->field('sku')) ? FALSE : TRUE;
    };

    if ($c->forward('submitted') && $c->forward('validate')) {
        my $product = $c->model('Products')->create({
            sku => $form->field('sku'),
            name => $form->field('name'),
            description => $form->field('description'),
            price => $form->field('price')
        });

        $c->response->redirect(
            $c->uri_for('/admin/products', $product->id, 'edit')
        );
    };
};

sub edit : PathPart('edit') Chained('load') Args(0) {
    my ($self, $c) = @_;
    my $product = $c->stash->{'product'};
    my $form = $c->forward('form');

    ## I love being evil. I'll make plugins eventually, but I don't want
    ## the module clutter at the moment
    local *FormValidator::Simple::Validator::PRODUCT_UNIQUE = sub {
        if ($product->sku eq $form->field('sku')) {
            return TRUE;
        };
        my $existing = $c->model('Products')->get_by_sku($form->field('sku'));

        if ($existing && $existing->id != $product->id) {
            return FALSE;
        } else {
            return TRUE;
        };
    };

    $form->values({
        id          => $product->id,
        sku         => $product->sku,
        name        => $product->name,
        description => $product->description,
        price       => $product->price->value,
        created     => $product->created . ''
    });

    if ($c->forward('submitted') && $c->forward('validate')) {
        $product->name($form->field('name'));
        $product->sku($form->field('sku'));
        $product->description($form->field('description'));
        $product->price($form->field('price'));
        $product->update;
    };
};

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;