{ pkgs, pkgs-unstable, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    # ---- editors / browsers
    vscode
    chromium 
    neovim 
    ghostty

    # ---- C / C++
    gcc
    gnumake
    cmake
    ninja
    gdb
    clang-tools       # clangd, clang-format, clang-tidy
    pkg-config

    # ---- other languages (Java is configured below via programs.java)
    maven
    gradle
    python3
    uv                # Python projects/venvs; global pip installs don't work on NixOS
    nodejs            # current LTS
    go
    rustup

    # ---- embedded / bench
    gcc-arm-embedded  # arm-none-eabi-*
    can-utils         # candump, cansend, canplayer
    tio               # serial console
    usbutils          # lsusb
    pciutils          # lspci

    # ---- everyday CLI
    git
    gh
    curl
    wget
    jq                # also used by update-insiders.sh
    ripgrep
    fd
    btop
    tmux
    tree
    unzip
    file
  ]) ++ [
    # ---- AI coding agents, from unstable so they're closer to upstream
    pkgs-unstable.claude-code
    pkgs-unstable.codex
    pkgs-unstable.code-cursor
  ];

  # JDK on PATH plus JAVA_HOME
  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  # Lets generic Linux binaries run, most importantly the VS Code Server
  # that Remote-SSH from the MacBook drops into ~/.vscode-server.
  # Without this, Remote-SSH to a NixOS host fails.
  programs.nix-ld.enable = true;

  # Auto-load a project's devShell when you cd into it (via .envrc)
  programs.direnv.enable = true;

  # Nicer rebuild/cleanup wrapper:
  #   nh os switch   (rebuild from the flake path below)
  #   nh clean all   (manual cleanup; also runs weekly)
  programs.nh = {
    enable = true;
    flake = "/home/supernode/nixos-config";
    clean.enable = true;
    clean.extraArgs = "--keep-since 14d --keep 5";
  };

  # Run Chromium/Electron apps natively on Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
