FROM ruby:2.3
MAINTAINER yasslab

VOLUME /book
WORKDIR /book

RUN mkdir /texlive
COPY texlive.profile /texlive

RUN cd /texlive && \
    wget http://mirror.unl.edu/ctan/systems/texlive/tlnet/install-tl-unx.tar.gz && \
    tar xvf install-tl-unx.tar.gz && \
    cd install-tl* && \
    ./install-tl --profile /texlive/texlive.profile --repository http://mirror.ctan.org/systems/texlive/tlnet/
RUN /usr/local/texlive/2016/bin/x86_64-linux/tlmgr path add; exit 0

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update && apt-get install -y \
    inkscape \
    zip \
    default-jre \
    fontconfig \
    calibre-bin \
    nodejs \
    libopencv-dev \
    python-opencv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 | tar -jxf- -C /opt
RUN mkdir -p /opt/kindlegen && curl -sL http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz | tar -zxf- -C /opt/kindlegen

ENV PATH $PATH:/opt/phantomjs-2.1.1-linux-x86_64/bin:/opt/kindlegen

RUN gem install bundler epubcheck-ruby
