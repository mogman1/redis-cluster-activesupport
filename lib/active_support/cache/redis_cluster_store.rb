require "active_support/core_ext/hash" # needed for redis-activesupport in rails 7.1
require "redis-activesupport"
require "set"

module ActiveSupport
  module Cache
    class RedisClusterStore < RedisStore
      # method signature overridden slightly to support MRI >= 3.0 / JRuby >= 9.4 and Rails < 6.0
      def delete_entry(key, options = {})
        super(key, **options)
      end

      def delete_matched(matcher, options = nil)
        fail ::NotImplementedError, "Deleting keys with a matcher is not supported with redis cluster"
      end

      def fetch_multi(*names)
        fail ::NotImplementedError, "The default implementation uses MULTI which isn't supported. This can be changed to use MSET and work."
      end

      def increment(key, amount = 1, options = {})
        options = merged_options(options)
        ttl = _expires_in(options)
        normalized_key = normalize_key(key, options)
        instrument(:increment, key, :amount => amount) do
          failsafe :increment do
            with do |c|
              if ttl
                new_value, _ = c.pipelined do
                  c.incrby normalized_key, amount
                  c.expire normalized_key, ttl
                end
                new_value
              else
                c.incrby normalized_key, amount
              end
            end
          end
        end
      end

      # method signature overridden slightly to support MRI 3+ and Rails = 6.0
      def read_entry(key, options = {})
        super
      end

      private

      def _expires_in(options)
        if options
          # Rack::Session           Merb                    Rails/Sinatra
          options[:expire_after] || options[:expires_in] || options[:expire_in]
        end
      end

      # Overrides failsafe method in v5.3.0 of redis-activesupport to instead rescue from the broader BaseError all
      # Redis errors inherit from.  This is in line with how Rails handles Redis failures in the implementation of their
      # Redis cache.
      # @see https://github.com/redis-store/redis-activesupport/blob/v5.3.0/lib/active_support/cache/redis_store.rb#L339-L345
      # @see https://github.com/rails/rails/blob/v6.0.6.1/activesupport/lib/active_support/cache/redis_cache_store.rb#L477-L482
      # @see https://github.com/redis/redis-rb/blob/v4.8.1/lib/redis/errors.rb#L4-L6
      def failsafe(method, returning: nil)
        yield
      rescue ::Redis::BaseError => e
        raise if raise_errors?
        handle_exception(exception: e, method: method, returning: returning)
        returning
      end
    end
  end
end
