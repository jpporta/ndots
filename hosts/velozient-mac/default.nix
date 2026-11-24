{ ... }:

# Work Mac. Everything shared lives in modules/darwin/base.
{
  imports = [
    ../../modules/darwin/base
  ];

  networking.hostName = "velozient-mac";
  networking.computerName = "velozient-mac";

  custom.keys = {
    ssh.comment = "Main SSH key for jpporta's Velozient Mac";
    gpg = {
      email = "joao.porta@gigawatt.ai";
      comment = "Main GPG key for jpporta's Velozient Mac";
    };
  };
}
