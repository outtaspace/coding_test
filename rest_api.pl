#!/usr/bin/perl

use Mojolicious::Lite;

get '/article/comments' => sub {
    my $self = shift;

    {
        my $validation = $self->validation;
        $validation->required('article_id')->like(qr{^\d+$}x);

        return $self->render(json => {status => 422}, status => 422)
            if $validation->has_error;
    }

    $self->render(json => {status => 200});
};

post '/article/comment/create' => sub {
    my $self = shift;

    {
        my $validation = $self->validation;
        $validation->required('article_id')->like(qr{^\d+$}x);
        $validation->required('user_id')->like(qr{^\d+$}x);
        $validation->required('comment');

        return $self->render(json => {status => 422}, status => 422)
            if $validation->has_error;
    }

    $self->render(json => {status => 200, comment_id => int(rand 100500)});
};

post '/article/comment/delete' => sub {
    my $self = shift;

    {
        my $validation = $self->validation;
        $validation->required('id')->like(qr{^\d+$}x);

        return $self->render(json => {status => 422}, status => 422)
            if $validation->has_error;
    }

    $self->render(json => {status => 200});
};

app->start;

__END__

Run all tests with the command:
$ ./rest_api.pl test

