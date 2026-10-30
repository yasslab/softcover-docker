# softcover で電子書籍を作るためのイメージ
# 公式の softcover/softcover（Debian 9・TeX Live 2016・Ruby 2.6）に、Ruby 3.3 を足したもの。
# OS と TeX を変えないので、作られる PDF・EPUB・HTML は元のイメージと同じになる。
# 元のイメージは 2020 年から更新が無いので、digest で固定する。
FROM softcover/softcover:latest@sha256:91548db9cf0268ba69db3b8e77837308bd2c6c3fd5a3a98f000040ebee8ae822

LABEL org.opencontainers.image.source="https://github.com/yasslab/softcover-docker"

# Ruby はソースから組む。tarball は https://www.ruby-lang.org/ja/downloads/releases/ の sha256 で照合する
ARG RUBY_VERSION=3.3.13
ARG RUBY_SHA256=4cae72e971bd1cdb20ca87d299111182417c5276c162de8ead0ab0531426cd61
# 開発用のライブラリ（libssl・libyaml など）は元のイメージに入っているので、apt は使わない
RUN cd /tmp \
  && curl -fsSLO "https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%.*}/ruby-${RUBY_VERSION}.tar.gz" \
  && echo "${RUBY_SHA256}  ruby-${RUBY_VERSION}.tar.gz" | sha256sum -c - \
  && tar -xzf "ruby-${RUBY_VERSION}.tar.gz" \
  && cd "ruby-${RUBY_VERSION}" \
  && ./configure --prefix=/opt/ruby --disable-install-doc \
  && make -j"$(nproc)" \
  && make install \
  && cd / && rm -rf /tmp/ruby-* \
  && mkdir -p /opt/ruby-gems && chown circleci:circleci /opt/ruby-gems \
  && /opt/ruby/bin/ruby -ropenssl -e 'puts OpenSSL::OPENSSL_LIBRARY_VERSION'

# 元の Ruby 2.6 の gem の置き場（/usr/local/bundle）と混ざらないようにする
ENV PATH=/opt/ruby/bin:$PATH \
    GEM_HOME=/opt/ruby-gems \
    BUNDLE_PATH= \
    BUNDLE_APP_CONFIG=/opt/ruby-gems/.bundle

# softcover 1.6 系が使う古い C 拡張は、Ruby 3.3 が付ける -Werror=... で組めないので、警告に戻す。
# nokogiri 1.10 は元のイメージの libxml2 を使う（同梱の libxml2 を組む途中で、Ruby 3.1 で外れた net/ftp を読むため）
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1 \
    BUNDLE_BUILD__CURB="--with-cflags=-Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=int-conversion" \
    BUNDLE_BUILD__EVENTMACHINE="--with-cflags=-Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=int-conversion" \
    BUNDLE_BUILD__JSON="--with-cflags=-Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=int-conversion" \
    BUNDLE_BUILD__MSGPACK="--with-cflags=-Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=int-conversion" \
    BUNDLE_BUILD__THIN="--with-cflags=-Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=int-conversion" \
    BUNDLE_BUILD__BYEBUG="--with-cflags=-Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=int-conversion" \
    BUNDLE_BUILD__NOKOGIRI="--use-system-libraries --with-cflags=-Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=int-conversion"
