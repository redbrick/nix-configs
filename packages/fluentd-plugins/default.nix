{ pkgs, bundlerEnv ? pkgs.bundlerEnv, ruby ? pkgs.ruby }:

bundlerEnv {
  inherit ruby;
  name = "fluentd-plugins";
  gemdir = ./.;
}
