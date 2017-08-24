package Blog::Test::Articles;

use Mojo::Base -base;

has 'app';

sub get_all_articles {
    my $self = shift;

    return $self->app->url_for('get_all_articles');
}

sub create_article {
    my $self = shift;

    return $self->app->url_for('create_article');
}

1;

