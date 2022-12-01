FROM docker.io/hexpm/elixir:1.13.4-erlang-24.3.4.5-alpine-3.15.6

ARG AKKOMA_VER=stable
ARG UID=911
ARG GID=911
ENV MIX_ENV=prod

RUN echo "http://nl.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories \
    && apk update \
    && apk add git gcc g++ musl-dev make cmake file-dev exiftool ffmpeg imagemagick libmagic ncurses postgresql-client

RUN addgroup -g ${GID} akkoma \
    && adduser -h /akkoma -s /bin/false -D -G akkoma -u ${UID} akkoma

ARG DATA=/var/lib/akkoma
RUN mkdir -p /etc/akkoma \
    && chown -R akkoma /etc/akkoma \
    && mkdir -p ${DATA}/uploads \
    && mkdir -p ${DATA}/static \
    && chown -R akkoma ${DATA}

USER akkoma
WORKDIR /akkoma

RUN git clone -b stable https://akkoma.dev/AkkomaGang/akkoma.git /akkoma \
    && git checkout ${AKKOMA_VER}

RUN echo "import Mix.Config" > config/prod.secret.exs \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get --only prod \
    && mkdir release \
    && mix release --path /akkoma

COPY ./config.exs /etc/akkoma/config.exs

EXPOSE 4000

ENTRYPOINT ["/akkoma/docker-entrypoint.sh"]
