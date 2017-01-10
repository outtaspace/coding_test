package TestArticle;

use Mojo::Base -base;

has 'article_id';
has 'name';

sub articles_url {
    return '/blog/articles';
}

sub article_url {
    my $self = shift;

    return sprintf '%s/%d', $self->articles_url, $self->article_id;
}

sub comments_url {
    my $self = shift;

    return sprintf '%s/comments', $self->article_url;
}

sub comments_as_tree_url {
    my $self = shift;

    return sprintf '%s/comments/as_tree', $self->article_url;
}

1;

