Vagrant.configure("2") do |config|
  config.vm.box = "win-test"
  config.vm.box_url = "packer_test_libvirt.box"
  config.vm.boot_timeout = 1200

  config.vm.guest = :windows
  config.vm.communicator = "winrm"
  config.winrm.transport = :ssl
  config.winrm.ssl_peer_verification = false

  # Do we really need to set this?
  config.winrm.password = "vagrant"
  config.winrm.username = "vagrant"

  # Do we really need to set this?
  # config.vm.network :forwarded_port, guest: 5986, host: 5986, id: "winrm-ssl", auto_correct:true
  # config.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct:true

  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :libvirt do |l|
    l.driver = "kvm"
    l.cpus = 2
    l.disk_bus = "virtio"
    l.graphics_type = "spice"
    l.video_type = "qxl"
    l.machine_type = "pc-q35-6.1"

    # For QXL graphics comm to host
    l.channel :type => 'spicevmc', :target_name => 'com.redhat.spice.0', :target_type => 'virtio'
    # For guest agent comm to host
    l.channel :type => 'unix', :target_name => 'org.qemu.guest_agent.0', :target_type => 'virtio'

    # Enable Hyper-V enlightments: https://blog.wikichoon.com/2014/07/enabling-hyper-v-enlightenments-with-kvm.html
    l.hyperv_feature :name => 'relaxed', :state => 'on'
    l.hyperv_feature :name => 'synic',   :state => 'on'
    l.hyperv_feature :name => 'vapic',   :state => 'on'
    l.hyperv_feature :name => 'vpindex', :state => 'on'
  end
end
