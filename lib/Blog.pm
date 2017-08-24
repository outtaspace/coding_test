package Blog;

use Mojo::Base 'Mojolicious';

use Mojo::Pg;
use Blog::Model::Articles;
use Blog::Model::Article;
use Blog::Model::ArticleComments;
use Blog::Model::ArticleComment;

sub startup {
    my $self = shift;

    $self->plugin('Config');

    $self->app->secrets($self->app->config->{'secrets'});

    $self->init_routes;
    $self->init_models;
}

sub init_routes {
    my $self = shift;

    my $r = $self->routes;

    # Blog::Controller::Articles
    $r->get('/blog/articles/')
        ->to('articles#all')
        ->name('get_all_articles');

    $r->post('/blog/articles/')
        ->to('articles#create')
        ->name('create_article');

    # Blog::Controller::Article
    $r->get('/blog/articles/:article_id/')
        ->to('article#get')
        ->name('get_article');

    $r->put('/blog/articles/:article_id/')
        ->to('article#update')
        ->name('update_article');

    $r->delete('/blog/articles/:article_id/')
        ->to('article#delete')
        ->name('delete_article');

    $r->post('/blog/articles/:article_id/comments/')
        ->to('article#create_comment')
        ->name('create_article_comment');

    $r->get('/blog/articles/:article_id/comments/')
        ->to('article#all_comments')
        ->name('get_all_article_comments');

    $r->get('/blog/articles/:article_id/comments/as_tree/')
        ->to('article#all_comments_as_tree')
        ->name('get_all_article_comments_as_tree');

    # Blog::Controller::ArticleComment
    $r->get('/blog/comments/:comment_id/')
        ->to('article_comment#get')
        ->name('get_article_comment');

    $r->put('/blog/comments/:comment_id/')
        ->to('article_comment#update')
        ->name('update_article_comment');

    $r->delete('/blog/comments/:comment_id/')
        ->to('article_comment#delete')
        ->name('delete_article_comment');
}

sub init_models {
    my $self = shift;

    state $pg = Mojo::Pg->new($self->app->config->{'pg_connection'});

    $self->helper(model_articles => sub {
        state $model_articles = Blog::Model::Articles->new(pg => $pg);
    });

    $self->helper(model_article => sub {
        state $model_article = Blog::Model::Article->new(pg => $pg);
    });

    $self->helper(model_articlecomments => sub {
        state $model_articlecomments = Blog::Model::ArticleComments->new(pg => $pg);
    });

    $self->helper(model_articlecomment => sub {
        state $model_articlecomment = Blog::Model::ArticleComment->new(pg => $pg);
    });
}

1;

