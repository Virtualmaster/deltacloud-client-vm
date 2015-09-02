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
  class HardwareProfile < Base

    include DeltacloudVM::Client::Helpers

    attr_reader :properties

    def self.parse(hwp)
      {
        :properties => hwp.xpath('property').map { |p|
          property_klass(p['kind']).parse(p)
        }
      }
    end

    def cpu
      property :cpu
    end

    def memory
      property :memory
    end

    def architecture
      property :architecture
    end

    def storage
      property :storage
    end

    def opaque?
      @properties.empty? && @name == 'opaque'
    end

    private

    def property(name)
      @properties.find { |p| p.name == name.to_s }
    end

    def self.property_klass(kind)
      case kind
        when 'enum'   then Property::Enum
        when 'range'  then Property::Range
        when 'fixed'  then Property::Fixed
        when 'opaque' then Property::Property
        else raise error.new("Unknown HWP property: #{kind}")
      end
    end

  end
end
