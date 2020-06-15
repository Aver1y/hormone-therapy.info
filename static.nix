{ pkgs ? import ./nixpkgs.nix
, compiler ? "ghc865"
}:
let
  static-haskell-nix = pkgs.fetchFromGitHub {
    owner = "nh2";
    repo = "static-haskell-nix";
    rev = "dbce18f4808d27f6a51ce31585078b49c86bd2b5";
    sha256 = "084hxnrywsgb73zr41argdkbhkxzm1rqn058pv1l4cp9g1gjr2rr";
  };
  survey = import "${static-haskell-nix}/survey" {
    normalPkgs = pkgs;
    inherit compiler;
  };
  haskellPackages = survey.haskellPackages
    .override (old: {
        overrides = pkgs.lib.composeExtensions
          (self: super: {
            pandoc-citeproc = self.pandoc-citeproc_0_17;
            pandoc-url2cite-hs = self.callCabal2nix "pandoc-url2cite-hs" (pkgs.fetchFromGitHub {
              owner = "Aver1y";
              repo = "pandoc-url2cite-hs";
              rev = "5e16501451cf232e71e7b8ecd4d880ef0a86f18f";
              sha256 = "1wasf2lw1nimli57jzpbdqjq5n4lyz2nzqfbpqbxacc2j94ax72m";
            }) {};
            hakyll = pkgs.haskell.lib.doJailbreak super.hakyll;
            site-gen = pkgs.haskell.lib.appendConfigureFlag
              (self.callCabal2nix "site-gen" ./site-gen {})
              # Similar to https://github.com/nh2/static-haskell-nix/issues/10
              "--ld-option=-Wl,--start-group --ld-option=-Wl,-lstdc++";
          })
          (old.overrides or (_: _: {}));
      });
in
pkgs.haskell.lib.shellAware haskellPackages.site-gen
