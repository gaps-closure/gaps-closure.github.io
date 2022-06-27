{
    description = "CLOSURE Documentation and Website";
    inputs.flake-utils.url = "github:numtide/flake-utils";
    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem 
        (system:
            let 
            pkgs = nixpkgs.legacyPackages.${system};
            buildInputs = [ pkgs.pandoc pkgs.texlive.combined.scheme-full ];
            in
            {
                devShell = pkgs.mkShell {
                    inherit buildInputs;
                    shellHook = ''
                        export PANDOC=${pkgs.pandoc.out}/bin/pandoc 
                    '';
                };
                defaultPackage = pkgs.stdenv.mkDerivation {
                    name = "CLOSURE C Docs";
                    src = ./.; 
                    inherit buildInputs;
                    installPhase = ''
                        mkdir -p $out
                        mv doc.html doc.pdf $out/
                    '';
                };
            }
        );
}