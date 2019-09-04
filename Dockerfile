
# ---- Build Stage ----
FROM elixir:1.9.1 AS app_builder
COPY . .
RUN export MIX_ENV=prod && \
	mix local.hex --force && \
	mix local.rebar --force && \
	mix release.init && \
    rm -Rf _build && \
    mix deps.get && \
    mix deps.compile && \
    mix phx.digest && \
    mix release && \
    cat mix.exs | grep app: | sed -e 's/ app: ://' | tr ',' ' ' | sed 's/ //g' > app_name.txt
RUN cat app_name.txt
# ---- Release Stage ----
FROM debian:stretch AS app
EXPOSE 4000
ENV LANG=C.UTF-8
RUN apt-get update && apt-get install -y openssl
RUN useradd --create-home app
COPY --from=app_builder ./_build .
COPY --from=app_builder ./app_name.txt ./app_name.txt
RUN chown -R app: ./prod
CMD ["sh","-c","./prod/rel/$(cat ./app_name.txt)/bin/$(cat ./app_name.txt) start"]