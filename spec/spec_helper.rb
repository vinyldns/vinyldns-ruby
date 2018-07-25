# Copyright 2018 Comcast Cable Communications Management, LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'bundler/setup'
Bundler.setup
require 'pathname'
# require 'webmock/rspec'
require 'yaml'
SPEC_DIR = Pathname.new(__FILE__).dirname
MOCK_DIR = SPEC_DIR + 'mock_data'
require 'vinyldns/api'
# WebMock.enable!
# WebMock.disable_net_connect!
module Helpers end
RSpec.configure do |c|
  c.include Helpers
end
