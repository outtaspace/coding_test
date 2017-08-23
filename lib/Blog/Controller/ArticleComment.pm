package Blog::Controller::ArticleComment;

use Mojo::Base 'Mojolicious::Controller';

sub get {
    my $self = shift;

    my $comment_id = $self->param('comment_id');

    my $comment = $self->model_articlecomment->get(id => $comment_id);

    return $self->reply->not_found unless $comment;

    $self->render(json => $comment);
}

sub update {
    my $self = shift;

    my %param;
    {
        my $json = $self->req->json;

        %param = (
            id      => $self->param('comment_id'),
            name    => $json->{'name'},
            comment => $json->{'comment'},
        );
    }

    my $comment_id = $self->model_articlecomment->update(%param);

    return $self->reply->not_found unless $comment_id;

    $self->render(json => {});
}

sub delete {
    my $self = shift;

    my $comment_id = $self->param('comment_id');

    $comment_id = $self->model_articlecomment->delete(id => $comment_id);

    return $self->reply->not_found unless $comment_id;

    $self->render(json => {});
}

1;

