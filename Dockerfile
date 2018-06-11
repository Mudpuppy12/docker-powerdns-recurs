FROM alpine
MAINTAINER Christoph Wiechert <wio@psitrax.de>

ENV REFRESHED_AT="2018-05-21" \
    POWERDNS_VERSION=4.1.3 

RUN apk --update add libpq libstdc++ libgcc boost lua-dev openssl-dev && \
    apk add --virtual build-deps \
      g++ make curl boost-dev && \
    curl -sSL https://downloads.powerdns.com/releases/pdns-recursor-$POWERDNS_VERSION.tar.bz2 | tar xj -C /tmp && \
    cd /tmp/pdns-recursor-$POWERDNS_VERSION && \
    ./configure --prefix="" --exec-prefix=/usr --sysconfdir=/etc/pdns && \
    make && make install-strip && cd / && \
    mkdir -p /etc/pdns/conf.d && \
    addgroup -S pdns 2>/dev/null && \
    adduser -S -D -H -h /var/empty -s /bin/false -G pdns -g pdns pdns 2>/dev/null && \
    apk del --purge build-deps && \
    rm -rf /tmp/pdns-recursor-$POWERDNS_VERSION /var/cache/apk/*

ADD entrypoint.sh /

ADD recursor.conf /etc/pdns/

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/entrypoint.sh"]
