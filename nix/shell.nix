{
  perSystem = { pkgs, self', ... }: {
    devShells.mkdocs = let
      pythonEnv = pkgs.python314.withPackages (ps: with ps; [
        mkdocs
        mkdocs-material
        mkdocs-minify-plugin
        pymdown-extensions
        mkdocs-get-deps
        mkdocs-exclude
        mkdocs-table-reader-plugin
      ]);
    in
      (pkgs.mkShell {
        name = "mkdocs-shell";

        buildInputs = [
          pythonEnv
          pkgs.just
          pkgs.git
        ];

        shellHook = ''
          export PS1="(mkdocs) ''${PS1}";
        '';

      }
    );
  };
}