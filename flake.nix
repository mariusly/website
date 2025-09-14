{
  description = "Hauntingly cool website";

  inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "website";
        version = "0.1.3";

        src = ./.;

        nativeBuildInputs = [
          pkgs.glibcLocales
          pkgs.guile
          pkgs.guile-commonmark
          pkgs.haunt
        ];

        buildPhase = ''
          export LC_ALL=en_US.UTF-8
          haunt build
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          cp -r site/* $out/

          runHook postInstall
        '';
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.guile
          pkgs.guile-commonmark
          pkgs.haunt
        ];
        shellHook = ''
          echo "Entered Haunt dev shell. Run: haunt build/serve"
        '';
      };
    };
}
