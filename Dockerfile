FROM alpine:3.4

ENV DIRPATH /usr/share/coding_test
ENV EV_EXTRA_DEFS -DEV_NO_ATFORK

COPY cpanfile /
RUN apk update && \
    apk add perl perl-io-socket-ssl perl-dbd-pg perl-dev g++ make wget curl && \
    curl -L https://cpanmin.us | perl - App::cpanminus && \
    cpanm --installdeps . -M https://cpan.metacpan.org && \
    apk del perl-dev g++ make wget curl && \
    rm -rf /root/.cpanm/* /usr/local/share/man/* && \
    rm -f cpanfile \

WORKDIR $DIRPATH

COPY rest_api.conf .
COPY rest_api.pl .
COPY lib/ lib/
COPY migrations/ migrations/

CMD ["perl", "rest_api.pl", "migrate"]
CMD ["perl", "rest_api.pl", "test"]

EXPOSE 8080
CMD ["perl", "rest_api.pl", "daemon", "-m", "production", "-l", "http://*:8080"]
