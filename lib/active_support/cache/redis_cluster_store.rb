require "redis-activesupport"
require "set"

module ActiveSupport
  module Cache
    class RedisClusterStore < RedisStore
      attr_reader :ignored_command_errors

      DEFAULT_IGNORED_COMMAND_ERRORS = ["ERR Proxy error"].freeze

      def initialize(*)
        super
        @ignored_command_errors = ::Set.new(@options.fetch(:ignored_command_errors, DEFAULT_IGNORED_COMMAND_ERRORS))
      end

      def delete_entry(key, options)
        super
      rescue Redis::CommandError => error
        raise unless ignored_command_errors.include?(error.message)
        raise if raise_errors?
        false
      end

      def delete_matched(matcher, options = nil)
        fail ::NotImplementedError, "Deleting keys with a matcher is not supported with redis cluster"
      end

      def fetch_multi(*names)
        fail ::NotImplementedError, "The default implementation uses MULTI which isn't supported. This can be changed to use MSET and work."
      end

      def increment(key, amount = 1, options = {})
        options = merged_options(options)
        expires_in = options[:expires_in]
        normalized_key = normalize_key(key, options)
        instrument(:increment, key, :amount => amount) do
          with { |c|
            if expires_in
              c.pipelined do
                c.incrby normalized_key, amount
                c.expire normalized_key expires_in 
              end
            else
              c.incrby normalized_key, amount
            end
          }
        end
      end

      def read_entry(key, options)
        super
      rescue Redis::CommandError => error
        raise unless ignored_command_errors.include?(error.message)
        raise if raise_errors?
        nil
      end

      def write_entry(key, entry, options)
        super
      rescue Redis::CommandError => error
        raise unless ignored_command_errors.include?(error.message)
        raise if raise_errors?
        false
      end
    end
  end
end
