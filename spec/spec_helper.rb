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
module Helpers
  MAX_RETRIES = 30
  RETRY_WAIT = 0.05

  def wait_until_zone_active(zone_id)
    retries = MAX_RETRIES
    zone_request = Vinyldns::API::Zone.get(zone_id)
    while zone_request.class.name == ("Net::HTTPNotFound") && retries > 0
      zone_request = Vinyldns::API::Zone.get(zone_id)
      retries -= 1
      sleep(RETRY_WAIT)
    end
    zone_request
  end

  def wait_until_zone_deleted(zone_id)
    retries = MAX_RETRIES
    zone_request = Vinyldns::API::Zone.delete(zone_id)
    while zone_request.class.name != ("Net::HTTPNotFound") && retries > 0
      zone_request = Vinyldns::API::Zone.get(zone_id)
      retries -= 1
      sleep(RETRY_WAIT)
    end
    zone_request
  end

  def wait_until_recordset_active(zone_id, recordset_id)
    retries = MAX_RETRIES
    recordset_request = Vinyldns::API::Zone::RecordSet.get(zone_id, recordset_id)
    while recordset_request.class.name == ("Net::HTTPNotFound") && retries > 0
      recordset_request = Vinyldns::API::Zone::RecordSet.get(zone_id, recordset_id)
      retries -= 1
      sleep(RETRY_WAIT)
    end
    recordset_request
  end

  def wait_until_batch_change_completed(batch_change)
    change = batch_change
    retries = MAX_RETRIES
    while !['Complete', 'Failed', 'PartialFailure'].include?(change['status']) && retries > 0
      latest_change = Vinyldns::API::Zone::BatchRecordChanges.get(change['id'])
      if(latest_change.class.name != "Net::HTTPNotFound")
        change = latest_change
      end
      retries -= 1
      sleep(RETRY_WAIT)
    end
    return change
  end
end

RSpec.configure do |c|
  c.include Helpers
end
