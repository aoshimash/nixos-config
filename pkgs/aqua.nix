{
  lib,
  fetchurl,
  stdenvNoCC,
  autoPatchelfHook,
}:
let
  pname = "aqua";
  version = "2.56.7";

  src = fetchurl {
    url = "https://github.com/aquaproj/aqua/releases/download/v${version}/aqua_linux_amd64.tar.gz";
    hash = "sha256-KMZjNSZUUawNNKNk5Xg25tc+9Vy7lpgmXOPuK5fxx8A=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook ];

  unpackPhase = ''
    tar xzf $src
  '';

  installPhase = ''
    install -Dm755 aqua $out/bin/aqua
  '';

  meta = {
    description = "Declarative CLI Version Manager";
    homepage = "https://aquaproj.github.io/";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "aqua";
  };
}
