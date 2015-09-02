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

require_relative '../test_helper'

describe DeltacloudVM::Client::Methods::Realm do

  before do
    VCR.insert_cassette(__name__)
    @client = new_client
  end

  after do
    VCR.eject_cassette
  end

  it 'supports #realms' do
    @client.must_respond_to :realms
    @client.realms.must_be_kind_of Array
    @client.realms.each { |r| r.must_be_instance_of DeltacloudVM::Client::Realm }
  end

  it 'supports filtering #realms by :id' do
    result = @client.realms(:id => 'eu')
    result.must_be_kind_of Array
    result.size.must_equal 1
    result.first.must_be_instance_of DeltacloudVM::Client::Realm
  end

  it 'support #realm' do
    @client.must_respond_to :realm
    result = @client.realm('eu')
    result.must_be_instance_of DeltacloudVM::Client::Realm
    lambda { @client.realm(nil) }.must_raise DeltacloudVM::Client::NotFound
    lambda { @client.realm('foo') }.must_raise DeltacloudVM::Client::NotFound
  end

end
