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
      npmlock2nix.node_modules { src = ./.; } + /node_modules;
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
