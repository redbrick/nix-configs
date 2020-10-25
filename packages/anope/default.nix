{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation rec {
  pname = "anope";
  version = "2.0.7";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    sha256 = "1lbdjmyby8iz0782y9mfshl5a6b7isn2b2zavgsflrfj90s82xam";
    rev = version;
  };

  enableParallelBuilding = true;

  buildInputs = [ mysql-client libmysqlclient sqlite ];
  nativeBuildInputs = [ cmake pkgconfig openssl gnutls pkgconfig ];

  preConfigure = ''
    ln -s $PWD/modules/extra/m_ssl_openssl.cpp $PWD/modules
    ln -s $PWD/modules/extra/m_mysql.cpp $PWD/modules
    ln -s $PWD/modules/extra/m_sqlite.cpp $PWD/modules
  '';

  cmakeFlags = ["-DDEFUMASK=077" "-DCMAKE_BUILD_TYPE=RELEASE"];

  postInstallPhase = ''
    mkdir -p $out/include
    cp -R $src/include $out/include
  '';

  meta = {
    homepage    = "https://www.anope.org/";
    description = "Anope is an open source set of IRC Services";
    platforms   = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ butlerx ];
    license     = stdenv.lib.licenses.gpl2;
  };
}
