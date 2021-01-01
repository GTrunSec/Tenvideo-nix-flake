{
  inputs.nixpkgs.url = "nixpkgs/7ff5e241a2b96fff7912b7d793a06b4374bd846c";


  outputs = { self, nixpkgs }: {

    overlay = final: prev: {
      tenvideo = self.defaultPackage.x86_64-linux;
    };

    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };
      stdenv.mkDerivation {
        pname = "tenvideo";
        version = "1.0.10";
        src = fetchurl {
          url = "https://dldir1.qq.com/qqtv/linux/Tenvideo_universal_${self.outputs.defaultPackage.x86_64-linux.version}_amd64.deb";
          sha256 = "sha256-2JD4Z8kuNiCVB2SJbE3VTvD1UsedVZmEWNS/BGriRSo=";
        };

        buildInputs = [
          gnome3.gsettings_desktop_schemas
          glib
          gtk3
          cairo
          atk
          gdk-pixbuf
          at-spi2-atk
          dbus
          dconf
          xorg.libX11
          xorg.libxcb
          xorg.libXi
          xorg.libXcursor
          xorg.libXdamage
          xorg.libXrandr
          xorg.libXcomposite
          xorg.libXext
          xorg.libXfixes
          xorg.libXrender
          xorg.libXtst
          xorg.libXScrnSaver
          nss
          nspr
          alsaLib
          fontconfig
          libpulseaudio
          libappindicator-gtk3
        ];

        nativeBuildInputs = [
          wrapGAppsHook
          autoPatchelfHook
          makeWrapper
          dpkg
        ];

        
        runtimeLibs = lib.makeLibraryPath [ libudev0-shim glibc curl pulseaudio ];

        unpackPhase = "dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner";

        preConfigure = ''
        '';
        installPhase = ''
        mkdir -p $out/share
        mkdir -p $out/{bin,lib}
        mv usr/share/* $out/share/
        mv opt/腾讯视频/ $out/share/tenvideo
        mv $out/share/tenvideo/*.so $out/lib/

        ln -s $out/share/tenvideo/TencentVideo $out/bin/TencentVideo

        substituteInPlace $out/share/applications/TencentVideo.desktop \
          --replace "/opt/腾讯视频/TencentVideo" "$out/bin/TencentVideo"
          '';

        preFixup = ''
         gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : "${self.outputs.defaultPackage.x86_64-linux.runtimeLibs}" )
         '';

        enableParallelBuilding = true;
      };

    checks.x86_64-linux.build = self.defaultPackage.x86_64-linux;

  };

}
