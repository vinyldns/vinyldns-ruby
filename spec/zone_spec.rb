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
RSpec.describe Vinyldns::API::Zone do
  before(:all) do
    Vinyldns::API::Group.create("test-group", "foo@bar.com", [], [], "description")
  end

  let!(:first_group) do
    Vinyldns::API::Group.list_my_groups["groups"].find do |group|
      group["name"] == "test-group"
    end
  end

  after(:each) do
    Vinyldns::API::Zone.search["zones"].each do |zone|
      Vinyldns::API::Zone.delete(zone["id"])
      wait_until_zone_deleted(zone["id"])
    end
  end

  after(:all) do
    Vinyldns::API::Group.list_my_groups["groups"].each do |group|
      Vinyldns::API::Group.delete(group["id"])
    end
  end

  describe '.connect' do
    it 'can POST & connect to a zone' do
      connection = Vinyldns::API::Zone.connect('ok', first_group['email'], first_group['id'], isTest: true)
      wait_until_zone_active(connection['zone']['id'])
      expect(connection['status']).to eq('Pending')
    end
    it 'can POST & receives 409 Conflict connecting to an already existing zone' do
      connection = Vinyldns::API::Zone.connect('ok', first_group['email'], first_group['id'], isTest: true)
      wait_until_zone_active(connection['zone']['id'])
      expect(Vinyldns::API::Zone.connect('ok', first_group['email'], first_group['id']).class.name).to eq('Net::HTTPConflict')
    end
    it 'raises error when group_id AND group_name_filter are nil arguments' do
      expect { Vinyldns::API::Zone.connect('dummy', first_group['email']) }.to raise_error(ArgumentError)
    end
    it 'raises error when Group.search is used and group_name doesn\'t find anything' do
      expect { Vinyldns::API::Zone.connect('dummy', first_group['email'], nil, 'test09999999').message }.to raise_error(ArgumentError, 'No group found for your group_name_filter. Please re-check the spelling so it\'s exact.')
    end
  end
  describe '.update' do
    it 'can PUT & receives 400 Bad Request with "Missing Zone.name"' do
      connection = Vinyldns::API::Zone.connect('ok', first_group['email'], first_group['id'], isTest: true)
      expect(Vinyldns::API::Zone.update(connection['zone']['id'], { email: 'new-email' }).body).to include('Missing Zone')
    end
    it 'raises error when request_params argument is not hash' do
      expect { Vinyldns::API::Zone.update('', 'testing') }.to raise_error(ArgumentError, 'Request Parameters must be a Hash')
    end
  end
  describe '.get' do
    it 'does not raise an error' do
      connection = Vinyldns::API::Zone.connect('ok', first_group['email'], first_group['id'], isTest: true)
      request = wait_until_zone_active(connection['zone']['id'])
      expect(Vinyldns::API::Zone.get(request['zone']['id']).class.name).to eq('Hash')
    end
  end
  describe '.search' do
    it 'returns zones' do
      connection = Vinyldns::API::Zone.connect('ok', first_group['email'], first_group['id'], isTest: true)
      request = wait_until_zone_active(connection['zone']['id'])
      expect(Vinyldns::API::Zone.search["zones"].length).to eq(1)
    end
  end

  # Sync is left out due to complexity of replies
  # describe '.sync' do
  #   it "syncs" do
  #     # Grab the first zone in users zone listing
  #     p Vinyldns::API::Zone.sync(@first_zone['id']).body
  #     expect()Vinyldns::API::Zone.sync(@first_zone['id']).body).to include('was recently synced')
  #   end
  # end

  # describe '.history' do
  #   it "does not raise an error" do
  #     # Attempt to post it
  #     expect {Vinyldns::API::Zone.history(@first_zone['id'])}.to_not raise_error
  #   end
  # end

  # describe '.list_changes' do
  #   it 'does not raise an error' do
  #     expect { Vinyldns::API::Zone.list_changes(@first_zone['id']).class.name }.to_not raise_error
  #   end
  # end
end

