#******************************************************************************
/*
         Stage 1
*/
#******************************************************************************
###############################################
#        Sources
# From ISO, create basic functioning image
###############################################
source "qemu" "base" {
  iso_url           = var.iso_url
  iso_checksum      = "md5:${var.iso_checksum_md5}"
  communicator      = "winrm"
  winrm_username    = var.remote_username
  winrm_password    = var.remote_password
  winrm_timeout     = var.winrm_timeout
  winrm_insecure    = true
  winrm_use_ssl     = true
  memory            = var.memory
  cpus              = var.cpus
  headless          = var.headless
  floppy_files      = var.floppy_files
  boot_wait         = var.boot_wait
  boot_command      = var.boot_command
  shutdown_command  = var.shutdown_command
  http_directory    = var.http_directory
  # QEMU specific stuff
  format            = "qcow2"
  accelerator       = "kvm"
  net_device        = "virtio-net"
  cd_files          = [var.virtio_win_dir]
}

source "virtualbox-iso" "base" {
  iso_url              = var.iso_url
  iso_checksum         = "md5:${var.iso_checksum_md5}"
  communicator         = "winrm"
  winrm_username       = var.remote_username
  winrm_password       = var.remote_password
  winrm_timeout        = var.winrm_timeout
  memory               = var.memory
  cpus                 = var.cpus
  headless             = var.headless
  floppy_files         = var.floppy_files
  boot_wait            = var.boot_wait
  boot_command         = var.boot_command
  shutdown_command     = var.shutdown_command
  # Virtual specific stuff
  guest_os_type        = "Windows10_64"
  guest_additions_mode = "disable"
  gfx_vram_size        = 128
  gfx_controller       = "vboxsvga"
  gfx_accelerate_3d    = true
  format               = "ova"
}
###############################################
#        Builds
###############################################
build {
  name = "stage_1"
  sources = ["sources.virtualbox-iso.base", "sources.qemu.base"]

  ###################################
  #        Provisioners
  ###################################
  provisioner "ansible" {
    playbook_file = "ansible/virtio-win.yml"
    user          = var.remote_username
    use_proxy     = false
    extra_arguments = [
        "--extra-vars",
        "ansible_winrm_server_cert_validation=ignore",
        "--extra-vars",
        "virtio_win_iso_drive=E:",
        "--extra-vars",
        "virtio_win_iso_path=virtio-win",
        "--extra-vars",
        "virtio_driver_directory=w10"
    ]
  }

  provisioner "ansible" {
    playbook_file = "ansible/vdagent-win.yml"
    user          = var.remote_username
    use_proxy     = false
    extra_arguments = [
        "--extra-vars",
        "ansible_winrm_server_cert_validation=ignore"
    ]
  }

  provisioner "ansible" {
    playbook_file = "ansible/virtiofs-win.yml"
    user          = var.remote_username
    use_proxy     = false
    extra_arguments = [
        "--extra-vars",
        "ansible_winrm_server_cert_validation=ignore",
        "--extra-vars",
        "virtio_win_iso_drive=E:",
        "--extra-vars",
        "virtio_win_iso_path=virtio-win",
        "--extra-vars",
        "virtio_driver_directory=w10"
    ]
  }

  ###################################
  #        Post-processors
  ###################################
  post-processor "manifest" {
    output = "${build.name}-manifest.json"
  }
  post-processor "checksum" {
    output = "${build.name}.checksum"
}

}
#******************************************************************************
/*
         Stage 2
*/
#******************************************************************************
locals {
  /* The ternary statements handle Packer template errors when the
    files/variables aren't set.

    These are also ordered in a specific way
    because "The true and false result expressions must have consistent types" per Packer.
  */

  # Read manifest file into string
  manifest_data_file = fileexists("stage_1-manifest.json") ? file("stage_1-manifest.json") : ""

  # Turn the manifest into a JSON object, then peel off the array of build info
  build_info = local.manifest_data_file != "" ? jsondecode(local.manifest_data_file).builds : []

  # Traverse the JSON object for the iso location
  iso_file = local.build_info != [] ? local.build_info[0].files[0].name : ""
}
###############################################
#        Sources
# Take ISO from Stage 2 and customize.
# Sysprep at end.
###############################################
source "qemu" "custom" {
  disk_image        = true
  iso_url           = local.iso_file
  iso_checksum      = "file:stage_1.checksum"
  communicator      = "winrm"
  winrm_username    = var.remote_username
  winrm_password    = var.remote_password
  winrm_timeout     = var.winrm_timeout
  winrm_insecure    = true
  winrm_use_ssl     = true
  memory            = var.memory
  cpus              = var.cpus
  headless          = var.headless
  shutdown_command  = var.shutdown_command
  http_directory    = var.http_directory
  floppy_files      = ["floppy/sysprep_shutdown.ps1",
                       "floppy/sysprep_unattend.xml"]
}
###############################################
#        Builds
###############################################
build {
  name = "stage_2"
  sources = ["sources.qemu.custom"]

  ###################################
  #        Provisioners
  ###################################
  provisioner "ansible" {
    playbook_file = "ansible/configure-win.yml"
    user          = var.remote_username
    use_proxy     = false
    extra_arguments = [
        "-e",
        "ansible_winrm_server_cert_validation=ignore"
    ]
  }

  ###################################
  #        Post-processors
  ###################################
  post-processor "vagrant" {
    keep_input_artifact = true
    output = "win-pipeline-test.{{.Provider}}.box"
  }
}

###############################################
#        Variables
###############################################
variable "remote_username" {
  type    = string
  default = "vagrant"
}

variable "remote_password" {
  type    = string
  default = "vagrant"
}

variable "iso_url" {
  type    = string
  default = "../Downloads/Win10_21H2_English_x64.iso"
}

variable "iso_checksum_md5" {
  type    = string
  default = "823c3cb59ff0fd43272f12bb2e3a089d"
}

variable "sysprep_shutdown_command" {
  type    = string
  # default = "shutdown /s /t 10 /f /d p:4:1 /c Packer"
  default  = "powershell.exe A:\\sysprep_shutdown.ps1"
}

variable "shutdown_command" {
  type    = string
  default  = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
}

variable "winrm_timeout" {
  type    = string
  # Set pretty high to account for a slow build computer.
  default = "1h"
}

variable "headless" {
  type    = bool
  default = false
}

variable "boot_command" {
  type    = list(string)
  default = [
    # This tapping of the enter key is for UEFI boots, but is harmless for BIOS.
    "<enter><wait1s><enter><wait1s><enter>",
    # Set pretty high to account for a slow build computer.
    "<wait90s>",
    # Open a CMD prompt when the Windows Setup screen is shown.
    "<leftShiftOn><f10><leftShiftOff><wait3s>",
    # Run Windows Setup with the answer file.
    "setup /unattend:A:\\Autounattend_bios.xml",
    "<enter>"
  ]
}

variable "boot_wait" {
  type    = string
  default = "5s"
}

variable "memory" {
  type    = number
  default = 6000
}

variable "cpus" {
  type    = number
  default = 2
}

variable "floppy_files" {
  type    = list(string)
  default = ["floppy"]
}

variable "virtio_win_dir" {
  type    = string
  default = "/opt/virtio-win"
}

variable "http_directory" {
  type = string
  default = "materials/"
}