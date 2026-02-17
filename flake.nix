{
  description = "ebudget-community.ru MkDocs Documentation Project";

  inputs = {
    # Using latest nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Flake Parts tool
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Import Tree tool
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./nix);
}