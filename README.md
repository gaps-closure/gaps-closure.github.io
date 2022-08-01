# gaps-closure.github.io Webpages and Documentation

[![Generate Docs](https://github.com/gaps-closure/gaps-closure.github.io/actions/workflows/gen-docs.yml/badge.svg)](https://github.com/gaps-closure/gaps-closure.github.io/actions/workflows/gen-docs.yml)

## Building Documentation with Make

The documentation can be built using the makefiles provided.

The C documentation can be built using

```
make cdocs
```

and similary the Java documentation can built using

```
make jdocs
```

The default make target builds both.

It requires a recent version of [pandoc](https://pandoc.org) and 
[texlive](https://www.tug.org/texlive/)

## Building with Nix

If you have [nix](https://search.nixos.org/packages) installed and [flakes](https://nixos.wiki/wiki/Flakes)
enabled, you can build the documentation using `nix build`, and can activate a development shell with
pandoc and texlive installed by using `nix develop`.

## Documentation

The documentation is written in markdown and converted to PDF using pandoc. Each file corresponds with a section and given a prefix which specifies the section, e.g. `03-02-conflict-analyzer.md`.
The C and Java documentation can be found under `docs/C` and `docs/Java` respectively.
