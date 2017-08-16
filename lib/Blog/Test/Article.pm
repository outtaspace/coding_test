package Blog::Test::Article;

use Mojo::Base 'Blog::Test::Articles';

has 'article_id';
has 'name';

sub url {
    my $self = shift;

    return sprintf '%s%d/', $self->SUPER::url, $self->article_id;
}

sub comments_url {
    my $self = shift;

    return sprintf '%scomments/', $self->url;
}

sub comments_as_tree_url {
    my $self = shift;

    return sprintf '%scomments_as_tree/', $self->url;
}

1;

