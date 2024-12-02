{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-marketplace; [
      astro-build.astro-vscode
      barbosshack.crates-io
      bbenoist.nix
      bierner.markdown-emoji
      bierner.markdown-preview-github-styles
      bradlc.vscode-tailwindcss
      christian-kohler.path-intellisense
      dbaeumer.vscode-eslint
      denoland.vscode-deno
      editorconfig.editorconfig
      esbenp.prettier-vscode
      formulahendry.auto-rename-tag
      foxundermoon.shell-format
      github.copilot
      github.copilot-chat
      github.vscode-github-actions
      golang.go
      heybourn.headwind
      kamikillerto.vscode-colorize
      mechatroner.rainbow-csv
      mkhl.direnv
      ms-azuretools.vscode-docker
      ms-python.black-formatter
      ms-python.mypy-type-checker
      ms-python.python
      ms-python.vscode-pylance
      pkgs.vscode-extensions.ms-vscode.cpptools # not provided by nix-vscode-extensions due to needing patching
      redhat.vscode-xml
      redhat.vscode-yaml
      rust-lang.rust-analyzer
      sclu1034.justfile
      svelte.svelte-vscode
      tamasfe.even-better-toml
      timonwong.shellcheck
      ultram4rine.vscode-choosealicense
      usernamehw.errorlens
      vscode-icons-team.vscode-icons
      wayou.vscode-todo-highlight
      yoavbls.pretty-ts-errors
    ];
  };
}
