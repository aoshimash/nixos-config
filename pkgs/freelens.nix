{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "freelens";
  version = "1.8.1";

  src = fetchurl {
    url = "https://github.com/freelensapp/freelens/releases/download/v${version}/Freelens-${version}-linux-amd64.AppImage";
    hash = "sha256-Goe/eAmefL+4itHrGmQjBGVWalk559kGg/OgA1yKKdk=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/freelens.desktop $out/share/applications/freelens.desktop
    install -Dm444 ${appimageContents}/freelens.png $out/share/pixmaps/freelens.png
    substituteInPlace $out/share/applications/freelens.desktop \
      --replace-warn 'Exec=AppRun' 'Exec=freelens'
  '';

  meta = {
    description = "Open-source Kubernetes IDE";
    homepage = "https://github.com/freelensapp/freelens";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "freelens";
  };
}
