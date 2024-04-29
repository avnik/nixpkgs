{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, pkg-config
, libmysqlclient
, libaio
, luajit
# For testing:
, testers
, sysbench
}:

stdenv.mkDerivation rec {
  pname = "sysbench";
  version = "1.0.20";

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ libmysqlclient luajit ] ++ lib.optionals stdenv.isLinux [ libaio ];
  depsBuildBuild = [ pkg-config ];

  src = fetchFromGitHub {
    owner = "akopytov";
    repo = pname;
    rev = version;
    sha256 = "1sanvl2a52ff4shj62nw395zzgdgywplqvwip74ky8q7s6qjf5qy";
  };

  enableParallelBuilding = true;

  configureFlags = [
    # The bundled version does not build on aarch64-darwin:
    # https://github.com/akopytov/sysbench/issues/416
    "--with-system-luajit"
    "--with-mysql-includes=${lib.getDev libmysqlclient}/include/mysql"
    "--with-mysql-libs=${libmysqlclient}/lib/mysql"
  ];

  # Vendored libck version require more hacks than regular nixpkgs' one.
  # Sysbench related on statically linked vendored libck.
  postPatch = ''
    substituteInPlace \
      third_party/concurrency_kit/ck/configure \
        --replace \
          'COMPILER=`./.1 2> /dev/null`' \
          "COMPILER=gcc" \
        --replace \
          'PLATFORM=`uname -m 2> /dev/null`' \
          "PLATFORM=${stdenv.hostPlatform.parsed.cpu.name}"
    substituteInPlace \
      third_party/concurrency_kit/ck/src/Makefile.in \
        --replace \
          "ar rcs" \
          "${stdenv.cc.targetPrefix}ar rcs"
  '';

  passthru.tests = {
    versionTest = testers.testVersion {
      package = sysbench;
    };
  };

  meta = {
    description = "Modular, cross-platform and multi-threaded benchmark tool";
    longDescription = ''
      sysbench is a scriptable multi-threaded benchmark tool based on LuaJIT.
      It is most frequently used for database benchmarks, but can also be used
      to create arbitrarily complex workloads that do not involve a database
      server.
    '';
    homepage = "https://github.com/akopytov/sysbench";
    downloadPage = "https://github.com/akopytov/sysbench/releases/tag/${version}";
    changelog = "https://github.com/akopytov/sysbench/blob/${version}/ChangeLog";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
  };
}
