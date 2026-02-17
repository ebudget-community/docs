{
    perSystem = { pkgs, self', ... }: {
      devShells.default = self'.devShells.mkdocs;
    };
}