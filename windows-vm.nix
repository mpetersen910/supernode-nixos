{ config, pkgs, ... }:

# Host side of the Windows VM for S32 Design Studio.
# The VM itself is created once in virt-manager; libvirt stores it under
# /var/lib/libvirt, outside this config.

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      # Software TPM 2.0, required by the Windows 11 installer
      swtpm.enable = true;
      # UEFI/Secure Boot firmware (OVMF) ships with QEMU and is picked up
      # automatically since 25.11. The old qemu.ovmf option is gone.
    };
  };

  # libvirt's built-in "default" NAT network (virbr0, 192.168.122.0/24).
  # NixOS ships it but leaves it switched off; this turns it on at every
  # boot. Same effect as running `virsh net-start default` and
  # `virsh net-autostart default` by hand, and safe to run repeatedly.
  systemd.services.libvirt-net-default = {
    description = "Start libvirt's default NAT network";
    requires = [ "libvirtd.service" ];
    after = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      virsh=${config.virtualisation.libvirtd.package}/bin/virsh
      $virsh net-autostart default
      $virsh net-info default | grep -q '^Active:.*yes' || $virsh net-start default
    '';
  };

  # GUI for creating and managing VMs
  programs.virt-manager.enable = true;

  # Ad hoc USB redirection from a virt-manager/SPICE window.
  # For the J-Link, prefer a permanent "USB Host Device" in the VM's
  # hardware settings; it reattaches on every boot, no window needed.
  virtualisation.spiceUSBRedirection.enable = true;

  users.users.supernode.extraGroups = [ "libvirtd" ];

  # The NixOS firewall otherwise blocks DHCP/DNS on libvirt's NAT bridge,
  # and the VM boots with no network.
  networking.firewall.trustedInterfaces = [ "virbr0" ];
}
