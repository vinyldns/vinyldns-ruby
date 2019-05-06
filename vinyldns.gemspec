# Copyright 2018 Comcast Cable Communications Management, LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -*- encoding: utf-8 -*-

lib = File.expand_path('lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vinyldns/version'
Gem::Specification.new do |gem|
  gem.name          = 'vinyldns-ruby'
  gem.version       = Vinyldns::VERSION
  gem.summary       = 'Ruby gem for VinylDNS'
  gem.description   = 'Ruby gem containing methods to perform various API requests in VinylDNS'
  gem.authors       = ['Nathan Pierce']
  gem.email         = 'nathan_pierce@comcast.com'
  gem.homepage      = 'https://github.com/vinyldns/vinyldns-ruby'
  gem.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  gem.licenses      = ['Apache-2.0']

  # `git submodule --quiet foreach --recursive pwd`.split($/).each do |submodule|
  #   submodule.sub!("#{Dir.pwd}/",'')
  #   Dir.chdir(submodule) do
  #     `git ls-files`.split($/).map do |subpath|
  #       gem.files << File.join(submodule,subpath)
  #     end
  #   end
  # end
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.require_paths = ['lib']
  gem.add_runtime_dependency 'aws-sigv4', '~> 1.0'
  gem.add_development_dependency 'bundler', '~> 1.13'
  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'rspec', '3.7.0'
  gem.add_development_dependency 'rb-readline', '~> 0.5.5'
  gem.add_development_dependency 'pry', '~> 0.10.3'
  # Dependencies
  # Licensed uses the the libgit2 bindings for Ruby provided by rugged. rugged has its own dependencies - cmake and pkg-config - which you may need to install before you can install Licensed.
  # For example, on macOS with Homebrew: brew install cmake pkg-config and on Ubuntu: apt-get install cmake pkg-config.
  gem.add_development_dependency 'licensed', '1.5.2'
end
