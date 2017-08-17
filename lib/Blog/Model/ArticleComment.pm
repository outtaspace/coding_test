package Blog::Model::ArticleComment;

use Mojo::Base -base;

has 'pg';

sub get {
    my ($self, %param) = @_;

    return $self->pg->db->select(
        'blog.article_comments',
        [qw(id article_id parent_id name comment)],
        {id => $param{'id'}},
    )->hash;
}

sub update {
    my ($self, %param) = @_;

    return $self->pg->db->update(
        'blog.article_comments',
        {name => $param{'name'}, comment => $param{'comment'}},
        {id => $param{'id'}},
        {returning => 'id'},
    )->hash->{'id'};
}

sub delete {
    my ($self, %param) = @_;

    return $self->pg->db->delete(
        'blog.article_comments',
        {id => $param{'id'}},
        {returning => 'id'},
    )->hash->{'id'};
}

1;

