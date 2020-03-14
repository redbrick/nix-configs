{
  # libksi has an outdated dependency on openssl_1_0_2
  # We don't need it, so remove it from rsyslog
  nixpkgs.overlays = [
    (self: super: {
      rsyslog = super.rsyslog.override {
        libksi = null;
      };
    })
  ];
}
