#Steps to run phx api in production.

1. run `mix phx.new APPNAME --no-html --no-webpack` (you can also use --no-ecto if it is a non database application, appname should be snakecase)
2. go comment out cache\_static\_manifest in /config/prod.exs
3. go uncomment config :saas\_kit\_auth, SaasKitAuthWeb.Endpoint, server: true in /config/prod.secret.exs
4. run `Touch Dockerfile` at the base of your phoenix project and copy the Dockerfile in this repo.
5. Replace any required ENV in prod.exs or prod.secret.exs with hardcoded value or alter Dockerfile to include these required ENV vars(SECRET_KEY_BASE and sometimes database information). Add release.exs for any runtime configs.
5. run `docker build --build-arg dir_name=(directory folder name of phx project) -t DOCKERNAME .` in base of phoenix project where DOCKERNAME is the name you want the image called.
6. run `docker container run -p 4000:4000 --rm -it DOCKERNAME` to run your image locally. You can change the port forward but 4000 is the default exposed by phoenix.
7. run `docker push DOCKERNAME` to push this image to docker hub so you can run the above command on other computers/servers and use it in compose.

### Things to note:
Your env you use in the first build step will not end up in the final build(they are just used to build the .tar)

This dockerfile needs expanded further if we want the runtime args to be set during the app start.
