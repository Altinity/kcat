FROM alpine:3.16.2

COPY . /usr/src/kcat

ENV BUILD_DEPS bash make gcc g++ cmake curl pkgconfig python3 perl bsd-compat-headers zlib-dev zstd-dev zstd-libs lz4-dev openssl-dev curl-dev tar gzip

ENV RUN_DEPS libcurl lz4-libs zstd-libs ca-certificates

# Kerberos requires a default realm to be set in krb5.conf, which we can't
# do for obvious reasons. So skip it for now.
#ENV BUILD_DEPS_EXTRA cyrus-sasl-dev
#ENV RUN_DEPS_EXTRA libsasl heimdal-libs krb5

RUN echo Installing ; \
  apk add --no-cache --virtual .dev_pkgs $BUILD_DEPS $BUILD_DEPS_EXTRA && ln -sf python3 /usr/bin/python &&\
  apk add --no-cache $RUN_DEPS $RUN_DEPS_EXTRA && \
  echo Building && \
  cd /usr/src/kcat && \
  rm -rf tmp-bootstrap && \
  echo "Source versions:" && \
  grep ^github_download ./bootstrap.sh && \
  ./bootstrap.sh --no-install-deps --no-enable-static && \
  mv kcat /usr/bin/ && \
  echo Cleaning up && \
  cd / && \
  rm -rf /usr/src/kcat && \
  apk del .dev_pkgs && \
  rm -rf /var/cache/apk/*

RUN kcat -V

ENTRYPOINT ["kcat"]
