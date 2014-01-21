#
# Cookbook Name:: varnishd
# Recipe:: vmods
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
include_recipe 'git'

directory node[:varnishd][:runtime][:vmod_dir] do
  recursive true
end

node[:varnishd][:vmods].each_pair do |vmod, attributes|

  git "/usr/local/src/libvmod-#{vmod}" do
    repository attributes[:repository]
    reference attributes[:reference].to_s == '' ? 'master' : attributes[:reference]
    action :sync
  end

  execute "varnish-vmod-build-#{vmod}" do
    cwd "/usr/local/src/libvmod-#{vmod}"
    command './autogen.sh && ./configure && make && make check && make install'
    environment(
      'VARNISHSRC' => '/usr/local/src/varnish',
      'VMODDIR' => node[:varnishd][:runtime][:vmod_dir]
    )
    notifies :restart, 'service[varnish]', :delayed
    only_if do
      !::File.exists?("/usr/local/src/libvmod-#{vmod}/configure") ||
      ::File.mtime("/usr/local/src/libvmod-#{vmod}/configure") < ::File.mtime("/usr/local/src/libvmod-#{vmod}/.git") ||
      ::File.mtime("/usr/local/src/libvmod-#{vmod}/configure") < ::File.mtime('/usr/local/src/varnish')
    end
  end
end
