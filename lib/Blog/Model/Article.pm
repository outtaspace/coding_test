package Blog::Model::Article;

use Mojo::Base -base;

has 'pg';

sub get {
    my ($self, %param) = @_;

    return $self->pg->db->select(
        'blog.articles',
        [qw(id name)],
        {id => $param{'id'}},
    )->hash;
}

sub update {
    my ($self, %param) = @_;

    return $self->pg->db->update(
        'blog.articles',
        {name => $param{'name'}},
        {id => $param{'id'}},
        {returning => 'id'},
    )->hash->{'id'};
}

sub delete {
    my ($self, %param) = @_;

    return $self->pg->db->delete(
        'blog.articles',
        {id => $param{'id'}},
        {returning => 'id'},
    )->hash->{'id'};
}

1;

