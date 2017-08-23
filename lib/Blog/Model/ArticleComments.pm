package Blog::Model::ArticleComments;

use Mojo::Base -base;

use Try::Tiny;

has 'pg';

sub all {
    my ($self, %param) = @_;

    my $comments;
    try {
        my $db = $self->pg->db;
        my $tx = $db->begin;

        if ($self->is_article_exists(article_id => $param{'article_id'})) {
            $comments = $db->select(
                'blog.article_comments',
                [qw(id parent_id)],
                {article_id => $param{'article_id'}},
                {-asc => 'id'},
            )->hashes;
        }

        $tx->commit;
    };

    return $comments;
}

sub all_as_tree {
    my ($self, %param) = @_;

    my $comments = $self->all(%param);

    return unless defined $comments;

    my %parent = (0 => []);

    for my $each_comment (@{ $comments }) {
        my $id        = $each_comment->{'id'};
        my $parent_id = $each_comment->{'parent_id'} // 0;

        $each_comment->{'comments'} = [];

        $parent{$id} = $each_comment->{'comments'};

        push @{ $parent{$parent_id} }, $each_comment;
    }

    return $parent{0};
}

sub create {
    my ($self, %param) = @_;

    my $id;
    try {
        my $db = $self->pg->db;
        my $tx = $db->begin;

        if ($self->is_article_exists(article_id => $param{'article_id'})) {
            $id = $db->insert(
                'blog.article_comments',
                {
                    article_id => $param{'article_id'},
                    parent_id  => $param{'parent_id'},
                    name       => $param{'name'},
                    comment    => $param{'comment'},
                },
                {returning => 'id'},
            )->hash->{'id'};
        }

        $tx->commit;
    };

    return $id;
}

sub is_article_exists {
    my ($self, %param) = @_;

   return $self->pg->db->select(
        'blog.articles',
        ['id'],
        {id => $param{'article_id'}},
    )->hash->{'id'} ? 1 : 0;
}

1;

