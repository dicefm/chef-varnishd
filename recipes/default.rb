#
# Cookbook Name:: varnishd
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

include_recipe 'varnishd::build'



execute 'varnish-secret' do
  command 'uuidgen > /usr/local/etc/varnish/secret && chmod 0600 /usr/local/etc/varnish/secret'
  creates '/usr/local/etc/varnish/secret'
end




user node[:varnishd][:runtime][:user] do
  system true
  shell '/bin/false'
end

group node[:varnishd][:runtime][:group] do
  action :create
end


template '/usr/local/etc/varnish/default.vcl' do
  source 'default.vcl.erb'
  notifies :reload, 'service[varnish]', :delayed
end

template '/etc/init/varnish.conf' do
  source 'varnish.conf.erb'
  notifies :restart, 'service[varnish]', :delayed
end

service 'varnish' do
  provider Chef::Provider::Service::Upstart
  supports restart: true, reload: true, status: true
  restart_command 'stop varnish && start varnish'
  action [:enable, :start]
end

