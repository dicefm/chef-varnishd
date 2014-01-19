#
# Cookbook Name:: varnishd
# Recipe:: build
#
# Copyright (C) 2014 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
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

directory '/usr/local/src' do
  recursive true
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
end

