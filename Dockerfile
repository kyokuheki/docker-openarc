FROM alpine:latest as builder
LABEL maintainer Kenzo Okuda <kyokuheki@gmail.comt>
ENV LANG="en_US.UTF-8"
    #VERSION="1-0-0-Beta3"

RUN set -x \
 && apk add --no-cache \
    autoconf \
    automake \
    build-base \
    curl \
    libbsd-dev \
    libmilter-dev \
    libtool \
    make \
    openssl \
    openssl-dev \
    pkgconfig

#ADD https://github.com/trusteddomainproject/OpenARC/archive/rel-openarc-1-0-0-Beta3.tar.gz /OpenARC
# && curl -sSL https://github.com/trusteddomainproject/OpenARC/archive/rel-openarc-${VERSION}.tar.gz | tar zxvf - -C /openarc --strip-components 1 \

RUN set -x \
 && mkdir /openarc \
 && curl -sSL https://github.com/trusteddomainproject/OpenARC/archive/develop.tar.gz | tar zxvf - -C /openarc --strip-components 1 \
 && cd /openarc \
 && autoreconf -fvi \
 && ./configure --prefix=/usr \
 && make install

FROM alpine:latest
LABEL maintainer Kenzo Okuda <kyokuheki@gmail.com>
ENV LANG="en_US.UTF-8"

COPY --from=builder /usr/sbin/openarc /usr/sbin/
COPY --from=builder /usr/lib/libopenarc.so.0 /usr/lib/
COPY --from=builder /usr/share/doc/openarc /usr/share/doc/

RUN set -x \
 && apk add --no-cache \
    libmilter

RUN set -x \
 && addgroup -g 101 -S opendkim \
 && adduser -h /run/opendkim -s /sbin/nologin -D -S -u 100 -g openarc -G opendkim opendkim \
 && addgroup opendkim mail

EXPOSE 8891/tcp
VOLUME ["/etc/openarc","/etc/dkimkeys"]

CMD set -x; \
    /usr/sbin/openarc -n -u opendkim -c /etc/openarc/openarc.conf \
 && /usr/sbin/openarc -p inet:8891@127.0.0.1 -u opendkim -A -f -vvvv -c /etc/openarc/openarc.conf
