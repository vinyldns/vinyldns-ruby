[![Travis build](https://api.travis-ci.org/vinyldns/vinyldns-ruby.svg?branch=master)](https://travis-ci.org/vinyldns/vinyldns-ruby)

# VinylDNS-Ruby

Ruby gem for working with VinylDNS.

* It was built around [the API](https://www.vinyldns.io/api/)
* It relies, currently, on the AWS-SDK to sign the HTTP requests it makes

# Requirements

1. Ruby ~> 2.4
2. ```ENV['VINYLDNS_ACCESS_KEY_ID']``` & ```ENV['VINYLDNS_SECRET_ACCESS_KEY']``` are set in your application or local shell
    * You can find both of these within the portal by downloading your credentials file
3. ```ENV['VINYLDNS_API_URL']``` is set with your api url (if applicable include http[s]:// and port)

# Installation

Add this line to your application's Gemfile:

```ruby
gem 'vinyldns-ruby'
```

# Usage

Add this require to your code:

```ruby
require 'vinyldns/api'
```

# Getting Started

This project adheres to the Contributor Covenant [code of conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior

* Each method returns a JSON object
* The methods request an 'api_request_object' with the HTTP Method specified like: ```Vinyldns::API.new('get')```, then perform a variation of ```Vinyldns::API.make_request(api_request_object, "zones/#{zone_id}")```
* Method parameters match the HTTP Request Parameter requirements in the API. See the [API Reference](https://www.vinyldns.io/api/) for more information.
* SSL verification is enabled by default; `ENV['VINYLDNS_VERIFY_SSL']` can be set to false in order to disable.

## Contributing

If you decide to contribute, please read over our [contributor documentation](CONTRIBUTING.md).

## Developing

### Running the RSpec tests

Testing requires a local running VinylDNS instance and this depends on having **Docker**.

There are a number of scripts for executing the tests located in the scripts/ directory.  These can be executed simply by running:
```
  $ make test
```
If the local api isn't available it will be downloaded and launched before the tests begin running.
The script will leae the api running.  When you are done with it you can stop it using the following command:
```
  $ make stop-api
```

## Namespaces and Methods

* Arguments to methods, take Vinyldns::API::Zone.get(id) as an example, can be a little confusing at first. All arguments used under a method that are not explicit, like in our example *id*, can be understood as *zone_id* due to it existing under the namespace ::Zone.

## Simple Example (Pull first zone you have access to)

* Requires you to have at least one zone for your user/group

        [1] pry(main)> require 'vinyldns/api'
        => true
        [2] pry(main)> Vinyldns::API::Zone.search()
        => {"zones"=>
          [{"name"=>"XXXXXXX.yourdomain.net.",
            "email"=>"XXXXX@yourdomain.com",
            "status"=>"Active",
            "created"=>"2017-11-27T17:06:53Z",
            "updated"=>"2018-01-30T13:56:55Z",
            "id"=>"92cXXXXX3b67a",
            "connection"=>{"name"=>"XXXXXXX.yourdomain.net.", "keyName"=>"_t&p-@yourdomain.com", "key"=>"OBe0nmlA==", "primaryServer"=>"XX.rXXXX.yourdomain.net"},
            "account"=>"system",
            "shared"=>false,
            "acl"=>{"rules"=>[{"accessLevel"=>"Delete", "groupId"=>"15e073b7119c", "recordTypes"=>["A", "NS", "SPF", "AAAA", "SSHFP", "CNAME", "SRV", "PTR", "TXT", "MX"]}]},
            "adminGroupId"=>"ac1",
            "latestSync"=>"2017-12-04T19:35:53Z"}],
         "maxItems"=>5}

            
## All Available Methods  

* Below method arguments with "=" next to them indicate a default value. You do not have to specify "argmuentX = nil', just know if you don't set it nil will be used.
     
### Vinyldns::API

    - new(method, region = 'us-east-1', api_url = ENV['VINYLDNS_API_URL'], content_type = 'application/x-www-form-urlencoded')
       - Required for make_request, but not before any of the Vinyldns::API::* methods.
    
    - make_request(signed_object, uri, body = '')
       - HTTP requests that fail are returned as: ```#<Net::HTTPUnauthorized 401 Unauthorized readbody=true>```

### Vinyldns::API::Zone

    - connect(name, distribution_email, group_id = nil, group_name_filter = nil)
        - "Connects user to an existing zone. User must be a member of the group that has access to the zone."
        - name must be the full zone name you wish to connect to. For example: ingest.yourdomain.net instead of ingest.
        - Will use group_id and ignore group_name_filter if group_id is set.
        - If group_id is nil and group_name_filter is set, it will run Vinyldns::API::Group.list_my_groups and use the ID of the group it finds.
        - group_name_filter searches must return only 1 entry else it will error, so be specific.

    - update(id, request_params)
        - Zone API Reference > Zone Model details all available options
        - request_params must be a hash of values permitted by the API. See the API reference linked to above.
        - Updates are NOT immediate.
        
    - delete(id)

    - get(id)

    - search(name_filter = nil, max_items = 5, start_from = nil)
        - If name_filter is not set, it will pull an alphabetical list of zones you have access to.

    - sync(id)

    - history(id)

    - list_changes(id, max_items = 5, start_from = nil)

### Vinyldns::API::Zone::RecordSet

    - create(zone_id, name, type, ttl, records_array)
        - Suggested ttl is 900

    - update(zone_id, request_params)
        - request_params must be a hash of values permitted by the API. See the API reference linked to above.

    - delete(zone_id, id)

    - get(zone_id, id)

    - search(zone_id, name_filter = nil, max_items=10, start_from = nil)
        - If name_filter is not set, it will pull an alphabetical list of zones you have access to.

    - get_change(zone_id, id, change_id)
        - Use Vinyldns::API::Zone.list_changes to obtain change_id
        
### Vinyldns::API::Zone::BatchRecordChanges

    [No Zone ID needed for these]

    - create(changes_array, comments)
        - changes must be an array of Add or DeleteRecordSet hashes.

    - get(id)
    
    - user_recent
        - Summary information for the most recent 100 batch changes created by the user.

### Vinyldns::API::Group

    - create(name, distribution_email, members_array, admins_array, description = '')
        - members_array and admins_array must be included. Please see API reference linked to at the top of this readme.

    - update(id, request_params)
        - request_params must be a hash of values permitted by the API. See the API reference linked to above.

    - delete(id)

    - get(id)

    - list_my_groups(name_filter = nil, max_items = 5, start_from = nil)
        - If name_filter is not set, it will pull an alphabetical list of zones you have access to.

    - list_group_admins(id)

    - list_group_members(id, max_items = 5, start_from = nil)

    - get_group_activity(id, max_items = 5, start_from = nil)

# Maintainers
* [Nathan Pierce](https://github.com/NorseGaud)
