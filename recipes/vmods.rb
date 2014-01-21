#
# Cookbook Name:: varnishd
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
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
    notifies :run, 'execute[varnish-vmod-build-#{vmod}]', :immediately
  end

  execute "varnish-vmod-build-#{vmod}" do
    cwd "/usr/local/src/libvmod-#{vmod}"
    command './autogen.sh && ./configure && make && make check && make install'
    environment(
      'VARNISHSRC' => '/usr/local/src/varnish',
      'VMODDIR' => node[:varnishd][:runtime][:vmod_dir]
    )
    notifies :restart, 'service[varnish]', :delayed
  end
end
