{ ... }:

# Isolated bench LAN on eno1 (GS308E switch).
# supernode = 192.168.50.1 and serves DHCP + .bench DNS + NTP.
# canpi has no Wi-Fi and no default route, so it depends on this for
# its address and its clock.
#
# Check the interface name first with `ip link`. If it isn't eno1,
# change every eno1 below.

{
  # Keep NetworkManager off eno1; it gets a fixed address instead
  networking.networkmanager.unmanaged = [ "eno1" ];
  networking.interfaces.eno1.ipv4.addresses = [
    { address = "192.168.50.1"; prefixLength = 24; }
  ];

  services.dnsmasq = {
    enable = true;

    # dnsmasq only listens on the bench interface, so it must not
    # become supernode's own resolver or host DNS breaks.
    resolveLocalQueries = false;

    settings = {
      interface = "eno1";
      # bind-dynamic (not bind-interfaces): still binds only to the bench
      # address, so it can't collide with libvirt's dnsmasq on virbr0, but it
      # also waits for eno1 to come up at boot instead of failing to start.
      bind-dynamic = true;
      listen-address = "192.168.50.1";

      # .bench names
      domain = "bench";
      local = "/bench/";
      expand-hosts = true;
      no-hosts = true; # keeps supernode.bench from resolving to 127.0.0.1
      address = "/supernode.bench/192.168.50.1";

      dhcp-authoritative = true;
      dhcp-range = "192.168.50.100,192.168.50.200,12h";
      dhcp-option = [
        "3"                               # empty router: no default route via the bench
        "option:ntp-server,192.168.50.1"
      ];

      # Fixed leases. Fill in the real MACs, then uncomment
      # (canpi: `ip link show eth0`; Mac: System Settings > Network > Ethernet > Details > Hardware).
      dhcp-host = [
        "88:a2:9e:c6:58:63,canpi,192.168.50.10"
        "9c:69:d3:6c:ba:b1,macbook,192.168.50.5"
      ];
    };
  };

  # Time server for canpi (also replaces systemd-timesyncd on this host)
  services.chrony = {
    enable = true;
    extraConfig = ''
      allow 192.168.50.0/24
      local stratum 10
    '';
  };

  # Open DNS, DHCP and NTP on the bench interface only
  networking.firewall.interfaces.eno1 = {
    allowedUDPPorts = [ 53 67 123 ];
    allowedTCPPorts = [ 53 ];
  };
}
