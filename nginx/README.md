# Nginx

## Maintainers

The Habitat Maintainers humans@habitat.sh

## Type of Package

Service

## Usage

This plan is generally used with a web app that you want to be served over nginx.

You can use this plan by adding core/nginx to your package dependencies in your plan file:

```
pkg_deps=(
  core/nginx
)
```

Although there are defaults for configuration files, (check out [config/nginx.conf](./config/nginx.conf)) for an example, you can also customize them by adding your own template's to your application's config folder.

Let's say I have a custom package called "my_app_server" and I'm keeping all of my habitat files in a habitat directory within my_app_server's repo.

```
$ ls my_app_server
src/
habitat/
```

```
$ ls my_app_server/habitat
config/
plan.sh
```

To add in a custom nginx conf file, I would add the file to habitat/config/

```
$ touch my_app_server/habitat/config/nginx.conf
```

And then add in your custom conf template, i.e.

nginx.conf
```
daemon off;
pid {{ pkg.svc_var_path }}/pid;
worker_processes {{ cfg.worker_processes }};

events {
  worker_connections {{ cfg.events.worker_connections }};
}

http {
  client_body_temp_path {{ pkg.svc_var_path }}/client-body;
  fastcgi_temp_path {{ pkg.svc_var_path }}/fastcgi;
  proxy_temp_path {{ pkg.svc_var_path }}/proxy;
  scgi_temp_path {{ pkg.svc_var_path }}/scgi_temp_path;
  uwsgi_temp_path {{ pkg.svc_var_path }}/uwsgi;

  server {
    listen {{ cfg.http.server.listen }};
    root {{ cfg.http.server.root }};
    index {{ cfg.http.server.index }};
  }
}
```

For more information, check out the [Habitat documentation on configuration templates](https://www.habitat.sh/docs/developing-packages/#configuration-templates).

## Bindings

For more general information on binding Habitat services, check out [the official Habitat documentation](https://www.habitat.sh/docs/developing-packages/#runtime-binding)

Let's say we are still using the "my_app_server" package mentioned above.  Let's go ahead and run this package wherever you want to run it with:

```
$ hab start <origin>/my_app_server
```

And now let's say we want to bind a separate Habitat service to this running my_app_server service.  Perhaps we have a PHP app that we want to use this service.

Assuming I have also packaged my_php_app with Habitat, I would bind to the my_app_server service when I start my_php_app like this:

```
$ hab start <origin>/my_php_app --bind
```
