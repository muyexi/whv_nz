# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'whv_nz/version'

Gem::Specification.new do |spec|
  spec.name          = "whv_nz"
  spec.version       = WhvNz::VERSION
  spec.authors       = ["muyexi"]
  spec.email         = ["muyexi@gmail.com"]

  spec.summary       = %q{Ruby script to apply for Working Holiday Visa from New Zeanland.}
  spec.homepage      = "https://github.com/muyexi/whv_nz"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'pry'
  
  spec.add_dependency 'activesupport'
  spec.add_dependency 'faraday', '~> 0.11.0'
  spec.add_dependency 'slop'
  spec.add_dependency 'selenium-webdriver', '~> 3.1'
  spec.add_dependency 'rollbar'
  spec.add_dependency 'sucker_punch', '~> 1.6'
  spec.add_dependency 'mailgun-ruby', '~> 1.1'
  spec.add_dependency 'faraday_middleware', '~> 0.10.0'
  spec.add_dependency 'nokogiri', '~> 1.6', '>= 1.6.8'
end
