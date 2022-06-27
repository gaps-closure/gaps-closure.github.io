{ pkgs ? import <nixpkgs> {}, buildInputs ? [ pkgs.pandoc pkgs.texlive.combined.scheme-full ] }:
pkgs.mkShell {
    inherit buildInputs;
    shellHook = ''
        export PANDOC=${pkgs.pandoc.out}/bin/pandoc 
    '';
}