{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = "dstengele";
  home.homeDirectory = "/home/dstengele";

  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    jira-cli-go
    lazygit
    _1password-cli
    _1password-gui
    firefox
    jwt-cli
    ffmpeg
    yt-dlp
    nixfmt
  ];

  programs = {
    home-manager.enable = true;
    go = {
      enable = true;
      packages = {
        "github.com/barnardb/cookies" = builtins.fetchGit {
          url = "https://github.com/barnardb/cookies.git";
          rev = "964a94d2885feda7378a5faa275981f2664a0c3c";
        };
      };
    };
    zsh = {
      enable = true;
      enableVteIntegration = true;
      autocd = true;
      history = {
        append = true;
        extended = true;
      };
      historySubstringSearch = { enable = true; };
      syntaxHighlighting = { enable = true; };
      zplug = {
        enable = true;
        plugins = [{ name = "popstas/zsh-command-time"; }];
      };
      shellAliases = {
        is_mac = ''[[ $(uname) == "Darwin" ]]'';
        ll = "ls -lah";
        l = "ls -lAh";
        gs = "git status";
        ga = "git add";
        gb = "git branch";
        gc = "git commit";
        gd = "git diff";
        gco = "git checkout";
        du = "du -h";
        duh = "du -h -d";
        tmux = "tmux -u";
        playspace =
          "play -nq -c1 synth whitenoise band -n 100 20 band -n 50 20 gain +30 fade h 1 86400 1";
        playnetwork =
          "sudo tcpdump -n -w- | play --buffer 10000 -r 8000 -b 8 -c 1 -e signed-integer -t raw - band 2k vol 0.1";
        dunnet = "emacs -batch -l dunnet";
        ls = "ls -Gh --color=auto";
        path = ''echo $PATH | tr ":" "\n"'';
        csvview =
          "column -s \\; -t | vim -c 'set scrollopt=hor | set nowrap | 1split | windo set scrollbind' -";

        wincbpaste =
          "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe Get-Clipboard | sed 's/\\r$//' | head -c -1";
        wincbcopy =
          "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command '(\\$input | Out-String -Stream) -join \\\"\\`r\\`n\\\" | Set-Clipboard'";

        disk_ids = ''
          ls -la /dev/disk/by-id/ | tail -n+4 | grep -v part | rev | sort | rev | awk '{ printf "%s\t%s\t%s\n", $(NF-2), $(NF-1), $(NF) }' | column -t'';
      };
      localVariables = {
        VIRTUAL_ENV_DISABLE_PROMPT = "1";
        WORKON_HOME = "$HOME/.virtualenv";
        PROJECT_HOME = "$HOME/Development";
        ZSH_DISABLE_COMPFIX = "true";
        COLORTERM = "truecolor";
        EDITOR = "vim";
        TAPE = "/dev/st0m";
        AZURE_IDENTITY_DISABLE_CP1 = "1";
      };
      initContent = builtins.readFile ./shellInit.zsh;
    };
  };
}
