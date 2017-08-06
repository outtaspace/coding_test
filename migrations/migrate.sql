-- 1 up
CREATE SCHEMA blog;
ALTER SCHEMA blog OWNER TO coding_test;

CREATE TABLE blog.articles (
    id integer NOT NULL,
    name character varying(255)
);
ALTER TABLE blog.articles OWNER TO coding_test;

CREATE SEQUENCE blog.articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE blog.articles_id_seq OWNER TO coding_test;

ALTER SEQUENCE blog.articles_id_seq OWNED BY blog.articles.id;
ALTER TABLE ONLY blog.articles ALTER COLUMN id SET DEFAULT nextval('blog.articles_id_seq'::regclass);
SELECT pg_catalog.setval('blog.articles_id_seq', 1, false);
ALTER TABLE ONLY blog.articles ADD CONSTRAINT articles_pkey PRIMARY KEY (id);

CREATE TABLE blog.article_comments (
    id integer NOT NULL,
    article_id integer NOT NULL,
    parent_id integer DEFAULT 0,
    name character varying(255) NOT NULL,
    comment text NOT NULL
);
ALTER TABLE blog.article_comments OWNER TO coding_test;

CREATE SEQUENCE blog.article_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE blog.article_comments_id_seq OWNER TO coding_test;

ALTER SEQUENCE blog.article_comments_id_seq OWNED BY blog.article_comments.id;
ALTER TABLE ONLY blog.article_comments ALTER COLUMN id SET DEFAULT nextval('blog.article_comments_id_seq'::regclass);
SELECT pg_catalog.setval('blog.article_comments_id_seq', 1, false);
ALTER TABLE ONLY blog.article_comments ADD CONSTRAINT article_comments_pkey PRIMARY KEY (id);

CREATE INDEX fki_articles_id_fk ON blog.article_comments USING btree (article_id);
ALTER TABLE ONLY blog.article_comments ADD CONSTRAINT articles_id_fk FOREIGN KEY (article_id) REFERENCES blog.articles(id) MATCH FULL ON DELETE CASCADE;

-- 1 down
DROP INDEX blog.fki_articles_id_fk;

ALTER TABLE ONLY blog.article_comments DROP CONSTRAINT article_comments_pkey;
ALTER TABLE blog.article_comments ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE blog.article_comments_id_seq;
DROP TABLE blog.article_comments;


ALTER TABLE ONLY blog.articles DROP CONSTRAINT articles_pkey;
ALTER TABLE blog.articles ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE blog.articles_id_seq;
DROP TABLE blog.articles;

DROP SCHEMA blog;

