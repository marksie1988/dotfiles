{ pkgs, username, ... }:
{
  # ---- Nix / platform ----
  # Nix itself is installed by the Determinate Systems installer (see
  # setup/bootstrap.sh), which manages the daemon and enables flakes. Tell
  # nix-darwin not to manage the Nix installation to avoid conflicting with it.
  nix.enable = false;

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Bump only when the nix-darwin release notes say to.
  system.stateVersion = 5;

  # Required by recent nix-darwin for user-scoped defaults + Homebrew.
  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  # zsh as login shell; /etc/zshrc sources the Nix profile.
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  # ---- Fonts (was .zsh/installers/fonts.sh — Hack Nerd Font) ----
  fonts.packages = [ pkgs.nerd-fonts.hack ];

  # ---- GUI apps via declarative Homebrew (was optional.sh) ----
  # Homebrew itself must already be installed (bootstrap.sh handles that).
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = false;
      # "none" leaves manually-installed casks alone. Switch to "zap" for strict
      # reproducibility (removes everything not listed below — destructive).
      cleanup = "none";
    };
    # CLI formulae (prebuilt bottles) — avoids a heavy from-source Nix build.
    brews = [
      "herdr" # agent multiplexer (https://herdr.dev)
    ];
    # GUI apps only — CLI tools come from Nix (home/packages.nix), shared with
    # Linux. Hack Nerd Font is NOT a cask here: it's provided by fonts.packages.
    casks = [
      "ghostty"
      "visual-studio-code"
      "1password"
      "android-studio"
      "angry-ip-scanner"
      "dbeaver-community"
      "displaylink"
      "gcloud-cli"
      "google-drive"
      "inkscape"
      "keybase"
      "mqttx"
      "warp"
      # claude-code cask intentionally omitted: claude is installed via the
      # official self-updating installer at ~/.local/bin/claude.
    ];
  };

  # ---- macOS system defaults (was .zsh/installers/macos_defaults.sh) ----
  # Note: purely imperative bits from the old script (boot-sound nvram,
  # chflags, lsregister, Launchpad reset, killall) are not carried over — they
  # aren't declarative settings. nix-darwin applies these on activation.
  system.defaults = {
    NSGlobalDomain = {
      NSNavPanelExpandedStateForSaveMode = true;
      PMPrintingExpandedStateForPrint = true;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      AppleShowAllExtensions = true;
      "com.apple.mouse.tapBehavior" = 1;
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      tilesize = 36;
      mineffect = "scale";
      minimize-to-application = true;
      show-process-indicators = true;
      launchanim = false;
      expose-animation-duration = 0.1;
      mru-spaces = false;
      showhidden = true;
      show-recents = false;
      dashboard-in-overlay = true;
    };

    finder = {
      ShowStatusBar = true;
      ShowPathbar = true;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      AppleShowAllExtensions = true;
    };

    trackpad.Clicking = true;

    ActivityMonitor = {
      OpenMainWindow = true;
      IconType = 5;
      ShowCategory = 100; # 100 = All Processes (nixpkgs 26.11 requires the 100–107 enum; was 0)
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };

    # The long tail — written verbatim via `defaults`, no schema validation.
    CustomUserPreferences = {
      "NSGlobalDomain" = {
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint2 = true;
        WebKitDeveloperExtras = true;
      };
      "com.apple.print.PrintingPrefs" = {
        "Quit When Finished" = true;
      };
      "com.apple.LaunchServices" = {
        LSQuarantine = false;
      };
      "com.apple.finder" = {
        WarnOnEmptyTrash = false;
        OpenWindowForNewRemovableDisk = true;
      };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.frameworks.diskimages" = {
        auto-open-ro-root = true;
        auto-open-rw-root = true;
      };
      "com.apple.dock" = {
        mouse-over-hilite-stack = true;
        enable-spring-load-actions-on-all-items = true;
        expose-group-by-app = false;
      };
      "com.apple.dashboard" = {
        mcx-disabled = true;
      };
      "com.apple.Safari" = {
        ShowFavoritesBar = false;
        ShowSidebarInNewWindowsAtLaunch = false;
        DebugSnapshotsUpdatePolicy = 2;
        IncludeInternalDebugMenu = true;
        FindOnPageMatchesWordStartsOnly = false;
        IncludeDevelopMenu = true;
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
        SendDoNotTrackHTTPHeader = true;
        InstallExtensionUpdatesAutomatically = true;
      };
      "com.apple.mail" = {
        DisableReplyAnimations = true;
        DisableSendAnimations = true;
        AddressesIncludeNameOnPasteboard = false;
        DisableInlineAttachmentViewing = true;
        SpellCheckingBehavior = "NoSpellCheckingEnabled";
        DraftsViewerAttributes = {
          DisplayInThreadedMode = "yes";
          SortedDescending = "yes";
          SortOrder = "received-date";
        };
      };
      "com.apple.TimeMachine" = {
        DoNotOfferNewDisksForBackup = true;
      };
      "com.apple.terminal" = {
        StringEncodings = [ 4 ];
      };
      "com.apple.messageshelper.MessageController" = {
        SOInputLineSettings = {
          automaticQuoteSubstitutionEnabled = false;
          continuousSpellCheckingEnabled = false;
        };
      };
      "com.apple.ImageCapture" = {
        disableHotPlug = true;
      };
    };
  };
}
