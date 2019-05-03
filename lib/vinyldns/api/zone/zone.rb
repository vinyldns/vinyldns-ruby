# Copyright 2018 Comcast Cable Communications Management, LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require_relative '../../util/util'
module Vinyldns
  class API
    class Zone
      @api_uri = 'zones'

      def self.connect(name, distribution_email, group_id = nil, group_name_filter = nil, **optional_args)
        # Find the group ID using the group_name
        if (group_id.nil? || group_id.empty?) && (!group_name_filter.nil? && !group_name_filter.empty?)
          # Obtain admin group ID for body
          group_object = Vinyldns::API::Group.list_my_groups(group_name_filter)['groups']
          ## Validation
          raise(StandardError, 'Parameter group_object returned nil. This is a problem with the make_request or list_my_groups methods.') if group_object.nil?
          raise(ArgumentError, 'No group found for your group_name_filter. Please re-check the spelling so it\'s exact.') if group_object.empty?
          raise(ArgumentError, 'Your group_name_filter used returned more than one group. Please re-check the spelling so it\'s exact.') if group_object.count > 1
          group_id = group_object.first['id']
        elsif (group_id.nil? || group_id.empty?) && (group_name_filter.nil? || group_name_filter.empty?)
          raise(ArgumentError, 'You must include a group_id or group_name_filter.')
        end # Else, we just use the group_id
        parameters = { adminGroupId: group_id, name: name, email: distribution_email}
        parameters.merge!(optional_args)
        # Post to API
        api_request_object = Vinyldns::API.new('post')
        Vinyldns::API.make_request(api_request_object, @api_uri, parameters)
      end

      def self.update(id, request_params)
        # We use request_params here as values required by create may differ from update
        # Validations
        raise(ArgumentError, 'Request Parameters must be a Hash') unless request_params.is_a? Hash
        api_request_object = Vinyldns::API.new('put')
        Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{id}", request_params)
      end

      def self.delete(id)
        api_request_object = Vinyldns::API.new('delete')
        Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{id}")
      end

      def self.get(id)
        api_request_object = Vinyldns::API.new('get')
        Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{id}")
      end

      def self.search(name_filter = nil, max_items = 5, start_from = nil)
        api_request_object = Vinyldns::API.new('get')
        # UNI.encode matches all symbols that must be replaced with codes
        Vinyldns::API.make_request(api_request_object, "#{@api_uri}?#{URI.encode_www_form([['nameFilter', name_filter], ['maxItems', max_items], ['startFrom', start_from]])}")
      end

      def self.sync(id)
        api_request_object = Vinyldns::API.new('post')
        Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{id}/sync")
      end

      # Warning: Being deprecated, use list_changes
      # def self.history(id)
      #   api_request_object = Vinyldns::API.new('get')
      #   Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{id}/history")
      # end

      def self.list_changes(id, max_items = 5, start_from = nil)
        api_request_object = Vinyldns::API.new('get')
        # UNI.encode matches all symbols that must be replaced with codes
        Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{id}/changes?maxItems=#{max_items}#{start_from.nil? ? '' : "&startFrom=#{start_from}"}")
      end

      class RecordSet
        @api_uri = 'zones'
        @api_uri_addition = 'recordsets'

        def self.create(zone_id, name, type, ttl, records_array, owner_group_id = "")
          # Post
          api_request_object = Vinyldns::API.new('post')
          payload = { 'name': name, 'type': type, 'ttl': ttl, 'records': records_array, 'zoneId': zone_id, 'ownerGroupId': owner_group_id }
          params = Vinyldns::Util.clean_request_payload(payload)
          Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{zone_id}/#{@api_uri_addition}", params)
        end

        def self.update(zone_id, id, request_params)
          # We use request_params here as values required by create may differ from update
          # Validations
          raise(ArgumentError, 'Request Parameters must be a Hash') unless request_params.is_a? Hash
          api_request_object = Vinyldns::API.new('put')
          Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{zone_id}/recordsets/#{id}", request_params)
        end

        def self.delete(zone_id, id)
          api_request_object = Vinyldns::API.new('delete')
          Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{zone_id}/#{@api_uri_addition}/#{id}")
        end

        def self.get(zone_id, id)
          api_request_object = Vinyldns::API.new('get')
          Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{zone_id}/#{@api_uri_addition}/#{id}")
        end

        def self.search(zone_id, name_filter = nil, max_items = 10, start_from = nil)
          api_request_object = Vinyldns::API.new('get')
          # UNI.encode matches all symbols that must be replaced with codes
          parameters = "?maxItems=#{max_items}#{name_filter.nil? ? '' : "&recordNameFilter=#{name_filter}"}#{start_from.nil? ? '' : "&start_from=#{start_from}"}"
          Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{zone_id}/#{@api_uri_addition}#{parameters}")
        end

        def self.get_change(zone_id, id, change_id) # Use Vinyldns::API::Zone.list_changes to obtain change_id
          api_request_object = Vinyldns::API.new('get')
          Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{zone_id}/#{@api_uri_addition}/#{id}/changes/#{change_id}")
        end
      end
      class BatchRecordChanges
        @api_uri = 'zones'
        @api_uri_addition = 'batchrecordchanges'

        def self.create(changes_array, comments="", owner_group_id="")
          raise(ArgumentError, 'changes_array parameter must be an Array') unless changes_array.is_a? Array
          api_request_object = Vinyldns::API.new('post')
          payload = {'changes': changes_array, 'comments': comments, 'ownerGroupId':owner_group_id}
          params = Vinyldns::Util.clean_request_payload(payload)
          Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{@api_uri_addition}", params)
        end

        def self.get(id)
          api_request_object = Vinyldns::API.new('get')
          Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{@api_uri_addition}/#{id}")
        end

        def self.user_recent
          api_request_object = Vinyldns::API.new('get')
          Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{@api_uri_addition}")
        end
      end
    end
  end
end
