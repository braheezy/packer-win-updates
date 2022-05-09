# Windows Pipelines
We describe an automated process for creating configured Windows OSes.

Goals:
- Vanilla Windows 10 image
- `.wim` and `.iso` output
- Features:
    - Sysprep
    - Windows Updates
    - VS Code installed

The workstation is Windows 10 Home with access to Fedora 35 VM and Ubuntu WSL.

# Prequisites
We'll need the following:
- Windows OS
    - Decided to use an ISO.
        - Used the Windows Media Creation tool to create a local ISO. Assuming it's the same OS as the host that ran the tool.
    - Tested this ISO can be used to boot a new Windows VM in VirtualBox.
        - Getting Packer to run on WSL was a bitch
        - Turns out the install image the Windows Media Creaton tool makes is an encrypted `.esd` instead of `wim`, which seemed to cause problems. It would not auto-select the OS during boot.
            - Mount the `.iso`, and copy the `.esd` somewhere else.
            - Convert it: `dism /Export-Image /SourceImageFile:install.esd /SourceIndex:1 /DestinationImageFile:install.wim /Compress:Max /CheckIntegrity`
            - Copy all the contents of the old ISO to a new folder to prepare for making a new ISO.
            - Create bootable ISO from directory. On Windows, this means a GUI program or installing `oscdimg.exe` after hopping through more
              Microsoft hoops. Or get yourself to a Linux machine and run `mkisofs` (I used a Fedora VM).
              1. `oscdimg.exe -m -o -u2 -udfver102 -bootdata:2#p0,e,bz:\new_mount\boot\etfsboot.com#pEF,e,bz:\new_mount\efi\microsoft\boot\efisys.bin z:\new_mount z:\windows10.iso`
              2. `mkisofs -bboot/etfsboot.com -no-emul-boot -boot-load-seg 1984 -boot-load-size 8 -iso-level 2 -J -l -D -N -joliet-long -allow-limited-size -relaxed-filenames -V "WIN10" -o ../windows10.iso .`

        - So we probably could have skipped Media Creation tool...


- Build Tools
    - Packer: Orchestrate the build
    - Ansible: Configure the OS

# Packer
When building for libvirt needs virtio drivers
- `curl -L -o /tmp/virtio-win.iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.217-1/virtio-win.iso`
- `xorriso -report_about WARNING -osirrox on -indev /tmp/virtio-win.iso -extract / ./virtio-win`
- `chmod -R 755 ./virtio-win`

The output goals:
- `.qcow2` file, a full image representing the latest, patched OS
- Various `.wim` image files:
    - `full.wim`, aka the entire C: drive
    - `update.wim`, a data image containing the updates that were applied

## Provisioning
