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

      def delete_matched(matcher, options = nil)
        fail NotImplementedError, "Deleting keys with a matcher is not supported with redis cluster"
      end

      def write_entry(key, entry, options)
        super
      rescue Redis::CommandError => error
        raise unless ignored_command_errors.include?(error.message)
        raise if raise_errors?
        false
      end

      def read_entry(key, options)
        super
      rescue Redis::CommandError => error
        raise unless ignored_command_errors.include?(error.message)
        raise if raise_errors?
        nil
      end

      def delete_entry(key, options)
        super
      rescue Redis::CommandError => error
        raise unless ignored_command_errors.include?(error.message)
        raise if raise_errors?
        false
      end
    end
  end
end
