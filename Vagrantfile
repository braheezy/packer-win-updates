Vagrant.configure("2") do |config|
  config.vm.box = "win-test"
  config.vm.box_url = "packer_test_libvirt.box"

  # Prefer the libvirt provider if not specified
  config.vm.provider :libvirt do |l|
    l.driver = "kvm"
    l.cpus = 2
    l.graphics_type = "spice"
    l.video_type = "qxl"
  end
end
