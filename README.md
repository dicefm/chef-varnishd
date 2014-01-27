# varnishd cookbook

A [Chef](http://docs.opscode.com/#) [cookbook](http://docs.opscode.com/essentials_cookbooks.html) for installing and configuring [Varnish](https://www.varnish-cache.org/), with some specific design constraints.

* Varnish and [VMODs](https://www.varnish-cache.org/vmods) are installed from **source**.
* ***Every*** tunable parameter is exposed in the [attributes](http://docs.opscode.com/chef_overview_attributes.html).
* Services are managed by [Upstart](http://upstart.ubuntu.com/) to provide straight-forward resource limits, respawing, and control.
* Carefully triggered and idempotent build/dependency chains to insure Chef runs cleanly in the event of errors.

## Requirements

### Platforms

Using [test kitchen](https://github.com/test-kitchen/test-kitchen), this cookbook is tested against the following platforms.

- Ubuntu 12.04, Ubuntu 12.10, Ubuntu 13.04

It'd be reasonable to assume that Ubuntu versions more recent than 13.04 will work as well as Debian and older Ubuntu distributions that have Upstart configured.

### Cookbooks

- apt
- build-essential
- git

## Usage

Add `varnishd::default` to your node's [run-list](http://docs.opscode.com/essentials_node_object_run_lists.html). If you do not want to setup the `varnishd` daemon as a service, you may include `varnishd::build` and `varnishd::vmods` seperately instead.

## Attributes

It's important to note that the `:version`, `:url`, and `:checksum` attributes must always be modified together and are in no way automatically generated.

key | description | default
--- | --- | ---
[:varnishd][:version] | Complete Varnish version you are installing | '3.0.5'
[:varnishd][:url] | URL for an source archive of that version | 'http://repo.varnish-cache.org/source/varnish-3.0.5.tar.gz'
[:varnishd][:checksum] | Checksum for that archive | '302fd6afc7…'
[:varnishd][:vcl_source] | Template to use to render the VCL | 'default.vcl.erb'
[:varnishd][:vcl_cookbook] | Cookbook in which to find that template | 'varnishd'
[:varnishd][:storage] | Storage type and options | 'malloc,128M'
[:varnishd][:pid] | Write the daemon's PID to file | '/var/run/varnishd.pid'
[:varnishd][:limit][:nofile] | File limit | '131072'
[:varnishd][:limit][:memlock] | Memory limit | '82000'

The mechanism for specifying a VCL template in a wrapping cookbook is the same as in the [varnish cookbook](https://github.com/opscode-cookbooks/varnish).

### VMODs

VMODs to build and install can be specified as part of the `[:varnishd][:vmods]` attribute. For example, to include [boltsort](https://github.com/vimeo/libvmod-boltsort).

```ruby
node.set[:varnishd][:vmods][:boltsort][:repository] = 'https://github.com/vimeo/libvmod-boltsort.git'
node.set[:varnishd][:vmods][:boltsort][:reference] = 'master'
```

The `:reference` is optional, and if it is missing `master` will be used by default.

### Varnish Runtime Options

A key feature of this cookbook is providing access to *every* Varnish runtime option as described in [the documentation](https://www.varnish-cache.org/docs/3.0/reference/varnishd.html). These options are listed out in the default [attribute file](http://docs.opscode.com/essentials_cookbook_attribute_files.html) like so.

```ruby
default[:varnishd][:runtime][:http_max_hdr] = nil #'64'
```

For most values the default is `nil` and the value that Varnish will use when the value is not provided is listed in end of line comment. Any value not set to nil will be passed to `varnishd` when run using the `-p` flag.

## Contributing

Please do! We'll follow the [git-flow](http://nvie.com/posts/a-successful-git-branching-model/) method, so please submit pull requests as feature branches.

## Contributors

* **[@buth](https://github.com/buth)**
