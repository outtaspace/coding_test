package Blog::Model::Articles;

use Mojo::Base -base;

has 'pg';

sub all {
    my $self = shift;

    return $self->pg->db->select(
        'blog.articles',
        [qw(id name)],
        undef,
        {-asc => 'id'},
    )->hashes;
}

sub create {
    my ($self, %param) = @_;

    return $self->pg->db->insert(
        'blog.articles',
        {name => $param{'name'}},
        {returning => 'id'},
    )->hash->{'id'};

}

1;

