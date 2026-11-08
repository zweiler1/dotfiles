{
  programs = {
    git = {
      enable = true;

      settings = {
        user = {
          name = "Marc Zweiler";
          email = "marc.zweiler@outlook.at";
        };

        init.defaultBranch = "main";
        fetch.prune = true;
      };

      signing = {
        format = "openpgp";
        key = "5D51 A11D 0F30 FD88 D291  73AC 6D7C F0EA 0ABD 3370";
        signByDefault = true;
      };
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
}
