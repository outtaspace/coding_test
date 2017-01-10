package TestArticleComments;

use Mojo::Base -base;

has 'article';
has 'comment_id';
has 'parent_id';
has 'name';
has 'comment';

sub comment_url {
    my $self = shift;

    return sprintf '%s/%d', $self->article->comments_url, $self->comment_id;
}

1;

