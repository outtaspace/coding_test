drop database if exists `coding_test`;
create database `coding_test` character set=utf8;

use `coding_test`;

create table `articles` (
    `id` integer not null auto_increment,
    `name` varchar(255) not null,
    primary key (`id`)
) engine=innodb default charset=utf8 row_format=compact;

create table `article_comments` (
    `id` integer not null auto_increment,
    `article_id` integer not null,
    `parent_id` integer null default null,
    `name` varchar(255) not null,
    `comment` text not null,
    primary key (`id`),
    index `article_id` (`article_id`)
) engine=innodb default charset=utf8 row_format=compact;

alter table coding_test.article_comments
add constraint `fk_comments_to_articles`
  foreign key (`article_id`)
  references coding_test.articles (`id`)
  on delete cascade
  on update no action;
