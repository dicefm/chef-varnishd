#
# Cookbook Name:: varnishd
# Recipe:: default
#
# Copyright (C) 2014 Eric Buth
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

include_recipe 'varnishd::build'
include_recipe 'varnishd::vmods'

user node[:varnishd][:runtime][:user] do
  system true
  shell '/bin/false'
end

group node[:varnishd][:runtime][:group] do
  action :create
end

template 'varnish-vcl' do
  path '/usr/local/etc/varnish/default.vcl'
  source 'default.vcl.erb'
  notifies :reload, 'service[varnish]', :delayed
end

template 'varnish-upstart' do
  path '/etc/init/varnish.conf'
  source 'varnish.conf.erb'
  notifies :restart, 'service[varnish]', :delayed
end

service 'varnish' do
  provider Chef::Provider::Service::Upstart
  supports restart: true, reload: true, status: true
  restart_command 'stop varnish && start varnish'
  action [:enable, :start]
end
