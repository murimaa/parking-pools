FROM elixir:1.14.3-alpine AS build

# install build dependencies
RUN apk add --no-cache --update build-base git nodejs npm

# prepare build dir
WORKDIR /app
RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

# copy resources
COPY mix.exs mix.lock ./
COPY config config
COPY apps apps

RUN cd apps/parking_pool_web && mix setup 
RUN mix deps.get && \
    mix deps.compile

RUN cd apps/parking_pool_web && mix assets.deploy
RUN mix phx.digest && \
    mix compile && \
    mix release parking_pool_full


# runtime image
FROM alpine:3.16 AS app
RUN apk upgrade --no-cache && \
    apk add --no-cache openssl ncurses-libs libgcc libstdc++

WORKDIR /app

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/parking_pool_full ./

RUN chown nobody:nobody /app
USER nobody:nobody

ENTRYPOINT ["bin/parking_pool_full"]
CMD ["start"]
