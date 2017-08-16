package Blog::Test::ArticleComment;

use Mojo::Base 'Blog::Test::ArticleComments';

has 'comment_id';
has 'parent_id';
has 'name';
has 'comment';

sub url {
    my $self = shift;

    return sprintf '%s%d/', $self->SUPER::url, $self->comment_id;
}

1;

