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

require 'rubygems'
require 'rubygems/package_task'
require 'rake'
require 'rake/testtask'

spec = Gem::Specification.load('deltacloud-client.gemspec')

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

desc "Re-install the deltacloud-client gem (used for development)"
task :reinstall do
  puts %x{gem uninstall deltacloud-client --all -I -x}
  puts %x{gem build deltacloud-client.gemspec}
  puts %x{gem install deltacloud-client-*.gem --local}
end

desc 'Generate model/methods files for collection.'
task :generate, :name do |t, args|
  require 'erb'
  require_relative './lib/deltacloud_vm/core_ext'
  model_tpl = ERB.new(File.read('support/model_template.erb'))
  methods_tpl = ERB.new(File.read('support/methods_template.erb'))
  name = args[:name]
  model_file = "lib/deltacloud_vm/client/models/#{name}.rb"
  methods_file = "lib/deltacloud_vm/client/methods/#{name}.rb"
  puts model_body = model_tpl.result(binding)
  print "Save model to '#{model_file}'? [Y/n]"
  answer = $stdin.gets.chomp
  if answer.empty? or answer == 'Y'
    File.open(model_file, 'w') { |f|
      f.write(model_body)
    }
    File.open('lib/deltacloud_vm/client/models.rb', 'a') { |f|
      f.puts "require_relative './models/#{name}'"
    }
  end
  puts methods_body = methods_tpl.result(binding)
  print "Save methods to '#{methods_file}'? [Y/n]"
  answer = $stdin.gets.chomp
  if answer.empty? or answer == 'Y'
    File.open(methods_file, 'w') { |f|
      f.write(methods_body)
    }
    File.open('lib/deltacloud_vm/client/methods.rb', 'a') { |f|
      f.puts "require_relative './methods/#{name}'"
    }
  end
  puts
  puts "Don't forget to add this line to 'lib/deltacloud_vm/client/connection.rb':"
  puts
  puts "include DeltacloudVM::Client::Methods::#{name.to_s.camelize}"
  puts
end

desc 'Generate method test file'
task :test_generate, :name do |t, args|
  require 'erb'
  require_relative './lib/deltacloud_vm/core_ext'
  method_tpl = ERB.new(File.read('support/method_test_template.erb'))
  name = args[:name]
  methods_file = "tests/methods/#{name}_test.rb"
  puts method_body = method_tpl.result(binding)
  print "Save method test to '#{methods_file}'? [Y/n]"
  answer = $stdin.gets.chomp
  if answer.empty? or answer == 'Y'
    File.open(methods_file, 'w') { |f|
      f.write(method_body)
    }
  end
end


desc "Open console with client connected to #{ENV['API_URL'] || 'localhost:3002/api'}"
task :console do
  require 'pry'
  unless binding.respond_to? :pry
    puts 'To open a console, you need to have "pry" installed (gem install pry)'
    exit(1)
  end
  require_relative './lib/deltacloud_vm/client'
  client = DeltacloudVM::Client(
    ENV['API_URL'] || 'http://localhost:3002/api',
    ENV['API_USER'] || 'mockuser',
    ENV['API_PASSWORD'] || 'mockpassword'
  )
  binding.pry
end

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList[
    'tests/*/*_test.rb'
  ]
end

desc "Execute test against live DeltacloudVM API"
task :test_live do
  ENV['NO_VCR'] = 'true'
  Rake::Task[:test].invoke
end

desc "Generate test coverage report"
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task[:test].invoke
end
