Vagrant.configure("2") do |config|
  config.vm.box = "win-test"
  config.vm.box_url = "win-pipeline-test.libvirt.box"
  config.vm.boot_timeout = 1200

  config.vm.guest = :windows
  config.vm.communicator = "winrm"
  config.winrm.transport = :ssl
  config.winrm.ssl_peer_verification = false

  # Do we really need to set this? It's the default
  config.winrm.password = "vagrant"
  config.winrm.username = "vagrant"

  config.vm.synced_folder "materials", "/vagrant", disabled: false

  config.vm.define "man-up"
  config.vm.define "auto-up"

  config.vm.provider :libvirt do |l, override|
    l.driver = "kvm"
    l.cpus = 2
    l.memory = 4096
    l.disk_bus = "virtio"
    l.graphics_type = "spice"
    l.video_type = "qxl"
    l.machine_type = "pc-q35-6.1"

    l.memorybacking :access, :mode => "shared"
    override.vm.synced_folder "./scripts", "/scripts", disabled: false, type: "virtiofs"

    l.storage :file, :device => :cdrom, :bus => "sata", :path => '/home/braheezy/windows-pipeline/virtio-win-0.1.217.iso'

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
