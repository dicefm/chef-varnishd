#
# Cookbook Name:: varnishd
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
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
