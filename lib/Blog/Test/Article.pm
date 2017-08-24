package Blog::Test::Article;

use Mojo::Base -base;

has 'app';
has 'id';
has 'name';

sub get_article {
    my $self = shift;

    return $self->app->url_for('get_article', article_id => $self->id);
}

sub update_article {
    my $self = shift;

    return $self->app->url_for('update_article', article_id => $self->id);
}

sub delete_article {
    my $self = shift;

    return $self->app->url_for('delete_article', article_id => $self->id);
}

sub create_article_comment {
    my $self = shift;

    return $self->app->url_for('create_article_comment', article_id => $self->id);
}

sub get_all_article_comments {
    my $self = shift;

    return $self->app->url_for('get_all_article_comments', article_id => $self->id);
}

sub get_all_article_comments_as_tree {
    my $self = shift;

    return $self->app->url_for('get_all_article_comments_as_tree', article_id => $self->id);
}

1;

