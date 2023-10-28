require "active_support" # needed for rails 7.1
require "active_support/core_ext/integer" # needed for rails 7.1
require "bundler/setup"
require "pry"
require "redis/cluster/activesupport"
require "fakeredis/rspec"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
