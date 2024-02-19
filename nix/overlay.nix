{ inputs, versions }:

final: prev:

let
  fennelVersions = [
    "stable"
    "unstable"
  ];

  luaVersions = [
    "luajit"
    "lua5_1"
    "lua5_2"
    "lua5_3"
    "lua5_4"
  ];

  fennelLuaVersionMatrix = prev.lib.cartesianProductOfSets {
    fennelVersion = fennelVersions;
    luaVersion = luaVersions;
  };

  buildFennel = { fennelVersion, luaVersion }:
    final.callPackage ./pkgs/fennel {
      version = versions."fennel-${fennelVersion}";
      src = inputs."fennel-${fennelVersion}";
      lua = final.${luaVersion};
    };

  buildFaith = { fennelVersion, luaVersion }:
    final.callPackage ./pkgs/faith {
      version = versions.faith;
      src = inputs.faith;
      fennel = final."fennel-${fennelVersion}-${luaVersion}";
    };

  buildPackageSet = { pname, builder }:
    builtins.listToAttrs
      (map
        ({ fennelVersion, luaVersion } @ args:
          {
            name = "${pname}-${fennelVersion}-${luaVersion}";
            value = builder args;
          })
        fennelLuaVersionMatrix);
in

(buildPackageSet {
  pname = "fennel";
  builder = buildFennel;
}) // (buildPackageSet {
  pname = "faith";
  builder = buildFaith;
}) // {
  fnlfmt = final.callPackage ./pkgs/fnlfmt {
    version = versions.fnlfmt;
    src = inputs.fnlfmt;
    lua = final.luajit;
  };
  fenneldoc = final.callPackage ./pkgs/fenneldoc {
    version = versions.fenneldoc;
    src = inputs.fenneldoc;
    lua = final.lua5_4;
  };
}
