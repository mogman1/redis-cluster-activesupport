# Redis cluster stores for ActiveSupport [![Build Status](https://travis-ci.org/film42/redis-cluster-activesupport.svg?branch=master)](https://travis-ci.org/film42/redis-cluster-activesupport)

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

Beginning in v0.4.0, all `::Redis::BaseErrors` are automatically caught and ignored _unless_ the `:raise_errors` 
configuration option is set. The `:ignored_command_errors` option no longer has any effect.  However, 
`redis-activesupport`'s `:error_handler` option is now available.  This allows you to set an error handler function with
a method signature of `(error:, method:, returning:)` where `error` is the error that was raised, `method` is the method
where the error happened, and `returning` is the default value that's going to get returned.  You can then use this
handler to still report the occurrence of the error, but without having your cache failure knock your app over.

```ruby
module MyProject
  class Application < Rails::Application
    config.cache_store = :redis_cluster_store, { :error_handler => -> (exception:, method:, returning:) { ::Rails.logger.warn("redis encountered `#{exception.class}: #{exception.message}` in #{method}, returned #{returning}")} }
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "redis-cluster-activesupport"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redis-cluster-activesupport

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/film42/redis-cluster-activesupport.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
