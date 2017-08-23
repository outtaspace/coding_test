package Blog::Test::Article;

use Mojo::Base 'Blog::Test::Articles';

has 'id';
has 'name';

sub url {
    my $self = shift;

    return sprintf '%s%d/', $self->SUPER::url, $self->id;
}

sub comments_url {
    my $self = shift;

    return sprintf '%scomments/', $self->url;
}

sub comments_as_tree_url {
    my $self = shift;

    return sprintf '%scomments/as_tree/', $self->url;
}

1;

