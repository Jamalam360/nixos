{
  pkgs,
  lib,
  ...
}: {
  programs.vscode = {
    enable = true;
    userSettings = {
      "[astro]"."editor.defaultFormatter" = "astro-build.astro-vscode";
      "[c]"."editor.defaultFormatter" = "ms-vscode.cpptools";
      "[go]"."editor.defaultFormatter" = "golang.go";
      "[html]"."editor.defaultFormatter" = "vscode.html-language-features";
      "[jsonc]"."editor.defaultFormatter" = "vscode.json-language-features";
      "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
      "[python]"."editor.defaultFormatter" = "ms-python.black-formatter";
      "[rust]"."editor.defaultFormatter" = "rust-lang.rust-analyzer";
      "[svelte]"."editor.defaultFormatter" = "svelte.svelte-vscode";
      "[toml]"."editor.defaultFormatter" = "tamasfe.even-better-toml";
      "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[xml]"."editor.defaultFormatter" = "redhat.vscode-xml";
      "[yaml]"."editor.defaultFormatter" = "redhat.vscode-yaml";

      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.detectIndentation" = true;
      "editor.fontFamily" = lib.mkForce "'Inconsolata', 'monospace', monospace";
      "editor.fontSize" = 16;
      "editor.formatOnSave" = true;
      "editor.formatOnType" = true;
      "editor.inlineSuggest.enable" = true;
      "editor.insertSpaces" = false;
      "editor.minimap.enabled" = false;
      "editor.renderWhitespace" = "trailing";
      "editor.stickScroll.maxLineCount" = 3;
      "editor.stickyScroll.enabled" = true;
      "editor.tabSize" = 4;
      "explorer.confirmDragAndDrop" = false;
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "git.autoFetch" = true;
      "git.confirmSync" = false;
      "git.enableSmartCommit" = true;
      "git.openRepositoryInParentFolders" = "never";
      "github.copilot.editor.enableAutoCompletions" = true;
      "javascript.updateImportsOnFileMove.enabled" = "always";
      "prettier.printWidth" = 120;
      "redhat.telemetry.enabled" = false;
      "search.followSymlinks" = false;
      "typescript.updateImportsOnFileMove.enabled" = "always";
      "vsicons.dontShowNewVersionMessage" = true;
      "window.autoDetectColorScheme" = true;
      "workbench.preferredDarkColorTheme" = "Solarized Dark";
      "workbench.preferredLightColorTheme" = "Solarized Light";
      "workbench.iconTheme" = "vscode-icons";
      "[markdown]" = {
        "editor.defaultFormatter" = "edbenp.prettier-vscode";
        "editor.wordWrap" = "on";
        "editor.quickSuggestions" = {
          comments = "off";
          other = "off";
          strings = "off";
        };
        "editor.unicodeHighlight" = {
          ambiguousCharacters = false;
          invisibleCharacters = false;
        };
      };
    };

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
