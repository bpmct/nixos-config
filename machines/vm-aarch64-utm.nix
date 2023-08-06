# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

let
  apple-emoji = pkgs.callPackage ../pkgs/apple-emoji.nix { };
  dbus-sway-environment = pkgs.writeTextFile {
  name = "dbus-sway-environment";
  destination = "/bin/dbus-sway-environment";
  executable = true;

  text = ''
    dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
    systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  '';
  };
in
{
  imports =
    [
      ../pkgs/sysbox.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  i18n.defaultLocale = "en_CA.UTF-8";
  networking.hostName = "m2-nixos";
  networking.networkmanager.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" "impure-derivations" ];
  time.timeZone = "America/Chicago";

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # Enable graphics virtualization.
  hardware.opengl.enable = true;

  # Add my user!
  users.users.benpotter = {
    isNormalUser = true;
    description = "Ben Potter";
    # Wheel allows sudo without password.
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish;
  };
  security.sudo.wheelNeedsPassword = false;

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    alacritty
    chromium
    firefox
    go_1_20
    fish
    flameshot
    yarn
    htop
    nixpkgs-fmt
    tor
    bintools
    google-cloud-sdk
    nodejs-18_x
    tailscale
    vscode
    bat
    unzip
    git
    gnumake
    jq
    gh
    glxinfo
    vim
    gotools
    libnotify
    xorg.libxcvt
    arandr
    # gnome3.nautilus
    # xorg.xev
    # xorg.xmodmap
    # mate.caja

    # Sway stuff
    dbus-sway-environment
    configure-gtk
    wayland
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    dracula-theme # gtk theme
    gnome3.adwaita-icon-theme  # default gnome cursors
    swaylock
    swayidle
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    bemenu # wayland clone of dmenu
    mako # notification system developed by swaywm maintainer
    wdisplays # tool to configure displays
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # enable sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  programs.fish.enable = true;
  
  # Required for automating resizing with UTM.
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  
  # Docker
  virtualisation.docker.enable = true;
  services.sysbox.enable = true;
  services.tailscale.enable = true;
  # Useful for VS Code storing credentials.
  services.gnome.gnome-keyring.enable = true;

  # Change the display manager to i3.
  # services.xserver = {
  #   enable = true;
  #   layout = "us";
  #   xkbVariant = "";

  #   # For Ultrawide
  #   # dpi = 120;

  #   # For laptop
  #   dpi = 220;

  #   desktopManager = {
  #     xterm.enable = false;
  #   };

  #   displayManager = {
  #     autoLogin.enable = true;
  #     autoLogin.user = "benpotter";
  #     defaultSession = "none+i3";
  #   };

  #   windowManager.i3 = {
  #     enable = true;
  #     extraPackages = with pkgs; [
  #       dmenu
  #       rofi
  #       i3status
  #       i3lock
  #       i3blocks
  #       xclip
  #       xorg.libXcursor
  #       xorg.libXi
  #       dunst

  #       # Required for py3status to work!
  #       (python3.withPackages (p: with p; [
  #         python-dateutil
  #         google-api-python-client
  #         httplib2
  #         py3status
  #       ]))
  #     ];
  #   };
  # };

  # Adjusts the scaling of the display.
  environment.variables = {
    GDK_SCALE = "2";
    # For Ultrawide
    # GDK_DPI_SCALE = "0.5";

    # For laptop
    GDK_DPI_SCALE = "0.4";
  };
  
  # Makes Chrome use dark mode by default!
  environment.etc = {
    "xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme = true
    '';
  };

  fonts.fonts = with pkgs; [ apple-emoji fira-code ];
  fonts.fontconfig.defaultFonts.emoji = [ "Apple Color Emoji" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.htm
  system.stateVersion = "23.05";
}
