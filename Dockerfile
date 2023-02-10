FROM elixir:1.14.3-alpine AS build

# install build dependencies
RUN apk add --no-cache --update build-base git nodejs npm

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
# compile and build release
COPY apps apps

RUN cd apps/parking_pool_web && mix setup
RUN mix deps.get && \
    mix deps.compile

RUN mix phx.digest && \
    mix compile && \
    mix release parking_pool_full


# prepare release image
FROM alpine:3.16 AS app
#RUN apk upgrade --no-cache && \
#    apk --no-cache add bash-5.1.16-r2 libgcc-11.2.1_git20220219-r2 \
#    libstdc++-11.2.1_git20220219-r2 ncurses-libs-6.3_p20220521-r0
#    #openssl=1.1.1k-r0
RUN apk upgrade --no-cache && \
    apk add --no-cache openssl ncurses-libs libgcc libstdc++


WORKDIR /app


COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/parking_pool_full ./


# change ownership
RUN chown nobody:nobody /app
USER nobody:nobody

ENTRYPOINT ["bin/parking_pool_full"]

# "start_iex" starts it in an IEx console
# which is handy if running locally.
# Normally we'd have "start" here.
# TODO: change to "start"
CMD ["start_iex"]
