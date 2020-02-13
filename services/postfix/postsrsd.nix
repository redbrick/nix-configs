# SecretsFile is automatically created by this service's module
{config, pkgs, ...}:
let
  tld = config.redbrick.tld;
in {
  services.postsrsd = {
    enable = true;
    domain = tld;
    excludeDomains = [ "mail.${tld}" ];
    secretsFile = "/var/secrets/postsrsd.secret";
  };
}
