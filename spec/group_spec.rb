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

describe Vinyldns::API::Group do

  let(:first_group) do
    # A group is expected to exist for now
    Vinyldns::API::Group.list_my_groups['groups'].first
  end

  describe '.create' do
    it 'can POST & receives 409 Conflict connecting to an already existing group' do
      expect(Vinyldns::API::Group.create(first_group['name'], first_group['email'], first_group['members'], first_group['admins']).class.name).to eq('Net::HTTPConflict')
    end
  end
  describe '.update' do
    it 'can PUT & receives 400 Bad Request with "Missing Group"' do
      expect(Vinyldns::API::Group.update(first_group['id'], { email: first_group['email'] }).body).to include('Missing Group')
    end
    it 'raises error when request_params argument is not hash' do
      expect { Vinyldns::API::Group.update('', 'testing') }.to raise_error(ArgumentError, 'Request Parameters must be a Hash')
    end
  end
  describe '.get' do
    it 'does not raise an error' do
      expect { Vinyldns::API::Group.get(first_group['id']) }.to_not raise_error
    end
  end
  describe '.list_my_groups' do
    it 'does not raise an error' do
      expect { Vinyldns::API::Group.list_my_groups }.to_not raise_error
    end
    it 'returns something' do
      expect(Vinyldns::API::Group.list_my_groups['groups'].any?).to be_truthy
    end
  end

  describe '.list_group_admins' do
    it 'does not raise an error' do
      expect { Vinyldns::API::Group.list_group_admins(first_group['id']) }.to_not raise_error
    end
  end

  describe '.list_group_members' do
    it 'does not raise an error' do
      expect { Vinyldns::API::Group.list_group_members(first_group['id']) }.to_not raise_error
    end
  end

  describe '.get_group_activity' do
    it 'does not raise an error' do
      expect { Vinyldns::API::Group.get_group_activity(first_group['id']) }.to_not raise_error
    end
  end
end
