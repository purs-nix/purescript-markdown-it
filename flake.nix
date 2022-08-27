{ inputs =
    { make-shell.url = "github:ursi/nix-make-shell/1";
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

      npmlock2nix =
        { flake = false;
          url = "github:nix-community/npmlock2nix";
        };

      ps-tools.follows = "purs-nix/ps-tools";
      purs-nix.url = "github:purs-nix/purs-nix/ps-0.14";
      utils.url = "github:ursi/flake-utils/8";
    };

  outputs = { utils, ... }@inputs:
    with builtins;
    utils.apply-systems { inherit inputs; }
      ({ make-shell, pkgs, ps-tools, purs-nix, ... }:
         let
           l = p.lib; p = pkgs;
           npmlock2nix = import inputs.npmlock2nix { inherit pkgs; };
           our-node = p.nodejs-14_x;
           inherit (import ./purs.nix { inherit npmlock2nix our-node p; } purs-nix)
             package
             ps;
         in
         rec
         { packages.default = package;

           devShell =
             make-shell
               { packages =
                   with p;
                   [ esbuild
                     nodePackages.bower
                     nodePackages.purescript-language-server
                     our-node
                     ps-tools.pulp-15

                     # for npm test
                     ps-tools.purescript-0_13_8

                     (ps.command
                        { bundle =
                            { main = false;
                              module = "MarkdownIt";
                            };
                        }
                     )
                   ];
               };
         }
      );
}
