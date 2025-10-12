final: prev: {
  scripts = {
    copy-artifacts-to-prism = prev.callPackage ./copy-artifacts-to-prism.nix {};
    devshell-init = prev.callPackage ./devshell-init.nix {};
  };
}
