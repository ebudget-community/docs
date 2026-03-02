{
    perSystem = { pkgs, self', ... }: {
      devShells.default = self'.devShells.uv2nix;
    };
}