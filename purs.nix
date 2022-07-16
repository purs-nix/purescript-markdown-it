with builtins;
{ npmlock2nix, our-node, p }:
{ build, ps-pkgs, purs, ... }:
  let
    l = p.lib;

    dependencies =
      with ps-pkgs;
      [ effect
        prelude
        options
      ];

    foreign.MarkdownIt.node_modules =
      npmlock2nix.node_modules
        { src =
            let
              new-pj =
                l.pipe (l.importJSON ./package.json)
                  [ (pj: pj // { scripts = {}; devDependencies = {}; })
                    toJSON
                    (toFile "package.json")
                  ];
            in
            p.runCommand "patched-package.json" {}
              ''
              mkdir $out; cd $out

              # ln breaks when using --impure
              cp ${new-pj} package.json
              cp ${./package-lock.json} package-lock.json
              '';
        }
      + /node_modules;
  in
  { package =
      build
        { name = "markdown-it";
          src.path = ./.;

          info =
            { inherit dependencies foreign;
              version = "0.4.0";
            };
        };

    ps =
      purs
        { inherit dependencies foreign;
          srcs = [ ./src ];
          nodejs = our-node;
        };
  }
