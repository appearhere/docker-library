FROM ubuntu:18.04 AS builder
MAINTAINER tech@appearhere.co.uk

ENV LANG C.UTF-8

# skip installing gem documentation
RUN mkdir -p /usr/local/etc \
  && { \
  echo 'install: --no-document'; \
  echo 'update: --no-document'; \
  } >> /usr/local/etc/gemrc

ENV RUBY_MAJOR 2.5
ENV RUBY_VERSION 2.5.1
ENV RUBYGEMS_VERSION 2.7.7
ENV BUNDLER_VERSION 1.16.2

ENV RUBY_HOME /usr/local/ruby
ENV PATH $RUBY_HOME/bin:$PATH

RUN set -ex \
  \
  && runDeps=' \
    autoconf \
    bison \
    build-essential \
    cmake \
    dpkg-dev \
    git \
    libffi-dev \
    libgdbm-dev \
    libjemalloc-dev \
    libncurses5-dev \
    libreadline6-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    pkg-config \
    tzdata \
    zlib1g-dev \
  ' \
  && buildDeps=' \
    ruby \
    wget \
  ' \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $buildDeps $runDeps \
  && rm -rf /var/lib/apt/lists/* \
  \
  && mkdir -p $RUBY_HOME \
  && git clone git://github.com/rbenv/ruby-build.git /usr/src/ruby-build \
  && cd /usr/src/ruby-build \
  && RUBY_CONFIGURE_OPTS="--with-jemalloc" bin/ruby-build $RUBY_VERSION $RUBY_HOME \
  && rm -r /usr/src/ruby-build \
  \
  && apt-get purge -y --auto-remove $buildDeps \
  && cd / \
  \
  && gem update --system "$RUBYGEMS_VERSION" \
  && gem install bundler --version "$BUNDLER_VERSION" --force \
  && rm -r /root/.gem/

ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH
ENV MALLOC_ARENA_MAX=2

RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"

CMD [ "irb" ]
