# Copyright 2018 Comcast Cable Communications Management, LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'vinyldns/version'
require 'vinyldns/api'
module Vinyldns
  raise('You must have ENV[\'VINYLDNS_ACCESS_KEY_ID\'] set to use vinyldns-ruby') unless ENV['VINYLDNS_ACCESS_KEY_ID']
  raise('You must have ENV[\'VINYLDNS_SECRET_ACCESS_KEY\'] set to use vinyldns-ruby') unless ENV['VINYLDNS_SECRET_ACCESS_KEY']
  raise('You must have ENV[\'VINYLDNS_API_URL\'] set to use vinyldns-ruby') unless ENV['VINYLDNS_API_URL']
end
