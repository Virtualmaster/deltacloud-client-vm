# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

module DeltacloudVM::Client
  class Connection

    attr_accessor :connection
    attr_reader :request_driver
    attr_reader :request_provider
    attr_reader :entrypoint

    include DeltacloudVM::Client::Helpers::Model

    include DeltacloudVM::Client::Methods::Address
    include DeltacloudVM::Client::Methods::Api
    include DeltacloudVM::Client::Methods::BackwardCompatibility
    include DeltacloudVM::Client::Methods::Blob
    include DeltacloudVM::Client::Methods::Bucket
    include DeltacloudVM::Client::Methods::Common
    include DeltacloudVM::Client::Methods::Driver
    include DeltacloudVM::Client::Methods::Firewall
    include DeltacloudVM::Client::Methods::HardwareProfile
    include DeltacloudVM::Client::Methods::Image
    include DeltacloudVM::Client::Methods::Instance
    include DeltacloudVM::Client::Methods::InstanceState
    include DeltacloudVM::Client::Methods::Key
    include DeltacloudVM::Client::Methods::Realm
    include DeltacloudVM::Client::Methods::StorageSnapshot
    include DeltacloudVM::Client::Methods::StorageVolume
    include DeltacloudVM::Client::Methods::LoadBalancer
    include DeltacloudVM::Client::Methods::Metric

    def initialize(opts={})
      @request_driver = opts[:driver]
      @request_provider = opts[:provider]
      @connection = Faraday.new(:url => opts[:url]) do |f|
        # NOTE: The order of this is somehow important for VCR
        #       recording.
        f.request :url_encoded
        f.headers = deltacloud_request_headers
        f.basic_auth opts[:api_user], opts[:api_password]
        f.use DeltacloudVM::ErrorResponse
        f.adapter :net_http
      end
      cache_entrypoint!
      @request_driver ||= current_driver
      @request_provider ||= current_provider
    end

    # Change the current driver and return copy of the client
    # This allows chained calls like: client.driver(:ec2).instances
    #
    # - driver_id -> The new driver id (:mock, :ec2, :rhevm, ...)
    # - api_user -> API user name
    # - api_password -> API password
    # - api_provider -> API provider (aka API_PROVIDER string)
    #
    def use(driver_id, api_user, api_password, api_provider=nil, &block)
      new_client = self.class.new(
        :url => @connection.url_prefix.to_s,
        :api_user => api_user,
        :api_password => api_password,
        :provider => api_provider,
        :driver => driver_id
      )
      new_client.cache_entrypoint!
      yield new_client if block_given?
      new_client
    end

    # Change the API provider but keep the current client credentials.
    # This allows to change the EC2 region and list instances in that
    # region without need to supply credentials.
    #
    # client.use_provider('eu-west-1') { |p| p.instances }
    #
    # - provider_id -> API provider (aka API_PROVIDER)
    #
    def use_provider(provider_id, &block)
      new_client = self.clone
      new_connection = @connection.clone
      new_connection.headers['X-DeltacloudVM-Provider'] = provider_id
      new_client.connection = new_connection
      new_client.cache_entrypoint!(true)
      yield new_client if block_given?
      new_client
    end

    # Cache the API entrypoint (/api) for the current connection,
    # so we don't need to query /api everytime we ask if certain
    # collection/operation is supported
    #
    # - force -> If 'true' force to refresh stored cached entrypoint
    #
    def cache_entrypoint!(force=false)
      @entrypoint = nil if force
      @entrypoint ||= connection.get(path).body
    end

    # Check if the credentials used are valid for the current @connection
    #
    def valid_credentials?
      begin
        r = connection.get(path, { :force_auth => 'true' })
        r.status == 200
      rescue error(:authentication_error)
        false
      end
    end

    private

    # Default DeltacloudVM HTTP headers. Common for *all* requests
    # to DeltacloudVM API
    #
    def deltacloud_request_headers
      headers = {}
      headers['Accept'] = 'application/xml'
      headers['X-DeltacloudVM-Driver'] = @request_driver.to_s \
        if @request_driver
      headers['X-DeltacloudVM-Provider'] = @request_provider.to_s \
        if @request_provider
      headers
    end

  end
end
