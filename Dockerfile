FROM alpine:3.4

ENV DIRPATH /usr/share/coding_test

COPY cpanfile /
RUN apk update && \
    apk add perl perl-io-socket-ssl perl-dbd-pg perl-dev g++ make wget curl && \
    curl -L https://cpanmin.us | perl - App::cpanminus && \
    cpanm --installdeps . -M https://cpan.metacpan.org && \
    apk del perl-dev g++ make wget curl && \
    rm -rf /root/.cpanm/* /usr/local/share/man/* && \
    rm -f cpanfile

WORKDIR $DIRPATH

ADD lib/ lib/
ADD migrations/ migrations/
ADD t/ t/
ADD rest_api.production.conf rest_api.conf
ADD rest_api.pl .

ENV MOJO_MIGRATIONS_DEBUG 1
ENV MOJO_REVERSE_PROXY 1
ENV MOJO_MODE production

CMD ["perl", "rest_api.pl", "migrate"]
CMD ["perl", "rest_api.pl", "test"]

EXPOSE 8080
ENTRYPOINT ["perl", "rest_api.pl", "prefork", "-l", "http://*:8080"]
