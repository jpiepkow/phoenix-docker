# ---- Build Base Stage ----
FROM elixir:1.9.1-alpine AS app_builder
RUN apk add --no-cache=true \
	gcc \
	g++ \
	git \
	make \
	musl-dev
RUN mix do local.hex --force, local.rebar --force	

# ---- Build Deps Stage ----
FROM app_builder as deps
COPY mix.exs mix.lock ./
ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV
RUN mix do deps.get --only=$MIX_ENV, deps.compile

# ---- Build Release Stage ----
FROM deps as releaser
RUN echo $MIX_ENV
COPY config ./config
COPY lib ./lib
COPY priv ./priv
RUN mix release && \
    cat mix.exs | grep app: | sed -e 's/ app: ://' | tr ',' ' ' | sed 's/ //g' > app_name.txt

# ---- Final Image Stage ----
FROM alpine:3.9 as app
RUN apk add --no-cache bash libstdc++ openssl
ENV CMD=start
EXPOSE 4000
COPY --from=releaser ./_build .
COPY --from=releaser ./app_name.txt ./app_name.txt
CMD ["sh","-c","./prod/rel/$(cat ./app_name.txt)/bin/$(cat ./app_name.txt) $CMD"]
