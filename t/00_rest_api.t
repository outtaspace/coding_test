#!/usr/bin/perl

use Mojo::Base -strict;
use Test::Mojo;
use Test::More;
use FindBin;
use Storable qw(dclone);

require $FindBin::Bin .'/../rest_api.pl';

my $t = Test::Mojo->new;

#########################################################################################
## /article/comments ####################################################################
{
    my $form_hashref = {article_id => 1};

    $t->get_ok('/article/comments' => form => $form_hashref)
        ->status_is(200)
        ->json_is('/status' => 200)
        ->json_is('/comments' => []);

    my $make_some_bad_decisions = sub {
        my $callback = shift;

        my $bad_form_hashref = $callback->(dclone $form_hashref);

        $t->get_ok('/article/comments' => form => $bad_form_hashref)
            ->status_is(422)
            ->json_is('/status' => 422);
    };

    $make_some_bad_decisions->(sub {
        my $hashref = shift;
        delete $hashref->{'article_id'};
        return $hashref;
    });
    $make_some_bad_decisions->(sub {
        my $hashref = shift;
        $hashref->{'article_id'} = 'string';
        return $hashref;
    });
}


#########################################################################################
## /article/comment/create ##############################################################
{
    my $form_hashref = {
        article_id => 1,
        user_id    => 1,
        comment    => 'Hello!',
    };

    $t->post_ok('/article/comment/create' => form => $form_hashref)
        ->status_is(200)
        ->json_is('/status' => 200)
        ->json_like('/comment_id' => qr{^\d+$}x);

    my $make_some_bad_decisions = sub {
        my $callback = shift;

        my $bad_form_hashref = $callback->(dclone $form_hashref);

        $t->post_ok('/article/comment/create' => form => $bad_form_hashref)
            ->status_is(422)
            ->json_is('/status' => 422);
    };

    $make_some_bad_decisions->(sub {
        my $hashref = shift;
        delete $hashref->{'article_id'};
        return $hashref;
    });
    $make_some_bad_decisions->(sub {
        my $hashref = shift;
        $hashref->{'article_id'} = 'string';
        return $hashref;
    });

    $make_some_bad_decisions->(sub {
        my $hashref = shift;
        delete $hashref->{'user_id'};
        return $hashref;
    });
    $make_some_bad_decisions->(sub {
        my $hashref = shift;
        $hashref->{'user_id'} = 'string';
        return $hashref;
    });

    $make_some_bad_decisions->(sub {
        my $hashref = shift;
        delete $hashref->{'comment'};
        return $hashref;
    });

    $make_some_bad_decisions->(sub {
        my $hashref = shift;
        $hashref->{'parent_id'} = 'string';
        return $hashref;
    });
}


#########################################################################################
## /article/comment/delete ##############################################################
{
    my $form_hashref = {id => 100500};

    $t->post_ok('/article/comment/delete' => form => $form_hashref)
        ->status_is(200)
        ->json_is('/status' => 200);

    my $make_some_bad_decisions = sub {
        my $callback = shift;

        my $bad_form_hashref = $callback->(dclone $form_hashref);

        $t->post_ok('/article/comment/delete' => form => $bad_form_hashref)
            ->status_is(422)
            ->json_is('/status' => 422)
    };

    $make_some_bad_decisions->(sub {
        my $hashref = shift;
        delete $hashref->{'id'};
        return $hashref;
    });
    $make_some_bad_decisions->(sub {
        my $hashref = shift;
        $hashref->{'id'} = 'string';
        return $hashref;
    });
}

done_testing();

