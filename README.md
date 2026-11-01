# supernode NixOS config

Flake for the Beelink (hostname `supernode`) on NixOS 26.05.

| File | What's in it |
|---|---|
| `flake.nix` | Inputs (nixpkgs 26.05 + unstable) and the `supernode` system output |
| `configuration.nix` | Boot, GNOME, user, SSH, mDNS, nix settings |
| `dev.nix` | VS Code Insiders, Chromium, languages, embedded tools, Claude Code, Codex |
| `windows-vm.nix` | libvirt/QEMU + virt-manager for the S32DS Windows VM |
| `bench-lan.nix` | eno1 static IP, dnsmasq DHCP/DNS for `.bench`, chrony NTP (optional, drop the import if unwanted) |
| `vscode-insiders.json` | Pinned Insiders build, updated by `update-insiders.sh` |
| `hardware-configuration.nix` | Not in this repo until you copy it from `/etc/nixos` |
