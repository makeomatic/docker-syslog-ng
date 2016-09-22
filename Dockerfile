FROM alpine:3.3

ENV SYSLOG_VERSION=3.8.1
ENV DOWNLOAD_URL="https://github.com/balabit/syslog-ng/releases/download/syslog-ng-${SYSLOG_VERSION}/syslog-ng-${SYSLOG_VERSION}.tar.gz"

# Configuration options here:
# https://github.com/balabit/syslog-ng/blob/master/configure.ac

RUN \
  apk --no-cache add \
    glib \
    pcre \
    libeventlog \
    openssl \
    json-c \
  && apk --no-cache add --virtual .devDeps \
    curl \
    alpine-sdk \
    glib-dev \
    pcre-dev \
    openssl-dev \
    libeventlog-dev \
    json-c-dev \
  && cd /tmp \
  && curl -L "${DOWNLOAD_URL}" > "syslog-ng-${SYSLOG_VERSION}.tar.gz" \
  && tar zxf "syslog-ng-${SYSLOG_VERSION}.tar.gz" \
  && cd "syslog-ng-${SYSLOG_VERSION}" \
  && ./configure \
    --prefix=/usr \
    --enable-mongodb=no \
    --enable-json=yes \
    --with-mongoc=no \
    --enable-legacy-mongodb-options=no \
  && make \
  && make install \
  && cd .. \
  && rm -rf "syslog-ng-${SYSLOG_VERSION}" "syslog-ng-${SYSLOG_VERSION}.tar.gz" \
  && apk del .devDeps

COPY root/ /

VOLUME ["/var/log/syslog-ng", "/var/run/syslog-ng"]

EXPOSE 514/tcp 514/udp

CMD ["/usr/sbin/syslog-ng", "-F", "-f", "/etc/syslog-ng/syslog-ng.conf"]
