lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "redis-cluster-activesupport"
  spec.version       = "0.3.0"
  spec.authors       = ["Garrett Thornburg"]
  spec.email         = ["film42@gmail.com"]

  spec.summary       = "Extension to redis-activesupport for working with redis cluster"
  spec.description   = "Extension to redis-activesupport for working with redis cluster"
  spec.homepage      = "https://github.com/film42/redis-cluster-activesupport"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # 7.2 drops support for cache_format_version 6.1, test when 7.2 is released
  spec.add_dependency "activesupport", ">= 4.2", "< 7.2"
  spec.add_dependency "redis-activesupport", "~> 5.3"
  spec.add_development_dependency "fakeredis"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
