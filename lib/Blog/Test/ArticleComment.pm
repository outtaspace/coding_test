package Blog::Test::ArticleComment;

use Mojo::Base -base;

has 'app';
has 'id';
has 'article_id';
has 'parent_id';
has 'name';
has 'comment';

sub get_article_comment {
    my $self = shift;

    return $self->app->url_for('get_article_comment', comment_id => $self->id);
}

sub update_article_comment {
    my $self = shift;

    return $self->app->url_for('update_article_comment', comment_id => $self->id);
}

sub delete_article_comment {
    my $self = shift;

    return $self->app->url_for('delete_article_comment', comment_id => $self->id);
}

1;

