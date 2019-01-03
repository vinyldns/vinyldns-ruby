# Copyright 2018 Comcast Cable Communications Management, LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'vinyldns/api/zone/zone'
require 'vinyldns/api/group/group'
require 'net/http'
require 'openssl'
require 'json'
require 'aws-sigv4'
module Vinyldns
  class API
    # Make sure we can access parameters of the object
    attr_accessor :api_url, :method, :region, :body, :content_type, :signer
    # Required arguments:
    # - method
    def initialize(method, region = 'us-east-1', api_url = ENV['VINYLDNS_API_URL'], content_type = 'application/x-www-form-urlencoded')
      @api_url = api_url
      @method = method.upcase
      raise(ArgumentError, 'Not a valid http request method') unless %w[GET HEAD POST PUT DELETE TRACE OPTIONS CONNECT PATCH].include?(@method)
      @region = region
      if @method == 'GET'
        @content_type = content_type
      elsif @method == 'POST' || @method == 'PUT'
        @content_type = 'application/json'
      end
      # Generate a signed header for our HTTP requests
      # http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Sigv4/Signer.html
      @signer = Aws::Sigv4::Signer.new(
          service: 'VinylDNS',
          region: 'us-east-1',
          access_key_id: ENV['VINYLDNS_ACCESS_KEY_ID'],
          secret_access_key: ENV['VINYLDNS_SECRET_ACCESS_KEY'],
          apply_checksum_header: false # Required for posting body in make_request : http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Sigv4/Signer.html : If the 'X-Amz-Content-Sha256' header is set, the :body is optional and will not be read.
      )
    end

    # Required arguments:
    # - a signed object. ex: Vinyldns::API.new('get/POST/dElETe')
    # - a uri path. ex: 'zones/92cc1c82-e2fc-424b-a178-f24b18e3b67a' -- This will pull ingest.yourdomain.net's zone
    def self.make_request(signed_object, uri, body = '')
      signed_headers = signed_object.signer.sign_request(
            http_method: signed_object.method,
            url: uri == '/' ? "#{signed_object.api_url}#{uri}" : "#{signed_object.api_url}/#{uri}",
            headers: { 'content-type' => signed_object.content_type },
            body: body == '' ? body : body.to_json
      )
      url = URI(signed_object.api_url)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true ? url.scheme == "https" : https.use_ssl = false
      if ENV['VINYLDNS_VERIFY_SSL'] == false || ENV['VINYLDNS_VERIFY_SSL'] == 'false'
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      elsif ENV['VINYLDNS_VERIFY_SSL'] == true || ENV['VINYLDNS_VERIFY_SSL'] == 'true' || ENV['VINYLDNS_VERIFY_SSL'].nil?
        https.verify_mode = OpenSSL::SSL::VERIFY_PEER
      else
        raise('Unsupported value for ENV[\'VINYLDNS_VERIFY_SSL\']!')
      end
      request = Net::HTTP::Post.new(uri == '/' ? uri : "/#{uri}") if signed_object.method == 'POST'
      request = Net::HTTP::Put.new(uri == '/' ? uri : "/#{uri}") if signed_object.method == 'PUT'
      request = Net::HTTP::Get.new(uri == '/' ? uri : "/#{uri}") if signed_object.method == 'GET'
      signed_headers.headers.each { |k, v| request[k] = v }
      request['content-type'] = signed_object.content_type
      request.body = body == '' ? body : body.to_json
      response = https.request(request)
      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      else
        return response
        # "HTTP Error: #{response.code} #{response.message} : #{response.body}"
      end
    end
  end
end
