final: prev: {
  flashprint = prev.flashprint.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [final.gnused];
    postInstall =
      (old.postInstall or "")
      + ''
        sed -i "s~MimeType=.*;~~" $out/share/applications/FlashPrint5.desktop
      '';
  });
}
