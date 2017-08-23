package Blog::Controller::Article;

use Mojo::Base 'Mojolicious::Controller';

sub get {
    my $self = shift;

    my $article_id = $self->param('article_id');

    my $article = $self->model_article->get(id => $article_id);

    return $self->reply->not_found unless $article;

    $self->render(json => $article);
}

sub update {
    my $self = shift;

    my $article_id   = $self->param('article_id');
    my $article_name = $self->req->json->{'name'};

    $article_id = $self->model_article->update(
        id   => $article_id,
        name => $article_name,
    );

    return $self->reply->not_found unless $article_id;

    $self->render(json => {});
}

sub delete {
    my $self = shift;

    my $article_id = $self->param('article_id');

    $article_id = $self->model_article->delete(id => $article_id);

    return $self->reply->not_found unless $article_id;

    $self->render(json => {});
}

sub create_comment {
    my $self = shift;

    my %param;
    {
        my $json = $self->req->json;

        %param = (
            article_id => $self->param('article_id'),
            parent_id  => $json->{'parent_id'},
            name       => $json->{'name'},
            comment    => $json->{'comment'},
        );
    }

    my $comment_id = $self->model_articlecomments->create(%param);

    return $self->reply->not_found unless $comment_id;

    $self->render(json => {id => $comment_id}, status => 201);
}

sub all_comments {
    my $self = shift;

    my $article_id = $self->param('article_id');

    my $comments = $self->model_articlecomments->all(
        article_id => $article_id,
    );

    return $self->reply->not_found unless $comments;

    $self->render(json => $comments);
}

sub all_comments_as_tree {
    my $self = shift;

    my $article_id = $self->param('article_id');

    my $comments = $self->model_articlecomments->all_as_tree(
        article_id => $article_id,
    );

    return $self->reply->not_found unless $comments;

    $self->render(json => $comments);
}

1;

