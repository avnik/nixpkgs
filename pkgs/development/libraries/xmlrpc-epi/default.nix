{ stdenv, fetchurl, expat }:

stdenv.mkDerivation rec {
  name = "libxmlrpc-epi-${version}";
  version = "0.54.2";
  src = fetchurl {
    url = "mirror://sourceforge/xmlrpc-epi/xmlrpc-epi-base/${version}/xmlrpc-epi-${version}.tar.bz2";
    sha256 = "1f6hvqndc290pawpb9r5j3v6fjvi35vg70la2f80h50bd3xzhkn7";
  };

  buildInputs = [ expat ];

  meta = with stdenv.lib; {
    description = "implementation of the xmlrpc protocol in C";
    homepage = "http://xmlrpc-epi.sourceforge.net/";
    license = licenses.bsd3;
    mainainer = with maintaines; [ avnik ];
  };
}
