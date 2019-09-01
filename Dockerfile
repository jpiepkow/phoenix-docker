# ---- Build Stage ----
FROM elixir:1.9.1 AS app_builder
ARG dir_name
ENV env_dir_name=$dir_name
RUN : "${dir_name?Need to set dir_name, this should be the directory name of your phoenix project.}"
COPY . .
RUN export MIX_ENV=prod && \
	mix local.hex --force && \
	mix local.rebar --force && \
	mix release.init && \
    rm -Rf _build && \
    mix deps.get && \
    mix deps.compile && \
    mix phx.digest && \
    mix release
# ---- Release Stage ----
FROM debian:stretch AS app
ARG dir_name
ENV env_dir_name=$dir_name
EXPOSE 4000
ENV LANG=C.UTF-8
RUN apt-get update && apt-get install -y openssl
RUN useradd --create-home app
COPY --from=app_builder ./_build .
RUN chown -R app: ./prod
CMD ["sh","-c","./prod/rel/${env_dir_name}/bin/${env_dir_name} start"]
