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
                devShell = import ./shell.nix { inherit pkgs buildInputs; };
                defaultPackage = pkgs.stdenv.mkDerivation {
                    name = "CLOSURE Docs";
                    src = ./.; 
                    inherit buildInputs;
                    installPhase = ''
                        mkdir -p $out
                        mv cdoc.html cdoc.pdf $out/
                    '';
                };
            }
        );
}