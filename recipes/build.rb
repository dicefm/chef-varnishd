#
# Cookbook Name:: varnishd
# Recipe:: build
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

include_recipe 'build-essential'

%w[
  libtool
  pkg-config
  python-docutils
  xsltproc
  libpcre3-dev
].each do |name|
  package name
end

%w[
  /usr/local/src
  /usr/local/etc/varnish
].each do |path|
  directory path do
    recursive true
  end
end

execute 'varnish-secret' do
  command 'uuidgen > /usr/local/etc/varnish/secret && chmod 0600 /usr/local/etc/varnish/secret'
  creates '/usr/local/etc/varnish/secret'
end

remote_file "/usr/local/src/varnish-#{node[:varnishd][:version]}.tar.gz" do
  source node[:varnishd][:url]
  checksum node[:varnishd][:checksum]
end

execute 'varnish-unpack' do
  command "tar -zxf varnish-#{node[:varnishd][:version]}.tar.gz"
  cwd '/usr/local/src'
  creates "/usr/local/src/varnish-#{node[:varnishd][:version]}"
end  

execute 'varnish-build' do
  command './autogen.sh && ./configure && make'
  cwd "/usr/local/src/varnish-#{node[:varnishd][:version]}"
  creates "/usr/local/src/varnish-#{node[:varnishd][:version]}/bin/varnishd/varnishd"
end

link '/usr/local/src/varnish' do
  to "/usr/local/src/varnish-#{node[:varnishd][:version]}"
end

execute 'varnish-install' do
  command 'make install'
  cwd '/usr/local/src/varnish'
  not_if "/usr/local/sbin/varnishd -V 2>&1 | grep -q '\\bvarnish-#{node[:varnishd][:version]}\\b'"
  notifies :restart, 'service[varnish]', :delayed
end
