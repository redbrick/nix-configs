{ config, ... }:
let
  milterPort = "/run/rspamd/milter.sock";
in {
  # Not necessary since it's in the postfix import, but just in case
  imports = [
    ../redis.nix
  ];

  # Add rspamd to redis group
  users.users.rspamd.extraGroups = [
    "redis"
  ];

  # Ensure redis is started before rspamd
  systemd.services.postfix = {
    requires = [ "redis.service" ];
    after = [ "redis.service" ];
  };

  services.rspamd = {
    enable = true;
    postfix = {
      enable = true;
      config = {
        smtpd_milters = [ "unix:${milterPort}" ];
        non_smtpd_milters = [ "unix:${milterPort}" ];
      };
    };
    overrides."options.inc".text = ''
      # Don't whitelist any IP addresses for SPF/DKIM checks
      # This unfortunately doesn't work, at least when implemented in 2020
      # and thus we have to blacklist local IPs sending unauthed mail in postfix
      local_addrs = [];
    '';
    locals."redis.conf".text = ''
      # Redis is needed for a number of modules
      servers = "/run/redis/redis.sock";
    '';
    locals."dkim_signing.conf".text = ''
      path = "/var/secrets/$domain.$selector.dkim.key";
      selector = "${config.networking.hostName}";
      allow_username_mismatch = true;
      sign_local = false;
      sign_authenticated = true;
	  use_esld = false;
    '';
    locals."worker-controller.inc".text = ''
      # generate a password hash using the `rspamadm pw` command and put it here
      # This is git safe - it's a hash, for god sake
      password = "$2$6znhwcxm4f3aja5d4cwaj1pheayfddms$13x4n1kn8frfnnx6mwkpchi3twd9napyqpf4pyom5rrqktxdgobb";
      enable_password = "$2$6znhwcxm4f3aja5d4cwaj1pheayfddms$13x4n1kn8frfnnx6mwkpchi3twd9napyqpf4pyom5rrqktxdgobb";

      # dovecot will use this socket to communicate with rspamd
      # RuntimeDirectory created by systemd in nixpkgs module for rspamd
      bind_socket = "/run/rspamd/rspamd.sock mode=0660 owner=rspamd group=dovecot2";

      # you can comment this out if you don't need the web interface
      bind_socket = "127.0.0.1:11334";
    '';
    locals."worker-normal.inc".text = ''
      # we're not running rspamd in a distributed setup, so this can be disabled
      # the proxy worker will handle all the spam filtering
      enabled = false;
    '';
    locals."worker-proxy.inc".text = ''
      # this worker will be used as postfix milter
      milter = yes;

      # RuntimeDirectory created by systemd in nixpkgs module for rspamd
      bind_socket = "${milterPort} mode=0660 owner=rspamd group=postfix";

      # the following specifies self-scan mode, for when rspamd is on the same
      # machine as postfix
      timeout = 120s;
      upstream "local" {
        default = yes;
        self_scan = yes;
      }
    '';
    locals."classifier-bayes.conf".text = ''
      autolearn = true;
      backend = "redis";
    '';
    locals."maillist.conf".text = "";
    locals."mx_check.conf".text = ''
      enabled = true;
    '';
    locals."phishing.conf".text = ''
      openphis_enabled = true;
      phishtank_enabled = true;
    '';
    locals."replies.conf".text = ''
      action = "no action";
    '';
    locals."spf.conf".text = ''
      spf_cache_size = 2k;
      spf_cache_expire = 1d;
      max_dns_nesting = 8;
      max_dns_requests = 20;
      min_cache_ttl = 5m;
      disable_ipv6 = false;
    '';
    locals."dkim.conf".text = ''
      dkim_cache_size = 2k;
    '';
    locals."url_reputation.conf".text = ''
      # Scan URLs
      enabled = true;
    '';
    locals."url_tags.conf".text = ''
      # Redis caching of URL tags
      enabled = true;
    '';
  };
}
