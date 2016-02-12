{ stdenv, fetchFromGitHub, autoconf, automake, libtool, glib, gtk3, dbus, pkgconfig,
  file, intltool, openconnect }:

stdenv.mkDerivation rec {
  pname = "connman-gtk";
  name = "${pname}-${version}";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "jgke";
    repo = pname;
    rev = "v${version}";
    sha256 = "09k0hx5hxpbykvslv12l2fq9pxdwpd311mxj038hbqzjghcyidyr";
  };

  buildInputs = [ autoconf automake libtool glib gtk3 dbus pkgconfig file intltool openconnect ];

  preConfigure = ''
    rm m4/intltool.m4
    ln -s ${intltool}/share/aclocal/intltool.m4 m4/
    set -e
    ./autogen.sh
    sed -i "s/\/usr\/bin\/file/file/g" ./configure
  '';

  configureScript = "./configure";

  meta = with stdenv.lib; {
    description = "Alternative GTK GUI for connman";
    homepage = "https://github.com/jgke/connman-gtk";
    maintainers = [ maintainers.avnik ];
    platforms = platforms.linux;
    license = licenses.gpl2;
  };
}
