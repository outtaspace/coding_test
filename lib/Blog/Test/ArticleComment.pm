package Blog::Test::ArticleComment;

use Mojo::Base -base;

has 'id';
has 'article_id';
has 'parent_id';
has 'name';
has 'comment';

sub url {
    my $self = shift;

    return sprintf '/blog/comments/%d/', $self->id;
}

1;

