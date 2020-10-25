{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation rec {
  pname = "inspircd";
  version = "3.7.0";

  extras = [
    "ldap"
    "regex_posix"
    "ssl_gnutls"
    "ssl_openssl"
    "sslrehashsignal"
  ];

  src = fetchFromGitHub {
    owner = "inspircd";
    repo = "inspircd";
    sha256 = "1npzp23c3ac7m1grkm39i1asj04rs4i0jwf5w0c0j0hmnwslnz7a";
    rev = "v${version}";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ openldap perl openssl gnutls pkgconfig ];


  # So, this package is still not ready for prime-time. Why not?
  # Well, two reasons:
  # 1. the postInstallPhase include stuff below doesn't actually work. No clue
  # why.
  # 2. include probably is being handled wrong, as are modules
  # So for 2, what do I mean? Ideally we want the longer-term thing to be that
  # the inspircd bin is one output (what you run), the modules are another
  # (which the bin loads dynamically), and the include is a third (which is
  # used for compiling out-of-tree modules).
  # Using multiple outputs is something I'm not super familiar with, so I
  # didn't get it working to my satisfaction.
  # I'm going to just leave this bad derivation off in my tree and use it for
  # now, but I'll go back and ask for help on #nixos or on a PR in the future
  # and get this merged.
  configurePhase = ''
    patchShebangs ./configure ./make/unit-cc.pl

    ./configure --enable-extras=${builtins.concatStringsSep "," extras}
    ./configure --disable-interactive \
      --prefix=$prefix \
      --manual-dir=$out/doc \
      --binary-dir=$out/realbin
  '';

  buildPhase = ''
    # otherwise it uses /bin/pwd
    make $makeFlags SOURCEPATH=$PWD
  '';

  installPhase = ''
    # same deal
    make install $makeFlags SOURCEPATH=$PWD
  '';

  postInstallPhase = ''
    mkdir -p $out/include
    cp -R $src/include $out/include
  '';

  # Sooo, inspircd has two types of binaries it outputs
  # In the '--binary-dir' above, it plops two perl scripts (a service manager
  # one that knows how to stop and start the inspircd bin) and a 'genssl' one.
  # Frankly, I think they're both unneeded on nixos. We can use a systemd
  # service file and generate ssl more reasonably without using those perl
  # scripts imho.
  fixupPhase = ''
    # perl scripts
    rm -f $out/inspircd
    rmdir $out/logs $out/data
    # real elf binaries
    mv $out/realbin $out/bin
  '';


  meta = {
    homepage    = "https://www.inspircd.org/";
    description = "A modular C++ IRC server";
    platforms   = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ butlerx ];
    license     = stdenv.lib.licenses.gpl2Plus;
  };
}
