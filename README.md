Redis cluster stores for ActiveSupport
======================================

This gem is an extension to [redis-activesupport](https://github.com/redis-store/redis-activesupport) that adds support
for a few features required to use `redis-store` with redis cluster. Right now there isn't an official redis cluster
client in ruby, so it's become common to use a redis cluster proxy like [corvus](https://github.com/eleme/corvus). When
switching there are a few things you can't do with redis cluster that you can do with a single redis server. Most of
them revolve around issuing commands with multiple keys. In redis cluster, your keys are partitioned and live on
different physical servers, operations like `KEYS` are not possible. Corvus will break apart `MSET` and `MGET` into
individual `GET` and `SET` commands automatically, but in general, it's not a good idea to use them.

## Usage

This gem is a small extension to `redis-activesupport`, so refer to their documentation for most configuration. Instead
of specifying `:redis_store` you must now specify `:redis_cluster_store` to load this extension.

```ruby
module MyProject
  class Application < Rails::Application
    config.cache_store = :redis_cluster_store, options
  end
end
```

Additionally, there's a new configuration option: `:ignored_command_errors`. This is useful if you're using a redis
cluster proxy like corvus who will raise a `Redis::CommandError` with a message indicating the cluster is offline or
experiencing a partial outage. This extension allows you to whitelist certain `ignored_command_errors` that would
normally be raised by `redis-activesupport`. By default this gem whitelists the following errors:

```ruby
DEFAULT_IGNORED_COMMAND_ERRORS = ["ERR Proxy error"]
```

If you need additional errors added to the whitelist, you can do this through your own configuration or open a pull
request to add it to the default whitelist. NOTE: this list is turned into a `Set` to keep lookups fast, so feel free to
make this list as big as you need. Example:

```ruby
module MyProject
  class Application < Rails::Application
    config.cache_store = :redis_cluster_store, {:ignored_command_errors => ["Uh oh", "Please, stop", "Fire emoji"]}
  end
end
```

With this change, your cache store will now silently fail once again so a redis cluster won't knock your rails apps
offline.


## Installation

Add this line to your application's Gemfile:

```ruby
gem "redis-activesupport-cluster"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redis-activesupport-cluster

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/film42/redis-activesupport-cluster.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
