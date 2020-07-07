FROM ruby:2.7.1
MAINTAINER yasslab

ENV LANG en_US.UTF-8

RUN mkdir /src
WORKDIR /src

RUN useradd -m --shell /bin/bash --uid 1000 ruby
RUN chown ruby:ruby /src

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  texlive-full \
  ttf-mscorefonts-installer \
  fonts-liberation \
  fonts-migmix \
  inkscape \
  zip \
  default-jre \
  epubcheck \
  calibre \
  nodejs \
  imagemagick \
  phantomjs \
  libcurl4-gnutls-dev

USER ruby
ENV BUNDLE_PATH vendor/bundle
