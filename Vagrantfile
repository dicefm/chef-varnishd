# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
 
  config.omnibus.chef_version = :latest

  config.vm.hostname = "baseline"
  config.vm.box = "opscode-ubuntu-13.04"
  config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-13.04_provisionerless.box"
  
  config.berkshelf.berksfile_path = "./Berksfile"
  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      varnishd: {
        vmods: {
          boltsort: {
            repository: 'https://github.com/vimeo/libvmod-boltsort.git'
          }      
        }
      }
    }

    chef.run_list = [
      'recipe[varnishd]'
    ]
  end
end
