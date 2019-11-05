{ compiler    ? "ghc863"
, system      ? builtins.currentSystem
, doBenchmark ? false
, doTracing   ? false
, doStrict    ? false
, rev         ? "a3b6b49eac91baa25a01ef10b74a7aeb89a963a1"
, sha256      ? "1za2mvmc9nlxb91syd608fjrkm53rm658nflracy1js1a3nlaj06"
, pkgs        ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    inherit sha256; }) {
    inherit system;
    config.allowUnfree = true;
    config.allowBroken = false;
  }
, returnShellEnv ? pkgs.lib.inNixShell
, mkDerivation ? null
}:

let
  haskellPackages = pkgs.haskell.packages.${compiler};

  pact = import ../pact;

in haskellPackages.developPackage {
  root = ./.;

  overrides = self: super: {
  };

  source-overrides = {
  };

  modifier = drv: pkgs.haskell.lib.overrideCabal drv (attrs: {
    doCheck = false;
    executableSystemDepends = (attrs.executableSystemDepends or []) ++ [
      pact
      pkgs.python27
      pkgs.jq
      pkgs.bash
      pkgs.curl
    ];

    preBuild = ''
      sed -i -e "s%\"balance\",%\"$out/bin/balance\",%" src/App.hs
      sed -i -e 's%PACT=pact%PACT=${pact}/bin/pact%' balance
      sed -i -e 's%\bcurl\b%${pkgs.curl}/bin/curl%' balance
      sed -i -e 's%\bpython\b%${pkgs.python27}/bin/python%' balance
      sed -i -e 's%\bjq\b%${pkgs.jq}/bin/jq%' balance
    '';

    postInstall = ''
      mkdir -p $out/bin
      cp balance $out/bin
    '';

    inherit doBenchmark;
  });

  inherit returnShellEnv;
}