RSpec.describe Vinyldns::API::Zone::BatchRecordChanges do
  before(:all) do
    group = Vinyldns::API::Group.create("another-test-group", "foo@bar.com", [], [], "description")
    zone_connection = Vinyldns::API::Zone.connect('ok', group['email'], group['id'], isTest: true)
    wait_until_zone_active(zone_connection['zone']['id'])
  end

  after(:all) do
    Vinyldns::API::Group.list_my_groups["groups"].each do |group|
      Vinyldns::API::Group.delete(group["id"])
    end
    Vinyldns::API::Zone.search["zones"].each do |zone|
      Vinyldns::API::Zone.delete(zone["id"])
      wait_until_zone_deleted(zone["id"])
    end
  end

  describe '.create' do
    it 'raises error if changes param is not an array' do
      expect { Vinyldns::API::Zone::BatchRecordChanges.create({}, 'vinyldns-ruby gem testing') }.to raise_error(ArgumentError)
      expect { Vinyldns::API::Zone::BatchRecordChanges.create('test', 'vinyldns-ruby gem testing') }.to raise_error(ArgumentError)
    end
    it 'raises error if zones don\'t exist to delete' do
      request = Vinyldns::API::Zone::BatchRecordChanges.create(
          [
             {
                 'inputName': 'testvinyldnsruby.dodo.',
                 'changeType': 'DeleteRecordSet',
                 'type': 'A'
             }
          ], 'vinyldns-ruby gem testing'
      )
      expect(request.class.name).to eq("Net::HTTPBadRequest")
      expect(request.body).to include("does not exist in VinylDNS")
    end
    it 'can POST' do
      request = Vinyldns::API::Zone::BatchRecordChanges.create(
          [
            {
              'inputName': 'testvinyldnsruby.ok.',
              'changeType': 'Add',
              'type': 'A',
              "ttl": 3600,
              "record": {
                  "address": '1.1.1.2'
              }
            },
            {
              'inputName': 'testvinyldnsruby2.ok.',
              'changeType': 'Add',
              'type': 'A',
              "ttl": 3600,
              "record": {
                  "address": '11.11.11.11'
              }
            }
          ], 'vinyldns-ruby gem testing'
      )
      completed_batch = wait_until_batch_change_completed(request)
      expect(completed_batch['changes'].length).to eq(2)
      expect(completed_batch['status']).to eq('Complete')
      expect(completed_batch['comments']).to eq('vinyldns-ruby gem testing')
    end
    it 'can DELETE' do
      request = Vinyldns::API::Zone::BatchRecordChanges.create(
        [
            {
               'inputName': 'testvinyldnsruby2.ok.',
               'changeType': 'DeleteRecordSet',
               'type': 'A'
            }
        ], 'vinyldns-ruby gem testing'
      )
      completed_batch = wait_until_batch_change_completed(request)
      expect(completed_batch['changes'].length).to eq(1)
      expect(completed_batch['changes'][0].has_value?("testvinyldnsruby2.ok."))
      expect(completed_batch['changes'][0].has_value?("DeleteRecordSet"))
      expect(completed_batch['changes'][0].has_value?("A"))
      expect(completed_batch['comments']).to eq('vinyldns-ruby gem testing')
      expect(completed_batch['status']).to eq('Complete')
    end

    it 'can POST with ownerGroupId' do
      request = Vinyldns::API::Zone::BatchRecordChanges.create(
          [
            {
              'inputName': 'testvinyldnsruby.ok.',
              'changeType': 'Add',
              'type': 'A',
              "ttl": 3600,
              "record": {
                  "address": '1.1.1.2'
              }
            },
            {
              'inputName': 'testvinyldnsruby2.ok.',
              'changeType': 'Add',
              'type': 'A',
              "ttl": 3600,
              "record": {
                  "address": '11.11.11.11'
              }
            }
          ], 'vinyldns-ruby gem testing',
             group['id']
      )
      completed_batch = wait_until_batch_change_completed(request)
      expect(completed_batch['changes'].length).to eq(2)
      expect(completed_batch['status']).to eq('Complete')
      expect(completed_batch['comments']).to eq('vinyldns-ruby gem testing')
      expect(completed_batch['ownerGroupId']).to eq(group['id'])
    end
    it 'can DELETE' do
      request = Vinyldns::API::Zone::BatchRecordChanges.create(
        [
            {
               'inputName': 'testvinyldnsruby2.ok.',
               'changeType': 'DeleteRecordSet',
               'type': 'A'
            }
        ], 'vinyldns-ruby gem testing'
      )
      completed_batch = wait_until_batch_change_completed(request)
      expect(completed_batch['changes'].length).to eq(1)
      expect(completed_batch['changes'][0].has_value?("testvinyldnsruby2.ok."))
      expect(completed_batch['changes'][0].has_value?("DeleteRecordSet"))
      expect(completed_batch['changes'][0].has_value?("A"))
      expect(completed_batch['comments']).to eq('vinyldns-ruby gem testing')
      expect(completed_batch['status']).to eq('Complete')
    end
  end
  describe '.user_recent' do
    it 'can obtain ID from user_recent' do
      expect { Vinyldns::API::Zone::BatchRecordChanges.user_recent }.to_not raise_error
    end
  end
  describe '.get' do
    it 'can obtain ID GET' do
      batch_change = Vinyldns::API::Zone::BatchRecordChanges.user_recent['batchChanges'].first
      expect { Vinyldns::API::Zone::BatchRecordChanges.get(batch_change['id']) }.to_not raise_error
    end
  end
end
