# Redis cluster stores for ActiveSupport [![Build Status](https://travis-ci.org/film42/redis-cluster-activesupport.svg?branch=master)](https://travis-ci.org/film42/redis-cluster-activesupport)

This gem was an extension to [redis-activesupport](https://github.com/redis-store/redis-activesupport) that adds support
for a few features required to use `redis-store` with redis cluster. Right now there isn't an official redis cluster
client in ruby, so it's become common to use a redis cluster proxy like [corvus](https://github.com/eleme/corvus) or Envoy. When
switching there are a few things you can't do with redis cluster that you can do with a single redis server. Most of
them revolve around issuing commands with multiple keys. In redis cluster, your keys are partitioned and live on
different physical servers, operations like `KEYS` are not possible.

This is now leveraging Rails 6's built-in redis cache store with troubled commands removed.

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
