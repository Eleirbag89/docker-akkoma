FROM docker.io/hexpm/elixir:1.13.4-erlang-24.3.4.5-alpine-3.15.6

ENV MIX_ENV=prod

ARG HOME=/opt/akkoma

RUN apk add git gcc g++ musl-dev make cmake file-dev exiftool ffmpeg imagemagick libmagic ncurses postgresql-client

EXPOSE 4000

ARG UID=1000
ARG GID=1000
ARG UNAME=akkoma

RUN addgroup -g $GID $UNAME
RUN adduser -u $UID -G $UNAME -D -h $HOME $UNAME

WORKDIR /opt/akkoma

USER $UNAME
RUN echo "import Mix.Config" > config/prod.secret.exs \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get --only prod \

ENTRYPOINT ["/opt/akkoma/docker-entrypoint.sh"]
