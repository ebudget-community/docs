{ inputs, self, ... }: {
  perSystem = { pkgs, lib, ... }: {

    devShells.uv2nix = 
    let
      python = pkgs.python312;

      pythonBase = pkgs.callPackage inputs.pyproject-nix.build.packages {
        inherit python;
      };

      workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
        workspaceRoot = self;
      };
      
      overlay = workspace.mkPyprojectOverlay {
        sourcePreference = "wheel";
      };

      pythonSet = pythonBase.overrideScope (
        lib.composeManyExtensions [
          inputs.pyproject-build-systems.overlays.wheel
          overlay

          # Мне эту хитрую конструкцию Google (ИИ-режим) предложил, но она работает...
          (final: prev: 
            let 
              # Список пакетов, которым не хватает setuptools для сборки
              legacyPackages = [
                "csscompressor"
                "jsmin"
                "mkdocs-exclude"
              ];
              
              fixLegacy = name: {
                ${name} = prev.${name}.overrideAttrs (old: {
                  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.setuptools ];
                });
              };
            in
              lib.foldl' lib.recursiveUpdate {} (map fixLegacy legacyPackages)
          )
        ]
      );

      virtualenv = pythonSet.mkVirtualEnv "mkdocs-env" workspace.deps.default;
    in
      (pkgs.mkShell {
        name = "mkdocs-shell";

        packages = [
          virtualenv
          pkgs.uv
          pkgs.just
          pkgs.git
        ];

        env = {
          UV_NO_SYNC = "1";
          UV_PYTHON = pythonSet.python.interpreter;
          UV_PYTHON_DOWNLOADS = "never";
        };

        shellHook = ''
          unset PYTHONPATH
          export REPO_ROOT=$(git rev-parse --show-toplevel)
          export PS1="(mkdocs)\\040''${PS1}";
        '';

      });

    devShells.uv = pkgs.mkShell {
      name = "uv-shell";

      buildInputs = with pkgs; [
        uv
        just
        git
      ];

      shellHook = ''
        export PS1="(uv)\\040''${PS1}";
      '';
    };
    
  };

}