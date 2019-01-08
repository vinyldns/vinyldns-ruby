# Copyright 2018 Comcast Cable Communications Management, LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'spec_helper'
RSpec.describe Vinyldns::API do
  describe 'Generate Object (.new)' do
    it 'can generate object with argument (of any case)' do
      api_request_object = Vinyldns::API.new('gEt')
      expect { api_request_object }.to_not raise_error
    end
    it 'can not generate object with argument that is not a valid request method' do
      expect { Vinyldns::API.new('reload') }.to raise_error(ArgumentError, 'Not a valid http request method')
    end
    it 'can not generate object without argument' do
      expect { Vinyldns::API.new }.to raise_error(ArgumentError)
    end
    it 'can generate object with signer' do
      api_request_object = Vinyldns::API.new('pOSt')
      expect(api_request_object.signer).to_not be_nil
    end
  end

  describe 'Make Requests (.make_request)' do
    it 'can not make http request without arguments' do
      expect { Vinyldns::API.make_request }.to raise_error(ArgumentError)
    end
    it 'can make http request' do
      api_request_object = Vinyldns::API.new('GEt')
      # Requires you to have at least one zone for your user/group
      expect { Vinyldns::API.make_request(api_request_object, 'zones?maxItems=1') }.to_not raise_error
    end
    it 'can not make http request with bad uri' do
      api_request_object = Vinyldns::API.new('GEt')
      # Requires you to have at least one zone for your user/group
      expect(Vinyldns::API.make_request(api_request_object, 'maxItems=1').class.name).to eq('Net::HTTPUnauthorized')
    end

    describe 'Make Requests with ENV[\'VINYLDNS_VERIFY_SSL\']' do
      #TODO
    end

  end
end
