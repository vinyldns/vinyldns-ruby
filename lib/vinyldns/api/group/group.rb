# Copyright 2018 Comcast Cable Communications Management, LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
module Vinyldns
  class API
    class Group
      @api_uri = 'groups'

      def self.create(name, distribution_email, members_array, admins_array, description = '')
        api_request_object = Vinyldns::API.new('post')
        Vinyldns::API.make_request(api_request_object, @api_uri, { 'name': name, 'email': distribution_email, 'description': description, 'members': members_array, 'admins': admins_array })
      end

      def self.update(id, request_params)
        # We use request_params here as require arguments as create arguments may differ from update
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

      def self.list_my_groups(name_filter = nil, max_items = 5, start_from = nil)
        api_request_object = Vinyldns::API.new('get')
        # URI.encode matches all symbols that must be replaced with codes
        Vinyldns::API.make_request(api_request_object, "#{@api_uri}?#{URI.encode_www_form([['groupNameFilter', name_filter], ['maxItems', max_items], ['startFrom', start_from]])}")
      end

      def self.list_group_admins(id)
        api_request_object = Vinyldns::API.new('get')
        Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{id}/admins")
      end

      def self.list_group_members(id, max_items = 5, start_from = nil)
        api_request_object = Vinyldns::API.new('get')
        # UNI.encode matches all symbols that must be replaced with codes
        Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{id}/members?maxItems=#{max_items}#{start_from.nil? ? '' : "&startFrom=#{start_from}"}")
      end

      def self.get_group_activity(id, max_items = 5, start_from = nil)
        api_request_object = Vinyldns::API.new('get')
        # UNI.encode matches all symbols that must be replaced with codes
        Vinyldns::API.make_request(api_request_object, "#{@api_uri}/#{id}/activity?maxItems=#{max_items}#{start_from.nil? ? '' : "&startFrom=#{start_from}"}")
      end
    end
  end
end
