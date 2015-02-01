FROM ruby:2.2

ENV GINATRA_PORT 9797

RUN apt-get update \
  && apt-get install -y git cmake \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
COPY . /usr/src/app
RUN bundle install \
	&& apt-get purge -y --auto-remove cmake

EXPOSE 9797
CMD bundle exec puma --port $GINATRA_PORT ./config.ru
