package Blog::Controller::Articles;

use Mojo::Base 'Mojolicious::Controller';

sub all {
    my $self = shift;

    $self->render(json => $self->model_articles->all);
}

sub create {
    my $self = shift;

    my $article_name = $self->req->json->{'name'};

    my $article_id = $self->model_articles->create(
        name => $article_name,
    );

    $self->render(json => {id => $article_id}, status => 201);
}

1;

