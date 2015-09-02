 # -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "deltacloud-client-vm"
  s.version     = '1.1.4.3'
  s.authors     = ["Jiri Kaipr"]
  s.email       = ["jiri.kaipr@gmail.com"]
  s.homepage    = "https://github.com/virtualmaster/virtualmaster-cli"
  s.summary     = %q{Virtualmaster version of deltacloud-client.}
  s.description = %q{Deltacloud API ruby client.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_dependency "faraday", "~> 0.9"
  s.add_dependency "minitest", "~> 5.8"
  s.add_dependency "nokogiri", "~> 1.6"
  s.add_dependency "pry", "~> 0.1"
  s.add_dependency "rake", "~> 10.1"
  s.add_dependency "simplecov", "~> 0.1"
  s.add_dependency "vcr", "~> 2.9"
end
