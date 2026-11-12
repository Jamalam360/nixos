final: prev: {
  scripts = {
    copy-artifacts-to-prism = prev.callPackage ./copy-artifacts-to-prism.nix {};
    devshell-init = prev.callPackage ./devshell-init.nix {};
    mcserver = prev.writers.writePython3Bin "mcserver" {flakeIgnore = ["E501"];} (builtins.readFile ./mcserver.py);
  };
}
