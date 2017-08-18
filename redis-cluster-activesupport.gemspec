lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "redis-cluster-activesupport"
  spec.version       = "0.1.0"
  spec.authors       = ["Garrett Thornburg"]
  spec.email         = ["film42@gmail.com"]

  spec.summary       = "Add support for catch redis cluster proxy errors"
  spec.description   = "Add support for catch redis cluster proxy errors"
  spec.homepage      = "https://github.com/film42/redis-cluster-activesupport"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "redis-activesupport"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
