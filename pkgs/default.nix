final: prev: {
  custom = {
    discord-github-releases = prev.callPackage ./discord-github-releases.nix {};
    pinguino-quotes = prev.callPackage ./pinguino-quotes.nix {};
    reposilite = prev.callPackage ./reposilite.nix {};
    sat-bot = prev.callPackage ./sat-bot.nix {};
  };
}
