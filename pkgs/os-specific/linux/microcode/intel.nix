{ stdenv, fetchurl, libarchive }:

stdenv.mkDerivation rec {
  name = "microcode-intel-${version}";
  version = "20150121";

  src = fetchurl {
    url = "http://downloadmirror.intel.com/24661/eng/microcode-${version}.tgz";
    sha256 = "1cznv3f25cxkwxdc930ab0ifvq0c76fryppadi4p26a2pf9knd93";
  };

  buildInputs = [ libarchive ];

  sourceRoot = ".";

  buildPhase = ''
    gcc -O2 -Wall -o intel-microcode2ucode ${./intel-microcode2ucode.c}
    ./intel-microcode2ucode microcode.dat
  '';

  installPhase = ''
    mkdir -p $out kernel/x86/microcode
    mv microcode.bin kernel/x86/microcode/GenuineIntel.bin
    echo kernel/x86/microcode/GenuineIntel.bin | bsdcpio -o -H newc -R 0:0 > $out/intel-ucode.img
  '';

  meta = with stdenv.lib; {
    homepage = http://www.intel.com/;
    description = "Microcode for Intel processors";
    license = licenses.unfreeRedistributableFirmware;
    maintainers = with maintainers; [ wkennington ];
    platforms = platforms.linux;
  };
}
