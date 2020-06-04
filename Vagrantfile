Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  config.vm.synced_folder ".", "/vagrant"

  # Provision
  config.vm.provision :shell, path: "configuration.sh"
end
